//
//  Path.swift
//  PythonSwiftProject
//
import PathKit
import Foundation


extension Path {
    public static var ps_shared: Path { "/Users/Shared/psproject"}
    public static var ps_support: Path { ps_shared + "support" }
}

public extension Path {
    static let hostPython = Path.ps_shared + "hostpython3"
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
    public static func withTemporaryFolder(_ handle: @escaping (Path) throws ->Void) throws {
        let tmp = try Path.uniqueTemporary()
        try tmp.mkpath()
        defer { try? tmp.delete() }
        try tmp.chdir {
            try handle(tmp)
        }
        
    }
}
