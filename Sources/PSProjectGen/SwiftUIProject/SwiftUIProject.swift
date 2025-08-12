//
//  SwiftUIProject.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 08/07/2025.
//

import Foundation
import AppKit
import PathKit
import XcodeGenKit
import ProjectSpec
import Yams
//import RecipeBuilder
import Zip
import XCAssetsProcessor


public class SwiftUIProject: PSProjectProtocol {
    public var name: String
    
    public var py_src: PathKit.Path
    
    let workingDir: Path
    
    var _targets: [PSProjTargetProtocol] = []
    
    public init(name: String, py_src: PathKit.Path, workingDir: Path) async throws {
        self.name = name
        self.py_src = py_src
        self.workingDir = workingDir
        
        let base_target = Target(
            name: name,
            pythonProject: py_src,
            workingDir: workingDir,
            app_path: workingDir
        )
        _targets.append(base_target)
    }
    
    public func targets() async throws -> [ProjectSpec.Target] {
        try await _targets.asyncMap { t in
            try await t.target()
        }
    }
    
    public func configs() async throws -> [ProjectSpec.Config] {
        [.init(name: "Debug", type: .debug),.init(name: "Release", type: .release)]
    }
    
    public func schemes() async throws -> [ProjectSpec.Scheme] {
        []
    }
    
    public func projSettings() async throws -> ProjectSpec.Settings {
        .empty
    }
    
    public func settingsGroup() async throws -> [String : ProjectSpec.Settings] {
        [:]
    }
    
    public func packages() async throws -> [String : ProjectSpec.SwiftPackage] {
        let output: [String : ProjectSpec.SwiftPackage] = [
            "PythonCore": .remote(
                url: "https://github.com/py-swift/PythonCore",
                versionRequirement: .exact("311.0.0")
            ),
//            "PySwiftKit": .remote(
//                url: "https://github.com/py-swift/PySwiftKit",
//                versionRequirement: .upToNextMajorVersion("311.0.0")
//            ),
            "PySwiftKit": .local(
                path: "/Volumes/CodeSSD/PythonSwiftGithub/PySwiftKit",
                group: nil,
                excludeFromProject: false
            ),
        ]
        
        return output
    }
    
    public func specOptions() async throws -> ProjectSpec.SpecOptions {
        return .init(bundleIdPrefix: "org.pyswift")
    }
    
    public func fileGroups() async throws -> [String] {
        []
    }
    
    public func configFiles() async throws -> [String : String] {
        [:]
    }
    
    public func attributes() async throws -> [String : Any] {
        [:]
    }
    
    public func projectReferences() async throws -> [ProjectSpec.ProjectReference] {
        []
    }
    
    public func projectBasePath() async throws -> PathKit.Path {
        workingDir
    }
    
    public func createStructure() async throws {
        let basePath = workingDir
        
        for _target in _targets {
            try await _target.prepare()
        }
        
        
    }
    
    public func project() async throws -> ProjectSpec.Project {
        Project(
            basePath: workingDir,
            name: name,
            configs: try! await configs(),
            targets: try! await targets(),
            aggregateTargets: [],
            settings: try! await projSettings(),
            settingGroups: try! await settingsGroup(),
            schemes: try! await schemes(),
            breakpoints: [],
            packages: try! await packages(),
            options: try! await specOptions(),
            fileGroups: try! await fileGroups(),
            configFiles: try! await configFiles(),
            attributes: try! await attributes(),
            projectReferences: []
        )
    }
    
    public func generate() async throws {
        let project = try! await project()
        let fw = FileWriter(project: project)
        let projectGenerator = ProjectGenerator(project: project)
        
        guard let userName = ProcessInfo.processInfo.environment["LOGNAME"] else {
            throw KivyCreateError.missingUsername
        }
        
        let xcodeProject = try! projectGenerator.generateXcodeProject(in: workingDir, userName: userName)
        
        //xcodeProject.pbxproj.nativeTargets.first?
        //xcodeProject.pbxproj.targets(named: "macOS").first?.productName = name
        //xcodeProject.pbxproj.buildConfigurations.first!.buildSettings
        try! fw.writePlists()
        //
        
        try! fw.writeXcodeProject(xcodeProject)
        try! await NSWorkspace.shared.open([project.defaultProjectPath.url], withApplicationAt: .applicationDirectory.appendingPathComponent("Xcode.app"), configuration: .init())
    }
    
    
}
