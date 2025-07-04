//
//  Process.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 20/06/2025.
//

import Foundation
import PathKit

@discardableResult
func pipInstall(requirements: Path, site_path: Path, upgrade: Bool) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    var arguments = ["install" ,"-r", requirements.string, "-t", site_path.string, "--compile", "--no-cache-dir", "--isolated"]
    if upgrade { arguments.append("--upgrade")}
    task.arguments = arguments
    task.executableURL = try? which_pip3().url
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    return output
}

@discardableResult
func pipInstall(_ pip: String, site_path: Path, upgrade: Bool) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    var arguments = ["install",pip, "-t", site_path.string, "--compile", "--no-cache-dir",  "--isolated"]
    
    if upgrade { arguments.append("--upgrade")}
    task.arguments = arguments
    
    task.executableURL = try? which_pip3().url
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    return output
}

@discardableResult
func pipUninstall(_ pip: String, site_path: Path) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["uninstall",pip, "-t", site_path.string]
    task.executableURL = try? which_pip3().url
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    return output
}

func which_pip3() throws -> Path {
    let proc = Process()
    //proc.executableURL = .init(filePath: "/bin/zsh")
    proc.executableURL = .init(filePath: "/usr/bin/which")
    proc.arguments = ["pip3.11"]
    let pipe = Pipe()
    
    proc.standardOutput = pipe
    var env = ProcessInfo.processInfo.environment
    env["PATH"]?.extendedPath()
    proc.environment = env
    
    try! proc.run()
    proc.waitUntilExit()
    
    guard
        let data = try? pipe.fileHandleForReading.readToEnd(),
        var path = String(data: data, encoding: .utf8)
    else { fatalError() }
    return .init(path.strip())
}

extension Pipe {
    
    func readData() -> Data? {
        let data = try? fileHandleForReading.readToEnd()
        return data
    }
    
    func read() -> String? {
        guard
            let data = readData(),
            let path = String(data: data, encoding: .utf8)
        else { return nil }
        
        return path.strip()
    }
}

extension Process {
    static func withPipeOut(_ pipe: Pipe) -> Process {
        let proc = Process()
        proc.standardOutput = pipe
        return proc
    }
    func runAndWait() throws {
        try run()
        waitUntilExit()
    }
}

extension Process {
    static func which(_ name: String) -> String? {
        let pipe = Pipe()
        let proc = Process.withPipeOut(pipe)
        proc.standardOutput = pipe
        proc.executableURL = .which
        proc.arguments = [name]
        
        var env = ProcessInfo.processInfo.environment
            env["PATH"]? += ":/usr/local/bin"
            //print(env)
            proc.environment = env
        
        try! proc.runAndWait()
        //print(Self.self, proc.executableURL, proc.arguments)
        return pipe.read()
    }
    
    static func py_version(_ python: URL) -> String? {
        let pipe = Pipe()
        let proc = Process.withPipeOut(pipe)
        proc.executableURL = python
        proc.arguments = ["--version"]
        
        try? proc.runAndWait()
        return pipe.read()
    }
    
    static func pip_install(_ python: URL, pips: [String], target: String) {
        let pipe = Pipe()
        let proc = Process.withPipeOut(pipe)
        let arguments = ["/Library/Frameworks/Python.framework/Versions/3.11/bin/pip3.11","install"] + pips + [
            "-t", target
        ]
        print(arguments)
        proc.arguments = arguments
        
        try? proc.runAndWait()
        if let log = pipe.read() {
            print(log)
        }
    }
}


