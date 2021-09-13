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

final class SignInViewModel: ViewModel {
    struct CredentialError: Error {
        let email: String
        let error: Error
    }

    typealias SignInResult = Result<(), CredentialError>

    // MARK: - iVar | Rx
    struct Input {
        let emailInput: AnyObserver<String?>
        let passInput: AnyObserver<String?>
        let buttonTriggered: AnyObserver<()>
    }
    let input: Input

    struct Output {
        let isActivityIndicatorAnimating: Driver<Bool>
        let inputEnabled: Driver<Bool>
        let signInResult: Observable<SignInResult>
    }

    let output: Output

    private let disposeBag = DisposeBag()

    // MARK: - iVar | DI
    typealias Dependencies = HasAPIClientService

    private let dependencies: Dependencies

    static let delayInterval: DispatchTimeInterval = .milliseconds(800)
    
    // MARK: - Init
    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        // Inputs
        let email = BehaviorSubject<String?>(value: nil)
        let pass = BehaviorSubject<String?>(value: nil)
        let button = PublishSubject<()>()
        // Activity loading
        let isActivityIndicatorHidden = BehaviorRelay(value: false)

        let inputEnabled = isActivityIndicatorHidden.map { !$0 }.asDriver(onErrorDriveWith: .empty())

        // Validated inputs
        let signInResult = button.withLatestFrom(Observable.combineLatest(email.compactMap{ $0 }, pass.compactMap{ $0 }))
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(true)
            })
            .flatMap {
                dependencies.apiService.signIn(email: $0.0, password: $0.1)
                    .delaySubscription(SignInViewModel.delayInterval, scheduler: MainScheduler.instance)
                .map { Result<(), CredentialError>.success(()) }
                .catch { .just(.failure(CredentialError(email: (try? email.value()) ?? "", error: $0 )))}
            }
            .do(onNext: { _ in
                isActivityIndicatorHidden.accept(false)
            }).asObservable()

        // Assignement
        self.input = Input(emailInput: email.asObserver(),
                           passInput: pass.asObserver(),
                           buttonTriggered: button.asObserver())

        self.output = Output(isActivityIndicatorAnimating: isActivityIndicatorHidden.asDriver(),
                             inputEnabled: inputEnabled, signInResult: signInResult)
    }
}
