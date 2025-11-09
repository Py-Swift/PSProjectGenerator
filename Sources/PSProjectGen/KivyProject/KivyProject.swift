//
//  File.swift
//  
//
//  Created by CodeBuilder on 08/10/2023.
//

import Foundation
import AppKit
@preconcurrency import PathKit
import XcodeGenKit
import ProjectSpec
import Yams
//import RecipeBuilder
import Zip
import XCAssetsProcessor

enum KivyCreateError: Error, CustomStringConvertible {
	case missingProjectSpec(Path)
	case projectSpecParsingError(Error)
	case cacheGenerationError(Error)
	case validationError(SpecValidationError)
	case generationError(Error)
	case missingUsername
	case writingError(Error)
	
	var description: String {
		switch self {
		case let .missingProjectSpec(path):
			return "No project spec found at \(path.absolute())"
		case let .projectSpecParsingError(error):
			return "Parsing project spec failed: \(error)"
		case let .cacheGenerationError(error):
			return "Couldn't generate cache file: \(error)"
		case let .validationError(error):
			return error.description
		case let .generationError(error):
			return String(describing: error)
		case .missingUsername:
			return "Couldn't find current username"
		case let .writingError(error):
			return String(describing: error)
		}
	}
	
	var message: String? {
		description
	}
	
	var exitStatus: Int32 {
		1
	}
}





//@resultBuilder
//struct packageBuilder {
//	static func buildBlock(_ components: Component...) -> Component {
//
//	}
//	
//}

public typealias ProjectSpecDictionary = [String:Any] //[ String: [[String: Any]] ]


public enum ProjectTarget: CustomStringConvertible {
    case iOS
    case macOS
    
    public var description: String {
        switch self {
        case .iOS:
            "iOS"
        case .macOS:
            "macOS"
        }
    }
    
    public func root(current: Path, ios_only: Bool) -> Path {
        if ios_only {
            current
        } else {
            switch self {
            case .iOS:
                current + "iOS"
            case .macOS:
                current + "macOS"
            }
        }
    }
    
    public func sources(current: Path, ios_only: Bool) -> Path {
        root(current: current, ios_only: ios_only) + "Sources"
    }
    
    public func resources(current: Path, ios_only: Bool) -> Path {
        root(current: current, ios_only: ios_only) + "Resources"
    }
    
    public func site_packages(current: Path, ios_only: Bool) -> Path {
        resources(current: current, ios_only: ios_only) + "site-packages"
    }
}

