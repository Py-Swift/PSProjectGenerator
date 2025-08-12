//
//  PSProjectUpdate.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 20/06/2025.
//
import XcodeProj
import PathKit
import Foundation
import PSProjectGen

//func get_site_packages(pbxproj: PBXProj, platforms: [KivyProject.Platform]) -> [PBXFileElement] {
//    let sites = pbxproj.groups.compactMap { group in
//        group.children.first { file in
//            file.path == "site-packages"
//        }
//    }
//    return sites
//    let filtered_sites = sites.filter { site in
//        platforms.contains { plat in
//            site.parent?.parent?.path?.lowercased().hasSuffix(plat.rawValue) ?? false
//        }
//    }
//    
//    
//    return filtered_sites
//}

//public class ProjectUpdater {
//    
//    let root: Path
//    var context: XcodeProj
//    let pbxproj: PBXProj
//    let platforms: [KivyProject.Platform]
//    
//    public init(path: Path, platforms: [KivyProject.Platform]) throws {
//        root = path.absolute()
//        let xcodeproj = path + "\(path.lastComponent).xcodeproj"
//        self.context = try .init(path: xcodeproj)
//        pbxproj = context.pbxproj
//        self.platforms = platforms
//        let sites = site_packages
//        
//        
//    }
//    
//    var site_packages: [PBXFileElement] {
//        get_site_packages(pbxproj: pbxproj, platforms: platforms)
//    }
//    
//    public func pip_install(target: KivyProject.Platform = .ios, pip: String, upgrade: Bool = false) throws {
//        let site_path: String
//        if site_packages.count > 1 {
//            guard
//                let site = site_packages.first(where: { pbx in
//                    
//                    pbx.parent?.parent?.path?.lowercased().hasSuffix(target.rawValue ) ?? false
//                    
//                }),
//                let _site_path = try site.fullPath(sourceRoot: "/")
//            else { return }
//            site_path = String(_site_path.dropFirst())
//        } else {
//            guard
//                let site = site_packages.first,
//                let _site_path = try site.fullPath(sourceRoot: "/")
//            else {return}
//            site_path = String(_site_path.dropFirst())
//        }
//        
//        
//        //print(site_path)
//        
//        guard let python = Process.which("python3.11") else {
//            print("couldnt find any python 3.11")
//            return
//        }
//        //print(python)
//        
//        guard let py_version = Process.py_version(.init(filePath: python)) else {
//            print("error getting python version")
//            return
//        }
//        guard py_version == "Python 3.11.6" else {
//            print("wrong python version", py_version)
//            return
//        }
//        //print("root:",root)
//        pipInstall(pip, site_path: (root + site_path), upgrade: upgrade)
//        //Process.pip_install(.init(filePath: python), pips: [pip], target: site_path)
//    }
//    
//    public func pip_install(target: KivyProject.Platform = .ios, requirement: Path, upgrade: Bool = false) throws {
//        let site_path: String
//        if site_packages.count > 1 {
//            guard
//                let site = site_packages.first(where: { pbx in
//                    
//                    pbx.parent?.parent?.path?.lowercased().hasSuffix(target.rawValue ) ?? false
//                    
//                }),
//                let _site_path = try site.fullPath(sourceRoot: "/")
//            else { return }
//            site_path = String(_site_path.dropFirst())
//        } else {
//            guard
//                let site = site_packages.first,
//                let _site_path = try site.fullPath(sourceRoot: "/")
//            else {return}
//            site_path = String(_site_path.dropFirst())
//        }
//        
//        
//        //print(site_path)
//        
//        guard let python = Process.which("python3.11") else {
//            print("couldnt find any python 3.11")
//            return
//        }
//        //print(python)
//        
//        guard let py_version = Process.py_version(.init(filePath: python)) else {
//            print("error getting python version")
//            return
//        }
//        guard py_version == "Python 3.11.6" else {
//            print("wrong python version", py_version)
//            return
//        }
//        //print("root:",root)
//        pipInstall(requirements: requirement, site_path: root + site_path, upgrade: upgrade)
//        //Process.pip_install(.init(filePath: python), pips: [pip], target: site_path)
//    }
//    
//    public func pip_uninstall(target: KivyProject.Platform = .ios, pip: String) throws {
//        let site_path: String
//        if site_packages.count > 1 {
//            guard
//                let site = site_packages.first(where: { pbx in
//                    
//                    pbx.parent?.parent?.path?.lowercased().hasSuffix(target.rawValue ) ?? false
//                    
//                }),
//                let _site_path = try site.fullPath(sourceRoot: root.string)
//            else { return }
//            site_path = _site_path
//        } else {
//            guard
//                let site = site_packages.first,
//                let _site_path = try site.fullPath(sourceRoot: root.string)
//            else {return}
//            site_path = _site_path
//        }
//        
//        
//        print("site_path:", site_path)
//        
//        guard let python = Process.which("python3.11") else {
//            print("couldnt find any python 3.11")
//            return
//        }
//        print(python)
//        
//        guard let py_version = Process.py_version(.init(filePath: python)) else {
//            print("error getting python version")
//            return
//        }
//        guard py_version == "Python 3.11.6" else {
//            print("wrong python version", py_version)
//            return
//        }
//        pipUninstall(pip, site_path: .init(site_path))
//        //Process.pip_install(.init(filePath: python), pips: [pip], target: site_path)
//    }
//}
