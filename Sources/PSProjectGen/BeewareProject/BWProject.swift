import Foundation
import AppKit
import PathKit
import XcodeGenKit
import ProjectSpec
import Yams
//import RecipeBuilder
import Zip
import XCAssetsProcessor
import TOMLKit
import SwiftCPUDetect
import PSBackend

import PySwiftKit
import PyComparable
import PySerializing

let arch_info = CpuArchitecture.current() ?? .intel64

public class BWProject: PSProjectProtocol {
	public var name: String
	
	public var py_src: Path
	
	var _targets: [PSProjTargetProtocol] = []
	
	var requirements: Path?
    
    var icon: Path?
	
	var local_py_src: Bool
	
	public var projectSpec: Path?
	
	let workingDir: Path
	//let resourcesPath: Path
	//let pythonLibPath: Path
	//var projectSpecData: SpecData?
	let app_path: Path
    let psp_bundle: Bundle
    
    //let platforms: [any ContextProtocol]
    
    let platforms: [(XcodeTarget_Type, Array<any ContextProtocol>.SubSequence)]
    
    let single_target: Bool
    
    //var target_types: [ProjectTarget]
    
    //var pips: [String]
    
    var toml: PyProjectToml
    var toml_table: TOMLTable = .init([:])
    
    var uv: Path
    
    //var pyProjectToml: PyProjectToml?
    
    var forced: Bool = false
    
    var backends: [PSBackend] = []
	
    public init(
        name: String,
        py_src: Path?,
        requirements: Path?,
        icon: Path?,
        //projectSpec: Path?,
        workingDir: Path,
        app_path: Path,
        platforms: [any ContextProtocol],
        pips: [String],
        uv: Path
    ) async throws {
		self.name = name
        //self.platforms = platforms
        self.platforms = platforms.asChuckedTarget()
        self.uv = uv
        self.toml = try TOMLDecoder().decode(PyProjectToml.self, from: try uv.read())
        
        //single_target = !platforms.contains(.macos)
        single_target = false
//        self.target_types = platforms.map({ plat in
//            switch plat {
//            case .ios: .iOS
//            case .macos: .macOS
//            }
//        })
        
        //target_types = ios_only ? [.iOS] : [.iOS, .macOS]
        self.workingDir = workingDir
        //let resources = workingDir + "\(single_target ? "" : "iOS/")Resources"
        self.icon = icon
		//self.resourcesPath = resources
		//self.pythonLibPath = resources + "lib"
		self.app_path = app_path
        //self.ios_only = ios_only
		self.local_py_src = py_src == nil
		self.py_src = py_src ?? "py_src"
		self.requirements = requirements
		//self.projectSpec = projectSpec
		//self.projectSpecData = try projectSpec?.specData()
        //self.pips = pips
        
        
		_targets = []
        
        print(app_path)
        psp_bundle = Bundle(path: (app_path + "PythonSwiftProject_PSProjectGen.bundle").string )!
        
//        _targets = try await platforms.asyncMap { plat in
//            let base_target = try await BWProjectTarget(
//                name: name,
//                py_src: self.py_src,
//                //dist_lib: (try await Path.distLib(workingDir: workingDir)).string,
//                //projectSpec: projectSpecData,
//                workingDir: workingDir,
//                app_path: app_path,
//                sdk: .iphoneos,
//                single: !platforms.contains(.macos)
//            )
//            base_target.project = self
//            return base_target
//        }

	}
    
