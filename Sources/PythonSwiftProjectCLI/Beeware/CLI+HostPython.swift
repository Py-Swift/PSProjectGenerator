//
//  CLI+HostPython.swift
//  PythonSwiftProject
//

import Foundation
import ArgumentParser
import PathKit
import PSProjectGen
import Zip

extension PythonSwiftProjectCLI {
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
