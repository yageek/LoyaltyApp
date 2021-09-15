//
//  CardListViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 14/09/2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import UIKit
import LoyaltyAPIClient


final class CardListViewModel: ViewModel {
    // MARK: - Data
    enum Section: Hashable {
        case main
    }

    enum Cell: Hashable {
        case card(CardResource)
        case loading
    }

    // MARK: - I/O
    struct Input {
        let textSearch: AnyObserver<String?> // Input from the search
        let willDisplayCell: AnyObserver<IndexPath>
    }

    let input: Input

    struct Output {
        let content: Driver<NSDiffableDataSourceSnapshot<Section, Cell>>
    }

    let output: Output

    // MARK: - DI
    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies

    // MARK: - iVar
    private var state = BehaviorRelay<ListPageState>(value: .initial)
    private let disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let textSearch = BehaviorSubject<String?>(value: nil)
        let willDisplayCell = PublishSubject<IndexPath>()

        let content = BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Cell>>(value: NSDiffableDataSourceSnapshot())

        self.input = Input(textSearch: textSearch.asObserver(), willDisplayCell: willDisplayCell.asObserver())
        self.output = Output(content: content.asDriver())

        // MAIN LOGIC
        let loadingPageTrigger = willDisplayCell
            .withLatestFrom(self.state) { ($0, $1) }
            .filter { indexPath, state in
                if case .loading = state.cards[indexPath.row] {
                    return true
                }
                return false
            }
            .flatMap { _, state -> Observable<(UInt, CardPageResponse)> in
                let pageToLoad = state.currentOffset + 1
                return self.dependencies.apiService.getAllLoyalties(offset: pageToLoad, limit: 10).map { (pageToLoad, $0) }.asObservable()
            }

        loadingPageTrigger
            .scan(.initial, accumulator: ListPageState.reduce)
            .bind(to: self.state).disposed(by: self.disposeBag)

        // Binds to output
        self.state.map { state in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Cell>()
            snapshot.appendSections([.main])
            snapshot.appendItems(state.cards)
            return snapshot
        }.bind(to: content).disposed(by: self.disposeBag)
    }

}
