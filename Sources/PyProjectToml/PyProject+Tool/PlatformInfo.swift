//
//  PlatformInfo.swift
//  PSProjectGenerator
//
import Foundation

public enum PlatformType: String, Codable {
    case iphoneos
    case macos
    case android
}


extension PyProjectToml {
    //@MainActor
    public protocol PlatformInfo: Codable, Sendable {
        static var platform_type: PlatformType { get }
        //var bundle_id: String? { get }
        var backends: [String] { get }
        var extra_index: [String] { get }
        
        
    }
    
    public enum AnyPlatformCodingKeys: CodingKey {
        case android
        case ios
        case macos
    }
    
    
}


