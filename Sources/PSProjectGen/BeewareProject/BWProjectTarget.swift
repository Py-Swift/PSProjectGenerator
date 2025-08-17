
import Foundation
import AppKit
import PathKit
import XcodeGenKit
import ProjectSpec
import Yams
import Algorithms
import TOMLKit
import PSBackend
import PySwiftKit
import PyTypes
import PyComparable
import PSTools

extension Dictionary where Key == String, Value == Any {
    mutating func merge(pyDict: [String: PyPointer]) throws {
        for (k,v) in pyDict {
            self[k] = try py2any(value: v)
        }
    }
    
    init(object: PyPointer) throws {
        var new = Self()
        for (k,v) in try [String: PyPointer](object: object) {
            new[k] = try py2any(value: v)
        }
        self = new
    }
}

func py2any(value: PyPointer) throws -> Any {
    switch value {
    case &PyUnicode_Type:
        try String(object: value)
    case &PyLong_Type:
        try Int(object: value)
    case &PyList_Type:
        try [Any].fromList(list: value)
    case &PyDict_Type:
        try [String: Any](object: value)
    default: fatalError()
    }
}

extension Array where Element == Any {
    
    static func fromList(list: PyPointer) throws -> Self {
        try list.compactMap { item in
            if let item {
                try py2any(value: item)
            } else { nil }
        }
    }
   
}

public class BWProjectTarget: PSProjTargetProtocol {
	
	public var name: String
	public var pythonProject: Path

    //public var projectSpec: SpecData?
    var toml: PyProjectToml
    var toml_table: TOMLTable

	let workingDir: Path
	let resourcesPath: Path
	//let pythonLibPath: Path
	let app_path: Path
	
    weak var project: BWProject?
	
    //var target_sdk: Target_SDK
    
    //var platforms: [ any ContextProtocol ]
    //var chucked_platforms: [(String, Array<any ContextProtocol>.SubSequence)]
    //var platforms: [(XcodeTarget_Type, Array<any ContextProtocol>.SubSequence)]
    
    let target_type: XcodeTarget_Type
    let contexts: [any ContextProtocol]
    //var single_target: Bool
	
	
    public init(
        name: String,
        py_src: Path?,
        toml: PyProjectToml,
        toml_table: TOMLTable,
        //platforms: [(XcodeTarget_Type, Array<any ContextProtocol>.SubSequence)],
        target_type: XcodeTarget_Type,
        contexts: Array<any ContextProtocol>,
        workingDir: Path,
        app_path: Path
        //sdk: Target_SDK
    ) async throws {
        
        let root = workingDir
        
        //let single = (platforms.first?.1.count ?? 0) < 2
        //self.platforms = platforms
		self.name = name
        self.workingDir = root
		self.app_path = app_path
        self.resourcesPath = root + "Resources"
        //self.pythonLibPath = sdk.lib_root(current: workingDir)
		self.pythonProject = py_src ?? "$PROJECT_DIR/app/"
		//self.projectSpec = projectSpec
        self.toml = toml
        self.toml_table = toml_table
        //self.target_sdk = sdk
        self.target_type = target_type
        self.contexts = contexts
        //self.single_target = single
        //self.chucked_platforms = platforms.chunked(on: \.xcode_target)
        //platforms.chunked(on: \.sdk.xcode_target)
	}
	public func build() async throws {
		
	}
    
    
	
	public func projSettings() async throws -> ProjectSpec.Settings {
		let configDict: [String: Any] = [
			"LIBRARY_SEARCH_PATHS": [
				"$(inherited)",
            ],
			"SWIFT_VERSION": "5.0",
			"ENABLE_BITCODE": false,
            "PRODUCT_NAME": "$(PROJECT_NAME)"
		]
//        if let projectSpec = project?.projectSpecData {
//			try loadBuildConfigKeys(from: projectSpec, keys: &configDict)
//		}
		
		var configSettings: Settings {
			.init(dictionary: configDict)
		}
		
		return .init(configSettings: [
			"Debug": configSettings,
			"Release": configSettings
		])
	}
	
	public func configFiles() async throws -> [String : String] {
		[:]
	}
	
