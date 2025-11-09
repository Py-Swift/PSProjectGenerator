//
//  Tool.swift
//  PSProjectGenerator
//
//  Created by CodeBuilder on 01/11/2025.
//


//
//  PyProject+Tool.swift
//  PSProjectGenerator
//
import Foundation


public struct Tool: Decodable {
    public let uv: UV?
    public let psproject: PSProject?
    
}


extension Tool {
    public struct UV: Decodable {
        
        public let sources: Sources?
        
        public struct Sources: Decodable {
            
        }
    }
}
