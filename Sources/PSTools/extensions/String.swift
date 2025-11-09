//
//  String.swift
//  PythonSwiftProject
//
import Foundation
import PathKit

public extension String {
    mutating func extendedPath() {
        self += ":\(pathsToAdd().joined(separator: ":"))"
    }
    mutating func strip() {
        self.removeLast(1)
    }
}


fileprivate func pathsToAdd() -> [String] {[
    "/usr/local/bin",
    "/opt/homebrew/bin"
]}


public extension String {
    func resolve_path(prefix: Path, file_url: Bool = true) -> Self {
        switch self {
            case let http where http.hasPrefix("https"):
                return http
            case let relative where relative.hasPrefix("."):
                if file_url {
                    return "file://\((prefix + relative))"
                } else {
                    return "\((prefix + relative))"
                }
            default:
                if file_url {
                    return "file://\(self)"
                } else {
                    return self
                }
        }
    }
}

public extension Array where Element == String {
    func resolve(prefix: Path) -> Self {
        self.map { index in
            index.resolve_path(prefix: prefix)
        }
    }
}
