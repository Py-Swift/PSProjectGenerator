//
//  Platform+macOS.swift
//  PSProjectGenerator
//
import PathKit


extension Tool.PSProject.Platforms {
    public struct macOS: PyProjectToml.PlatformInfo {
        public static var platform_type: PlatformType { .macos }
        
        public var bundle_id: String?
        
        public var backends: [String]
        
        public var extra_index: [String]
        
        private enum CodingKeys: CodingKey {
            case bundle_id
            case backends
            case extra_index
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.bundle_id = try container.decodeIfPresent(String.self, forKey: .bundle_id)
            self.backends = try container.decodeIfPresent([String].self, forKey: .backends) ?? []
            self.extra_index = try container.decodeIfPresent([String].self, forKey: .extra_index) ?? []
            
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(self.bundle_id, forKey: .bundle_id)
            try container.encodeIfPresent(self.backends, forKey: .backends)
            try container.encodeIfPresent(self.extra_index, forKey: .extra_index)
        }
        
        public func get_project_root(root: Path) -> Path {
            root + "platform_dists/iphone_macos/xcode"
        }
    }
}
