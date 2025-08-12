// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import PSProjectGen

@main
struct PythonSwiftProjectCLI: AsyncParsableCommand {
	
	static var configuration: CommandConfiguration = .init(
		version: LIBRARY_VERSION,
        subcommands: [
            Wheels.self,
            HostPython.self,
            Create.self,
            Init.self,
            Template.self
        ]
	)
	
	
	enum CodingKeys: CodingKey {
	}
	

	
}