    public init(
        name: String?,
        uv: Path,
        _workingDir: Path,
        app_path: Path,
        psp_bundle: Bundle,
        forced: Bool
    ) async throws {
        self.uv = uv
        self.app_path = app_path
        self.psp_bundle = psp_bundle
        self.forced = forced
        let toml_path = (uv.absolute() + "pyproject.toml")
        let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
        self.toml = toml
        
        toml_table = try .init(string: toml_path.read(.utf8))
        
        print(uv.absolute())
        //let pyproject = try TOMLDecoder().decode(PyProjectToml.self, from: try (uv.absolute() + "pyproject.toml").read())
        //self.pyProjectToml = pyproject
        let pyswift_project = toml.pyswift.project
        let projName = name ?? pyswift_project?.name ?? "MyApp"
        let workingDir = _workingDir + ( toml.pyswift.project?.folder_name ?? projName)
        self.workingDir = workingDir
        self.name = projName
        
        single_target = true
        local_py_src = false
        py_src = if uv.isRelative, let name = toml.project?.name {
            .init("$(dirname $PROJECT_DIR)/\(uv.lastComponent)/src/\(name)")
        } else {
            workingDir + "app"
        }
        //pips = []
        
        if forced, workingDir.exists {
            try? workingDir.delete()
        }
        try? workingDir.mkdir()
        
        let platforms: [any ContextProtocol] = try {
            var plats: [any ContextProtocol] = []
            for p in pyswift_project?.platforms ?? [] {
                switch p {
                case .iphoneos:
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
                    switch arch_info {
                    case .intel64:
                        plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                    case .arm64:
                        plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                    default: break
                    }
                case .macos:
                    break
                }
            }
            
            return plats
        }()
        
        let chucked_platforms = platforms.asChuckedTarget()
        self.platforms = chucked_platforms
        
        _targets = []
        
        backends = try await pyswift_project?.loaded_backends() ?? []
        
        _targets = try await chucked_platforms.asyncMap({ (target, plats) in
            switch target {
            case .iphoneos:
                try await BWProjectTarget(
                    name: projName,
                    py_src: py_src,
                    toml: toml,
                    toml_table: toml_table,
                    target_type: target,
                    contexts: .init(plats),
                    workingDir: workingDir + "IphoneOS",
                    app_path: app_path
                )
            case .macos:
                try await BWProjectTarget(
                    name: projName,
                    py_src: py_src,
                    toml: toml,
                    toml_table: toml_table,
                    target_type: target,
                    contexts: .init(plats),
                    workingDir: workingDir + "MacOS",
                    app_path: app_path
                )
            }
        })
    }
    
    
	public func targets() async throws -> [Target] {
		var output: [Target] = []
		for target in _targets {
			output.append( try! await target.target() )
		}
		return output
	}
    
	var site_folders: [Path] {
		
		var output: [Path] = [ ]
//		let numpySite = resourcesPath + "numpy-site"
//		if numpySite.exists {
//			output.append(numpySite)
//		}
		
		return output
	}
	
	public func configs() async throws -> [ProjectSpec.Config] {
		[.init(name: "Debug", type: .debug),.init(name: "Release", type: .release)]
	}
	
	public func schemes() async throws -> [ProjectSpec.Scheme] {
        return []
//        return try platforms.map { platform in
//            switch platform {
//            case .ios:
//                    try .init(name: "iOS", build: .init(targets: [.init(target: .init("iOS"))]) , archive: .init(customArchiveName: name))
//            case .macos:
//                    try .init(name: "macOS", build: .init(targets: [.init(target: .init("macOS"))]), archive: .init(customArchiveName: name))
//            }
//        }
	}
	
	public func projSettings() async throws -> ProjectSpec.Settings {
		.empty
	}
	
	public func settingsGroup() async throws -> [String : ProjectSpec.Settings] {
		[:]
	}
	
