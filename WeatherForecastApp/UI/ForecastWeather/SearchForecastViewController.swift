//
//  SearchForecastViewController.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class SearchForecastViewController: UIViewController {
    
    var viewModel: SearchForecastViewModel!
    
    private typealias Section = SectionModel<String, WeatherForecastViewModel>
    private lazy var dataSource = makeDataSources()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = SearchForecastViewModel.Input(
            searchTextChanged: searchBar.rx.text.asDriver().throttle(.milliseconds(250)))
        
        let output = viewModel.transfrom(input)
        
        disposeBag.insert([
            output.popupErrorMessage.drive(showMessage),
            output.weatherForecastItems
                .map({ [Section(model: "", items: $0)] })
                .drive(tableView.rx.items(dataSource: dataSource))
        ])
    }
    
    // MARK: - Helpers
    
    private var showMessage: Binder<String?> {
        return Binder(self, binding: { (vc, msg) in
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true)
        })
    }
    
    private func makeDataSources() -> RxTableViewSectionedReloadDataSource<Section> {
        .init { _, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ForecastCell else {
                return UITableViewCell()
            }
            cell.configure(with: item)
            return cell
        }
    }
}
