//
//  String.swift
//  PythonSwiftProject
//
import Foundation


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
