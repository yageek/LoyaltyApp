//
//  Core.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 13/09/2021.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
}

import UIKit
protocol Bindable: UIViewController {
    associatedtype VM: ViewModel
    func bind(to viewModel: VM)
}
