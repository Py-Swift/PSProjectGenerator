
import Foundation
import PathKit
import ArgumentParser
import PSProjectGen
import TOMLKit
import MachO
import SwiftCPUDetect
import PSTools

let arch_info = CpuArchitecture.current() ?? .intel64

private func getAppLocation() -> Path? {
    let local_bin = Path(ProcessInfo.processInfo.arguments.first!)
    if local_bin.isSymlink {
        return try? local_bin.symlinkDestination()
    }
    return local_bin
}

extension PythonSwiftProjectCLI {
    
    struct Create: AsyncParsableCommand {
        @Option var name: String?
        
        @Option(name: .short) var python_src: Path?
        
        @Option(name: .short) var requirements: Path?
        
        //@Option(name: .short) var spec_file: Path?
        
        @Flag(name: .short) var forced: Bool = false
        
        //@Option(name: .long, transform: {.init(rawValue: $0) ?? .ios}) var platform: [ BWProject.Platform ] = [.ios]
        
        //@Option(name: .long) var icon: Path?
        
        //@Option(name: .long) var pip: [String] = []
        
        @Option var uv: Path?
        
        
        
        
        
        func run() async throws {
            //            try await GithubAPI(owner: "PythonSwiftLink", repo: "KivyCore").handleReleases()
            //            return
            
            if let uv {
                
                if !Validation.hostPython() { return }
                try Validation.backends()
                
                try launchPython()
                
                
                
                guard let app_path = getAppLocation()?.parent() else { fatalError("App Folder not found")}
                
                
                let proj = try await BWProject(
                    name: name,
                    uv: uv,
                    _workingDir: .current,
                    app_path: app_path,
                    psp_bundle: .init(),
                    forced: forced
                )
                
                try await proj.createStructure()
                try await proj.generate()
                
            } else {
                guard let name else { fatalError("None UV based project must include -n <name of app>")}
                //var spec_file = spec_file
                //print(platform)
                print(try await Path.ios_python())
                //guard let app_path = getAppLocation()?.parent() else { fatalError("App Folder not found")}
                
                var src: Path? = python_src
                let current = Path.current
                
                //            if spec_file == nil {
                //                switch current {
                //                case let py_spec where (py_spec + "projectSpec.py").exists:
                //                    spec_file = (py_spec + "projectSpec.py")
                //                case let yml_spec where (yml_spec + "projectSpec.yml").exists:
                //                    print("found projectSpec.yml in", yml_spec)
                //                    spec_file = (yml_spec + "projectSpec.yml")
                //                default: break
                //                }
                //            }
                // check if relative and create full path to it..
                if let python_src {
                    if python_src.isRelative {
                        if python_src.string.hasPrefix("..") {
                            src = current.parent() + python_src.parent()
                        } else {
                            src = current + python_src.parent()
                        }
                    }
                }
                // check if parh actually exist else do fatalError
                if let src {
                    guard src.exists else { fatalError("\(src) don't exist") }
                } else {
                    let emptySrc = (Path.current + name) + "py_src"
                    try emptySrc.mkpath()
                    src = emptySrc
                }
                
                let projDir = (Path.current + name)
                if forced, projDir.exists {
                    try? projDir.delete()
                }
                try? projDir.mkdir()
                
                
                
                //            let proj = try await BWProject(
                //                name: name,
                //                py_src: src,
                //                requirements: requirements,
                //                icon: icon,
                //                projectSpec: spec_file,
                //                workingDir: projDir,
                //                app_path: app_path,
                //                
                //                platforms: platform,
                //                pips: pip,
                //                uv: uv
                //            )
                
                //        let ___proj = try await KivyProject(
                //            name: name,
                //            py_src: src,
                //            requirements: requirements,
                //            icon: icon,
                //            //projectSpec: swift_packages == nil ? nil : .init(swift_packages!),
                //            projectSpec: spec_file,
                //            workingDir: projDir,
                //            app_path: app_path,
                //            legacy: legacy,
                //            platforms: platform,
                //            pips: pip
                //        )
                //            
                //            try await proj.createStructure()
                //            try await proj.generate()
                
            }
        }
    }
    
}
