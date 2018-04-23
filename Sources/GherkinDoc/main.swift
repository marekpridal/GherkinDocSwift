//
//  main.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 03.04.18.
//

import Foundation

//MARK: Funcs
func makeDoc(with path: URL, platform: Platform) {
    let generator = Generator(pathToSteps: path)
    do {
        let filePath = try generator.generateDocs(for: platform)
        print("File is located at path \(filePath.absoluteString)")
    } catch let e {
        print(e.localizedDescription)
    }
}

//MARK: Main body
if CommandLine.argc == 3 {
    let platformString = CommandLine.arguments[1]
    let pathString = CommandLine.arguments[2]
    if let platform = Platform.getPlatformForFileExtension(URL(fileURLWithPath: pathString).pathExtension) {
        makeDoc(with: URL(fileURLWithPath: pathString), platform: platform)
    } else {
        guard let platform = Platform(rawValue: platformString.lowercased()) else {
            print("⚠️ Unsupported platform, use android or ios identifier")
            exit(1)
        }
        makeDoc(with: URL(fileURLWithPath: pathString), platform: platform)
    }
    exit(0)
} else if CommandLine.argc == 2 {
    let pathString = CommandLine.arguments[1]
    if let platform = Platform.getPlatformForFileExtension(URL(fileURLWithPath: pathString).pathExtension) {
        makeDoc(with: URL(fileURLWithPath: pathString), platform: platform)
    } else {
        print("What's yout platform?")
        guard let platformString = readLine(), let platform = Platform(rawValue: platformString.lowercased()) else {
            print("⚠️ Unsupported platform, use android or ios identifier")
            exit(1)
        }
        makeDoc(with: URL(fileURLWithPath: pathString), platform: platform)
    }
    exit(0)
}

print("What's the path of UITestStepDefinitions file?")
guard let path = readLine() else {
    print("Cannot get path")
    exit(1)
}

if let platform = Platform.getPlatformForFileExtension(URL(fileURLWithPath: path).pathExtension) {
    makeDoc(with: URL(fileURLWithPath: path), platform: platform)
} else {
    print("What's yout platform?")
    guard let platformString = readLine(), let platform = Platform(rawValue: platformString.lowercased()) else {
        print("⚠️ Unsupported platform, use android or ios identifier")
        exit(1)
    }
    makeDoc(with: URL(fileURLWithPath: path), platform: platform)
}