	public func sources() async throws -> [ProjectSpec.TargetSource] {
		let current = workingDir
		
		var sourcesPath: Path {
			
			return (current + "Sources")
		}
        let target_group = workingDir.lastComponent
        //let res_group = single_target ? "Resources" : "\(target_group)/Resources"
        let res_group = "\(target_group)/Resources"
        let support_group = (workingDir.parent() + "Support")
        let dylib_plist = support_group + "dylib-Info-template.plist"
        
		var sources: [ProjectSpec.TargetSource] = [
            .init(path: "\(res_group)/Images.xcassets", group: res_group),
            //.init(path: "\(res_group)/icon.png", group: res_group),
            .init(path: (sourcesPath).string, group: target_group, type: .group),
		]
        
        switch target_type {
        case .iphoneos:
            sources.append(.init(path: "\(res_group)/Launch Screen.storyboard", group: res_group))
            sources.append(.init(path: dylib_plist.string, group: "Support"))
        case .macos:
            break
        }
		
		
        return sources
	}
	
	public func dependencies() async throws -> [ProjectSpec.Dependency] {
		var output: [ProjectSpec.Dependency] = [

			.init(type: .package(products: ["SwiftonizeModules"]), reference: "PySwiftKit"),
            .init(type: .package(products: ["PythonCore"]), reference: "PythonCore"),
			
		]
        
        if let project = toml.pyswift.project {
            let ttype: PSBackend.XcodeTarget_Type = switch target_type {
            case .iphoneos: .iphoneos
            case .macos: .macos
            }
            for backend in try await project.loaded_backends() {
                output.append(contentsOf: try await backend.target_dependencies(target_type: ttype))
            }
            
//            if let backends = project.backends {
//                
//                var use_sdl2 = false
//                var kivy_default = false
//                
//                for backend in backends {
//                    switch backend.lowercased() {
//                    case "sdl2":
//                        use_sdl2 = true
//                    case "kivylauncher":
//                        use_sdl2 = true
//                        kivy_default = true
//                    case "a4k_pyswift":
//                        output.append(.init(type: .package(products: ["a4k_pyswift"]), reference: "a4k_pyswift"))
//                    default: break
//                    }
//                }
//                
//                if use_sdl2 {
//                    output.append(contentsOf: [
//                        .init(type: .framework, reference: "Support/SDL2.xcframework", embed: true, codeSign: true),
//                        .init(type: .framework, reference: "Support/SDL2_image.xcframework", embed: true, codeSign: true),
//                        .init(type: .framework, reference: "Support/SDL2_mixer.xcframework", embed: true, codeSign: true),
//                        .init(type: .framework, reference: "Support/SDL2_ttf.xcframework", embed: true, codeSign: true)
//                    ])
//                }
//                
//                if kivy_default {
//                    output.append(.init(type: .package(products: ["KivyLauncher"]), reference: "KivyLauncher"))
//                }
//            }
        }
        
        
		
		return output
	}
    
    private func loadBasePlistKeys(from url: URL,  keys: inout [String:Any]) throws {
    
        guard let spec = try Yams.load(yaml: .init(contentsOf: url)) as? [String: Any] else { return }
        keys.merge(spec)
    }
    
	
	public func info() async throws -> ProjectSpec.Plist {
        var mainkeys: [String:Any] = switch target_type {
        case .iphoneos:
            [
                "UILaunchStoryboardName": "Launch Screen",
                "UIRequiresFullScreen": true
            ]
        case .macos:
            [:]
        }
        
        let py_plist = PyDict_New()!
        for backend in try await toml.pyswift.project?.loaded_backends() ?? [] {
            try backend.plist_entries(plist: py_plist, target_type: .iphoneos)
        }
        try mainkeys.merge(pyDict: try .init(object: py_plist))
        
        
        switch target_type {
        case .iphoneos:
            if
                let psp_bundle = Bundle(path: (app_path + "PythonSwiftProject_PSProjectGen.bundle").string ),
                let _project_plist_keys = psp_bundle.path(forResource: "project_plist_keys", ofType: "yml")
            {
                try loadBasePlistKeys(from: .init(filePath: _project_plist_keys), keys: &mainkeys)
            }
            if
                let pyswift = toml_table["pyswift"] ,
                let project = pyswift["project"],
                let plist = project["plist"]?.table,
                let plist_data = plist.convert(to: .json).data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: plist_data) as? [String:Any]
            {
                mainkeys.merge(json)
            }
        case .macos:
            break
        }
		
//        if
//            let _py_swift = toml_dict["pyswift"] as? [String:Any],
//            let project = _py_swift["project"] as? [String:Any],
//            let plist = project["plist"] as? [String:Any] {
//            mainkeys.merge(plist)
//        }
        
