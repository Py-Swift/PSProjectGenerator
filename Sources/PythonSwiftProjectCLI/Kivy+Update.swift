//
//  Kivy+Update.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 20/06/2025.
//

import ArgumentParser
import PathKit
import PSProjectUpdate
import PSProjectGen

extension PythonSwiftProjectCLI.Kivy {
    struct Update: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration = .init(subcommands: [
            Pip.self
        ])
        
    }
}

extension PythonSwiftProjectCLI.Kivy.Update {
    struct Pip: AsyncParsableCommand {
        static var configuration: CommandConfiguration = .init(subcommands: [
            Install.self,
            Uninstall.self
        ])
    }
}

extension PythonSwiftProjectCLI.Kivy.Update.Pip {
    struct Install: AsyncParsableCommand {
        @Option(name: .shortAndLong) var project: Path?
        @Option(name: .long) var platform: [KivyProject.Platform] = [.ios, .macos]
        @Option(name: .shortAndLong) var requirement: Path?
        @Flag(name: .long) var upgrade: Bool = false
        @Argument var pip: String?
        func run() async throws {
            guard let project else { return }
            let xc_proj = try ProjectUpdater(path: project, platforms: platform)
            if let requirement {
                for plat in platform {
                    try xc_proj.pip_install(target: plat, requirement: requirement, upgrade: upgrade)
                }
            } else {
                guard let pip else {
                    print("no pip name argument")
                    return
                }
                for plat in platform {
                    try xc_proj.pip_install(target: plat, pip: pip, upgrade: upgrade)
                }
            }
        }
    }
    
    struct Uninstall: AsyncParsableCommand {
        @Option(name: .shortAndLong) var project: Path?
        @Option(name: .long) var platform: [KivyProject.Platform] = [.ios, .macos]
        @Argument var pip: String
        func run() async throws {
            guard let project else { return }
            let xc_proj = try ProjectUpdater(path: project, platforms: platform)
            for plat in platform {
                try xc_proj.pip_uninstall(target: plat, pip: pip)
            }
        }
    }
}
