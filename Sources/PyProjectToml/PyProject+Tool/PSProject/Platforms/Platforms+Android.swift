//
//  Platforms+Android.swift
//  PSProjectGenerator
//
//  Created by CodeBuilder on 01/11/2025.
//

extension Tool.PSProject.Platforms {
    
    public struct Android: PyProjectToml.PlatformInfo {
        
        public static var platform_type: PlatformType {.android}
        
        public var package_name: String?
        
        public var backends: [String]
        
        public var extra_index: [String]
        
        public var api: Api?
        
        public var min_api: String?
        
        public var sdk: String?
        
        public var ndk: String?
        
        public var ndk_api: String?
        
    }
}


extension Tool.PSProject.Platforms.Android {
    public enum Api: Int, Codable, Sendable {
        case v34 = 34
        case v35 = 35
        case v36 = 36
    }
}

