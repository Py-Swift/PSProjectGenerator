//
//  PSTools.swift
//  PythonSwiftProject
//

import PathKit
import TOMLKit
import PSBackend
import PyProjectToml

public let HOST_PYTHON_VER = "3.13.7"

//@MainActor
public func generateReqFromUV(toml: PyProjectToml, uv: Path, backends: [PSBackend]) async throws -> String {
    //var excludes = toml.pyswift.project?.exclude_dependencies ?? []
    
    var excludes = toml.tool?.psproject?.exclude_dependencies ?? []
    
    for backend in backends {
        excludes.append(contentsOf: try backend.exclude_dependencies())
    }
    
    if !excludes.isEmpty {
        var reqs = [String]()
        let uv_abs = uv.absolute()
        try Path.withTemporaryFolder { tmp in
            // loads, modifies and save result as pyproject.toml in temp folder
            // and temp folder now mimics an uv project directory
            try copyAndModifyUVProject(uv_abs, excludes: excludes)
            reqs.append(
                UVTool.export_requirements(uv_root: tmp, group: nil)
            )
            
        }
        if let ios_pips = toml.tool?.psproject?.dependencies?.pips {
            reqs.append(contentsOf: ios_pips)
        }
        
        let req_txt = reqs.joined(separator: "\n")
        print(req_txt)
        return req_txt
    } else {
        // excludes not defined or empty go on like normal
        var reqs = [String]()
        reqs.append(
            UVTool.export_requirements(uv_root: uv, group: nil)
        )
        if let ios_pips = toml.tool?.psproject?.dependencies?.pips {
            reqs.append(contentsOf: ios_pips)
        }
                    
        let req_txt = reqs.joined(separator: "\n")
        print(req_txt)
        return req_txt
    }
    
}

@discardableResult
public func copyAndModifyUVProject(_ uv: Path, excludes: [String]) throws -> Path {
    let new = Path.current
    let pyproject = uv + "pyproject.toml"
    let py_new = new + "pyproject.toml"
    
    let modded = try TOMLTable(string: try pyproject.read())
    var deps = (modded["project"]?["dependencies"]?.array ?? []).compactMap(\.string)
    for ext in excludes {
        switch ext {
        case "kivy":
            deps.removeAll(where: { dep in
                if let dep = dep.string {
                    switch dep {
                    case let reloader where reloader.hasPrefix("kivy-reloader"):
                        false
                    default:
                        dep.hasPrefix(ext)
                    }
                } else {
                    false
                }
            })
        default:
            deps.removeAll(where: { dep in
                if let dep = dep.string {
                    dep.hasPrefix(ext)
                } else {
                    false
                }
            })
        }
        
    }
    modded["project"]?["dependencies"] = deps.tomlValue
    
    try py_new.write(modded.convert())
    return new
}
