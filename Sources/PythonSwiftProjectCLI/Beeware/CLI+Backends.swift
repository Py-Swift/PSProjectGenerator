//
//  CLI+Backends.swift
//  PythonSwiftProject
//
import Foundation
import PathKit
import ArgumentParser
import PSProjectGen
import TOMLKit
import PSTools

extension PythonSwiftProjectCLI {
    struct Backends: AsyncParsableCommand {
        
        static let configuration: CommandConfiguration = .init(
            subcommands: [
                Install.self,
                Update.self
            ]
        )
        
        
    }
}

extension PythonSwiftProjectCLI.Backends {
    struct Install: AsyncParsableCommand {
        
        @Argument var url: String
        
        func run() async throws {
            if !Validation.hostPython() { return }
            try await launchPython()
            
            let backends = Path.ps_shared + "backends"
            
            if !backends.exists {
                try? backends.mkdir()
            }
            
            let __init__ = backends + "__init__.py"
            if !__init__.exists { try __init__.write("") }
            
            PyTools.pipInstall(pip: "git+\(url)", "-U", "-t", backends.string)
        }
    }
}

extension PythonSwiftProjectCLI.Backends {
    struct Update: AsyncParsableCommand {
        
        @Argument var url: String?
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            try await launchPython()
            
            let backends = Path.ps_shared + "backends"
            
            if !backends.exists {
                try? backends.mkdir()
            }
            
            let __init__ = backends + "__init__.py"
            if !__init__.exists { try __init__.write("") }
            
            let official_backends = [
                
                "https://github.com/Py-Swift/PySwiftBackends",
                "https://github.com/kivy-school/pyswift-backends"
                
            ].map({"git+\($0)"})
            
            for backend in official_backends {
                PyTools.pipInstall(pip: backend, "-U", "-t", backends.string)
            }
            
            //PyTools.pipInstall(pip: "git+https://github.com/Py-Swift/PySwiftBackends", "-U", "-t", backends.string)
        }
        
    }
}
