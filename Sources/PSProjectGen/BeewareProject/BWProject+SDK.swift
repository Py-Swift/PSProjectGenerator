//
//  BWProjeft+SDK.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 03/08/2025.
//

import PathKit
import Foundation


extension BWProject {
    public enum SDK: String, CustomStringConvertible {
        case iphoneos
        case iphonesimulator
        case macos
        
        public var description: String { rawValue }
        
    }
}
