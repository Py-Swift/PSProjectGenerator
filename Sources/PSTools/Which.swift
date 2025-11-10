//
//  Which.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 15/08/2025.
//
import PathKit
import Foundation

@dynamicMemberLookup
public class Which {
    
    public subscript(dynamicMember member: String) -> Path {
        let proc = Process()
        //proc.executableURL = .init(filePath: "/bin/zsh")
        proc.executableURL = .init(filePath: "/usr/bin/which")
        proc.arguments = [member]
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
        path.strip()
        return .init(path)
    }
}

//@MainActor
public let which = Which()
