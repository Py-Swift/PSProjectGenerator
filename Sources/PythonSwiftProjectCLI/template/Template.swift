//
//  Template.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/06/2025.
//

import ArgumentParser

extension PythonSwiftProjectCLI {
    
    
    struct Template: AsyncParsableCommand {
        public static var configuration: CommandConfiguration = .init(
            subcommands: [
                Package.self
            ]
        )
        
    }
    
}
