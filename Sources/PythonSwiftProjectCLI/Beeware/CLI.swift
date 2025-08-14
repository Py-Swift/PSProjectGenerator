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
    
    
//    
//    struct Beeware: AsyncParsableCommand {
//        
//        
//        public static var configuration: CommandConfiguration = .init(
//            subcommands: [
//
//            ]
//        )
//        
//        
//        
//        
//    }
    
    
}

extension PathKit.Path: ArgumentParser.ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}








