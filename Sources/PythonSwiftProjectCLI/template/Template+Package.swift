//
//  Template+Package.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/06/2025.
//

import ArgumentParser
import PSProjectGen
import PathKit


extension PythonSwiftProjectCLI.Kivy.Template {
    
    struct Package: AsyncParsableCommand {
        
        @Argument var name: String
        @Option var resource: [Path] = []
        
        func run() async throws {
            try PackageTemplate(
                name: name,
                resources: resource.map(\.string),
                root: .current
            ).generate()
        }
    }
    
}
