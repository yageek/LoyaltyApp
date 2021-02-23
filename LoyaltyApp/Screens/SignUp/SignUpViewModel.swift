//
//  SignUpViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class SignUpViewModel {

    typealias Dependencies = HasAPIClientService

    // MARK: - iVar | Inputs
    let emailInput: BehaviorRelay<String?>
    let passInput: BehaviorRelay<String?>
    let nameInput: BehaviorRelay<String?>
    let buttonTriggered: PublishSubject<()>

    // MARK: - iVar | Outputs
    private var _isActivityIndicatorAnimating: BehaviorRelay<Bool>
    var isActivityIndicatorAnimating: Driver<Bool> { return self._isActivityIndicatorAnimating.asDriver() }

    let signInResult: Signal<Result<(), Error>>
    var inputEnabled: Driver<Bool>

    // MARK: - iVar | Di
    let dependencies: Dependencies

    static let delayInterval: DispatchTimeInterval = .milliseconds(800)

    // MARK: - Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let email = BehaviorRelay<String?>(value: nil)
        let pass = BehaviorRelay<String?>(value: nil)
        let name = BehaviorRelay<String?>(value: nil)
        let button = PublishSubject<()>()

        // Activity loading
        let isActivityIndicatorHidden = BehaviorRelay(value: false)

        let displayed = button.withLatestFrom(Observable.combineLatest(email.compactMap { $0 }, pass.compactMap { $0 }, name.compactMap{ $0 }))
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(true)
            })
            .flatMap {
                dependencies.apiService.signUp(name: $0.2, email: $0.0, password: $0.1).delaySubscription(SignInViewModel.delayInterval, scheduler: MainScheduler.instance)
                    .map { Result<(), Error>.success(()) }
                    .catch { .just(.failure($0)) }
            }
            .asSignal(onErrorRecover: { Signal.just(.failure( $0 ))} )
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(false)
            })


        self._isActivityIndicatorAnimating = isActivityIndicatorHidden
        self.signInResult = displayed
        self.inputEnabled = isActivityIndicatorHidden.map { !$0 }.asDriver(onErrorJustReturn: false)
        self.emailInput = email
        self.passInput = pass
        self.buttonTriggered = button
        self.nameInput = name
    }
}
