//
//  IphoneOSWheelSources.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 26/07/2025.
//
import Foundation
import PathKit
import Zip

//@MainActor
public class IphoneosWheelSources {
    
    //@MainActor
    public static let shared: IphoneosWheelSources = .init()
    
    public struct PackageData: Decodable, Sendable {
        public let name: String
        public let id: String
        public let package_types: [String]
        
        public let versions: [String]
        
        public let files: [Release]
        
    }
    
    public struct Release: Decodable, Sendable {
        public let basename: String
        
        public let attrs: Attrs
        public let download_url: String
        public let version: String
        
        public struct Attrs: Decodable, Sendable {
            public let abi: String?
            public let python_version: String
            public let packagetype: String
        }
        
        public var url: URL {
            .init(string: "https:\(download_url)")!
        }
        
        public func install(to path: Path) async throws {
            let _url = url
            let url_req = URLRequest(url: _url)
            print("downloading wheel: \(_url)")
            let (url, _) = try await URLSession.shared.download(for: url_req)
            let dl = Path(url.path())
            let new = dl.parent() + "test.zip"
            try? dl.move(new)
            print("extracting to: \(path)")
            try Zip.unzipFile(new.url, destination: path.url, overwrite: true, password: nil)
            try new.delete()
        }
    }
}

extension IphoneosWheelSources {
    public protocol WheelSource: Hashable, RawRepresentable, Sendable {
        var baseURL: URL { get }
        var rawValue: String { get }
    }
}

extension IphoneosWheelSources {
    
    public enum beeware_wheels: String, CaseIterable, WheelSource, Hashable {
        case aiohttp
        case argon2_cffi = "argon2-cffi"
        case backports = "backports.zoneinfo"
        case bcrypt
        case bitarray
        case Brotli
        case bzip2
        case cffi
        case contourpy
        case coverage
        case cryptography
        case cymem
        case cytoolz
        case editdistance
        case ephem
        case freetype
        case frozenlist
        case gensim
        case greenlet
        case kiwisolver
        case libffi
        case libjpeg
        case libpng
        case lru_dict = "lru-dict"
        case matplotlib
        case multidict
        case murmurhash
        case netifaces
        case ninja
        case numpy
        case openssl
        case pandas
        case pillow = "Pillow"
        case preshed
        case pycrypto
        case pycurl
        case pynacl = "PyNaCl"
        case pysha3
        case pywavelets = "PyWavelets"
        case pyzbar
        case regex
        case ruamel_yaml_clib = "ruamel.yaml.clib"
        case scandir
        case spectrum
        case srsly
        case statsmodels
        case twisted = "Twisted"
        case typedast = "typed-ast"
        case typed_ast
        case ujson
        case wordcloud
        case xz
        case yarl
        case zstandard
        
        public var baseURL: URL {
            URL(string: "https://api.anaconda.org/package/beeware/\(rawValue)")!
        }
    }
    
    public enum pyswift_wheels: String, CaseIterable, WheelSource, Hashable {
        case bcrypt
        case bitarray
        case brotli = "Brotli"
        case cffi
        case cryptography
        case ios
        case kivy = "Kivy"
        case kivy_sdl2 = "kivy-sdl2"
        case lru_dict = "lru-dict"
        case materialyoucolor
        case matplotlib
        case numpy
        case pycryptodome
        case pydantic_core
        case pyobjus
        
        
        public var baseURL: URL {
            URL(string: "https://api.anaconda.org/package/PySwift/\(rawValue)")!
        }
    }
    
    
    public func extract(whl: Path, to path: Path) throws {
        try Zip.unzipFile(whl.url, destination: path.url, overwrite: true, password: nil)
    }
    
    public func all_wheels(sdk: BWProjectTarget.Target_SDK? = nil) -> [String] {
        var wheels = [String]()
        wheels.append(contentsOf: beeware_wheels.allCases.map(\.rawValue.localizedLowercase))
        wheels.append(contentsOf: pyswift_wheels.allCases.map(\.rawValue.localizedLowercase))
        wheels = wheels.uniqued()
        return wheels.sorted()
    }
    
    public func all_wheels(sdk: BWProjectTarget.Target_SDK) async throws -> [any WheelSource] {
        var wheel_srcs = [any WheelSource]()
        wheel_srcs.append(contentsOf: pyswift_wheels.allCases)
        
        for whl in beeware_wheels.allCases {
            if !wheel_srcs.contains(where: {$0.rawValue == whl.rawValue }) {
                wheel_srcs.append(whl)
            }
        }
        return wheel_srcs
    }
    
    public func all_wheels(sdk: BWProjectTarget.Target_SDK) async throws -> [PackageData] {
        
        let packages: [PackageData] = try await all_wheels(sdk: .iphoneos).asyncMap({try await $0.packageData()})
        
        
        return packages.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
    }
}


extension IphoneosWheelSources.WheelSource {
    func packageData() async throws -> Data {
        let request = URLRequest(url: baseURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    public func packageData() async throws -> IphoneosWheelSources.PackageData {
        try JSONDecoder().decode(
            IphoneosWheelSources.PackageData.self,
            from: try await packageData()
        )
    }
}



