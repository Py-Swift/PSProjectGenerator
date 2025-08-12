//
//  File.swift
//  
//
//  Created by CodeBuilder on 10/10/2023.
//

import Foundation
import SwiftSyntax
//import SwiftSyntaxParser
import SwiftParser
import SwiftSyntaxBuilder

private func addPythonSwiftImport(_ import_name: String, _ module_name: String) -> ExprSyntax {
//	let memberAccessExpr = MemberAccessExprSyntax(dot: .periodToken(), name: .identifier("init"))
//	let tuple: TupleExprElementList =  .init([
//		.init(label: .identifier("name"), expression: IdentifierExprSyntax(stringLiteral: "corebluetooth")),
//		.init(label: "name", expression: .init(stringLiteral: "PyInit_corebluetooth"))
//	])
	//return FunctionCallExprSyntax(calledExpression: memberAccessExpr, argumentList: tuple)
    return .init(ExprSyntax(stringLiteral: ".init(name: \"\(import_name)\", module: \(module_name).py_init)"))
        .with(\.leadingTrivia ,.newline + .tab)
	return .init(ExprSyntax(stringLiteral: ".init(name: \"\(module_name)\", module: PyInit_\(module_name))"))
		.with(\.leadingTrivia ,.newline + .tab)
//	fatalError()
}

private func add_PySwiftImport(name: String) -> ExprSyntax {
    return .init(MemberAccessExprSyntax(leadingTrivia: .newline + .tab ,period: .periodToken(), name: .identifier(name)))
}

public func ModifyMainFile(source: String, imports: [SwiftPackageData.PythonImport]) -> String {
//public func ModifyMainFile(source: String, imports: [String], pyswiftProducts: [String]) -> String {
	let parse = Parser.parse(source: source)
	var export: [CodeBlockItemListSyntax.Element] = []
//	var productImports: [ImportDeclSyntax] = pyswiftProducts.map { p in
//		return .init(path: .init([.init(name: .identifier(p))]))
//	}
	for stmt in parse.statements {
		let item = stmt.item
		//print()
		//print(item.kind)
		
		switch item.kind {
		case .variableDecl:
			var variDecl = item.as(VariableDeclSyntax.self)!
			//print(variDecl.modifiers)
			var binding = variDecl.bindings.first!
			//print(binding.typeAnnotation!)
			if
				let id = binding.pattern.as(IdentifierPatternSyntax.self),
				
				let initializer = binding.initializer,
				id.identifier.text == "pythonSwiftImportList"
			{
                imports.forEach { imp in
					export.append(
                        .init( leadingTrivia: .newline, item: .decl(.init(stringLiteral: "import \(imp.product)")) )
					)
				}
				if var arrayExpr = initializer.value.as(ArrayExprSyntax.self) {
					var elements = arrayExpr.elements.map(\.expression)
					
					for _imp in imports {
                        let imp = _imp.import_name ?? _imp.product.lowercased()
                        if imp.hasPrefix(".") {
                            elements.append(add_PySwiftImport(name: .init(imp.dropFirst())))
                        } else {
                            if let module = _imp.module {
                                elements.append(addPythonSwiftImport(imp, module))
                            }
                        }
					}
					
					arrayExpr.elements = .init(elements.map({ .init(expression: $0, trailingComma: .commaToken()) }))
					binding.initializer = .init(value: arrayExpr.with(\.leadingTrivia ,.space))
					variDecl.bindings = .init([binding])
					
					export.append(
						.init( leadingTrivia: .newline, item: .decl(.init(variDecl)) )
					)
				}
			} else {
				export.append(stmt)
			}

		default: export.append(stmt)
		}

	}

	return SourceFileSyntax(statements: .init(export), endOfFileToken: .endOfFileToken()).description
}


func macOS_MainFile() -> String {"""

import Foundation
import KivyLauncher
import PySwiftObject

let pythonSwiftImportList: [PySwiftModuleImport] = [
    
]

let extra_pip_folders: [URL] = [
    
]


func main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> Int32 {
    print("running main")
    //Bundle.module
    var ret: Int32 = 0
    
    do {
        let kivy = try KivyLauncher(
            site_packages: Bundle.main.url(forResource: "site-packages", withExtension: nil)!,
            site_paths: extra_pip_folders,
            pyswiftImports: pythonSwiftImportList
        )
        
        #if DEBUG
        kivy.KIVY_CONSOLELOG = true
        #endif
        
        //python.prog = PyCoreBluetooth.main_py.path
        
        kivy.setup()
        
        // overrite env values
        //kivy.env.KIVY_GL_BACKEND = "sdl2"
        
        kivy.start()
        
        ret = try kivy.run_main(argc, argv)
    } catch let err {
        print(err.localizedDescription)
    }
    
    return ret
    
}
var argc: [UnsafeMutablePointer<CChar>?] = []
_ = main(0, &argc)


"""}
