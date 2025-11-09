//
//  Create+Xcode.swift
//  PSProjectGenerator
//
import Foundation
import ArgumentParser
import PSTools
import PyProjectToml
import PathKit
import PSProjectGen

private func getAppLocation() -> Path? {
    let local_bin = Path(ProcessInfo.processInfo.arguments.first!)
    if local_bin.isSymlink {
        return try? local_bin.symlinkDestination()
    }
    return local_bin
}

extension PythonSwiftProjectCLI.Create {
    
    struct Xcode: AsyncParsableCommand {
        @Option var directory: Path?
        @Flag(name: .long) var ios = false
        @Flag(name: .long) var macos = false
        
        @Flag var forced = false
        
        //@MainActor
        func run() async throws {
            let root = directory ?? .current
            try Validation.pyprojectExist(root: root)
            if !Validation.hostPython() { return }
            try Validation.backends()
            let xcode_path = try Validation.xcodeProject(root: root)
            try launchPython()
            
            var targets: [XcodeTarget_Type] = []
            
            if !(ios && macos) {
                targets = [.iphoneos, .macos]
            } else {
                if ios { targets.append(.iphoneos) }
                if macos { targets.append(.macos) }
            }
            
            guard let app_path = getAppLocation()?.parent() else { fatalError("App Folder not found")}
            let pyproject = try (root + "pyproject.toml").loadPyProjectToml()
            
            guard let app_name = pyproject.tool?.psproject?.app_name else {
                fatalError("tool.psproject.name is missing")
            }
            let proj = try await BWProject(
                name: app_name,
                uv: root,
                _workingDir: xcode_path,
                app_path: app_path,
                psp_bundle: .init(),
                forced: forced,
                targets: targets
            )
            
            try await proj.createStructure()
            try await proj.generate()
        }
    }
    
}

