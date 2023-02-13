//
//  EmailValidatorTests.swift
//  nanameueTests
//
//  Created by Volnov Ivan on 13/02/2023.
//

@testable import nanameue
import XCTest

final class EmailValidatorTests: XCTestCase {
    
    var sut: EmailValidator!

    override func setUpWithError() throws {
        sut = EmailValidator()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testValidatorReturnTrue_whenEmailIsValid() throws {
        /// Given
        let email = "example@mail.com"
        /// when
        let isValid = sut.isValid(text: email)
        /// then
        XCTAssertTrue(isValid)
    }
    
    func testValidatorReturnFalse_whenEmailIsInvalid() throws {
        /// Given
        let email = "random string..."
        /// when
        let isValid = sut.isValid(text: email)
        /// then
        XCTAssertFalse(isValid)
    }
}
