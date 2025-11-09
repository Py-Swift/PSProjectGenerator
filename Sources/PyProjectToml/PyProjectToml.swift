//
//  PyProjectToml.swift
//  PSProjectGenerator
//
//  Created by CodeBuilder on 01/11/2025.
//
import PathKit
import TOMLKit

public final class PyProjectToml: Decodable {
    
    public let project: Project
    //public let pyswift: PySwift
    public let dependency_groups: [String: [String]]?
    public let tool: Tool?
    public var root: Path?
    
    enum CodingKeys: String, CodingKey {
        case project
        case pyswift
        case dependency_groups = "dependency-groups"
        case tool
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<PyProjectToml.CodingKeys> = try decoder.container(keyedBy: PyProjectToml.CodingKeys.self)
        self.project = try container.decode(Project.self, forKey: .project)
        //self.project = try container.decodeIfPresent(PyProjectToml.PyProject.self, forKey: PyProjectToml.CodingKeys.project)
        //self.pyswift = try container.decode(PyProjectToml.PySwift.self, forKey: PyProjectToml.CodingKeys.pyswift)
        self.dependency_groups = try container.decodeIfPresent([String : [String]].self, forKey: .dependency_groups)
        self.tool = try container.decodeIfPresent(Tool.self, forKey: .tool)
        
    }
    
    public var app_src_name: String {
        project.name.resolved_name
    }
    
    public func app_src(root: Path) -> Path {
        root + "src/\(app_src_name)"
    }
}

public extension String {
    var resolved_name: Self { self.replacing("-", with: "_") }
}

public extension Path {
    func loadPyProjectToml() throws -> PyProjectToml {
        try TOMLDecoder().decode(PyProjectToml.self, from: try read())
    }
    
    var last_resolved: Self {
        parent() + (lastComponent.resolved_name)
    }
}
