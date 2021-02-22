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

    // MARK: - iVar
    private let disposeBag = DisposeBag()
    // MARK: - DI
    private let dependencies: Dependencies

    // MARK: - Output
    private var _isActivityIndicatorAnimating: BehaviorRelay<Bool>
    var isActivityIndicatorAnimating: Driver<Bool> { return self._isActivityIndicatorAnimating.asDriver() }

    let signInResult: Driver<Result<(), CredentialError>>
    var inputEnabled: Driver<Bool>

    // MARK: - Init
    init(dependencies: Dependencies, emailTextField: Observable<String?>, passwordTextField: Observable<String?>, buttonTriggered: Observable<()>) {
        self.dependencies = dependencies

        let emailRelay = BehaviorRelay<String?>(value: nil)
        emailTextField.bind(to: emailRelay).disposed(by: self.disposeBag)

        // Name filtering
        let email = emailTextField.compactMap { $0 }
        let password = passwordTextField.compactMap { $0 }

        // Activity loading
        let isActivityIndicatorHidden = BehaviorRelay(value: false)

        let displayed = Observable.combineLatest(email, password, buttonTriggered)
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(true)
            })
            .flatMap { dependencies.apiService.rx_signIn(email: $0.0, password: $0.1).delaySubscription(.seconds(3), scheduler: MainScheduler.instance) }

            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(false)
            })
            .map{ Result<(), CredentialError>.success(()) }
            .asDriver(onErrorRecover: { Driver.just(.failure(CredentialError(email: emailRelay.value ?? "", error: $0)))} )


        self._isActivityIndicatorAnimating = isActivityIndicatorHidden
        self.signInResult = displayed
        self.inputEnabled = isActivityIndicatorHidden.asDriver().map { !$0 }

    }
}
