import Foundation
import PathKit
import ArgumentParser
import PSProjectGen
import TOMLKit



extension PythonSwiftProjectCLI.Beeware {
    struct Init: AsyncParsableCommand {
        @Argument var path: Path
        @Option var name: String?
        @Option var buildozer: Path?
        
        func run() async throws {
            
            let btoml: TOMLTable? = if let buildozer {
                try BuildozerSpecReader(path: buildozer).export()
            } else { fatalError() }
            let buildozer_app = btoml?["buildozer-app"]?.table
            
            UVTool.Init(path: path.string, name: name ?? buildozer_app?["package"]?["name"]?.string)
            let name = name ?? path.lastComponent
            let pyproject = path + "pyproject.toml"
            var pyproject_text = try pyproject.read(.utf8)
            
            let mainToml = TOMLTable()
            
            
            
            
            let project = pyswift_project_keys(buildozer: btoml?["buildozer-app"]?.table)
            
            let pyswift_toml = TOMLTable()
            pyswift_toml["swift-packages"] = TOMLTable()
            pyswift_toml["project"] = project
            mainToml["pyswift"] = pyswift_toml
            
            
            pyproject_text += "\n\n\(mainToml.convert(options: []))"
            
            if let btoml {
                pyproject_text += "\n\n\(btoml.convert(options: [.indentArrayElements]))"
            }
            
            
            
            print(
                pyproject_text
            )
        }
        
        func pyswift_project_keys(buildozer: TOMLTable?) -> TOMLTable {
            var project: [String: any TOMLValueConvertible] = [:]

            
            project["name"] = buildozer?["title"] ?? path.lastComponent
            if let package = buildozer?["package"] {
                project["folder_name"] = buildozer?["title"]?.string?.replacingOccurrences(of: " ", with: "_")
                project["bundle_id"] = package["domain"]
            } else {
                let fname = name ?? path.lastComponent
                project["folder_name"] = fname
                project["bundle_id"] = "org.pyswift.\(fname)"
            }
            
            project["swift_sources"] = TOMLArray()
            project["pip_install_app"] = false
            project["backends"] = buildozer == nil ? TOMLArray() : TOMLArray(["kivylauncher"])
            project["dependencies"] = TOMLTable(["pips": buildozer == nil ? [] : ["ios"]])
            
            project["plist"] = TOMLTable()
            return .init(project)
        }
    }
    
    
}
