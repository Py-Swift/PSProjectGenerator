//
//  SwiftUITarget.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 08/07/2025.
//

import Foundation
import AppKit
import PathKit
import XcodeGenKit
import ProjectSpec
import Yams
//import RecipeBuilder
import Zip
import XCAssetsProcessor

//public extension SwiftUIProject {
//    
//    class Target: PSProjTargetProtocol {
//        public var name: String
//        
//        public var pythonProject: PathKit.Path
//        
//        public var projectSpec: SpecData?
//        //    var projectSpec: SpecData?
//        
//        let workingDir: Path
//        let resourcesPath: Path
//        let pythonLibPath: Path
//        let app_path: Path
//        
//        init(name: String, pythonProject: PathKit.Path, projectSpec: SpecData? = nil, workingDir: Path, app_path: Path) {
//            self.name = name
//            self.pythonProject = pythonProject
//            self.projectSpec = projectSpec
//            self.workingDir = workingDir
//            let resources = workingDir + "Resources"
//            self.resourcesPath = resources
//            self.pythonLibPath = resources + "lib"
//            self.app_path = app_path
//        }
//      
//        
//        
//    }
//}
//
//extension SwiftUIProject.Target {
//    
//    public func projSettings() async throws -> ProjectSpec.Settings {
//        var configDict: [String: Any] = [
//            "LIBRARY_SEARCH_PATHS": [
//                "$(inherited)",
//            ] ,
//            "SWIFT_VERSION": "5.0",
//            "OTHER_LDFLAGS": "-all_load",
//            "ENABLE_BITCODE": false,
//            "PRODUCT_NAME": "$(PROJECT_NAME)"
//        ]
////        if let projectSpec = project?.projectSpecData {
////            try loadBuildConfigKeys(from: projectSpec, keys: &configDict)
////        }
//        
//        var configSettings: Settings {
//            .init(dictionary: configDict)
//        }
//        
//        return .init(configSettings: [
//            "Debug": configSettings,
//            "Release": configSettings
//        ])
//    }
//    
//    public func configFiles() async throws -> [String : String] {
//        [:]
//    }
//    
//    public func sources() async throws -> [ProjectSpec.TargetSource] {
//        let current = workingDir
//        let sourcesPath = (current + "Sources")
//        let target_group = "iOS"
//        let singleTarget = true
//        let res_group = "Resources"
//        
//        var sources: [ProjectSpec.TargetSource] = [
//            .init(path: "\(res_group)/site-packages", type: .file, buildPhase: .resources ),
//            .init(path: (sourcesPath).string, group: singleTarget ? nil : target_group, type: .group)
//        ]
//        return sources
//    }
//    
//    public func dependencies() async throws -> [ProjectSpec.Dependency] {
//        
//        
//        
//        var output: [ProjectSpec.Dependency] = [
//            .init(type: .package(products: ["SwiftonizeModules"]), reference: "PySwiftKit"),
//            .init(type: .package(products: ["PythonCore"]), reference: "PythonCore"),
//        ]
//        
//        return output
//    }
//    
//    public func info() async throws -> ProjectSpec.Plist {
//        .init(path: "Info.plist")
//    }
//    
//    public func preBuildScripts() async throws -> [ProjectSpec.BuildScript] {
//        []
//    }
//    
//    public func buildToolPlugins() async throws -> [ProjectSpec.BuildToolPlugin] {
//        []
//    }
//    
//    public func postCompileScripts() async throws -> [ProjectSpec.BuildScript] {
//        []
//    }
//    
//    public func postBuildScripts() async throws -> [ProjectSpec.BuildScript] {[
//        .init(
//            script: .script(install_target_modules(app_name: "MyApp")),
//            name: "Install target specific Python modules"
//        ),
//        .init(
//            script: .script(ios_sign_script()),
//            name: "Sign Python Binary Modules"
//        )
//    ]}
//    
//    public func attributes() async throws -> [String : Any] {
//        [:]
//    }
//    
//    public func build() async throws {
//        
//    }
//    
//    public func target() async throws -> ProjectSpec.Target {
//        let output = Target(
//            name:  name,
//            type: .application,
//            platform: .iOS,
//            productName: name,
//            deploymentTarget: .init("13.0"),
//            settings: try! await projSettings(),
//            configFiles: try! await configFiles(),
//            sources: try! await sources(),
//            dependencies: try! await dependencies(),
//            info: try! await info(),
//            entitlements: nil,
//            transitivelyLinkDependencies: false,
//            directlyEmbedCarthageDependencies: false,
//            requiresObjCLinking: true,
//            preBuildScripts: try await preBuildScripts(),
//            buildToolPlugins: try await buildToolPlugins(),
//            postCompileScripts: try await postCompileScripts(),
//            postBuildScripts: try await postBuildScripts(),
//            buildRules: [
//                
//            ],
//            scheme: nil,
//            legacy: nil,
//            attributes: try await attributes(),
//            onlyCopyFilesOnInstall: false,
//            putResourcesBeforeSourcesBuildPhase: false
//        )
//        
//        return output
//    }
//    
//    public func prepare() async throws {
//        let basePath = workingDir 
//        let resources = basePath + "Resources"
//        let site_packages = resources + "site-packages"
//        if !site_packages.exists {
//            try site_packages.mkpath()
//        }
//        
//        let sources = basePath + "Sources"
//        
//        if !sources.exists {
//            try sources.mkpath()
//        }
//        let app_file = sources + "\(name)App.swift"
//        
//        try app_file.write(appFile(), encoding: .utf8)
//        
//        let contentView = sources + "ContentView.swift"
//        try contentView.write(contentViewFile(), encoding: .utf8)
//    }
//}



