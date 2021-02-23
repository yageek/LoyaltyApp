//
//  SignInViewModelTests.swift
//  LoyaltyAppIsolatedTests
//
//  Created by eidd5180 on 22/02/2021.
//

import XCTest
import RxSwift
import RxRelay
import RxBlocking
import RxTest

struct LongLoader: APIClientService {
    let timeOut: DispatchTimeInterval

    private let scheduler = ConcurrentDispatchQueueScheduler(queue:
    .global())
    func signIn(email: String, password: String) -> Single<()> {
        return Single.just(()).delay(timeOut, scheduler: scheduler)
    }

    func signOut() -> Single<()> {
        return .just(())
    }
}

extension LongLoader: HasAPIClientService {
    var apiService: APIClientService { return self }
}

class SignInViewModelTests: XCTestCase {
    var viewModel: SignInViewModel!
    var testScheduler: TestScheduler!
    var subscription: Cancelable!
    override func setUpWithError() throws {
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        testScheduler.scheduleAt(1000) {
            self.subscription.dispose()
        }
    }

    func testLockingInterface() throws {

        let disposeBag = DisposeBag()

        let timeout: DispatchTimeInterval = .milliseconds(500)

        let email: TestableObservable<String?> = testScheduler.createHotObservable([.next(100, nil), .next(200, ""), .next(300, "Login")])
        let pass: TestableObservable<String?> = testScheduler.createHotObservable([.next(90, nil), .next(210, ""), .next(340, "Password")])
        let button = testScheduler.createHotObservable([.next(350, ())])

        let inputEnabled = testScheduler.createObserver(Bool.self)
        let animating = testScheduler.createObserver(Bool.self)

        // Initialisation
        testScheduler.scheduleAt(0) {
            // Subscription
            let viewModel = SignInViewModel(dependencies: LongLoader(timeOut: timeout), emailTextField: email.asObservable(), passwordTextField: pass.asObservable(), buttonTriggered: button.asObservable())
            viewModel.inputEnabled.drive(inputEnabled).disposed(by: disposeBag)
            viewModel.isActivityIndicatorAnimating.drive(animating).disposed(by: disposeBag)
            viewModel.signInResult.emit(onNext: { _ in }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            self.viewModel = viewModel
        }

        testScheduler.start()
        let expectedInputEvents = inputEnabled.events.compactMap { $0.value.element }
        let expectedAnimatingEvents = animating.events.compactMap { $0.value.element }

        XCTAssertEqual([false, true], expectedAnimatingEvents)
        XCTAssertEqual([true, false], expectedInputEvents)
        
    }


}