	public func packages() async throws -> [String : ProjectSpec.SwiftPackage] {
//		var releases = try await GithubAPI(owner: "kv-swift", repo: "KivyCore")
//      
//		try! await releases.handleReleases()
//		guard let latest = releases.releases.first else { throw CocoaError(.coderReadCorrupt) }
		let local = false
        var output: [String : ProjectSpec.SwiftPackage] = if local {
            [
                "PythonCore": .local(path: "/Volumes/CodeSSD/GitHub/PythonCore", group: nil, excludeFromProject: false),
                "PySwiftKit": .local(path: "/Volumes/CodeSSD/PythonSwiftGithub/PySwiftKit", group: nil, excludeFromProject: false),
            ]
        } else {
            [
                "PythonCore": .remote(
                    url: "https://github.com/py-swift/PythonCore",
                    versionRequirement: .upToNextMajorVersion("311.11.0")
                ),
                "PySwiftKit": .remote(
                    url: "https://github.com/py-swift/PySwiftKit",
                    versionRequirement: .upToNextMajorVersion("311.0.0")
                ),
                //"KivyLauncher": .local(path: "", group: "Frameworks", excludeFromProject: false)
//                "KivyLauncher": .remote(
//                    url: "https://github.com/kv-swift/KivyLauncher",
//                    versionRequirement: .branch("master")
//                ),
            ]
        }
        
            
            for backend in backends {
                for (k, v) in try backend.packages() {
                    output[k] = v
                }
            }
            
//            if let backends = project.backends {
//                for backend in backends {
//                    switch backend.lowercased() {
//                    case "kivylauncher":
//                        if local {
//                            output["KivyLauncher"] =  .local(path: "/Volumes/CodeSSD/beeware_env/swift_packages/KivyLauncher", group: nil, excludeFromProject: false)
//                        } else {
//                            output["KivyLauncher"] =  .local(path: "/Volumes/CodeSSD/beeware_env/swift_packages/KivyLauncher", group: nil, excludeFromProject: false)
//                        }
//                    case "a4k_pyswift":
//                        output["a4k_pyswift"] = .remote(url: "", versionRequirement: .upToNextMajorVersion("0.0.0"))
//                    default: break
//                    }
//                }
//                
//            }
        
		
		return output
	}
	
	public func specOptions() async throws -> ProjectSpec.SpecOptions {
		return .init(bundleIdPrefix: "org.pyswift")
	}
	
	public func fileGroups() async throws -> [String] {
		[]
	}
	public func configFiles() async throws -> [String : String] {
		[:]
	}
	public func attributes() async throws -> [String : Any] {
		[:]
	}
	
	public func projectReferences() async throws -> [ProjectSpec.ProjectReference] {
		[]
	}
	
	public func projectBasePath() async throws -> PathKit.Path {
//		let base: Path = workingDir + "\(name).xcodeproj"
//		if !base.exists {
//			try! base.mkpath()
//		}
		return workingDir
	}
	
    fileprivate func installBackends() async throws {
        let support = workingDir + "Support"
        
        try Validation.support()
        try await Validation.supportPythonFramework()
        
        for backend in backends {
            try await backend.do_install(support: .init(value: support))
        }

    }
    
    
    
    
    private func createRootFolders() async throws {
        let projDir = workingDir
        
        
        //try? (current + "wrapper_sources").mkdir()
        try? (workingDir + "app").mkpath()
        let support = workingDir + "Support"
        try? support.mkpath()
        
        let dylib_plist = support + "dylib-Info-template.plist"
        try dylib_plist.write(stdlib_plist(), encoding: .utf8)
        
        for (target, plats) in platforms {
            switch target {
            case .iphoneos:
                if let first = plats.first {
                    try await first.createTargetFolder(forced: true)
                    try await first.createResourcesFolder(forced: true)
                    try await first.createSourcesFolder(forced: true)
                }
                for platform in plats {
                    try await platform.createSiteFolder(forced: true)
                }
            case .macos:
                break
            }
        }
        
    }
    
    private func getKivyAppFiles() async throws -> Path {
        let kivyAppFiles: Path = .ps_support + "KivyAppFiles"
        if !kivyAppFiles.exists {
            //try! kivyAppFiles.delete()
            Path.ps_support.chdir {
                gitClone("https://github.com/py-swift/KivyAppFiles")
            }
        }
        
        return kivyAppFiles
        
    }
    
    private func generateIconAsset(resourcesPath: Path, appFiles: Path) async throws {
        let png: Path = appFiles + "icon.png"
        let dest: Path = resourcesPath + "Images.xcassets"
        
        let appiconset = dest + "AppIcon.appiconset"
        try? appiconset.mkpath()
        let iconsData = [IconDataItem].allIcons
        let assetData = iconsData.filter({$0.idiom != .mac})
            //iconsData.filter({$0.idiom == .mac})
        
        let sizes: [CGFloat] = assetData.compactMap { Double($0.expected_size)! }
        try XCAssetsProcessor(source: png).process(dest: appiconset, sizes: sizes)
        
        
        try JSONEncoder().encode(ContentsJson(images: assetData)).write(to: (appiconset + "Contents.json").url)
    }
    
