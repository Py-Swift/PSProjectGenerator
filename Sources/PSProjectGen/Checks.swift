//
//  Checks.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/08/2025.
//

import Foundation
import PathKit


public final class Checks {
    
    public static let shared = Checks()
    
    private static func _validateHostPython() -> Bool {
        let hostpy = Path.hostPython
        let py_bin = hostpy + "bin/python3"
        let pip_bin = hostpy + "bin/pip3"
        
        return py_bin.exists && pip_bin.exists
    }
    
    public static func validateHostPython() -> Bool {
        if _validateHostPython() {
            return true
        }
        print("""
        could not locate <\(Path.hostPython)>
        hostoython3 is not installed
        run:
            psproject host-python3
        """)
        return false
    }
}
