//
//  FeedViewModelTests.swift
//  nanameueTests
//
//  Created by Volnov Ivan on 13/02/2023.
//

@testable import nanameue
import XCTest

final class FeedViewModelTests: XCTestCase {
    
    enum Expected {
        static let post = Post(id: "id", url: "https://example.com", text: "text", created: Date())
        static let user = User(id: "id")
    }
    
    var imageServiceMock: ImageServiceMock!
    var postsServiceMock: PostsServiceMock!
    var userServiceMock: UserServiceMock!
    var sut: FeedViewModel!
    
    override func setUpWithError() throws {
        
        imageServiceMock = ImageServiceMock()
        postsServiceMock = PostsServiceMock()
        userServiceMock = UserServiceMock()
        
        sut = FeedViewModel(
            imageService: imageServiceMock,
            postsService: postsServiceMock,
            userService: userServiceMock
        )
        
    }

    override func tearDownWithError() throws {
        imageServiceMock = nil
        postsServiceMock = nil
        userServiceMock = nil
        sut = nil
    }
    
    func testSnapshotIsUpdated_whenPostsHaveBeenLoaded() throws {
        /// given
        let numberOfPostsBefore = sut.snapshot?.numberOfItems ?? 0
        XCTAssertTrue(numberOfPostsBefore == 0)
        /// when
        sut.loadPostsSubject.send(())
        userServiceMock.userUserSubject.send(.success(Expected.user))
        /// then
        let numberOfPostsAfter = sut.snapshot?.numberOfItems ?? 0
        XCTAssertTrue(numberOfPostsAfter > 0)
    }

    func testSignInScreenIsShown_whenThereIsNoUserSession() throws {
        /// given
        sut.showSignIn = false
        sut.loadPostsSubject.send(())
        /// when
        userServiceMock.userUserSubject.send(.failure(AppError.noUser))
        /// then
        XCTAssertTrue(sut.showSignIn)
    }
    
    func testSignInScreenIsShown_whenUserIsSignedOut() throws {
        /// given
        sut.showSignIn = false
        sut.loadPostsSubject.send(())
        /// when
        sut.signOutSubject.send(())
        /// then
        XCTAssertTrue(userServiceMock.signOutCalled)
        XCTAssertTrue(sut.showSignIn)
    }
    
    func testImageIsDeleted_whenPostIsDeleted() throws {
        /// given
        userServiceMock.userUserSubject.send(.success(Expected.user))
        /// when
        sut.deletePostSubject.send(Expected.post)
        imageServiceMock.deleteImageSubject.send(.success(()))
        /// then
        XCTAssertTrue(imageServiceMock.deleteImageWasCalled)
    }
    
    func testPostIsDeletedFromStorage_whenPostIsDeleted() throws {
        /// given
        userServiceMock.userUserSubject.send(.success(Expected.user))
        /// when
        sut.deletePostSubject.send(Expected.post)
        imageServiceMock.deleteImageSubject.send(.success(()))
        /// then
        XCTAssertTrue(postsServiceMock.deletePostWasCalled)
    }
}
