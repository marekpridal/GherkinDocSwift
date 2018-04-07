//
//  main.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 03.04.18.
//

import Foundation

//MARK: Funcs
func makeDoc(with path: URL) {
    let generator = Generator(pathToSteps: path)
    
    do {
        let filePath = try generator.generateDocs()
        print("File is located at path \(filePath.absoluteString)")
    } catch let e {
        print(e.localizedDescription)
    }
}

//MARK: Main body
if CommandLine.argc == 2 {
    let path = CommandLine.arguments[1]
    makeDoc(with: URL(fileURLWithPath: path))
    exit(0)
}


print("What's the path of UITestStepDefinitions file?")
guard let path = readLine() else {
    print("Cannot get path")
    exit(1)
}

makeDoc(with: URL(fileURLWithPath: path))
