import Foundation
import PathKit
import ArgumentParser
import PSProjectGen
import TOMLKit
import PSTools
import PyProjectToml

extension Dictionary where Key == String, Value == any TOMLValueConvertible {
    init(table: TOMLTable) {
        self = table.reduce([:], { partialResult, next in
            partialResult.merged([next.0:next.1])
        })
    }
}

@dynamicMemberLookup
class TomlTableHandler {
    typealias Value = [String:any TOMLValueConvertible]
    var toml: Value
    
    init(toml: Value? = nil) {
        self.toml = toml ?? .init()
    }
    
    subscript(dynamicMember key: String) -> (any TOMLValueConvertible)? {
        get {
            toml[key]
        }
        set {
            toml[key] = newValue
        }
    }
    
    subscript(dynamicMember key: String) -> TomlTableHandler {
        get {
            .init(toml: toml)
        }
        set {
            toml[key] = newValue.table
        }
    }
    
    var table: TOMLTable { .init(toml) }
}

extension PythonSwiftProjectCLI {
    struct Init: AsyncParsableCommand {
        @Argument var path: Path
        //@Option var name: String?
        @Option var buildozer: Path?
        @Flag var cythonized: Bool = false
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            
            let btoml: TOMLTable? = if let buildozer {
                try BuildozerSpecReader(path: buildozer).export()
            } else { nil }
            let buildozer_app = btoml?["buildozer-app"]?.table
            let uv_name = buildozer_app?["package"]?["name"]?.string
            UVTool.Init(path: path.string, name: uv_name ?? path.lastComponent)
            //let name = name ?? path.lastComponent
            let pyproject = path + "pyproject.toml"
            var pyproject_text = try pyproject.read(.utf8)
            if cythonized {
                let tmp_toml = try TOMLTable(string: pyproject_text)
                let build_system = TOMLTable()
                build_system["requires"] = [
                    "setuptools",
                    "cython"
                ]
                build_system["build-backend"] = "setuptools.build_meta"
                tmp_toml["build-system"] = build_system
                
                tmp_toml["tool"] = [
                    "setuptools" : [
                        "packages": [
                            "find": [
                                "where": [".cy_src"]
                            ]
                        ]
                    ]
                ]
                pyproject_text = "\(tmp_toml.convert(to: .toml))\n"
            }
            
            
            
            let mainToml = TOMLTable()
            let dep_groups = TOMLTable()
            dep_groups["iphoneos"] = TOMLArray()
            
            
            
            
            if cythonized {
                
                dep_groups["dev"] =  ["cython"]
                
            }
            
            mainToml["dependency-groups"] = dep_groups
            
            //let project = pyswift_project_keys(buildozer: btoml?["buildozer-app"]?.table)
            
            //project["cythonized_app"] = cythonized
            
            //let base = TomlTableHandler(toml: .init(table: try TOMLTable(string: pyproject_text)))
            
            let tool_string = tool_keys().convert(to: .toml, options: [
                .indentArrayElements
            ])
            
            pyproject_text = "\(pyproject_text)\n\(mainToml)\n\(tool_string)"

            
            print("\n####################### pyproject.toml ###########################\n")
            print(
                pyproject_text
            )
            print("\n##################################################################\n")
            try pyproject.write(pyproject_text)
            try await prepare_project()
            if cythonized {
                try (path + "setup.py").write(cythonized_setup_py)
                try (path + "MANIFEST.in").write(cythonized_manifest_in)
            }
        }
        
        fileprivate func tool_keys() -> TOMLTable {
            let toml = TomlTableHandler()
            
            let tool_toml = TomlTableHandler()
            
            tool_toml.psproject = psproject_keys()
            
            toml.tool = tool_toml
            
            
            return toml.table
        }
        
