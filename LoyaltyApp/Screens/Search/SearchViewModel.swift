//
//  SearchViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct SearchResult: Hashable {
    let id: Int
    let cardName: String
}

final class SearchViewModel: ViewModel {

    struct Input {
        let searchText: AnyObserver<String?>
    }

    let input: Input
    struct Output {
        let content: Driver<NSDiffableDataSourceSnapshot<Int, SearchResult>>
    }
    let output: Output

    let disposeBag = DisposeBag()

    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies
    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let input = BehaviorSubject<String?>(value: nil)
        self.input = Input(searchText: input.asObserver())

        let content = BehaviorRelay<NSDiffableDataSourceSnapshot<Int, SearchResult>>(value: NSDiffableDataSourceSnapshot())
        self.output = Output(content: content.asDriver())

        // Logic to implement

    }
}
