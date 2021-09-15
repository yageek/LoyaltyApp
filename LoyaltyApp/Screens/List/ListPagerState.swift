//
//  ListPageState.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import Foundation
import LoyaltyAPIClient

struct ListPagerState: Equatable {
    let cards: [CardResource]
    let loadNextPage: Bool
    let isFirstLoad: Bool
    
    private init(cards: [CardResource], loadNextPage: Bool, neverLoad: Bool) {
        self.cards = cards
        self.loadNextPage = loadNextPage
        self.isFirstLoad = neverLoad
    }

    var currentOffset: Int {
        self.cards.count
    }
    
    static var initial: ListPagerState = ListPagerState(cards: [], loadNextPage: true, neverLoad: true)

    static func reduce(lastState: ListPagerState, page: CardPageResponse) -> ListPagerState {
        if lastState.isFirstLoad {
            let loadNextPage = page.cards.count < page.count
            return ListPagerState(cards: page.cards, loadNextPage: loadNextPage, neverLoad: false)
        } else {
            let cards = lastState.cards + page.cards
            let loadNextPage = cards.count < page.count
            return ListPagerState(cards: cards, loadNextPage: loadNextPage, neverLoad: false)
        }
    }
}
