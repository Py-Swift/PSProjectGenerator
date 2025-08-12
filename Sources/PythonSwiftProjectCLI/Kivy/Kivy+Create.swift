//
//  Kivy+Project.swift
//


import Foundation
import PathKit
import ArgumentParser
import PSProjectGen


fileprivate let newSpecFile = """
# spec file when creating xcode project.

development_team:
	# id: T5Q8XY2KM9 # add team for signing automatically, you can find it on https://developer.apple.com/account#MembershipDetailsCard

info_plist:
	# NSBluetoothAlwaysUsageDescription: require bluetooth

packages:
	# PyCoreBluetooth:
	#     url:  https://github.com/KivySwiftPackages/PyCoreBluetooth
	#     branch: master
	#     products: [ PyCoreBluetooth ] # what products to add to target
	#     # python wrap packages only
	#     python_imports: # defines what to append to import list
	#         products: [ PyCoreBluetooth ] # what products that has wrapper
	#         modules: [ corebluetooth ] # what modules to append to import list .init(name: "corebluetooth", module: PyInit_corebluetooth)

pip_folders:
	# - path: /path/to/extra_pips

pip_requirements:
	# - path: /path/to/requirements.txt

toolchain_recipes:
	# - pillow

""".replacingOccurrences(of: "\t", with: "    ")


private func getAppLocation() -> Path? {
    let local_bin = Path(ProcessInfo.processInfo.arguments.first!)
    if local_bin.isSymlink {
        return try? local_bin.symlinkDestination()
    }
    return local_bin
}

extension KivyProject.Platform: ArgumentParser.ExpressibleByArgument {}
//
//extension PythonSwiftProjectCLI.Kivy {
//	
//	struct GenerateSpec: AsyncParsableCommand {
//        
//        @Flag(name: .shortAndLong) var python: Bool = false
//        
//        func run() async throws {
//            if python {
//                let specPath = (Path.current + "projectSpec.py")
//                try specPath.write(newSpecData(type: .py), encoding: .utf8)
//            } else {
//                let specPath = (Path.current + "projectSpec.yml")
//                try specPath.write(newSpecData(type: .yml), encoding: .utf8)
//            }
//        }
//        
////		func run() async throws {
////			let specPath = (Path.current + "projectSpec.yml")
////			if specPath.exists { throw CocoaError(.fileWriteFileExists) }
////			try specPath.write("""
////			# spec file when creating xcode project.
////
////			development_team:
////				# id: T5Q8XY2KM9 # add team for signing automatically, you can find it on https://developer.apple.com/account#MembershipDetailsCard
////
////			info_plist:
////				# NSBluetoothAlwaysUsageDescription: require bluetooth
////
////			packages:
////				# PyCoreBluetooth:
////				#     url:  https://github.com/KivySwiftPackages/PyCoreBluetooth
////				#     branch: master
////				#     products: [ PyCoreBluetooth ] # what products to add to target
////				#     # python wrap packages only
////				#     python_imports: # defines what to append to import list
////				#         products: [ PyCoreBluetooth ] # what products that has wrapper
////				#         modules: [ corebluetooth ] # what modules to append to import list .init(name: "corebluetooth", module: PyInit_corebluetooth)
////
////			pip_folders:
////				# - path: /path/to/extra_pips
////
////			pip_requirements:
////				# - path: /path/to/requirements.txt
////			
////			toolchain_recipes:
////				# - pillow
////				
////			""".replacingOccurrences(of: "\t", with: "    "), encoding: .utf8)
////		}
//	}
//	
//	struct Create: AsyncParsableCommand {
//		@Argument var name: String
//		
//		@Option(name: .short) var python_src: Path?
//		
//		@Option(name: .short) var requirements: Path?
//		
//		@Option(name: .short) var spec_file: Path?
//		
//		@Flag(name: .short) var forced: Bool = false
//        
//        @Option(name: .long) var platform: [ KivyProject.Platform ] = [.ios]
//        
//        @Option(name: .long) var icon: Path?
//        
//        @Option(name: .long) var pip: [String] = []
//        
//        @Flag() var legacy: Bool = false
//		
//		func run() async throws {
////			try await GithubAPI(owner: "PythonSwiftLink", repo: "KivyCore").handleReleases()
////			return
//            var spec_file = spec_file
//            print(platform)
//            
//            guard let app_path = getAppLocation()?.parent() else { fatalError("App Folder not found")}
//            
//            var src: Path? = python_src
//            let current = Path.current
//            
//            if spec_file == nil {
//                switch current {
//                case let py_spec where (py_spec + "projectSpec.py").exists:
//                    spec_file = (py_spec + "projectSpec.py")
//                case let yml_spec where (yml_spec + "projectSpec.yml").exists:
//                    print("found projectSpec.yml in", yml_spec)
//                    spec_file = (yml_spec + "projectSpec.yml")
//                default: break
//                }
//            } 
//            // check if relative and create full path to it..
//            if let python_src {
//                if python_src.isRelative {
//                    if python_src.string.hasPrefix("..") {
//                        src = current.parent() + python_src.lastComponent
//                    } else {
//                        src = current + python_src.lastComponent
//                    }
//                }
//            }
//            // check if parh actually exist else do fatalError
//            if let src {
//                guard src.exists else { fatalError("\(src) don't exist") }
//            } else {
//                let emptySrc = (Path.current + name) + "py_src"
//                try emptySrc.mkpath()
//                src = emptySrc
//            }
//            
//			let projDir = (Path.current + name)
//			if forced, projDir.exists {
//				try? projDir.delete()
//			}
//			try? projDir.mkdir()
//			//chdir(projDir.string)
//            
//			let proj = try await KivyProject(
//				name: name,
//				py_src: src,
//                requirements: requirements,
//                icon: icon,
//				//projectSpec: swift_packages == nil ? nil : .init(swift_packages!),
//                projectSpec: spec_file,
//                workingDir: projDir,
//                app_path: app_path,
//                legacy: legacy,
//                platforms: platform,
//                pips: pip
//			)
//			
//			try await proj.createStructure()
//			try await proj.generate()
//			
//			
//		}
//	}
//}
