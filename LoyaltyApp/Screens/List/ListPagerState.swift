//
//  ListPageState.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import Foundation
import LoyaltyAPIClient

enum ListPagerState {
    case initial
    case pageLoaded(offset: Int, cards: [CardResource], loadNextPage: Bool)

    var currentOffset: Int {
        switch self {
        case .initial:
            return 0
        case .pageLoaded(offset: let offset, cards: _, loadNextPage: _):
            return offset
        }
    }

    static func reduce(lastState: ListPagerState, page: CardPageResponse) -> ListPagerState {

        switch lastState {
        case .initial:
            let loadNextPage = page.cards.count < page.count
            return .pageLoaded(offset: page.cards.count, cards: page.cards, loadNextPage: loadNextPage)
        case .pageLoaded(offset: _, cards: let lastCards, _):
            let cards = lastCards + page.cards
            let loadNextPage = cards.count < page.count
            return .pageLoaded(offset: cards.count, cards: cards, loadNextPage: loadNextPage)
        }
    }
}
