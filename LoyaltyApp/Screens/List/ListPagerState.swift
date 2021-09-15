//
//  ListPageState.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import Foundation
import LoyaltyAPIClient



struct ListPagerState: Equatable {

    enum Event {
        case pageDownloaded(CardPageResponse)
        case reset
    }

    let cards: [CardResource]
    let loadNextPage: Bool
    let isFirstLoad: Bool
    
    private init(cards: [CardResource], loadNextPage: Bool, isFirstLoad: Bool) {
        self.cards = cards
        self.loadNextPage = loadNextPage
        self.isFirstLoad = isFirstLoad
    }

    var currentOffset: Int {
        self.cards.count
    }
    
    static var initial: ListPagerState = ListPagerState(cards: [], loadNextPage: true, isFirstLoad: true)

    static func reduce(lastState: ListPagerState, event: Event) -> ListPagerState {

        switch event {
        case .pageDownloaded(let page):
            if lastState.isFirstLoad {
                let loadNextPage = page.cards.count < page.count
                return ListPagerState(cards: page.cards, loadNextPage: loadNextPage, isFirstLoad: false)
            } else {
                let cards = lastState.cards + page.cards
                let loadNextPage = cards.count < page.count
                return ListPagerState(cards: cards, loadNextPage: loadNextPage, isFirstLoad: false)
            }
        case .reset:
            return .initial
        }
    }
}
