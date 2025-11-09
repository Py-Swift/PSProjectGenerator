//
//  PyBackendLoader.swift
//  PythonSwiftProject
//

import Foundation
import PathKit
import PSBackend
import PySwiftKit
import PySwiftWrapper

public enum PyBackendLoader {
    // static let spec_from_file_location = #PyCallable_P<String, Path>(PyImport(from: "importlib.util", import_name: "spec_from_file_location")!)
    // static let module_from_spec = #PyCallable_P<PyPointer>(PyImport(from: "importlib.util", import_name: "module_from_spec")!)
    
    //@MainActor
    public static func load_backend(name: String, path: Path? = nil) throws -> PSBackend {
        print(Self.self, "load_backend(name: \(name), path: \(path as Any))", PyHasGIL())
        guard
            let _backend = PyImport_ImportModule("pyswiftbackends.\(name)"),
            let backend = try? PyObject_GetAttr(_backend, key: "backend")
        else {
            PyErr_Print()
            fatalError()
        }
        
        return try .casted(from: backend)
    }
    
    public static func load_backend(external name: String, path: Path? = nil) throws -> PSBackend {
        guard
            let _backend = PyImport_ImportModule("\(name)"),
            let backend = try? PyObject_GetAttr(_backend, key: "backend")
        else {
            PyErr_Print()
            fatalError()
        }
        
        return try .casted(from: backend)
    }
    //@MainActor
    public static func install_pyframework_backend() async throws {
        let backend = try load_backend(name: "pyframework", path: "")
        try await backend.do_install(support: .init(value: .ps_support))
    }
}
