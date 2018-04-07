//
//  Generator.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 03.04.18.
//

import Foundation

class Generator {

    private let fileManager = FileManager.default
    
    private var steps:[PhraseWithLineNumber] = []
    private var comments:[PhraseWithLineNumber] = []
    private var sections:[PhraseWithLineNumber] = []
    
    private var stepsWithComments:[StepWithComment] = []
    private var stepsWithSections:[SectionWithSteps] = []
    
    ///Path to gherkin steps
    private let path:URL

    /**
    Required constructor for init Generator instance
     
     - parameters:
        - pathToSteps: Path to gherkin steps which will be used for doc generating
    */
    required init(pathToSteps: URL) {
        self.path = pathToSteps
    }
    
    /**
     Method tries to generate docs file and returns path to it
     
     - returns:
    Path to generated docs - Optional
     */
    func generateDocs()throws -> URL {
        
        let contentOfFile = try String(contentsOf: path)
    
        getParsedComments(for: contentOfFile).forEach { (value) in
            comments.append(PhraseWithLineNumber(phrase: value.replacingOccurrences(of: "\n", with: ""), lineNumber: nil))
        }
        
        getParsedSteps(for: contentOfFile).forEach { (value) in
            steps.append(PhraseWithLineNumber(phrase: value.replacingOccurrences(of: "\n", with: ""), lineNumber: nil))
        }
        
        getParsedSections(for: contentOfFile).forEach { (value) in
            sections.append(PhraseWithLineNumber(phrase: value.replacingOccurrences(of: "\n", with: ""), lineNumber: nil))
        }
        
        steps = getLinesWithLineCount(contentOfFile: contentOfFile, lines: steps).sorted{ $0.lineNumber ?? 0 < $1.lineNumber ?? 0 }
        comments = getLinesWithLineCount(contentOfFile: contentOfFile, lines: comments).sorted{ $0.lineNumber ?? 0 < $1.lineNumber ?? 0 }
        sections = getLinesWithLineCount(contentOfFile: contentOfFile, lines: sections.map{ PhraseWithLineNumber(phrase: "//MARK: \($0.phrase)", lineNumber: $0.lineNumber) }).map{ PhraseWithLineNumber(phrase: $0.phrase.replacingOccurrences(of: "//MARK: ", with: ""), lineNumber: $0.lineNumber) }.sorted{ $0.lineNumber ?? 0 < $1.lineNumber ?? 0 }
        
        stepsWithComments = getStepsWithComments(steps: steps, comments: comments, sections: sections)
        
        stepsWithSections = getSections(stepsWithComments: stepsWithComments, sections: sections).map{ SectionWithSteps(name: $0.name,steps: $0.steps.map{ StepWithComment(step: $0.step.replacingOccurrences(of: "(.*)", with: "VALUE"), comment: $0.comment, stepLine: $0.stepLine, section: $0.section) }, line: $0.line) }
        print(comments.count < steps.count ? "\n⚠️ Some steps are missing comments\n" : "")
        print("Number of steps \(steps.count)\n")
        print("Undocumented steps \(steps.count - comments.count)" + " " + (steps.count - comments.count == 0 ? "👍" : "👎"))
        if steps.count - comments.count > 0 {
            stepsWithComments.filter{ $0.comment == nil }.map{ ($0.step,$0.stepLine) }.forEach{ print("Step \($0.0) on line \($0.1 ?? 0) is undocumented") }
        }
        print("\n")
        return try HtmlMaker().generateHtml(with: stepsWithSections)
    }
    
    private func getSections(stepsWithComments:[StepWithComment], sections: [PhraseWithLineNumber]) -> [SectionWithSteps] {
        return sections.map({ (section) -> SectionWithSteps in
            return SectionWithSteps(name: section.phrase, steps: stepsWithComments.filter{ $0.section?.phrase == section.phrase }, line: section.lineNumber)
        })
    }
    
    private func getStepsWithComments(steps:[PhraseWithLineNumber], comments: [PhraseWithLineNumber], sections: [PhraseWithLineNumber]) -> [StepWithComment] {
        return steps.map{
            (phrase) -> StepWithComment in
            return StepWithComment(step: phrase.phrase, comment: comments.first(where: { (phrase.lineNumber ?? -1) - ($0.lineNumber ?? 0) < 3 && (phrase.lineNumber ?? -1) - ($0.lineNumber ?? 0) > 0 })?.phrase, stepLine: phrase.lineNumber, section: sections.filter{ $0.lineNumber ?? 0 < phrase.lineNumber ?? 0 }.last)
        }
    }
    
    private func getLinesWithLineCount(contentOfFile:String, lines:[PhraseWithLineNumber]) -> [PhraseWithLineNumber] {
        var lineNumber = 0
        var result:[PhraseWithLineNumber] = lines
        
        contentOfFile.enumerateLines { (line, _) in
            lineNumber += 1
            result = result.map{ line.contains($0.phrase) ? PhraseWithLineNumber(phrase: $0.phrase, lineNumber: lineNumber) : $0 }
        }
        
        return result
    }
    
    private func getParsedSteps(for fileContent:String) -> [String] {
        return matches(for: "step(.*)", in: fileContent).map{ matches(for: "\".*\"", in: $0).first }.filter{ !($0?.isEmpty ?? true) }.compactMap{ $0?.replacingOccurrences(of: "\"", with: "") }
    }
    
    private func getParsedComments(for fileContent:String) -> [String] {
        return matches(for: "/\\*(.*)\\*/", in: fileContent).compactMap{ $0.replacingOccurrences(of: "/* ", with: "").replacingOccurrences(of: " */", with: "") }
    }
    
    private func getParsedSections(for fileContent:String) -> [String] {
        return matches(for: "//MARK: (.*)\n", in: fileContent).compactMap{ $0.replacingOccurrences(of: "//MARK: ", with: "") }
    }

    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
