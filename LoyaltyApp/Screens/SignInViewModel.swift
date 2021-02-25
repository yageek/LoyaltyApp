//
//  SignInViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 22/02/2021.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class SignInViewModel {
    struct CredentialError: Error {
        let email: String
        let error: Error
    }
    typealias Dependencies = HasAPIClientService

    // MARK: - iVar | Rx
    private let disposeBag = DisposeBag()
    // MARK: - iVar | DI
    private let dependencies: Dependencies

    // MARK: - iVar | Inputs
    let emailInput: BehaviorRelay<String?>
    let passInput: BehaviorRelay<String?>
    let buttonTriggered: PublishSubject<()>

    // MARK: - iVar | Outputs
    private var _isActivityIndicatorAnimating: BehaviorRelay<Bool>
    var isActivityIndicatorAnimating: Driver<Bool> { return self._isActivityIndicatorAnimating.asDriver() }

    let signInResult: Signal<Result<(), CredentialError>>
    var inputEnabled: Driver<Bool>

    static let delayInterval: DispatchTimeInterval = .milliseconds(800)

    // MARK: - Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        // INputs
        let email = BehaviorRelay<String?>(value: nil)
        let pass = BehaviorRelay<String?>(value: nil)
        let button = PublishSubject<()>()

        // Activity loading
        let isActivityIndicatorHidden = BehaviorRelay(value: false)

        // Validated inputs
        let displayed = button.withLatestFrom(Observable.combineLatest(email.compactMap{ $0 }, pass.compactMap{ $0 }))
            .debug()
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(true)
            })
            .flatMap {
                dependencies.apiService.signIn(email: $0.0, password: $0.1).delaySubscription(SignInViewModel.delayInterval, scheduler: MainScheduler.instance)
                .map { Result<(), CredentialError>.success(()) }
                .catch { .just(.failure(CredentialError(email: email.value ?? "", error: $0 )))}
            }
            .asSignal(onErrorRecover: { .just(.failure(CredentialError(email: email.value ?? "", error: $0)))} )
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(false)
            })

        self._isActivityIndicatorAnimating = isActivityIndicatorHidden
        self.signInResult = displayed
        self.inputEnabled = isActivityIndicatorHidden.map { !$0 }.asDriver(onErrorJustReturn: false)
        self.emailInput = email
        self.passInput = pass
        self.buttonTriggered = button
    }
}
