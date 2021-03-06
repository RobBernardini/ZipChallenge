//
//  FavoriteStockViewController.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
 View Controller that displays the list of favourites stocks.
 It is a sub-class of Base Stock View Controller.
 Rx is used to update data coming in from the view model and to send signals
 to the view model to fetch data.
 It functions much like Stock View Controller but only for favourite stocks.
 The price data is updated every 15 seconds.
*/
final class FavoriteStockViewController: BaseStockViewController {
    typealias ViewModel = FavoriteStockViewModelType
    var viewModel: FavoriteStockViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchFavoriteStocks.accept(())
        viewModel.inputs.startUpdates.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.stopUpdates.accept(())
    }
    
    override func configureUserInterface() {
        super.configureUserInterface()
        navigationItem.title = "Favourite Stocks"
    }
    
    func bindUserInterface() {
        // Selected stock to see detail
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
        
        // Bindings in order to detect when table stops scrolling and
        // fetch profile data
        tableView.rx.willDisplayCell
            .map({ [unowned self] cellTuple -> Void in
                let stock = self.stocks[cellTuple.indexPath.row]
                self.stocksInView.append(stock)
            })
            .subscribe()
            .disposed(by: bag)
        
        tableView.rx.didEndDisplayingCell
            .map({ [unowned self] cellTuple -> Void in
                guard cellTuple.indexPath.row < self.stocks.count else { return }
                let stock = self.stocks[cellTuple.indexPath.row]
                guard let index = self.stocksInView.firstIndex(of: stock) else { return }
                self.stocksInView.remove(at: index)
            })
            .subscribe()
            .disposed(by: bag)
        
        let fetchProfiles = PublishRelay<[StockModel]>()
        tableView.rx.didEndDragging
            .map({ [unowned self] decelerating -> Void in
                if decelerating == false {
                    fetchProfiles.accept(self.stocksInView)
                }
            })
            .asObservable()
            .subscribe()
            .disposed(by: bag)

        let didEndDecelerating = tableView.rx.didEndDecelerating
            .map({ [unowned self] in self.stocksInView })
            .asObservable()
        
        let didScrollToTop = tableView.rx.didScrollToTop
            .map({ [unowned self] in self.stocksInView })
            .asObservable()

        Observable.merge(
            [fetchProfiles.asObservable(),
             didEndDecelerating,
             didScrollToTop])
            .bind(to: viewModel.inputs.fetchProfiles)
            .disposed(by: bag)
        
        // Update table and set favorite stocks
        viewModel.outputs.favoriteStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.stocks = $0
                self.tableView.reloadData()
                
                // Fire signal to fetch stock profiles when the data is first loaded.
                // A delay is needed so that the persistant data has time to load.
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    fetchProfiles.accept(self.stocksInView)
                }
            })
            .disposed(by: bag)
        
        // Update stocks
        viewModel.outputs.updatedStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                switch $0 {
                case .success(let stocks):
                    self?.update(with: stocks)
                    self?.reloadCells(for: stocks)
                case .failure: break
                }
                
            })
            .disposed(by: bag)

        // Remove stock
        viewModel.outputs.removedFavoriteStock
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.remove(stock: $0)
            })
            .disposed(by: bag)
    }

    func remove(stock: StockModel) {
        guard let index = stocks.firstIndex(of: stock) else { return }
        stocks.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    override func updateAsFavorite(stock: StockModel) {
        viewModel.inputs.removeFavoriteStock.accept(stock)
    }
}

extension FavoriteStockViewController: ViewModelable {}
