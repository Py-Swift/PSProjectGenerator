//
//  CLI+Wheels.swift
//  PythonSwiftProject
//
import Foundation
import ArgumentParser
import PathKit
import PSProjectGen
import Zip
import TOMLKit

extension PythonSwiftProjectCLI {
    
    struct Wheels: AsyncParsableCommand {
        
        public static var configuration: CommandConfiguration = .init(
            subcommands: [
                List.self,
                Test.self,
                Validate.self
            ]
        )
        
    }
}

extension PythonSwiftProjectCLI.Wheels {
    struct List: AsyncParsableCommand {
        
        @Flag var versions: Bool = false
        
        func run() async throws {
            
            
            if versions {
                print("processing .......")
                let list: [IphoneosWheelSources.PackageData] = try await IphoneosWheelSources.shared.all_wheels(sdk: .iphoneos)
                let items = list.map({ whl in
                    """
                    - \(whl.name):
                    \t\(whl.versions.sorted().joined(separator: "\n\t"))
                    """
                })
                print("""
                Available iOS Wheels (\(list.count) items):
                \(items.joined(separator: "\n"))
                """)
            } else {
                let list = IphoneosWheelSources.shared.all_wheels()
                print("""
                Available iOS Wheels (\(list.count) items):
                - \(list.joined(separator: "\n- "))
                """)
            }
        }
    }
    
    struct Test: AsyncParsableCommand {
        
        @Argument var names: [String]
        
        func run() async throws {
            for name in names {
                guard let source: any IphoneosWheelSources.WheelSource = try await IphoneosWheelSources.shared.all_wheels(sdk: .iphoneos).first(where: { src in
                    src.rawValue.lowercased() == name.lowercased()
                }) else {
                    fatalError("wheel for \(name) not found")
                }
                
                let wheels = try await source.packageData().files.filter({ w in
                    return w.attrs.python_version == "cp311" && (w.basename.hasSuffix("ios_12_0.whl") || w.basename.hasSuffix("iphoneos.whl"))
                })
                
                if let release = wheels.sorted(by: {$0.version > $1.version}).first {
                    try await release.install(to: .current)
                }
            }
            
            
            
        }
    }
    
    
    struct Validate: AsyncParsableCommand {
        
        @Argument var uv: Path
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
            let pyswift_project = toml.pyswift.project
            guard let folderName = pyswift_project?.folder_name else { return }
            let workingDir = (uv.parent()) + folderName
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
            
            let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            for platform in platforms.reversed() {
                let status = try await platform.validatePips(requirements: req_file)
                if status != 0 {
                    print("\n####################################################################################################")
                    print("pip wheels validation for platform <\(platform.wheel_platform)> failed")
                    print("####################################################################################################\n")
                    return
                } else {
                    print("\n####################################################################################################")
                    print("pip wheels validation for platform <\(platform.wheel_platform)> succeeded")
                    print("####################################################################################################\n")
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
    }
}
