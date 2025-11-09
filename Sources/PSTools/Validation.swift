//
//  Checks.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/08/2025.
//

import Foundation
import PathKit
import PSBackend
import PySwiftKit

public enum Validation {
    
    public enum ValidationError: Error {
        case pyprojectMissing(String)
    }
    
    
    private static func validateHostPython() -> Bool {
        let hostpy = Path.hostPython
        let py_bin = hostpy + "bin/python3"
        let pip_bin = hostpy + "bin/pip3"
        let py_lib = hostpy + "lib"
        return py_bin.exists && pip_bin.exists && py_lib.exists
    }
    
    public static func hostPython(_ ver: String? = nil) -> Bool {
        let version = ver ?? HOST_PYTHON_VER
        if validateHostPython() {
            return true
        }
        print("""
        could not locate <\(Path.hostPython)>
        hostpython is not detected
        
        options: 
        * set fixed path by (recommended):
        
            psproject host-python path "$(uv python find \(version))"
        
        * temporary set environment by:
            
            export HOST_PYTHON="$(uv python find \(version))"
        
        * install fixed host-python for psproject only
        
            psproject host-python install
        
        
        """)
        return false
    }
    
    private static func validateBackends() -> Bool {
        let backends = Path.ps_shared + "backends"
        let psbackends = backends + "pyswiftbackends"
        return backends.exists && psbackends.exists
    }
    
    public static func backends() throws {
        if validateBackends() { return }
        
        let backends = Path.ps_shared + "backends"
        if !backends.exists {
            try? backends.mkdir()
        }
        
        let __init__ = backends + "__init__.py"
        if !__init__.exists { try __init__.write("") }
        
        PyTools.pipInstall(pip: "git+https://github.com/Py-Swift/PySwiftBackends", "-t", backends.string)
        PyTools.pipInstall(pip: "git+https://github.com/kivy-school/pyswift-backends", "-t", backends.string)
    }
    
    public static func pyprojectExist(root: Path) throws {
        let pyproject = root + "pyproject.toml"
        if !pyproject.exists {
            throw ValidationError.pyprojectMissing("\(root) has no pyproject.toml")
        }
    }
    
    public static func xcodeProject(root: Path) throws -> Path {
        let project_dist = root + "project_dist"
        let xcode_dist = project_dist + "xcode"
        
        if !xcode_dist.exists { try xcode_dist.mkpath() }
        return xcode_dist
    }
    
    private static func validateSupportPythonFramework() -> Bool {
        let support = Path.ps_support
        let pyFramework = support + "Python.xcframework"
        
        return pyFramework.exists
    }
    
    
    
    public static func support() throws {
        let support = Path.ps_support
        if support.exists { return }
        try? support.mkpath()
    }
    
    //@MainActor
    public static func supportPythonFramework() async throws {
        if validateSupportPythonFramework() { return }
        //let gil = PyGILState_Ensure()
        var backend: PSBackend?
        try withGIL {
            backend = try PyBackendLoader.load_backend(name: "pyframework", path: "")
            
            
        }
        if let backend {
            try await backend.do_install(support: .init(value: .ps_support))
        }
        //PyGILState_Release(gil)
    }
}
