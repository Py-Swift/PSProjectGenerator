//
//  KivyProjectTarget 2.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 07/06/2025.
//
import Foundation
import AppKit
import PathKit
import XcodeGenKit
import ProjectSpec
import Yams

public class KivyProjectTargetMacOS: PSProjTargetProtocol {
    
    public var name: String
    public var pythonProject: Path
    
    var dist_lib: Path
    
    public var projectSpec: SpecData?
    //    var projectSpec: SpecData?
    
    let workingDir: Path
    let resourcesPath: Path
    let pythonLibPath: Path
    let app_path: Path
    let legacy: Bool
    let macos_only: Bool
    
    weak var project: KivyProject?
    
    let target_type = ProjectTarget.macOS
    
    
    
    public init(name: String, py_src: Path, dist_lib: Path, projectSpec: SpecData?, workingDir: Path, app_path: Path, legacy: Bool, macos_only: Bool = true) async throws {
        self.name = name
        self.macos_only = macos_only
        self.workingDir = macos_only ? workingDir : workingDir + "macOS"
        self.app_path = app_path
        let resources = workingDir + "Resources"
        self.resourcesPath = resources
        self.pythonLibPath = resources + "lib"
        self.pythonProject = py_src
        self.dist_lib = dist_lib
        self.projectSpec = projectSpec
        self.legacy = legacy
    }
    public func build() async throws {
        
    }
    
    public func projSettings() async throws -> ProjectSpec.Settings {
        var configDict: [String: Any] = [
            "LIBRARY_SEARCH_PATHS": [
                "$(inherited)",
            ] + ( legacy ? [dist_lib] : []),
            "SWIFT_VERSION": "5.0",
            "OTHER_LDFLAGS": "-all_load",
            "ENABLE_BITCODE": false,
            "PRODUCT_NAME": "$(PROJECT_NAME)"
        ]
        if let projectSpec = project?.projectSpecData {
            try loadBuildConfigKeys(from: projectSpec, keys: &configDict)
        }
        
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
        let target_group = "macOS"
        let res_group = macos_only ? "Resources" : "\(target_group)/Resources"
        var sources: [ProjectSpec.TargetSource] = [
            //.init(path: target_group, name: target_group, type: .group, createIntermediateGroups: true),
            
            //.init(path: "macOS/Resources",name: "Resources", group: target_group, type: .group),
            .init(path: "\(res_group)/YourApp", type: .file, buildPhase: .resources, createIntermediateGroups: true),
            .init(path: "\(res_group)/lib", type: .file, buildPhase: .resources),
            //.init(path: pythonLibPath.string, group: "Resources", type: .file, buildPhase: .resources, createIntermediateGroups: true),
            .init(path: "\(res_group)/site-packages", type: .file, buildPhase: .resources ),
            //.init(path: "\(res_group)/Launch Screen.storyboard", group: res_group),
            .init(path: "\(res_group)/Images.xcassets", group: res_group),
            .init(path: "\(res_group)/icon.png", group: res_group),
            
            .init(path: (sourcesPath).string, group: macos_only ? nil : target_group, type: .group),
        ]
        
        if let projectSpec = projectSpec {
            try loadExtraPipFolders(from: projectSpec, pips: &sources)
        }
        
        return sources
    }
    
    public func dependencies() async throws -> [ProjectSpec.Dependency] {
        var output: [ProjectSpec.Dependency] = [
            //            .init(type: .package(product: "PySwiftObject"), reference: "kv-swift"),
            //            .init(type: .package(product: "PythonSwiftCore"), reference: "kv-swift"),
            
            .init(type: .package(products: ["SwiftonizeModules"]), reference: "PySwiftKit"),
            .init(type: .package(products: ["PythonCore"]), reference: "PythonCore"),
            //.init(type: .package(products: ["KivyCore"]), reference: "KivyCore"),
            .init(type: .package(products: ["KivyLauncher"]), reference: "KivyLauncher"),
            
            
        ]
        if let packageSpec = projectSpec {
            try loadPackageDependencies(from: packageSpec, output: &output)
        }
        
        if let recipes = project?.projectSpecData?.toolchain_recipes {
            for recipe in recipes {
                output.append(.init(type: .package(products: [recipe]), reference: "KivyExtra"))
            }
        }
        
        return output
    }
    