    private func copyAppFiles_iOS() async throws {
        let appFiles = try await getKivyAppFiles()
        
        
        for (target, plats) in platforms {
            let targ_path = target.targetPath(workingDir)
            
            if let resourcesPath = plats.first?.getResourcesFolder() {
                switch target {
                case .iphoneos:
                    try? (appFiles + "Launch Screen.storyboard").copy(resourcesPath + "Launch Screen.storyboard")
                    
                    try await generateIconAsset(resourcesPath: resourcesPath, appFiles: appFiles)
                    
                case .macos:
                    break
                }
            }
        }
    }
    
    private func handleSwiftFiles() async throws {
        for (target, plats) in platforms {
            
            if let sourcesPath = plats.first?.getSourcesFolder() {
                switch target {
                case .iphoneos:
//                    let imps = try await backends.asyncMap { imp in
//                        try await imp.wrapper_imports(target_type: .iphoneos)
//                    }.flatMap(\.self)
                    let mainFile = try temp_main_file(
                        backends: backends
                    )
                    try (sourcesPath + "main.swift").write(mainFile)
                case .macos:
                    break
                }
            }
        }
    }
    
    private func copyPythonLibs() async throws {
        for (target, platforms) in platforms {
            switch target {
            case .iphoneos:
                let support = workingDir + "Support"
                let python_fw = Path.ps_support + "Python.xcframework"
                let lib_arm64 = python_fw + "ios-arm64"
                let lib_sim = python_fw + "ios-arm64_x86_64-simulator"
                for lib in [ lib_arm64, lib_sim ] {
                    print(lib)
                    try lib.copy(support + lib.lastComponent)
                }
            case .macos:
                break
            }
        }
    }
    
    private func pipInstallRequirements() async throws {
        let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
        let req_file = workingDir + "requirements.txt"
        try req_file.write(req_string)
        for (_, plats) in platforms {
            for platform in plats {
                try await platform.pipInstall(requirements: req_file)
            }
        }
    }
	
    private static func generateReqFromUV(toml: PyProjectToml, uv: Path) async throws -> String {
        var req_String = UVTool.export_requirements(uv_root: uv, group: "iphoneos")
        
        let ios_pips = (toml.pyswift.project?.dependencies?.pips ?? []).joined(separator: "\n")
        req_String = "\(req_String)\n\(ios_pips)"
        
        print(req_String)
        return req_String
    }
    
