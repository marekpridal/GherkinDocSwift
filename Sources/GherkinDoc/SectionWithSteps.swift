//
//  SectionWithSteps.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 04.04.18.
//

import Foundation

struct SectionWithSteps {
    let name:String
    let steps:[StepWithComment]
    let line:Int?
}