//public class KivyProject: PSProjectProtocol {
//	public var name: String
//	
//	public var py_src: Path
//	
//	var _targets: [PSProjTargetProtocol] = []
//	
//	var requirements: Path?
//    
//    var icon: Path?
//	
//	var local_py_src: Bool
//	
//	public var projectSpec: Path?
//	
//	let workingDir: Path
//	//let resourcesPath: Path
//	let pythonLibPath: Path
//	var projectSpecData: SpecData?
//	let app_path: Path
//    let psp_bundle: Bundle
//    
//    let legacy: Bool
//    
//    let platforms: [Platform]
//    
//    let ios_only: Bool
//    
//    var target_types: [ProjectTarget]
//    
//    var pips: [String]
//	
//    public init(
//        name: String,
//        py_src: Path?,
//        requirements: Path?,
//        icon: Path?,
//        projectSpec: Path?,
//        workingDir: Path,
//        app_path: Path,
//        legacy: Bool,
//        platforms: [Platform],
//        pips: [String]
//    ) async throws {
//		self.name = name
//        self.platforms = platforms
//        ios_only = !platforms.contains(.macos)
//        self.target_types = platforms.map({ plat in
//            switch plat {
//            case .ios: .iOS
//            case .macos: .macOS
//            }
//        })
//        
//        //target_types = ios_only ? [.iOS] : [.iOS, .macOS]
//		self.workingDir = workingDir
//        let resources = workingDir + "\(ios_only ? "" : "iOS/")Resources"
//        self.icon = icon
//		//self.resourcesPath = resources
//		self.pythonLibPath = resources + "lib"
//		self.app_path = app_path
//        self.legacy = legacy
//        //self.ios_only = ios_only
//		self.local_py_src = py_src == nil
//		self.py_src = py_src ?? "py_src"
//		self.requirements = requirements
//		self.projectSpec = projectSpec
//		self.projectSpecData = try projectSpec?.specData()
//        self.pips = pips
//        
//        
//		_targets = []
//        
//        print(app_path)
//        psp_bundle = Bundle(path: (app_path + "PythonSwiftProject_PSProjectGen.bundle").string )!
//        
//        _targets = try await platforms.asyncMap { plat in
//            switch plat {
//            case .ios:
//                let base_target = try await KivyProjectTarget(
//                    name: name,
//                    py_src: self.py_src,
//                    //dist_lib: (try await Path.distLib(workingDir: workingDir)).string,
//                    dist_lib: (workingDir + "dist_lib"),
//                    projectSpec: projectSpecData,
//                    workingDir: workingDir,
//                    app_path: app_path,
//                    legacy: legacy,
//                    ios_only: !platforms.contains(.macos)
//                )
//                base_target.project = self
//                return base_target
//            case .macos:
//                let macos_target = try await KivyProjectTargetMacOS(
//                    name: name,
//                    py_src: self.py_src,
//                    //dist_lib: (try await Path.distLib(workingDir: workingDir)).string,
//                    dist_lib: (workingDir + "dist_lib"),
//                    projectSpec: projectSpecData,
//                    workingDir: workingDir,
//                    app_path: app_path,
//                    legacy: legacy,
//                    macos_only: !platforms.contains(.ios)
//                )
//                macos_target.project = self
//                return macos_target
//            }
//        }
//
//	}
//    
//    
//	public func targets() async throws -> [Target] {
//		var output: [Target] = []
//		for target in _targets {
//			output.append( try! await target.target() )
//		}
//		return output
//	}
//    
//	public var distFolder: Path { workingDir + "dist_lib"}
//	
//    var distIphoneos: Path { distFolder + "iphoneos"}
//	
//    var distSimulator: Path { distFolder + "iphonesimulator"}
//	//var mainSiteFolder: Path { resourcesPath + "site-packages" }
//	var site_folders: [Path] {
//		
//		var output: [Path] = [ ]
////		let numpySite = resourcesPath + "numpy-site"
////		if numpySite.exists {
////			output.append(numpySite)
////		}
//		
//		return output
//	}
//	
//	public func configs() async throws -> [ProjectSpec.Config] {
//		[.init(name: "Debug", type: .debug),.init(name: "Release", type: .release)]
//	}
//	
//	public func schemes() async throws -> [ProjectSpec.Scheme] {
//        return []
//        return try platforms.map { platform in
//            switch platform {
//            case .ios:
//                    try .init(name: "iOS", build: .init(targets: [.init(target: .init("iOS"))]) , archive: .init(customArchiveName: name))
//            case .macos:
//                    try .init(name: "macOS", build: .init(targets: [.init(target: .init("macOS"))]), archive: .init(customArchiveName: name))
//            }
//        }
//	}
//	
//	public func projSettings() async throws -> ProjectSpec.Settings {
//		.empty
//	}
//	
//	public func settingsGroup() async throws -> [String : ProjectSpec.Settings] {
//		[:]
//	}
//	
//	public func packages() async throws -> [String : ProjectSpec.SwiftPackage] {
//		var releases = try await GithubAPI(owner: "kv-swift", repo: "KivyCore")
//      
//		try! await releases.handleReleases()
//		guard let latest = releases.releases.first else { throw CocoaError(.coderReadCorrupt) }
//		let local = false
//        var output: [String : ProjectSpec.SwiftPackage] = if local {
//            [
//                "PythonCore": .local(path: "/Volumes/CodeSSD/PythonSwiftGithub/PythonCore", group: nil, excludeFromProject: false),
//                "PySwiftKit": .local(path: "/Volumes/CodeSSD/PythonSwiftGithub/PySwiftKit", group: nil, excludeFromProject: false),
//                "KivyLauncher": .local(path: "/Volumes/CodeSSD/PythonSwiftGithub/KivyLauncher", group: nil, excludeFromProject: false),
//                
//            ]
//        } else {
//            [
//                "PythonCore": .remote(
//                    url: "https://github.com/kv-swift/PythonCore",
//                    versionRequirement: .exact(latest.tag_name)
//                ),
//                "PySwiftKit": .remote(
//                    url: "https://github.com/kv-swift/PySwiftKit",
//                    versionRequirement: .upToNextMajorVersion("311.0.0")
//                ),
//                "KivyLauncher": .remote(
//                    url: "https://github.com/kv-swift/KivyLauncher",
//                    versionRequirement: .branch("master")
//                ),
//            ]
//        }
//        if let packageSpec = projectSpecData {
//			try! loadSwiftPackages(from: packageSpec, output: &output)
//		}
//		if let recipes = projectSpecData?.toolchain_recipes  {
//			output = recipes.reduce(into: output) { partialResult, next in
//				partialResult[next] = .remote(url: "https://github.com/kv-swift/KivyExtra", versionRequirement: .exact( latest.tag_name))
//			}
//		}
//		
//		return output
//	}
//	
//	public func specOptions() async throws -> ProjectSpec.SpecOptions {
//		return .init(bundleIdPrefix: "org.kivy")
//	}
//	
//	public func fileGroups() async throws -> [String] {
//		[]
//	}
//	public func configFiles() async throws -> [String : String] {
//		[:]
//	}
//	public func attributes() async throws -> [String : Any] {
//		[:]
//	}
//	
//	public func projectReferences() async throws -> [ProjectSpec.ProjectReference] {
//		[]
//	}
//	
//	public func projectBasePath() async throws -> PathKit.Path {
////		let base: Path = workingDir + "\(name).xcodeproj"
////		if !base.exists {
////			try! base.mkpath()
////		}
//		return workingDir
//	}
//	
//	public func createStructure() async throws {
//       
//		//try? (current + "wrapper_sources").mkdir()
//       
//        
//        for target_type in target_types {
//            try? ( target_type.resources(current: workingDir, ios_only: ios_only) + "YourApp").mkpath()
//            switch target_type {
//            case .iOS:
//                
//                if legacy {
//                    try? distIphoneos.mkpath()
//                    try? distSimulator.mkpath()
//                }
//                let kivy_core = ReleaseAssetDownloader.KivyCore()
//                
//                
//                for asset in try await kivy_core.downloadFiles(legacy: legacy) ?? [] {
//                    
//                    //let url: URL = try await download(url: asset)
//                    
//                    if asset.lastPathComponent.contains("site") {
//                        try await unpackAsset(src: .init(asset.path()), to: target_type.resources(current: workingDir, ios_only: ios_only))
//                    }
//                    if legacy {
//                        if asset.lastPathComponent.contains("dist") {
//                            try await unpackDistAssets(src: .init(asset.path()), to: distFolder)
//                            
//                        }
//                    }
//                }
//                if let recipes = projectSpecData?.toolchain_recipes {
//                    let extra = ReleaseAssetDownloader.KivyExtra(recipes: recipes)
//                    if let assets = try await extra.downloadFiles(legacy: legacy) {
//                        for asset in assets {
//                            
//                            
//                            let name = asset.lastPathComponent
//                            
//                            if name.contains("site") {
//                                try await unpackAsset(src: .init(asset.path()), to: target_type.site_packages(current: workingDir, ios_only: ios_only))
//                            }
//                            
//                            if legacy {
//                                if name.contains("dist") {
//                                    try await unpackAsset(src: .init(asset.path()), to: distFolder)
//                                }
//                            }
//                            
//                        }
//                    }
//                }
//            case .macOS:
//                let python = ReleaseAssetDownloader.PythonCore()
//                if let assets = try await python.downloadFiles(legacy: legacy), let stdlib = assets.first {
//                    let stdlib_dest = target_type.resources(current: workingDir, ios_only: ios_only)
//                    try await unpackAsset(src: .init(stdlib.path()), to: stdlib_dest)
//                    
//                }
//            }
//        }
//        
//        
//        
//		try await postStructure()
//	}
//	
//	private func postStructure() async throws {
//		
//		let current = workingDir
//		
//		if let requirements = requirements {
//			let reqPath: Path
//			reqPath = requirements
//			
//			print("pip installing: \(reqPath)")
//			
//            for target_type in target_types {
//                switch target_type {
//                case .iOS:
//                    let site = target_type.site_packages(current: workingDir, ios_only: ios_only)
//                    pipInstall(reqPath, site_path: site)
//                case .macOS:
//                    let site = target_type.site_packages(current: workingDir, ios_only: ios_only)
//                    pipInstall(reqPath, site_path: site)
//                }
//            }
//		}
//        
//        for target_type in target_types {
//            switch target_type {
//            case .iOS:
//                let site = target_type.site_packages(current: workingDir, ios_only: ios_only)
//                for pip in projectSpecData?.pips ?? pips {
//                    pipInstall(pip: pip, site_path: site)
//                }
//            case .macOS:
//                let site = target_type.site_packages(current: workingDir, ios_only: ios_only)
//                for pip in projectSpecData?.pips ?? pips {
//                    pipInstall(pip: pip, site_path: site)
//                }
//            }
//        }
//        
//        for site_folder in site_folders {
//            if !legacy {
//                removeAll_so_libs(path: site_folder)
//            } else {
//                try patchPythonLib(pythonLib: site_folder, dist: distFolder + "iphoneos")
//            }
//        }
//        
//        if let kivy_requirements = psp_bundle.path(forResource: "kivy_requirements", withExtension: "txt") {
//            for target_type in target_types {
//                switch target_type {
//                case .iOS:
//                    pipInstall(kivy_requirements, site_path: target_type.site_packages(current: workingDir, ios_only: ios_only))
//                case .macOS:
//                    //
//                    pipInstall(pip: "https://files.pythonhosted.org/packages/f7/02/c76a94480adcb93e4da1b393a8eb392914b5812a5a5aa5bdb401c03571c7/Kivy-2.3.1-cp311-cp311-macosx_10_15_universal2.whl", site_path: target_type.site_packages(current: workingDir, ios_only: ios_only))
//                }
//            }
//        } else { fatalError("kivy_requirements.txt is missing")}
//        
//        //let workingDir = ios_only ? workingDir : workingDir + "iOS"
//        //let resourcesPath = workingDir + "Resources"
////        try? workingDir.mkpath()
////        try? resourcesPath.mkdir()
//        
//		let kivyAppFiles: Path = workingDir + "KivyAppFiles"
//		if kivyAppFiles.exists {
//			try kivyAppFiles.delete()
//		}
//        
//        
//		workingDir.chdir {
//			gitClone("https://github.com/PythonSwiftLink/KivyAppFiles")
//		}
//		
//        let sourcesPath = workingDir + "Sources"
//		if sourcesPath.exists {
//			try sourcesPath.delete()
//		}
//		try (kivyAppFiles + "Sources").move(sourcesPath)
//		
//        if !ios_only {
//            for target_type in target_types {
//                let sources = target_type.sources(current: workingDir, ios_only: ios_only)
//                try sourcesPath.copy(sources)
//                if target_type == .macOS {
//                    try? (sources + "Main.swift").delete()
//                    
//                    try (sources + "main.swift").write(macOS_MainFile(), encoding: .utf8)
//                    let resources = target_type.resources(current: workingDir, ios_only: ios_only)
//                    
//                    let stdlib_dest = target_type.resources(current: workingDir, ios_only: ios_only)
//                    
//                    let lib_folder = target_type.resources(current: workingDir, ios_only: ios_only) + "lib"
//                    try lib_folder.mkdir()
//                    let stdlib_final = lib_folder + "python3.11"
//                    try (stdlib_dest + "python-stdlib").move(stdlib_final)
//                }
//            }
//        }
//        
//        if let spec = projectSpecData {
//            for target_type in target_types {
//                try? loadRequirementsFiles(from: spec, site_path: target_type.resources(current: workingDir, ios_only: ios_only))
//                
//                var imports = [SwiftPackageData.PythonImport]()
//                //var pyswiftProducts = [String]()
//                
//                
//                if try! loadPythonPackageInfo(from: projectSpecData, imports: &imports) {
//                    
//                    let mainFile = target_type.sources(current: workingDir, ios_only: ios_only) + "Main.swift"
//                    let newMain = ModifyMainFile(source: try mainFile.read(), imports: imports)
//                    try! mainFile.write(newMain, encoding: .utf8)
//                }
//            }
//			
//		}
//		
//		//try? (kivyAppFiles + "dylib-Info-template.plist").move(resourcesPath + "dylib-Info-template.plist")
//        for target_type in target_types {
//            let resourcesPath = target_type.resources(current: workingDir, ios_only: ios_only)
//            
//            if let spec = projectSpecData {
//                
//                if let icon = spec.icon {
//                    try? icon.copy(resourcesPath + "icon.png")
//                } else {
//                    try? (kivyAppFiles + "icon.png").copy(resourcesPath + "icon.png")
//                }
//                
//                if let imageset = spec.imageset {
//                    try? imageset.copy(resourcesPath + "Images.xcassets")
//                } else {
//                    //try? (kivyAppFiles + "Images.xcassets").copy(resourcesPath + "Images.xcassets")
//                    
//                    let png: Path = resourcesPath + "icon.png"
//                    let dest: Path = resourcesPath + "Images.xcassets"
//
//                    let appiconset = dest + "AppIcon.appiconset"
//
//                    try? appiconset.mkpath()
//                    let iconsData = [IconDataItem].allIcons
//                    let assetData = switch target_type {
//                    case .iOS:
//                        iconsData.filter({$0.idiom != .mac})
//                    case .macOS:
//                        iconsData.filter({$0.idiom == .mac})
//                    }
//                    let sizes: [CGFloat] = assetData.compactMap { Double($0.expected_size)! }
//                    try XCAssetsProcessor(source: png).process(dest: appiconset, sizes: sizes)
//
//
//                    try JSONEncoder().encode(ContentsJson(images: assetData)).write(to: (appiconset + "Contents.json").url)
//                }
//                
//                if target_type == .iOS {
//                    if let launch_screen = spec.launch_screen {
//                        try launch_screen.copy(resourcesPath + "Launch Screen.storyboard")
//                    } else {
//                        try? (kivyAppFiles + "Launch Screen.storyboard").copy(resourcesPath + "Launch Screen.storyboard")
//                    }
//                }
//                
//            } else {
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
//        
//		
//		
//		if local_py_src {
//			try? (current + "py_src").mkdir()
//		} else {
//			try? (current + "py_src").symlink(py_src)
//		}
//		
//		if kivyAppFiles.exists {
//			try! kivyAppFiles.delete()
//		}
//		for target in _targets {
//			try! await target.build()
//		}
//        
//        if let packages_dump = projectSpecData?.packages_dump {
//            
//        }
//	}
//	
//	public func unpackAsset(src: Path, to: Path) async throws {
//		//var download: Path = .init( try await download(url: url ).path() )
//		let new_loc = to + src.lastComponent
//		//try download.move(new_loc)
//		//download = new_loc
//		//
//		try Zip.unzipFile(src.url, destination: to.url, overwrite: true, password: nil)
//		//temp.forEach({print($0)})
//		
//		//let extract_folder = temp + asset.extract_name
//		//try await completion(asset.asset, extract_folder)
//		//try? extract_folder.delete()
//	}
//    
//    public func unpackDistAssets(src: Path, to: Path) async throws {
//        //var download: Path = .init( try await download(url: url ).path() )
//        //let new_loc = to + src.lastComponent
//        //try download.move(new_loc)
//        //download = new_loc
//        let tmp = try Path.uniqueTemporary()
//        //
//        try Zip.unzipFile(src.url, destination: tmp.url, overwrite: true, password: nil)
//        //temp.forEach({print($0)})
//        let tmp_dist = tmp + "dist_files"
//        defer { try? tmp.delete() }
//        for folder in try tmp_dist.children() {
//            
//            let folder_name = folder.lastComponent
//            for file in try folder.children() {
//                
//                let folder_dest = to + folder_name
//                try? file.copy(folder_dest + file.lastComponent)
//            }
//                        
//        }
//        
//        //let extract_folder = temp + asset.extract_name
//        //try await completion(asset.asset, extract_folder)
//        //try? extract_folder.delete()
//    }
//	
//
//	public func project() async throws -> ProjectSpec.Project {
//		return Project(
//			basePath: workingDir,
//			name: name,
//			configs: try! await configs(),
//			targets: try! await targets(),
//			aggregateTargets: [],
//			settings: try! await projSettings(),
//			settingGroups: try! await settingsGroup(),
//			schemes: try! await schemes(),
//			breakpoints: [],
//			packages: try! await packages(),
//			options: try! await specOptions(),
//			fileGroups: try! await fileGroups(),
//			configFiles: try! await configFiles(),
//			attributes: try! await attributes(),
//			projectReferences: []
//		)
//	}
//	
//	public func generate() async throws {
//		let project = try! await project()
//		let fw = FileWriter(project: project)
//		let projectGenerator = ProjectGenerator(project: project)
//        
//		guard let userName = ProcessInfo.processInfo.environment["LOGNAME"] else {
//			throw KivyCreateError.missingUsername
//		}
//		
//		let xcodeProject = try! projectGenerator.generateXcodeProject(in: workingDir, userName: userName)
//        
//        //xcodeProject.pbxproj.nativeTargets.first?
//        //xcodeProject.pbxproj.targets(named: "macOS").first?.productName = name
//        //xcodeProject.pbxproj.buildConfigurations.first!.buildSettings
//		try! fw.writePlists()
//		//
//		
//		try! fw.writeXcodeProject(xcodeProject)
//		try! await NSWorkspace.shared.open([project.defaultProjectPath.url], withApplicationAt: .applicationDirectory.appendingPathComponent("Xcode.app"), configuration: .init())
//		//NSWorkspace.shared.openFile(project.defaultProjectPath.string, withApplication: "Xcode")
//	}
//}