fileprivate func swiftui_loadBuildConfigKeys(from projectSpec: SpecData, keys: inout [String:Any]) throws {
    // DEVELOPMENT_TEAM
    guard let id = projectSpec.development_team?.id else { return }
    keys["DEVELOPMENT_TEAM"] = id
//    guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return }
//    if let team = spec["development_team"] as? [String:String] {
//        if let id = team["id"] {
//            keys["DEVELOPMENT_TEAM"] = id
//        }
//    }
}


fileprivate func appFile() -> String{
    """
    import SwiftUI

    @main
    struct CleanSwiftUI_iOSApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
    """
}

fileprivate func contentViewFile() -> String {
    """
    import SwiftUI

    struct ContentView: View {
        var body: some View {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
    }

    #Preview {
        ContentView()
    }
    """
}

fileprivate func plist_base() -> String {
    """


    """
}

fileprivate func install_target_modules(
    app_name: String
) -> String {"""
set -e

mkdir -p "$CODESIGNING_FOLDER_PATH/python/lib"
if [ "$EFFECTIVE_PLATFORM_NAME" = "-iphonesimulator" ]; then
    echo "Installing Python modules for iOS Simulator"
    rsync -au --delete "$PROJECT_DIR/Support/ios-arm64_x86_64-simulator/lib/" "$CODESIGNING_FOLDER_PATH/python/lib/" 
    rsync -au --delete "$PROJECT_DIR/\(app_name)/app_packages.iphonesimulator/" "$CODESIGNING_FOLDER_PATH/app_packages" 
else
    echo "Installing Python modules for iOS Device"
    rsync -au --delete "$PROJECT_DIR/Support/ios-arm64/lib/" "$CODESIGNING_FOLDER_PATH/python/lib" 
    rsync -au --delete "$PROJECT_DIR//\(app_name)/app_packages.iphoneos/" "$CODESIGNING_FOLDER_PATH/app_packages" 
fi
"""}

fileprivate func ios_sign_script() -> String {"""
set -e

install_dylib () {
    INSTALL_BASE=$1
    FULL_EXT=$2

    # The name of the extension file
    EXT=$(basename "$FULL_EXT")
    # The location of the extension file, relative to the bundle
    RELATIVE_EXT=${FULL_EXT#$CODESIGNING_FOLDER_PATH/} 
    # The path to the extension file, relative to the install base
    PYTHON_EXT=${RELATIVE_EXT/$INSTALL_BASE/}
    # The full dotted name of the extension module, constructed from the file path.
    FULL_MODULE_NAME=$(echo $PYTHON_EXT | cut -d "." -f 1 | tr "/" "."); 
    # A bundle identifier; not actually used, but required by Xcode framework packaging
    FRAMEWORK_BUNDLE_ID=$(echo $PRODUCT_BUNDLE_IDENTIFIER.$FULL_MODULE_NAME | tr "_" "-")
    # The name of the framework folder.
    FRAMEWORK_FOLDER="Frameworks/$FULL_MODULE_NAME.framework"

    # If the framework folder doesn't exist, create it.
    if [ ! -d "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER" ]; then
        echo "Creating framework for $RELATIVE_EXT" 
        mkdir -p "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER"

        cp "$CODESIGNING_FOLDER_PATH/dylib-Info-template.plist" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
        plutil -replace CFBundleExecutable -string "$FULL_MODULE_NAME" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
        plutil -replace CFBundleIdentifier -string "$FRAMEWORK_BUNDLE_ID" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
    fi
    
    echo "Installing binary for $FRAMEWORK_FOLDER/$FULL_MODULE_NAME" 
    mv "$FULL_EXT" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/$FULL_MODULE_NAME"
    # Create a placeholder .fwork file where the .so was
    echo "$FRAMEWORK_FOLDER/$FULL_MODULE_NAME" > ${FULL_EXT%.so}.fwork
    # Create a back reference to the .so file location in the framework
    echo "${RELATIVE_EXT%.so}.fwork" > "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/$FULL_MODULE_NAME.origin"     
}

echo "Install standard library extension modules..."
find "$CODESIGNING_FOLDER_PATH/python/lib/python3.11/lib-dynload" -name "*.so" | while read FULL_EXT; do
    install_dylib python/lib/python3.11/lib-dynload/ "$FULL_EXT"
done
echo "Install app package extension modules..."
find "$CODESIGNING_FOLDER_PATH/app_packages" -name "*.so" | while read FULL_EXT; do
    install_dylib app_packages/ "$FULL_EXT"
done
echo "Install app extension modules..."
find "$CODESIGNING_FOLDER_PATH/app" -name "*.so" | while read FULL_EXT; do
    install_dylib app/ "$FULL_EXT"
done

# Clean up dylib template 
rm -f "$CODESIGNING_FOLDER_PATH/dylib-Info-template.plist"

echo "Signing frameworks as $EXPANDED_CODE_SIGN_IDENTITY_NAME ($EXPANDED_CODE_SIGN_IDENTITY)..."
find "$CODESIGNING_FOLDER_PATH/Frameworks" -name "*.framework" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" ${OTHER_CODE_SIGN_FLAGS:-} -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der "{}" \\; 

"""}
