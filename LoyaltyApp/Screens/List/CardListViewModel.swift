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
        let willDisplayCell: AnyObserver<IndexPath>
        let resetData: AnyObserver<()>
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
    private var state = BehaviorRelay<ListPagerState>(value: .initial)
    private let disposeBag = DisposeBag()

    static let PageCount = 5
    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let willDisplayCell = PublishSubject<IndexPath>()
        let reset = PublishSubject<()>()

        let content = BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Cell>>(value: NSDiffableDataSourceSnapshot())

        self.input = Input(willDisplayCell: willDisplayCell.asObserver(), resetData: reset.asObserver())
        self.output = Output(content: content.asDriver())
        
        // Manage paging
        let downloadEvents = willDisplayCell.withLatestFrom(content) { ($0, $1) }
            .filter { indexPath, content in
                let section = content.sectionIdentifiers[indexPath.section]
                let item = content.itemIdentifiers(inSection: section)[indexPath.row]

                if case .loading = item {
                    return true
                }
                return false
            }
            .withLatestFrom(self.state)
            .flatMap {
                self.dependencies.apiService.getAllLoyalties(offset: $0.currentOffset , limit: CardListViewModel.PageCount)
                    .delay(.seconds(1), scheduler: MainScheduler.instance)
                    .asObservable()

            }
            .map { ListPagerState.Event.pageDownloaded($0) }

        let deleteEvents = reset.map { _ in ListPagerState.Event.reset }

        Observable.merge([deleteEvents, downloadEvents])
            .scan(.initial, accumulator: ListPagerState.reduce)
            .bind(to: self.state).disposed(by: self.disposeBag)

        // Binds to output
        self.state
            .map { state in
            var snapshot = NSDiffableDataSourceSnapshot<Section, Cell>()
            snapshot.appendSections([.main])
            var cells = state.cards.map { Cell.card($0) }
            if state.loadNextPage {
                cells.append(.loading)
            }
            snapshot.appendItems(cells)
            return snapshot
        }.bind(to: content).disposed(by: self.disposeBag)

    }



}
