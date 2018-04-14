//
//  HtmlMaker.swift
//  GherkinDoc
//
//  Created by Marek Přidal on 04.04.18.
//

import Foundation

struct HtmlMaker {
    
    private let bootstrap = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    private let style:String
    
    init() {
        var isDirectory = ObjCBool(booleanLiteral: true)
        if !FileManager.default.fileExists(atPath: FileManager.default.currentDirectoryPath + "/doc", isDirectory: &isDirectory) {
            try! FileManager.default.createDirectory(atPath: FileManager.default.currentDirectoryPath + "/doc", withIntermediateDirectories: false, attributes: nil)
        }
        try! """
        .navbar.navbar-default {
            margin-top: 2%;
        }
        .steps {
            margin-left: 1%;
        }
        .undocumentedStep {
            color: grey;
        }
        """.write(toFile:  FileManager.default.currentDirectoryPath + "/doc/style.css", atomically: true, encoding: .utf8)
        style =  FileManager.default.currentDirectoryPath + "/doc/style.css"
    }
    
    func generateHtml(with sections:[SectionWithSteps])throws -> URL {
        try sections.forEach { (section) in
            var html = "<html>"
            html += getHead()
            html += getBody(for: section, availableSectionsForNavigation: sections)
            html += "</html>"
            try html.write(toFile:  FileManager.default.currentDirectoryPath + "/doc/\(section.name).html", atomically: true, encoding: .utf8)
        }
        try (getHead() + getBody(for: nil, availableSectionsForNavigation: sections)).write(toFile:  FileManager.default.currentDirectoryPath + "/doc/index.html", atomically: true, encoding: .utf8)
        return URL(string: FileManager.default.currentDirectoryPath + "/doc/index.html")!
    }
    
    private func getHead() -> String {
        return """
        <head>
        <meta charset="utf-8"><!--kódování-->
        <meta name="theme-color" content="#db5945"> <!--Změna barvy tabu v android google chrome-->
        <meta name="viewport" content="width=device-width, initial-scale=1"><!--přizpůsobení velikosti pro mobil-->
        <meta name="description" content="Popis"/><!--popis-->
        <title>GherkinDoc</title><!--název-->
        <link rel="stylesheet" href="\(style)" type="text/css"><!--styl-->
        <link rel="stylesheet" href="\(bootstrap)"><!--bootstrap-->
        <link rel="icon" sizes="192x192" href="icon.png"><!--ikona-->
        <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
        </head>
        """
    }
    
    private func getScripts() -> String {
        return """
        <script>
        function copyToClipboard(text) {
        var $temp = $("<input>");
        $("body").append($temp);
        $temp.val(text).select();
        document.execCommand("copy");
        $temp.remove();
        alert("Step " + text + " is now in clipboard");
        }
        </script>
        """
    }
    
    private func getBody(for section:SectionWithSteps?, availableSectionsForNavigation:[SectionWithSteps]) -> String {
        return """
        <body>
        <div class="container">
        \(getNavigation(for: availableSectionsForNavigation))
        \(getSteps(for: section))
        \(getScripts())
        </div>
        </body>
        """
    }
    
    private func getSteps(for section:SectionWithSteps?) -> String {
        var steps = ""
        section?.steps.forEach { (step) in
            steps += "<h3>\(step.step)</h3>\n"
            if let comment = step.comment {
                steps += "<p>\(comment)</p>"
            } else {
                steps += "<p class=\"undocumentedStep\">\("Step has no comment")</p>"
            }
            steps += "<button onclick=\"copyToClipboard('\(step.step)')\">Copy step to clipboard</button>"
        }
        return """
        <section>
        <article class="steps">
        \(steps)
        </article>
        </section>
        """
    }
    
    private func getNavigation(for sections:[SectionWithSteps]) -> String {
        var navigation = ""
        sections.forEach { (section) in
            navigation += "<li class=\"navigace-button\"><a href=\"\(section.name).html\">\(section.name)</a></li>"
        }
        
        return """
        <nav class="navbar navbar-default">
        <div class="container-fluid">
        <!-- Brand and toggle get grouped for better mobile display -->
        <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
        <span class="sr-only">Otevřít navigaci</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="index.html">GherkinDoc</a>
        </div>
        
        <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
        <ul class="nav navbar-nav navbar-right">
        \(navigation)
        </ul>
        </div><!-- /.navbar-collapse -->
        </div><!-- /.container-fluid -->
        </nav>
        """
    }
}