//public class _KivyProject {
//	
//	var name: String
//	
//	
//	
//	var pythonProject: String 
////	{
////		(Path.current + "py_src").string
////	}
//	
//	public init(name: String, py_src: String) async throws {
//		self.name = name
//		self.pythonProject = py_src
//		let current = Path.current
//		
//		try? (current + "YourApp").mkdir()
//		try? (current + "wrapper_sources").mkdir()
//		try? (current + "Resources").mkdir()
//		
//		let python_lib = try await Path.pythonLib()
//		let move_lib: Path = .current + "lib"
//		if move_lib.exists {
//			try move_lib.delete()
//		}
//		try python_lib.move(move_lib)
//
//		try patchPythonLib(dist: try await Path.distLib())
//		let kivyAppFiles = current + "KivyAppFiles"
//		if kivyAppFiles.exists {
//			try kivyAppFiles.delete()
//		}
//		gitClone("https://github.com/PythonSwiftLink/KivyAppFiles")
//		let sourcesPath = Path.current + "Sources"
//		if sourcesPath.exists {
//			try sourcesPath.delete()
//		}
//		try (kivyAppFiles + "Sources").move(sourcesPath)
//		
//		
//		
//		
//		// clean up
//		
//		if kivyAppFiles.exists {
//			try kivyAppFiles.delete()
//		}
//	}
//	
//	func projSettings() async throws -> Settings {
//		let dist_lib = (try await Path.distLib()).string
//		var configSettings: Settings {
//			[
//				"LIBRARY_SEARCH_PATHS": [
//					"\"$(inherited)\"",
//					dist_lib
//				],
//				"SWIFT_VERSION": "5.0",
//				"OTHER_LDFLAGS": "-all_load"
//			]
//		}
//		return .init(configSettings: [
//			"debug": configSettings,
//			"release": configSettings
//		])
//		
//	}
//	
//	var configFiles: [String:String] {
//		[:]
//	}
//	
//	func sources() async throws -> [TargetSource] {
//		
//		let current = PathKit.Path.current
//		
//		var testPath: Path {
//			
//			return (current + "Sources")
//		}
//		
//		let python_lib = (Path.current + "lib" ) //try await Path.pythonLib()
//		
//		
//		//let site_packs = python_lib + "python3.10/site-packages"
//		
//		
//		return [
//			//.init(path: current.string),
//			TargetSource(path: (testPath).string, type: .group),
//			//.init(path: "Resources", type: .group),
//			.init(path: "YourApp", group: "Resources", type: .file, buildPhase: .resources, createIntermediateGroups: true),
//			.init(path: python_lib.string, group: "Resources", type: .file, buildPhase: .resources, createIntermediateGroups: true),
//		]
//	}
//	
//	var dependencies: [Dependency] {
//		[
//			.init(type: .package(product: "PySwiftObject"), reference: "kv-swift"),
//			.init(type: .package(product: "PythonSwiftCore"), reference: "kv-swift"),
//			.init(type: .package(product: "KivyLauncher"), reference: "kv-swift"),
//		]
//	}
//	
//	func info() throws -> Plist {
//		.init(path: "Info.plist" )
//		
//	}
//	var preBuildScripts: [BuildScript] {
//		[
//			.init(
//				script: .script("""
//					rsync -av --delete "\(pythonProject)"/ "$PROJECT_DIR"/YourApp
//					"""
//				),
//				name: "Sync Project"
//			),
//			.init(
//				script: .script("""
//					python3.10 -m compileall -f -b "$PROJECT_DIR"/YourApp
//					"""
//			),
//				name: "Compile Python Files"
//			),
//			.init(
//				script: .script("""
//					find "$PROJECT_DIR"/YourApp/ -regex '.*\\.py' -delete
//					"""
//				),
//				name: "Delete .py leftovers"
//			)
//		]
//	}
//	var buildToolPlugins: [BuildToolPlugin] {
//		[.init(plugin: "Swiftonize", package: "SwiftonizePlugin")]
//	}
//	var postCompileScripts: [BuildScript] {
//		[]
//	}
//	var postBuildScripts: [BuildScript] {
//		[
//		]
//	}
//	
//	var attributes: [String : Any] {
//		[:]
//	}
//	func target() async throws -> Target {
//		let output = Target(
//			name: name,
//			type: .application,
//			platform: .iOS,
//			productName: nil,
//			deploymentTarget: .init("13.0"),
//			settings: try await projSettings(),
//			configFiles: configFiles,
//			sources: try await sources(),
//			dependencies: dependencies,
//			info: try info(),
//			entitlements: nil,
//			transitivelyLinkDependencies: false,
//			directlyEmbedCarthageDependencies: false,
//			requiresObjCLinking: true,
//			preBuildScripts: preBuildScripts,
//			buildToolPlugins: buildToolPlugins,
//			postCompileScripts: postCompileScripts,
//			postBuildScripts: postBuildScripts,
//			buildRules: [
//				
//			],
//			scheme: nil,
//			legacy: nil,
//			attributes: attributes,
//			onlyCopyFilesOnInstall: false,
//			putResourcesBeforeSourcesBuildPhase: false
//		)
//		//let info = InfoPlistGenerator()
//		
//		return output
//	}
//	}
