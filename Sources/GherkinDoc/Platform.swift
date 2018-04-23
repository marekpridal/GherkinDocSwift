//
//  Platform.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 23.04.18.
//

import Foundation

enum Platform: String {
    case Android = "android"
    case iOS = "ios"
    
    static func getPlatformForFileExtension(_ pathExtension:String) -> Platform? {
        switch pathExtension.lowercased()
        {
        case "java":
            return .Android
        case "swift":
            return .iOS
        default:
            return nil
        }
    }
}
