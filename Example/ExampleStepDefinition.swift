
import XCTest
import XCTest_Gherkin

final class UITestStepDefinitions: StepDefiner {
    
    override func defineSteps() {
        
        let app = XCUIApplication()
        
        //MARK: Common
        /* Launch the app app */
        step("I have launched app") {
            app.launch()
            while app.activityIndicators.firstMatch.exists {
                //wait
            }
        }
        
        /* Choose button with given identifier */
        step("I tap on (.*) button") {
            (matches: [String]) in
            
            XCTAssertTrue(matches.count > 0, "Should have been more than 0")
            
            guard let identifier = matches.first else {
                XCTAssertTrue(false, "Cannot get button indetifier name")
                return
            }
            
            while !app.buttons[identifier].exists && !app.cells[identifier].exists && !app.otherElements[identifier].exists && !app.textViews[identifier].exists && !app.textFields[identifier].exists {
                app.swipeUp()
            }
            
            if app.buttons[identifier].exists {
                app.buttons[identifier].tap()
            } else if app.cells[identifier].exists {
                app.cells[identifier].tap()
            } else if app.textViews[identifier].exists {
                app.textViews[identifier].tap()
            } else if app.textFields[identifier].exists {
                app.textFields[identifier].tap()
            } else if app.otherElements[identifier].exists {
                app.otherElements[identifier].tap()
            } else {
                XCTAssert(false, "Cannot found button or cell with identifier \(identifier)")
            }
            
            while app.activityIndicators.firstMatch.exists {
                //wait
            }
        }
        
        /* Check if navigation bar has given title */
        step("I am on screen (.*)") {
            (matches: [String]) in
            guard let title = matches.first else {
                XCTAssertTrue(false, "Cannot get string from step")
                return
            }
            
            XCTAssert(app.navigationBars[title].exists, "I am not on \(title) screen ‼️")
        }
        
        /* Bot is waiting for given amount of time */
        step("I wait for (.*) seconds") {
            (matches: [Double]) in
            
            guard let timeout = matches.first else {
                XCTAssert(false, "Cannot get Double from step")
                return
            }
            
            _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait...")], timeout: timeout)
        }
        
        //MARK: Login
        /* Insert text into secure text field (probably password) */
        step("I insert password (.*)") {
            (matches: [String]) in
            
            guard let password = matches.first else {
                XCTAssert(false, "Cannot get String from step")
                return
            }
            
            XCTAssert(app.secureTextFields[AccessibilityIdOnlinePairedPassword].exists, "Cannot found login input, check if backend is running and app is paired")
            app.secureTextFields[AccessibilityIdOnlinePairedPassword].tap()
            
            XCTAssert(app.keys["delete"].exists, "Cannot found delete button on virtual keyboard, check if is visible")
            app.keys["delete"].tap()
            
            app.secureTextFields[AccessibilityIdOnlinePairedPassword].typeText(password)
        }
        
        /* Check if you are on login screen */
        step("I am on Login screen") {
            (matches: [String]) in
            
            XCTAssert(app.isDisplayingLogin, "Not on Login screen")
        }
        
        /* Clear secure text field with given identifier */
        step("I clear secure text field with identifier (.*)") {
            (matches: [String]) in
            
            guard let identifier = matches.first else {
                XCTAssert(false, "Cannot get String from step")
                return
            }
            
            app.secureTextFields[identifier].tap()
            XCTAssert(app.keys["delete"].exists, "Cannot found delete key on keyboard. Check if virtual keyboard is active")
            app.keys["delete"].tap()
        }
    }
}
