//
//  InsightforgeXTests.swift
//  InsightforgeXTests
//
//  Created by Srivastava, Abhisht on 31/05/24.
//

import XCTest

final class InsightforgeXTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        let app = XCUIApplication()
        let usernameTextField = app.textFields["name@example.com"]
        usernameTextField.tap()
        usernameTextField.typeText("abhisht@sap.com")
        let passwordSecureTextField = app.secureTextFields["enter password"]
                passwordSecureTextField.tap()
                passwordSecureTextField.typeText("12345678")
        let buttons = app.buttons.allElementsBoundByIndex
                buttons[0].tap()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
