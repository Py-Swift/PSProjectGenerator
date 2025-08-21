//
//  Checks.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/08/2025.
//

import Foundation
import PathKit
import PSBackend

public enum Validation {
    
    
    private static func validateHostPython() -> Bool {
        let hostpy = Path.hostPython
        let py_bin = hostpy + "bin/python3"
        let pip_bin = hostpy + "bin/pip3"
        
        return py_bin.exists && pip_bin.exists
    }
    
    public static func hostPython() -> Bool {
        if validateHostPython() {
            return true
        }
        print("""
        could not locate <\(Path.hostPython)>
        hostoython3 is not installed
        run:
        
            psproject host-python
        
        
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
    
    public static func supportPythonFramework() async throws {
        if validateSupportPythonFramework() { return }
        try await PyBackendLoader.load_backend(name: "pyframework", path: "").do_install(support: .init(value: .ps_support))
    }
}
