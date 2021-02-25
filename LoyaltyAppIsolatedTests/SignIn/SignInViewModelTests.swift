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

    func signUp(name: String, email: String, password: String) -> Single<()> {
        return .just(())
    }
}

extension LongLoader: HasAPIClientService {
    var apiService: APIClientService { return self }
}

class SignInViewModelTests: XCTestCase {
    var viewModel: SignInViewModel!
    var scheduler: ConcurrentDispatchQueueScheduler!
    var emailInput: BehaviorRelay<String?>!
    var passInput: BehaviorRelay<String?>!
    var publishSub: PublishSubject<()>!

    override func setUpWithError() throws {
        emailInput = BehaviorRelay<String?>(value: nil)
        passInput = BehaviorRelay<String?>(value: nil)
        publishSub = PublishSubject()

        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLockingInterface() throws {
        let disposeBag = DisposeBag()

        // Initialisation
        let viewModel = SignInViewModel(dependencies: LongLoader(timeOut: .milliseconds(100)))

        emailInput.bind(to: viewModel.emailInput).disposed(by: disposeBag)
        passInput.bind(to: viewModel.passInput).disposed(by: disposeBag)
        publishSub.bind(to: viewModel.buttonTriggered).disposed(by: disposeBag)

        // Initialisation
        XCTAssertTrue(try viewModel.inputEnabled.toBlocking().first()!)
        XCTAssertFalse(try viewModel.isActivityIndicatorAnimating.toBlocking().first()!)

        // When triggers the call we must lock everyting and animate the activity indicator
        publishSub.onNext(())
        XCTAssertFalse(try viewModel.isActivityIndicatorAnimating.toBlocking().first()!)
        XCTAssertFalse(try viewModel.inputEnabled.toBlocking().first()!)

    }


}