    public func info() async throws -> ProjectSpec.Plist {
        var mainkeys: [String:Any] = [
            //"UILaunchStoryboardName": "Launch Screen",
            //"UIRequiresFullScreen": true
            :
        ]
//        if
//            let psp_bundle = Bundle(path: (app_path + "PythonSwiftProject_PSProjectGen.bundle").string ),
//            let _project_plist_keys = psp_bundle.path(forResource: "project_plist_keys", ofType: "yml")
//        {
//            try loadBasePlistKeys(from: .init(filePath: _project_plist_keys), keys: &mainkeys)
//        }
//        if let projectPkeys = Bundle.module.url(forResource: "project_plist_keys", withExtension: "yml") {
//            try loadBasePlistKeys(from: projectPkeys, keys: &mainkeys)
//        }
        if let packageSpec = projectSpec {
            var extraKeys = [String:Any]()
            
            try loadInfoPlistInfo(from: packageSpec, plist: &extraKeys)
            
            mainkeys.merge(extraKeys)
        }
        
        return .init(path: "\(macos_only ? "" : "macOS/")Info.plist", attributes: mainkeys)
    }
    
    public func preBuildScripts() async throws -> [ProjectSpec.BuildScript] {
        let YourApp = "\(macos_only ? "" : "macOS/")Resources/YourApp"
        return [
            .init(
                script: .script("""
    rsync -av --delete "\(pythonProject)"/ "$PROJECT_DIR"/\(YourApp)
    """),
                name: "Sync Project",
                basedOnDependencyAnalysis: false
            ),
            .init(
                script: .script("""
    python3.11 -m compileall -f -b "$PROJECT_DIR"/\(YourApp)
    """),
                name: "Compile Python Files"
            ),
            .init(
                script: .script("""
    find "$PROJECT_DIR"/\(YourApp)/ -regex '.*\\.py' -delete
    """),
                name: "Delete .py leftovers"
            ),
            
        ]
    }
    
    public func buildToolPlugins() async throws -> [ProjectSpec.BuildToolPlugin] {
        [
            //.init(plugin: "Swiftonize", package: "SwiftonizePlugin")
        ]
    }
    
    public func postCompileScripts() async throws -> [ProjectSpec.BuildScript] {
        [
   
        ]
    }
    
    public func postBuildScripts() async throws -> [ProjectSpec.BuildScript] {
        [
//            .init(
//                script: .script(PURGE_PYTHON_BINARY),
//                name: "Purge Python Binary Modules for Non-Target Platforms"
//            ),
//            .init(
//                script: .script(SIGN_PYTHON_BINARY),
//                name: "Sign Python Binary Modules"
//            )
            .init(
                script: .script("""
    set -e
    echo "Signed as $EXPANDED_CODE_SIGN_IDENTITY_NAME ($EXPANDED_CODE_SIGN_IDENTITY)"
    find "$BUILT_PRODUCTS_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/lib/python3.11/lib-dynload" -name "*.so" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der {} \\;
    #find "$BUILT_PRODUCTS_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/app_packages" -name "*.so" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der {} \\; 
    #find "$BUILT_PRODUCTS_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/app" -name "*.so" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der {} \\; 
    """),
                name: "sign .so"
            )
        ]
    }
    
    public func attributes() async throws -> [String : Any] {
        [:]
    }
    
    public func target() async throws -> ProjectSpec.Target {
        let output = Target(
            name: macos_only ? name : "\(name)-macos",
            type: .application,
            platform: .macOS,
            productName: name,
            deploymentTarget: .init("11.0"),
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

extension KivyProjectTargetMacOS {
    public func prepare() async throws {
        
    }
}
