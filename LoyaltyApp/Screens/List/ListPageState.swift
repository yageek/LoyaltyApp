//
//  ListPageState.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import Foundation
import LoyaltyAPIClient

struct ListPageState {
    let currentOffset: UInt
    let cards: [CardListViewModel.Cell]
    let totalCount: UInt?

    static var initial: ListPageState {
        return ListPageState(currentOffset: 0, cards: [], totalCount: nil)
    }

    static func reduce(lastState: ListPageState, page: (UInt, CardPageResponse)) -> ListPageState {
        let (pageLoaded, response) = page

        let totalCount = lastState.totalCount ?? UInt(response.count)

        var newCards = lastState.cards + response.cards.map { CardListViewModel.Cell.card($0) }
        if newCards.count < totalCount {
            newCards.append(.loading)
        }

        let currentOffset = pageLoaded
        return ListPageState(currentOffset: currentOffset, cards: newCards, totalCount: totalCount)
    }
}
