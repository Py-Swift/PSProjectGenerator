////
////  SwiftUI+Create.swift
////  PythonSwiftProject
////
////  Created by CodeBuilder on 08/07/2025.
////
//
//import ArgumentParser
//import PathKit
//import PSProjectGen
//
//extension PythonSwiftProjectCLI.SwiftUI {
//    struct Create: AsyncParsableCommand {
//        
//        @Argument var name: String
//        
//        @Option(name: .short) var python_src: Path?
//        
//        @Option(name: .short) var requirements: Path?
//        
//        @Option(name: .short) var spec_file: Path?
//        
//        @Flag(name: .short) var forced: Bool = false
//        
//        
//        func run() async throws {
//            let current = Path.current
//            let projDir = (current + name)
//            
//            var src: Path? = python_src
//            
//            if let python_src {
//                if python_src.isRelative {
//                    if python_src.string.hasPrefix("..") {
//                        src = current.parent() + python_src.lastComponent
//                    } else {
//                        src = current + python_src.lastComponent
//                    }
//                }
//            }
//            
//            if forced, projDir.exists {
//                try? projDir.delete()
//            }
//            try? projDir.mkdir()
//            
//            let proj = try await SwiftUIProject(
//                name: name,
//                py_src: src!,
//                workingDir: projDir
//            )
//            try await proj.createStructure()
//            try await proj.generate()
//        }
//    }
//}
