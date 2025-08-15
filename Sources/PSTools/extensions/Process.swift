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
