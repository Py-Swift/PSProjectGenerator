
import Foundation
import PathKit

public struct DevelopmentTeamData: Decodable {
	let id: String?
}

public struct PipFolder: Decodable {
	let path: String
}

public struct PipRequirement: Decodable {
	let path: String
}

public struct SwiftPackageData: Decodable {
	
	struct PythonImports: Decodable {
		let products: [String]
		let modules: [String]
	}
    let products: [String]?
	let url: String?
	let path: String?
	let branch: String?
	let version: String?
	let python_imports: PythonImports?
   
}

extension Path: @retroactive Decodable {
    public init(from decoder: any Decoder) throws {
        self = .init(try decoder.singleValueContainer().decode(String.self))
    }
    
    
}

public struct VenvPackages: Decodable {
    let venv_path: Path
    let packages: [Package]
    
    
    
    struct Package: Decodable {
        let url: Path?
        let path: Path?
        let version: String?
        let branch: String?
    }
}

public struct SpecData: Decodable {
	let development_team: DevelopmentTeamData?
	let info_plist: [String:String]?
	let pip_folders: [PipFolder]?
	let pips: [String]?
	let pip_requirements: [PipRequirement]?
	let packages: [String: SwiftPackageData]?
	let toolchain_recipes: [String]?
    let packages_dump: [VenvPackages]?
    let macos_target: Bool?
    // new
    let experimental: Bool?
    let icon: Path?
    let imageset: Path?
    let launch_screen: Path?
    
    let main_swift: Path?
}

fileprivate let newSpecFilePy = """


class ProjectSpec:

    development_team = {
        #"id": "T5Q8XY2KM9"
    }

    info_plist = {
        "NSCameraUsageDescription": "require camera"
         # "NSBluetoothAlwaysUsageDescription": "require bluetooth"
    }

    # icon = "your_path/icon.png"
    # imageset = "your_path/Images.xcassets"
    # launch_screen = "your_path/Launch Screen.storyboard"
    # main_swift = "your_path/Main.swift"
    
    packages = {
        # "PyCoreBluetooth" : {
        #     "url": "https://github.com/KivySwiftPackages/PyCoreBluetooth",
        #     "branch": "master",
        #     "products": [ "PyCoreBluetooth" ],
        #     "python_imports": {
        #         "products": [ "PyCoreBluetooth" ],
        #         "modules": [ "corebluetooth" ]
        #     }
        # }
    }

project = ProjectSpec()

"""

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

icon:
 # your_path/icon.png

imageset:
 # your_path/Images.xcassets

launch_screen:
 # your_path/Launch Screen.storyboard



pip_folders:
 # - path: /path/to/extra_pips

pip_requirements:
 # - path: /path/to/requirements.txt

toolchain_recipes:
 # - pillow

venv_packages:
 # - name: SomePackage

""".replacingOccurrences(of: "\t", with: "    ")

public func newSpecData(type: SpecFileType) -> String {
    switch type {
    case .yml:
        newSpecFile
    case .py:
        newSpecFilePy
    }
}

public enum SpecFileType: String {
    case yml
    case py
}

import Yams
extension PathKit.Path {
	public func specData() throws -> SpecData {
        guard let ext = self.extension, let fileType = SpecFileType(rawValue: ext) else { fatalError("wrong file format")}
        return switch fileType {
        case .yml:
            try YAMLDecoder().decode(SpecData.self, from: read())
        case .py:
            try pyDecode(path: self)
        }
		
	}
}

import PyCodable
import PySwiftKit
import PyExecute
fileprivate func pyDecode(path: Path) throws -> SpecData {
    try launchPython()
    let module = PyDict_New()!
    let code = try path.read(.utf8)
    PyRun_String(string: code, flag: .file, globals: module, locals: module)?.decref()
    guard let project = PyDict_GetItemString(module, "project") else {
        PyErr_Print()
        fatalError("module has no project variable")
    }
    defer {
        project.decref()
        module.decref()
    }
    return try PyDecoder().decode(SpecData.self, from: project)
}
