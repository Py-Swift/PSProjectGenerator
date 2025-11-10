//
//  Path.swift
//  PythonSwiftProject
//
@preconcurrency import PathKit
import Foundation

extension Path: @unchecked Swift.Sendable {}


extension Path {
    public static var ps_shared: Path { "/Users/Shared/psproject"}
    public static var ps_support: Path { ps_shared + "support" }
    public static let cibuildwheel = which.cibuildwheel
}

public func getHostPython() -> Path {
    let env = ProcessInfo.processInfo.environment
    
    if let host_python = env["HOST_PYTHON"] {
        let path: Path = .init(host_python)
        if path.isFile {
            let parent = path.parent()
            if parent.lastComponent == "bin" {
                return parent.parent()
            }
        }
        return .init(host_python)
    }
    return .ps_shared + "hostpython3"
}


public extension Path {
    static let hostPython = getHostPython()//Path.ps_shared + "hostpython3"
    static let venv = Path.hostPython + "venv"
    static let venvActivate = (Path.venv + "bin/activate")
    
    var escapedString: String {
        string.replacingOccurrences(of: " ", with: "\\ ")
    }
    var escapedWithoutExt: String {
        
        lastComponentWithoutExtension.replacingOccurrences(of: " ", with: "\\ ")
    }
}


extension Path {
    //@MainActor
    public func chdir(closure: () async throws -> ()) async rethrows {
        let previous = Path.current
        Path.current = self
        defer { Path.current = previous }
        try await closure()
      }
    
    public static func withTemporaryFolder(_ handle: @escaping (Path) throws ->Void) throws {
        let tmp = try Path.uniqueTemporary()
        try tmp.mkpath()
        defer { try? tmp.delete() }
        try tmp.chdir {
            try handle(tmp)
        }
        
    }
    
    //@MainActor
    public static func withTemporaryFolder(_ handle: @escaping (Path) async throws ->Void) async throws {
        let tmp = try Path.uniqueTemporary()
        try tmp.mkpath()
        defer { try? tmp.delete() }
        try await tmp.chdir {
            try await handle(tmp)
        }
        
    }
}
