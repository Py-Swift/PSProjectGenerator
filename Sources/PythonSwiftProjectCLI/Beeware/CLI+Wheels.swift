//
//  CLI+Wheels.swift
//  PythonSwiftProject
//
import Foundation
import ArgumentParser
import PathKit
import PSProjectGen
import Zip

extension PythonSwiftProjectCLI {
    
    struct Wheels: AsyncParsableCommand {
        
        public static var configuration: CommandConfiguration = .init(
            subcommands: [
                List.self,
                Test.self
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
}