        fileprivate func psproject_keys() -> TOMLTable {
            let toml = TomlTableHandler()
            
            let app_name = path.lastComponent
            toml.app_name = app_name
            toml.cythonized = cythonized
            toml.pip_install_app = false
            toml.backends = [String]()
            toml.extra_index = [String]()
            toml.swift_packages = TOMLTable()
            
            let toml_ios = TomlTableHandler()
            toml_ios.backends = TOMLArray()
            toml_ios.extra_index = [
                "https://pypi.anaconda.org/beeware/simple",
                "https://pypi.anaconda.org/pyswift/simple",
                "https://pypi.anaconda.org/kivyschool/simple"
            ]
            toml_ios.info_plist = TOMLTable()
            toml_ios.swift_packages = TOMLTable()
            
            toml.ios = toml_ios
            
            let toml_macos = TomlTableHandler()
            toml_macos.backends = TOMLArray()
            toml_macos.extra_index = TOMLArray()
            toml_macos.info_plist = TOMLTable()
            toml_macos.swift_packages = TOMLTable()
            toml.macos = toml_macos
            
            return toml.table
        }
        
        fileprivate func prepare_project() async throws {
            let pyproject = try (path + "pyproject.toml").loadPyProjectToml()
            //let src = path + "src"
            let app_src = pyproject.app_src(root: path)
            let module_name = pyproject.app_src_name
            
            let app_py = app_src + "app.py"
            let main_py = app_src + "__main__.py"
            let init_py = app_src + "__init__.py"
            
            
            let app_string = """
            def main():
                print("Hello World")
            """
            
            let init_string = """
            from .app import main
            """
            
            let main_string = """
            from \(module_name) import main
            
            if __name__ == "__main__":
                main()
            """
            
            try app_py.write(app_string)
            try main_py.write(main_string)
            try init_py.write(init_string)
        }
        
        func pyswift_project_keys(buildozer: TOMLTable?) -> TOMLTable {
            var project: [String: any TOMLValueConvertible] = [:]

            
            project["name"] = buildozer?["title"] ?? path.lastComponent
            if let package = buildozer?["package"] {
                project["folder_name"] = buildozer?["title"]?.string?.replacingOccurrences(of: " ", with: "_")
                project["bundle_id"] = package["domain"]
            } else {
                let fname = path.lastComponent
                project["folder_name"] = fname
                project["bundle_id"] = "org.pyswift.\(fname)"
            }
            
            project["swift_sources"] = TOMLArray()
            project["pip_install_app"] = false
            project["backends"] = buildozer == nil ? [] : ["kivylauncher"]
            project["dependencies"] = TOMLTable(["pips": buildozer == nil ? [] : ["ios"]])
            project["platforms"] = [
                "iphoneos"
            ]
            
            project["wheel_cache_dir"] = "wheels"
            
            project["exclude_dependencies"] = TOMLArray()
            project["extra_index"] = [
                "https://pypi.anaconda.org/beeware/simple",
                
                "https://pypi.anaconda.org/pyswift/simple",
                
            ]
            
            project["plist"] = TOMLTable()
            return .init(project)
        }
    }
    
    
}


let cythonized_setup_py = """
from setuptools import setup, Extension, find_packages, Command
from Cython.Build import cythonize
from os.path import curdir, abspath,join, splitext, dirname, basename, split, relpath, exists
import os
from shutil import move, copy
from pathlib import Path

print("WORK_DIR",abspath(curdir))

root_dir = abspath(curdir)

src_path = build_path = dirname(__file__)

extentions = []

cy_src = join(root_dir, ".cy_src")

exts = []

for (root, dir, files) in os.walk(join(root_dir, "src")):
    
    rp = relpath(root, root_dir + "/src")

    if rp == "." and "main.py" in files:
        continue

    target_folder = join(cy_src, rp)
    if not exists(target_folder):
        os.makedirs(target_folder)
    
    cy_path = rp.replace("/", ".")
        
    for file in files:
        
        if file == "__init__.py":
            copy(join(root, file), join(target_folder, file))
        else:
            fn, ext = splitext(file)
            if ext != ".py": continue

            py = join(root, file)
            pyx = join(target_folder, f"{fn}.pyx")
            
            print(py,"->", pyx)
            copy(py, pyx)
            exts.append(
                Extension(f"{cy_path}.{fn}", [join(".cy_src",rp, f"{fn}.pyx")])
            )

setup(
    ext_modules=cythonize(exts)
)
"""

let cythonized_manifest_in = """
global-exclude *.c *.pyx
global-include *.py
"""