        return switch target_type {
        case .iphoneos:
                .init(path: "IphoneOS/Info.plist", attributes: mainkeys)
        case .macos:
                .init(path: "MacOS/Info.plist", attributes: mainkeys)
        }
        
        //return .init(path: "\(single_target ? "" : "IphoneOS/")Info.plist", attributes: mainkeys)
	}
	
	public func preBuildScripts() async throws -> [ProjectSpec.BuildScript] {
		return []
	}
	
	public func buildToolPlugins() async throws -> [ProjectSpec.BuildToolPlugin] {
		[
            //.init(plugin: "Swiftonize", package: "SwiftonizePlugin")
        ]
	}
	
	public func postCompileScripts() async throws -> [ProjectSpec.BuildScript] {
		[]
	}
	
	public func postBuildScripts() async throws -> [ProjectSpec.BuildScript] {
        [
            .installPyModulesIphoneOS(pythonProject: pythonProject),
            .signPythonBinaryIphoneOS()
        ]
	}
	
	public func attributes() async throws -> [String : Any] {
		[:]
	}
	
	public func target() async throws -> ProjectSpec.Target {
        
		let output = Target(
            name: "\(name)-\(target_type)",
			type: .application,
			platform: .iOS,
			productName: name,
			deploymentTarget: .init("13.0"),
			settings: try! await projSettings(),
			configFiles: try! await configFiles(),
			sources: try! await sources(),
			dependencies: try! await dependencies(),
			info: try! await info(),
			entitlements: nil,
			transitivelyLinkDependencies: false,
			directlyEmbedCarthageDependencies: false,
			requiresObjCLinking: true,
			preBuildScripts: try await preBuildScripts(),
			buildToolPlugins: try await buildToolPlugins(),
			postCompileScripts: try await postCompileScripts(),
			postBuildScripts: try await postBuildScripts(),
			buildRules: [
				
			],
            scheme: nil,
			legacy: nil,
			attributes: try await attributes(),
			onlyCopyFilesOnInstall: false,
			putResourcesBeforeSourcesBuildPhase: false
		)
		
		return output
	}
	
	
}

import Zip

extension BWProjectTarget {
    public func prepare() async throws {
        
    }
    
   
}

extension BWProjectTarget {
    public enum Target_SDK: CustomStringConvertible {
        case iphoneos
        case iphonesimulator
        case macos
        
        public var description: String {
            switch self {
            case .iphoneos:
                "iphoneos"
            case .iphonesimulator:
                "iphonesimulator"
            case .macos:
                "macos"
            }
        }
        
        public func site_packages(current: Path) -> Path {
        
                switch self {
                case .iphoneos:
                    current + "site_packages.iphoneos"
                case .iphonesimulator:
                    current + "site_packages.iphonesimulator"
                case .macos:
                    current + "site_packages.macos"
                }
            
        }
        
        public func root(current: Path, ios_only: Bool) -> Path {
            switch self {
            case .iphoneos, .iphonesimulator: current + "iOS"
            case .macos: current + "macOS"
            }
        }
        
        public func sources(current: Path, ios_only: Bool) -> Path {
            root(current: current, ios_only: ios_only) + "Sources"
        }
        
        public func resources(current: Path, ios_only: Bool) -> Path {
            root(current: current, ios_only: ios_only) + "Resources"
        }
        
        public func support_dir(current: Path) -> Path {
            return current + "Support"
        }
        
        public func lib_root(current: Path) -> Path {
            let base = switch self {
            case .iphoneos:
                "ios-arm64"
            case .iphonesimulator:
                "ios-arm64_x86_64-simulator"
            case .macos:
                "macos-arm64_x86_64"
            }
            return current + "\(base)/lib"
        }
    }
}


func stdlib_plist() -> String {
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string></string>
    <key>CFBundleIdentifier</key>
    <string></string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
    <key>MinimumOSVersion</key>
    <string>13.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
"""
}
