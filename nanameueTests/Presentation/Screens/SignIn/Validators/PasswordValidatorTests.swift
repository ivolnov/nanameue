//
//  PasswordValidatorTests.swift
//  nanameueTests
//
//  Created by Volnov Ivan on 13/02/2023.
//

@testable import nanameue
import XCTest

final class PasswordValidatorTests: XCTestCase {
    
    var sut: PasswordValidator!

    override func setUpWithError() throws {
        sut = PasswordValidator()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testValidatorReturnFalse_whenNoCapitalLettersInPassword() throws {
        /// Given
        let password = "password123"
        /// when
        let isValid = sut.isValid(text: password)
        /// then
        XCTAssertFalse(isValid)
    }
    
    func testValidatorReturnFalse_whenNoNumbersInPassword() throws {
        /// Given
        let password = "Passsssword"
        /// when
        let isValid = sut.isValid(text: password)
        /// then
        XCTAssertFalse(isValid)
    }
    
    func testValidatorReturnFalse_whenPasswordIsTooShort() throws {
        /// Given
        let password = "Pass123"
        /// when
        let isValid = sut.isValid(text: password)
        /// then
        XCTAssertFalse(isValid)
    }
    
    func testValidatorReturnTrue_whenPasswordIsValid() throws {
        /// Given
        let password = "Password123"
        /// when
        let isValid = sut.isValid(text: password)
        /// then
        XCTAssertTrue(isValid)
    }
}
