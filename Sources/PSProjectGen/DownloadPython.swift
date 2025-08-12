//
//  File.swift
//  
//
//  Created by CodeBuilder on 14/01/2024.
//

import Foundation



//
//  PythonDownloader.swift
//  KivySwiftLink
//
//  Created by MusicMaker on 24/11/2021.
//

import Foundation

import PathKit
//import Tarscape

func downloadPython(version: String) async throws -> Path {
	
	guard let url: URL = .init(string: "https://www.python.org/ftp/python/\(version)/Python-\(version).tgz") else { throw CocoaError.error(.fileNoSuchFile)}
	let (data, response) = try await URLSession.shared.data(from: url)
	let tmp = try Path.uniqueTemporary() + "Python-\(version).tgz"
	try tmp.write(data)
	
//	let output = try Path.uniqueTemporary()
//	
//	try unTarDownload(path: tmp, output: output)
//
//	try tmp.delete()
	return tmp
}

func downloadOpenSSL(version: String) async throws -> Path {
	
	guard let url: URL = .init(string: "http://www.openssl.org/source/openssl-\(version).tar.gz") else { throw CocoaError.error(.fileNoSuchFile)}
	print("downloading \(url)")
	let (data, response) = try await URLSession.shared.data(from: url)
	let tmp = try Path.uniqueTemporary() + "openssl-\(version).tar.gz"
	try tmp.write(data)
	print("temporary path is: \n\t\(tmp.string)")
	//	let output = try Path.uniqueTemporary()
	//
	//	try unTarDownload(path: tmp, output: output)
	//
	//	try tmp.delete()
	return tmp
}


func downloadKivyIOS(version: String) async throws -> Path {
	
	guard let url: URL = .init(string: "http://www.openssl.org/source/openssl-\(version).tar.gz") else { throw CocoaError.error(.fileNoSuchFile)}
	print("downloading \(url)")
	let (data, response) = try await URLSession.shared.data(from: url)
	let tmp = try Path.uniqueTemporary() + "openssl-\(version).tar.gz"
	try tmp.write(data)
	print("temporary path is: \n\t\(tmp.string)")
	//	let output = try Path.uniqueTemporary()
	//
	//	try unTarDownload(path: tmp, output: output)
	//
	//	try tmp.delete()
	return tmp
}

//func unTarDownload(path: Path, output: Path) throws {
//	try FileManager.default.extractTar(at: path.url, to: output.url)
//}
