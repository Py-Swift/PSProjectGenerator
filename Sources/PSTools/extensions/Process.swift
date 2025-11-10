//
//  Process.swift
//  PythonSwiftProject
//

import Foundation
import PathKit

extension Process {
    public var executablePath: Path? {
        get {
            if let path = executableURL?.path() {
                return .init(path)
            }
            return nil
        }
        set {
            executableURL = newValue?.url
        }
    }
}

extension Process {
    @discardableResult
    public static func untar(url: Path) throws -> Int32 {
        let targs = [
            "-xzvf", url.string
        ]
        let task = Process()
        //task.launchPath = "/bin/zsh"
        task.executableURL = .tar
        task.arguments = targs
        
        try task.run()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    
}

@discardableResult
public func ciBuildWheelApp(src: Path, output_dir: Path, arch: String, platform: String) throws -> Int32 {
    
    var env = ProcessInfo.processInfo.environment
    
    env["CIBW_BUILD"] = "cp313-*"
    env["CIBW_ARCHS"] = arch
    env["CIBW_PLATFORM"] = platform
    let targs = [
        "--output-dir", output_dir.string
    ]
    let task = Process()
    
    task.executablePath = .cibuildwheel
    task.currentDirectoryURL = src.url
    task.arguments = targs
    task.environment = env
    try task.run()
    task.waitUntilExit()
    return task.terminationStatus
}
