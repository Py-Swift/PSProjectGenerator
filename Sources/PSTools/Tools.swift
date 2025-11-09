

import Foundation
@preconcurrency import PathKit




@discardableResult
func pythonScript(_ script: String) -> String {
	let task = Process()
	let pipe = Pipe()
	let inputFile: Path = try! .uniqueTemporary() + "tmp.py"
	try! inputFile.write(script, encoding: .utf8)
	task.standardOutput = pipe
	task.standardError = pipe
	task.arguments = [inputFile.string]
	//task.launchPath = "/usr/local/bin/python3.10"
	task.executableURL = .init(filePath: "/usr/local/bin/python3")
	task.standardInput = nil
	task.launch()
	
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!
	try! inputFile.delete()
	return output
}

@discardableResult
public func gitClone(_ repo: String) -> String {
	let task = Process()
	let pipe = Pipe()
	task.standardOutput = pipe
	task.standardError = pipe
	task.arguments = ["clone", repo]
	task.executableURL = .init(filePath: "/usr/bin/git")
	task.standardInput = nil
	task.launch()
	
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!
	print(output)
	return output
}

func which_pip3() throws -> Path {
    let proc = Process()
    //proc.executableURL = .init(filePath: "/bin/zsh")
    proc.executableURL = .init(filePath: "/usr/bin/which")
    proc.arguments = ["pip3.11"]
    let pipe = Pipe()
    
    proc.standardOutput = pipe
    var env = ProcessInfo.processInfo.environment
    env["PATH"]?.extendedPath()
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

@discardableResult
public func pipInstall(_ requirements: Path, site_path: Path) -> String {
	let task = Process()
	let pipe = Pipe()
	task.standardOutput = pipe
	task.standardError = pipe
	task.arguments = ["install","-r", requirements.string, "-t", site_path.string, "--compile"]
    task.executablePath = try? which_pip3()
	task.standardInput = nil
	task.launch()
	
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!
	print(output)
	return output
}

@discardableResult
func pipInstall(pip: String, site_path: Path) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["install", pip, "-t", site_path.string, "--compile"]
    task.executablePath = try? which_pip3()
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    return output
}


func pipInstall_ios(_ requirements: Path, site_path: Path, platform: String = "ios_13_0_arm64_iphoneos") {
    let task = Process()
    // let pipe = Pipe()
    //task.standardOutput = pipe
    //task.standardError = pipe
    task.arguments = [
        "install",
        "--disable-pip-version-check",
        "--platform=\(platform)",
        "--only-binary=:all:",
        "--extra-index-url",
        "https://pypi.anaconda.org/beeware/simple",
        "--extra-index-url",
        "https://pypi.anaconda.org/pyswift/simple",
        "--target", site_path.string,
        "-r", requirements.string,
        
    ]
    task.executablePath = PyTools.pip3
    task.standardInput = nil
    task.launch()
    task.waitUntilExit()
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8)!
//    print(output)
    //return output
}

@discardableResult
func pipInstall_ios(pip: String, site_path: Path, platform: String = "ios_13_0_arm64_iphoneos") -> String {
    let task = Process()
    let pipe = Pipe()
    //task.standardOutput = pipe
    //task.standardError = pipe
    task.arguments = [
        "install",
        "--disable-pip-version-check",
        "--platform=\(platform)",
        "--only-binary=:all:",
        "--extra-index-url",
        "https://pypi.anaconda.org/beeware/simple",
        "--extra-index-url",
        "https://pypi.anaconda.org/pyswift/simple",
        "--target", site_path.string,
        pip
    ]
    task.executablePath = "/Users/Shared/psproject/python3/bin/pip3"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    return output
}

public enum PyTools {
    public static let hostpython: Path = getHostPython()//"/Users/Shared/psproject/hostpython3"
    public static var pip3: Path { hostpython + "bin/pip3" }
    public static var python3: Path { hostpython + "bin/python3" }
    
    @discardableResult
    public static func pipInstall(pip: String, _ args: String...) -> Int32 {
        let task = Process()
        
        let arguments = [
            "install",
            pip
        ] + args
        
        task.arguments = arguments
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}

public class UVTool {
    
    //@MainActor
    static let shared = UVTool(uv: which.uv)
    
    private let uv: Path
    
    init(uv: Path) {
        self.uv = uv
    }
    
    //@MainActor
    public static func help() {
        let task = Process()
        task.arguments = ["help"]
        task.executablePath = shared.uv
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        
    }
    
    //@MainActor
    public static func Init(path: String, name: String?) {
        let task = Process()
        var arguments: [String] = [
            "init",
            //"--lib", path,
            "--package", name ?? path,
            "--python", "3.13"
        ]
//        if let name {
//            arguments.append(contentsOf: ["--name", name])
//        }
        
        task.arguments = arguments
        task.executablePath = shared.uv
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        
    }
    
    //@MainActor
    @_disfavoredOverload
    public static func export_requirements(project: Path, group: String?) {
        let task = Process()
        var arguments = [
            "export", "--no-hashes",
            "--no-emit-project",
            "--directory", project.string
        ]
        
        if let group {
            arguments.append("--group")
            arguments.append(group)
        }
        arguments.append(contentsOf: ["-o", project.string])
        
        task.arguments = arguments
        task.executablePath = shared.uv
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
    }
    
    //@MainActor
    public static func export_requirements(uv_root: Path, group: String?) -> String {
        let task = Process()
        var arguments = [
            "export", "--no-hashes",
            "--no-emit-project",
            "--no-dev",
            "--directory", uv_root.string
        ]
        
        if let group {
            arguments.append("--group")
            arguments.append(group)
        }
        //arguments.append(contentsOf: ["-o", project.string])
        
        let pipe = Pipe()
        
        task.standardOutput = pipe
        //task.standardError = pipe
        
        task.arguments = arguments
        task.executablePath = shared.uv
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        return output
    }
}
