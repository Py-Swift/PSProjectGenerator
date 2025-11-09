
import Foundation
import PathKit
import PSTools

extension Array {
    //@MainActor
    @inlinable public func asyncMap<T, E>(_ transform: (Element) async throws(E) -> T) async throws(E) -> [T] where E : Error {
        var elements = [T]()
        for element in self {
            elements.append(try await transform(element))
        }
        return elements
    }
}

public extension PathKit.Path {
	var isLibA: Bool {
		self.extension == "a"
	}
}





extension URL {
    var asPath: Path {
        .init(path())
    }
}

extension PathKit.Path {

	public init(_ url: URL) {
		self = .init(url.path())
	}
	
	var iphoneos: Self { self + "iphoneos"}
	var iphonesimulator: Self { self + "iphonesimulator"}
}

extension Bundle {
    func path(forResource: String, withExtension: String?) -> Path? {
        url(forResource: forResource, withExtension: withExtension)?.asPath
    }
}



func which_python() throws -> Path {
    let proc = Process()
    //proc.executableURL = .init(filePath: "/bin/zsh")
    proc.executableURL = .init(filePath: "/usr/bin/which")
    proc.arguments = ["python3.11"]
    let pipe = Pipe()
    
    proc.standardOutput = pipe
    let env = ProcessInfo.processInfo.environment
    //env["PATH"]?.extendedPath()
    proc.environment = env
    
    try! proc.run()
    proc.waitUntilExit()
    
    guard
        let data = try? pipe.fileHandleForReading.readToEnd(),
        var path = String(data: data, encoding: .utf8)
    else { fatalError() }
    path.strip()
    return .init(path)
}







extension URL {
    public static var beeware_python_ios: URL {
        .init(string: "https://github.com/beeware/Python-Apple-support/releases/download/3.13-b11/Python-3.13-iOS-support.b11.tar.gz")!
    }
    
    public static var sdl2_frameworks: URL {
        .init(string: "https://anaconda.org/PySwift/kivy-sdl2/2.3.10/download/kivy_sdl2-2.3.10-py3-none-any.whl")!
    }
}
extension Path {
    
    
    public static func ios_python() async throws -> Path {
        let py = ps_support + "Python.xcframework"
        
        if !py.exists {
            if !ps_support.exists {
                try ps_support.mkpath()
            }
            let (file, _) = try await URLSession.download(from: .beeware_python_ios)
            let parent = file.parent()
            let gz = parent + "\(file.lastComponentWithoutExtension).tar.gz"
            try file.move(gz)
            try ps_support.chdir {
                try Process.untar(url: gz)
            }
            
        }
        
        return py
    }
    
    public static func sdl2_frameworks() async throws -> Path {
        let sdl2_frameworks = ps_support + "sdl2_frameworks"
        var download_required = false
        
        for whl in ["SDL2.xcframework", "SDL2_image.xcframework", "SDL2_mixer.xcframework", "SDL2_ttf.xcframework"] {
            let path = sdl2_frameworks + whl
            if !path.exists {
                download_required = true
                break
            }
        }
        if download_required {
            if !sdl2_frameworks.exists {
                try sdl2_frameworks.mkpath()
            }
            
            let (file, _) = try await URLSession.download(from: .sdl2_frameworks)
            let parent = file.parent()
            let gz = parent + "\(file.lastComponentWithoutExtension).whl"
            try file.move(gz)
            try sdl2_frameworks.chdir {
                try Process.untar(url: gz)
            }
            
        }
        
        return sdl2_frameworks
    }
}


