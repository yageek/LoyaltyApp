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

        // Logic
        input.debounce(.milliseconds(500), scheduler: SerialDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { [weak self] text -> Observable<[SearchResult]> in
                guard let self = self else { return .empty() }
                let searchText = text ?? ""

                if searchText.isEmpty {
                    return .just([])
                } else {
                    return self.dependencies.apiService.searchLoyalty(byName: searchText)
                        .map { $0.map { SearchResult(id: $0.id, cardName: $0.name) }}
                        .catchAndReturn([])
                        .asObservable()
                }
            }
            .map { searchResults -> NSDiffableDataSourceSnapshot<Int, SearchResult>  in
                var snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>()
                snapshot.appendSections([0])
                snapshot.appendItems(searchResults)
                return snapshot
            }.bind(to: content)
            .disposed(by: self.disposeBag)

    }
}
