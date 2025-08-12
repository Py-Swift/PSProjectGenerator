//
//  File.swift
//  
//
//  Created by CodeBuilder on 07/10/2023.
//

import Foundation
import ArgumentParser


extension PythonSwiftProjectCLI {
	
	struct SwiftUI: AsyncParsableCommand {
		
        static var configuration: CommandConfiguration = .init(
            commandName: "swiftui",
            subcommands: [
                Create.self
            ]
        )
		
	}
}



extension PythonSwiftProjectCLI.SwiftUI {
	
}
