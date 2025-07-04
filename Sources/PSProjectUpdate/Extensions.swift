//
//  Extensions.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 20/06/2025.
//

import Foundation

import Foundation

public extension URL {
    static let which = URL(filePath: "/usr/bin/which")
    static let patch = URL(filePath: "/usr/bin/patch")
    static let xcrun = URL(filePath: "/usr/bin/xcrun")
    static let tar = URL(filePath: "/usr/bin/tar")
    static let xcodebuild = URL(filePath: "/usr/bin/xcodebuild")
    static let sh = URL(filePath: "/bin/sh")
    static let zsh = URL(filePath: "/bin/zsh")
    static let make = URL(filePath: "/usr/bin/make")
}


extension String {
    func strip() -> String {
        var this = self
        this.removeLast()
        return this
    }
}

fileprivate func pathsToAdd() -> [String] {[
    "/usr/local/bin",
    "/opt/homebrew/bin"
]}

extension String {
    mutating func extendedPath() {
        self += ":\(pathsToAdd().joined(separator: ":"))"
    }
    
}
