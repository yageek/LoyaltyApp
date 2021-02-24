//
//  CardListCellViewModel.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 23/02/2021.
//

import UIKit
import RxSwift
import RxCocoa
import LoyaltyAPIClient

final class CardListCellViewModel {

    let disposeBag = DisposeBag()

    enum Section: Hashable {
        case main
    }

    enum Cell: Hashable {
        case card(CardResource)
        case loading
    }

    // MARK: - Var
    typealias Dependencies = HasAPIClientService

    // MARK: - iVar | State
    private var currentOffset: BehaviorRelay<UInt?>
    private var totalCount: Int?
    private var elements: BehaviorRelay<[CardResource]>

    // MARK: iVar | Inputs
    let loadNextPageTrigger: BehaviorSubject<()>

    // MARK: iVar | Outputs
//    private var _changes: BehaviorRelay<NSDiffableDataSourceSnapshot<Section, Cell>> = BehaviorRelay(value: NSDiffableDataSourceSnapshot())
    var changes: Observable<NSDiffableDataSourceSnapshot<Section, Cell>>

    // MARK: - iVar | DI
    let dependencies: Dependencies

    init(dependencies: Dependencies) {

        // We load the first page immediatly

        let pageSize: UInt = 10

        let loadNextPageTrigger = BehaviorSubject<()>(value: ())
        let offset = BehaviorRelay<UInt?>(value: nil)
        let elements = BehaviorRelay<[CardResource]>(value: [])

        // Map offset
        let mappedOffset = offset.map({ offset -> UInt in
            if let offset = offset {
                return offset + 1
            } else {
                return 0
            }
        })

        let changes = loadNextPageTrigger
            .withLatestFrom(mappedOffset)
            .flatMap { dependencies.apiService.getAllLoyalties(offset: $0*pageSize, limit: pageSize) }
            .do(onNext: { (arg) in
                if let value = offset.value {
                    offset.accept(value + 1)
                } else {
                    offset.accept(0)
                }
            })
            .map { (page) -> (NSDiffableDataSourceSnapshot<Section, Cell>, [CardResource]) in
//                let (page, elements, _) = arg

                var newContents = elements.value
                newContents.append(contentsOf: page.cards)

                let contentSize = newContents.count

                var patch = NSDiffableDataSourceSnapshot<Section, Cell>()
                let cells = newContents.map { Cell.card($0) }
                patch.appendSections([.main])
                patch.appendItems(cells)

                if contentSize < page.count {
                    patch.appendItems([.loading])
                }
                return (patch, newContents)
            }
            .do(onNext: {(arg) in
                elements.accept(arg.1)
            })

        self.changes = changes.map { $0.0 }
        self.elements = elements
        self.currentOffset = offset
        self.dependencies = dependencies
        self.loadNextPageTrigger = loadNextPageTrigger

    }
}
