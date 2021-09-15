//
//  SearchVC.swift
//  LoyaltyApp
//
//  Created by eidd5180 on 15/09/2021.
//

import UIKit
import RxSwift

final class SearchViewController: UITableViewController, Bindable {

    private let searchController = UISearchController(searchResultsController: nil)

    private var viewModel: SearchViewModel?
    let disposeBag = DisposeBag()
    typealias Dependencies = HasAPIClientService
    let dependencies: Dependencies
    var dataSource: UITableViewDiffableDataSource<Int, SearchResult>?
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.searchController = self.searchController
        self.tableView.tableFooterView = UIView(frame: .zero)

        let dataSource = UITableViewDiffableDataSource<Int, SearchResult>(tableView: self.tableView) { tableView, IndexPath, result in

            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CellID")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "CellID")
            }

            cell.textLabel?.text = result.cardName
            return cell
        }

        self.tableView.dataSource = dataSource
        self.dataSource = dataSource
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let model = SearchViewModel(dependencies: self.dependencies)
        self.bind(to: model)
        self.viewModel = model
    }

    func bind(to viewModel: SearchViewModel) {

        self.searchController.searchBar.rx.text.bind(to: viewModel.input.searchText).disposed(by: self.disposeBag)

        viewModel.output.content.drive { [weak self] snapshot in
            self?.dataSource?.apply(snapshot)
        }.disposed(by: self.disposeBag)

    }
}
