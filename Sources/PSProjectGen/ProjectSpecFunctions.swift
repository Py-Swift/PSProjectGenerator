

import Foundation
import XcodeGenKit
import ProjectSpec
import PathKit
import Yams

//func loadSwiftPackages(from packageSpec: PathKit.Path, output: inout [String: SwiftPackage]) throws {
//    
////	let spec = (try Yams.load(yaml: .init(contentsOf: packageSpec.url)) as! ProjectSpecDictionary)
////	if let packages = spec["packages"] as? [String: [String:Any]] {
////		try packages.forEach { (ref: String, package: [String : Any]) in
////			output[ref] = try SwiftPackage(jsonDictionary: package)
////		}
////	}
//	
//}

func loadSwiftPackages(from spec: SpecData, output: inout [String: SwiftPackage]) throws {
	if let packages = spec.packages {
        packages.forEach { (key: String, value: SwiftPackageData) in
            if let url = value.url {
                if let branch = value.branch {
                    output[key] = .remote(url: url, versionRequirement: .branch(branch))
                } else if let from = value.version {
                    output[key] = .remote(url: url, versionRequirement: .upToNextMajorVersion(from))
                }
            } else if let path = value.path {
                output[key] = .local(path: path, group: nil, excludeFromProject: false)
            }
        }
//		try packages.forEach { (ref: String, package: [String : Any]) in
//			output[ref] = try SwiftPackage(jsonDictionary: package)
//		}
        
	}
}

func loadPackageDependencies(from projectSpec: SpecData, output: inout [ProjectSpec.Dependency] ) throws {
    if let packages = projectSpec.packages {
        for pack in packages {
            output.append(.init(type: .package(products: pack.value.products ?? []), reference: pack.key))
            
//            if let products = pack["products"] as? [String] {
//                for product in products {
//                    output.append(
//                        .init(type: .package(products: [product]), reference: ref)
//                    )
//                }
//            }
        }
    }
//	guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return }
//	if let packages = spec["packages"] as? [String: [String:Any]] {
//		packages.forEach { (ref: String, package: [String : Any]) in
//			if let products = package["products"] as? [String] {
//				for product in products {
//					output.append(
//						.init(type: .package(products: [product]), reference: ref)
//					)
//				}
//			}
//		}
//	}
}

func loadPythonPackageInfo(from projectSpec: SpecData?, imports: inout [SwiftPackageData.PythonImport]) throws -> Bool {
    if let packages = projectSpec?.packages {
        for pack in packages {
            if let python_imports = pack.value.python_imports {
                for imp in python_imports {
                    imports.append(imp)
                    //pyswiftProducts.append(imp.product)
                }
                //imports.append(contentsOf: python_imports.modules)
                //pyswiftProducts.append(contentsOf: python_imports.products)
            }
        }
        return true
    }
	//guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return false }

//	if let packages = spec["packages"] as? [String:[String:Any]] {
//        //print(packages)
//		packages.forEach { (ref: String, package: [String : Any]) in
//			//print(ref)
//			if let python_imports = package["python_imports"] as? [String:Any] {
//				if let modules = python_imports["modules"] as? [String] {
//					imports.append(contentsOf: modules)
//				}
//				if let products = python_imports["products"] as? [String] {
//					pyswiftProducts.append(contentsOf: products)
//				}
//			}
//		}
//		return true
//	}
	return false
}


func loadInfoPlistInfo(from projectSpec: SpecData, plist: inout [String:Any]) throws {
    if let infoplist = projectSpec.info_plist {
        plist.merge(infoplist)
    }
//	guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return }
//	if let infoplist = spec["info_plist"] as? [String:Any] {
//		plist.merge(infoplist)
//	}
}


func loadExtraPipFolders(from projectSpec: SpecData, pips: inout [ProjectSpec.TargetSource]) throws {
    if let pip_folders = projectSpec.pip_folders {
        for pip_folder in pip_folders {
            pips.append(.init(path: pip_folder.path, group: "Resources", type: .file, buildPhase: .resources))
        }
    }
//    guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return }
//	if let folders = spec["pip_folders"] as? [[String:String]] {
//		folders.forEach { folder in
//			if let path = folder["path"] {
//				pips.append(
//					.init(path: path, group: "Resources", type: .file, buildPhase: .resources)
//				)
//			}
//		}
//	}
}

func loadBasePlistKeys(from url: URL,  keys: inout [String:Any]) throws {
	
	guard let spec = try Yams.load(yaml: .init(contentsOf: url)) as? [String: Any] else { return }
	keys.merge(spec)
}

func loadBuildConfigKeys(from projectSpec: SpecData, keys: inout [String:Any]) throws {
	// DEVELOPMENT_TEAM
    guard let id = projectSpec.development_team?.id else { return }
    keys["DEVELOPMENT_TEAM"] = id
//	guard let spec = try Yams.load(yaml: projectSpec.read()) as? [String: Any] else { return }
//	if let team = spec["development_team"] as? [String:String] {
//		if let id = team["id"] {
//			keys["DEVELOPMENT_TEAM"] = id
//		}
//	}
}

func loadRequirementsFiles(from projectSpec: SpecData, site_path: Path) throws {
    if let requirements = projectSpec.pip_requirements {
        requirements.forEach { req in
            pipInstall(.init(req.path), site_path: site_path)
        }
    }
//	let spec = try Yams.load(yaml: projectSpec.read()) as! [String: Any]
//	if let requirements = spec["pip_requirements"] as? [[String:String]] {
//		requirements.forEach { req in
//			if let path = req["path"] {
//				pipInstall(.init(path), site_path: site_path)
//			}
//		}
//		
//	}
}
