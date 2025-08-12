//
//
//import Foundation
//import ArgumentParser
//import PathKit
//

//
//extension PythonSwiftProjectCLI {
//	
//	
//	
//	struct Kivy: AsyncParsableCommand {
//		
//		
//		public static var configuration: CommandConfiguration = .init(
//            subcommands: [
//                Create.self,
//                Update.self,
//                GenerateSpec.self,
//                Patch.self,
//                Recipe.self,
//                //Template.self,
//                HostPython.self
//            ]
//		)
//		
//		
//		
//		
//	}
//	
//	
//}
//import PSProjectGen
//extension PythonSwiftProjectCLI {
//    struct HostPython: AsyncParsableCommand {
//        
//        func run() async throws {
//            let app_sup = Path(URL.applicationSupportDirectory.path(percentEncoded: false))
//            //let _app_sup = Path(URL.applicationSupportDirectory.path(percentEncoded: false))
//            let app_dir = (app_sup + "psproject")
//            print(app_dir)
//            if !app_dir.exists { try! app_dir.mkpath() }
//            
//            try await buildHostPython(path: app_sup + "psproject")
//            InstallPythonCert(python: ((app_sup + "psproject") + "python3/bin/python3").url)
//        }
//    }
//}