	private func postStructure() async throws {
		let current = workingDir
        
        let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
        let req_file = workingDir + "requirements.txt"
        try req_file.write(req_string)
        for (target, plats) in platforms {
            for platform in plats {
                try await platform.pipInstall(requirements: req_file)
            }
        }
//        if let uv, let pyProjectToml {
//            let req = try! await Self.generateReqFromUV(toml: pyProjectToml, uv: uv)
//            fatalError("rest of uv is not done yet")
//        } else if let requirements = requirements {
//			
//            for target_type in target_types {
//                print("pip installing requirements: \(requirements)")
//                switch target_type {
//                case .iOS:
//                    
//                    var sites = [String]()
//                    
//                    
//                    let site = workingDir + "site_packages.iphoneos"
//                    pipInstall_ios(requirements, site_path: site)
//                case .macOS: break
//                }
//            }
//		}
//        
//        for target_type in target_types {
//            switch target_type {
//            case .iOS:
//                let site = target_type.site_packages(current: workingDir, ios_only: single_target)
//                for pip in projectSpecData?.pips ?? pips {
//                    pipInstall_ios(pip: pip, site_path: site)
//                }
//            case .macOS:
//                let site = target_type.site_packages(current: workingDir, ios_only: single_target)
//                for pip in projectSpecData?.pips ?? pips {
//                    pipInstall(pip: pip, site_path: site)
//                }
//            }
//        }
        
      
       
        
        //let workingDir = ios_only ? workingDir : workingDir + "iOS"
        //let resourcesPath = workingDir + "Resources"
//        try? workingDir.mkpath()
//        try? resourcesPath.mkdir()
        
//        let kivyAppFiles: Path = workingDir + "KivyAppFiles"
//        if kivyAppFiles.exists {
//            try! kivyAppFiles.delete()
//        }
//        
//        
//        workingDir.chdir {
//            gitClone("https://github.com/py-swift/KivyAppFiles")
//        }
//        print(kivyAppFiles)
//        let sourcesPath = workingDir + "Sources"
//		if sourcesPath.exists {
//			try! sourcesPath.delete()
//		}
//		try! (kivyAppFiles + "Sources").move(sourcesPath)
//		
//        for platform in platforms {
//            
//        }
        
        //if !single_target {
//            for target_type in target_types {
//                let sources = target_type.sources(current: workingDir, ios_only: false)
//                try! sourcesPath.copy(sources)
//                try? (sources + "Main.swift").delete()
//                try (sources + "main.swift").write(temp_main_file(), encoding: .utf8)
////                if target_type == .macOS {
////                    try? (sources + "Main.swift").delete()
////                    
////                    try (sources + "main.swift").write(macOS_MainFile(), encoding: .utf8)
////                    let resources = target_type.resources(current: workingDir, ios_only: single_target)
////                    
////                    let stdlib_dest = target_type.resources(current: workingDir, ios_only: single_target)
////                    
////                    let lib_folder = target_type.resources(current: workingDir, ios_only: single_target) + "lib"
////                    try lib_folder.mkdir()
////                    let stdlib_final = lib_folder + "python3.11"
////                    try (stdlib_dest + "python-stdlib").move(stdlib_final)
////                }
//            //}
//        }

		
		//try? (kivyAppFiles + "dylib-Info-template.plist").move(resourcesPath + "dylib-Info-template.plist")
        //for target_type in target_types {
//        for platform in platforms {
//            let resourcesPath = target_type.resources(current: workingDir, ios_only: single_target)
//            if !resourcesPath.exists {
//                try resourcesPath.mkdir()
//            }
////            if let spec = projectSpecData {
////                
////                if let icon = spec.icon {
////                    try? icon.copy(resourcesPath + "icon.png")
////                } else {
////                    try? (kivyAppFiles + "icon.png").copy(resourcesPath + "icon.png")
////                }
////                fatalError()
////                if let imageset = spec.imageset {
////                    try? imageset.copy(resourcesPath + "Images.xcassets")
////                } else {
////                    //try? (kivyAppFiles + "Images.xcassets").copy(resourcesPath + "Images.xcassets")
////                    
////                    let png: Path = resourcesPath + "icon.png"
////                    let dest: Path = resourcesPath + "Images.xcassets"
////
////                    let appiconset = dest + "AppIcon.appiconset"
////
////                    try? appiconset.mkpath()
////                    let iconsData = [IconDataItem].allIcons
////                    let assetData = switch target_type {
////                    case .iOS:
////                        iconsData.filter({$0.idiom != .mac})
////                    case .macOS:
////                        iconsData.filter({$0.idiom == .mac})
////                    }
////                    let sizes: [CGFloat] = assetData.compactMap { Double($0.expected_size)! }
////                    try XCAssetsProcessor(source: png).process(dest: appiconset, sizes: sizes)
////
////
////                    try JSONEncoder().encode(ContentsJson(images: assetData)).write(to: (appiconset + "Contents.json").url)
////                }
////                
////                if target_type == .iOS {
////                    if let launch_screen = spec.launch_screen {
////                        try launch_screen.copy(resourcesPath + "Launch Screen.storyboard")
////                    } else {
////                        try? (kivyAppFiles + "Launch Screen.storyboard").copy(resourcesPath + "Launch Screen.storyboard")
////                    }
////                }
////                
////            } else {
//                if target_type == .iOS {
//                    try? (kivyAppFiles + "Launch Screen.storyboard").copy(resourcesPath + "Launch Screen.storyboard")
//                }
//                //try? (kivyAppFiles + "Images.xcassets").copy(resourcesPath + "Images.xcassets")
//                if let icon {
//                    try? icon.copy(resourcesPath + "icon.png")
//                } else {
//                    try? (kivyAppFiles + "icon.png").copy(resourcesPath + "icon.png")
//                }
//                
//                let png: Path = resourcesPath + "icon.png"
//                let dest: Path = resourcesPath + "Images.xcassets"
//
//                let appiconset = dest + "AppIcon.appiconset"
//
//                try? appiconset.mkpath()
//                let iconsData = [IconDataItem].allIcons
//                let assetData = switch target_type {
//                case .iOS:
//                    iconsData.filter({$0.idiom != .mac})
//                case .macOS:
//                    iconsData.filter({$0.idiom == .mac})
//                }
//                let sizes: [CGFloat] = assetData.compactMap { Double($0.expected_size)! }
//                try XCAssetsProcessor(source: png).process(dest: appiconset, sizes: sizes)
//
//
//                try JSONEncoder().encode(ContentsJson(images: assetData)).write(to: (appiconset + "Contents.json").url)
//            }
//        }
        
		
		
		if local_py_src {
			try? (current + "py_src").mkdir()
		} else {
			try? (current + "py_src").symlink(py_src)
		}
		
//		if kivyAppFiles.exists {
//			try! kivyAppFiles.delete()
//		}
		for target in _targets {
			try! await target.build()
		}
        
 
        
        //if kivyAppFiles.exists { try kivyAppFiles.delete() }
        //if sourcesPath.exists { try sourcesPath.delete() }
	}
	
