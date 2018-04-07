//
//  StepWithComment.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 04.04.18.
//

import Foundation

struct StepWithComment {
    let step:String
    let comment:String?
    let stepLine:Int?
    let section:PhraseWithLineNumber?
}
