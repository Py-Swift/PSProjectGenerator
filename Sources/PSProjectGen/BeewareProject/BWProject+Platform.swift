//
//  BWProject+Platform.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 03/08/2025.
//

import PathKit
import Foundation
import PSTools
import SwiftCPUDetect


public extension BWProject {
    
    
    
    final class Platform {
        var arch: Arch
        var sdk: SDK
        var type: PlatformType
        
        init(arch: Arch, sdk: SDK, type: PlatformType) {
            self.arch = arch
            self.sdk = sdk
            self.type = type
        }
    }
}

extension BWProject.Platform {
    
    public var wheel_platform: String {
        switch sdk {
            
        case .iphoneos:
            "ios_13_0"
        case .iphonesimulator:
            "ios_13_0"
        case .macos:
            "macosx_10_15"
        }
    }
    
    public var platform_site: String {
        "site_packages.\(sdk)"
    }
    
    func site_path(root: Path) -> Path {
        root + platform_site
    }
    
    
    
}