    public func createStructure() async throws {
        
        try await createRootFolders()
        
        try await installBackends()
        
        try await copyPythonLibs()
        
        try await copyAppFiles_iOS()
        
        try await handleSwiftFiles()
        
        
        try await pipInstallRequirements()
        
        //try await postStructure()
    }
    
	public func project() async throws -> ProjectSpec.Project {
		return Project(
			basePath: workingDir,
			name: name,
			configs: try! await configs(),
			targets: try! await targets(),
			aggregateTargets: [],
			settings: try! await projSettings(),
			settingGroups: try! await settingsGroup(),
			schemes: try! await schemes(),
			breakpoints: [],
			packages: try! await packages(),
			options: try! await specOptions(),
			fileGroups: try! await fileGroups(),
			configFiles: try! await configFiles(),
			attributes: try! await attributes(),
			projectReferences: []
		)
	}
	
	public func generate() async throws {
		let project = try! await project()
		let fw = FileWriter(project: project)
		let projectGenerator = ProjectGenerator(project: project)
        
		guard let userName = ProcessInfo.processInfo.environment["LOGNAME"] else {
			throw KivyCreateError.missingUsername
		}
		
		let xcodeProject = try! projectGenerator.generateXcodeProject(in: workingDir, userName: userName)
        
        //xcodeProject.pbxproj.nativeTargets.first?
        //xcodeProject.pbxproj.targets(named: "macOS").first?.productName = name
        //xcodeProject.pbxproj.buildConfigurations.first!.buildSettings
		try! fw.writePlists()
		//
		
		try! fw.writeXcodeProject(xcodeProject)
//        try! await NSWorkspace.shared.open([project.defaultProjectPath.url], withApplicationAt: .applicationDirectory.appendingPathComponent("Xcode.app"), configuration: .init())
		//NSWorkspace.shared.openFile(project.defaultProjectPath.string, withApplication: "Xcode")
	}
}

func temp_main_file(backends: [PSBackend]) throws -> String {
    let imports = try backends.flatMap { backend in
        try backend.wrapper_imports(target_type: .iphoneos).flatMap { imp in
            imp.libraries.map(\.description)
        }
    }
    let modules = try backends.flatMap { backend in
        try backend.wrapper_imports(target_type: .iphoneos).flatMap { imp in
            imp.modules.map(\.description)
        }
    }
    let pre_lines = try backends.compactMap { backend in
        try backend.pre_main_swift(libraries: imports, modules: modules)
    }
    let post_lines = try backends.compactMap { backend in
        try backend.main_swift(libraries: imports, modules: modules)
    }
    //let imports = wrapper_importers.flatMap({$0.libraries.map(\.description)})
    //let modules = wrapper_importers.flatMap({$0.modules.map(\.description)})
    return """
    import Foundation
    import PySwiftObject
    \(imports.joined(separator: "\n"))

    \(pre_lines.joined(separator: "\n"))
    
    \(post_lines.joined(separator: "\n"))
    """
}



