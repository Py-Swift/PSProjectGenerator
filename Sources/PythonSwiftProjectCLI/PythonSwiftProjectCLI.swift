// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

@preconcurrency import ArgumentParser
import PSProjectGen


@main
struct PythonSwiftProjectCLI: AsyncParsableCommand {
	
	static let configuration: CommandConfiguration = .init(
		version: LIBRARY_VERSION,
        subcommands: [
            Create.self,
            Update.self,
            Init.self,
            Backends.self,
            HostPython.self,
            Template.self,
            Wheels.self
        ]
	)
	
	
	enum CodingKeys: CodingKey {
	}
	

	
}


