//
//  Beeware.swift
//  PythonSwiftProject
//
import Foundation
import ArgumentParser
import PathKit
import PSProjectGen
import Zip

extension PythonSwiftProjectCLI {
    
    
    
    struct Beeware: AsyncParsableCommand {
        
        
        public static var configuration: CommandConfiguration = .init(
            subcommands: [
                Wheels.self,
                HostPython.self,
                Create.self,
                Init.self,
                Template.self
            ]
        )
        
        
        
        
    }
    
    
}



extension PythonSwiftProjectCLI.Beeware {
    struct HostPython: AsyncParsableCommand {
        
        func run() async throws {
            
            //let _app_sup = Path(URL.applicationSupportDirectory.path(percentEncoded: false))
            let app_dir = Path.ps_shared
            print(app_dir)
            if !app_dir.exists { try! app_dir.mkpath() }
            
            try await buildHostPython(version: "3.11.11", path: app_dir)
            InstallPythonCert(python: (app_dir + "hostpython3/bin/python3").url)
        }
    }
}






