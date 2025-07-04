//
//  File.swift
//  
//
//  Created by CodeBuilder on 07/10/2023.
//

import Foundation
import ArgumentParser
import PathKit

extension PathKit.Path: ArgumentParser.ExpressibleByArgument {
	public init?(argument: String) {
		self.init(argument)
	}
}

extension PythonSwiftProjectCLI {
	
	
	
	struct Kivy: AsyncParsableCommand {
		
		
		public static var configuration: CommandConfiguration = .init(
            subcommands: [
                Create.self,
                Update.self,
                GenerateSpec.self,
                Patch.self,
                Recipe.self,
                Template.self
            ]
		)
		
		
		
		
	}
	
	
}

