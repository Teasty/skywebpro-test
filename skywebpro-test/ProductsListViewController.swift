//
//  ProducsListViewController.swift
//  skywebpro-test
//
//  Created by Андрей Лихачев on 11.07.2021.
//

import UIKit

class ProductsListViewController: UIViewController {
    
    var category_id: Int?
    var netWorker: NetWorker?
    
    private var data = [Product]()
    private var searchBarText = ""
    
    private func currentData() -> [Product] {
        if !searchBarText.isEmpty {
            return data.filter({ value -> Bool in
                value.name.lowercased().contains(searchBarText.lowercased())
            })
        } else {
            return data
        }
    }
    
    private var endIndex = 0
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        netWorker?.fetchProducts(startIndex: 0, category_id: category_id!, complition: { [weak self] result in
            switch result {
            case .success((let products, let index)):
                self?.data = products
                self?.endIndex = index
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                break
            }
            
        })
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        netWorker?.fetchProducts(startIndex: 0, category_id: category_id!, complition: { [weak self] result in
            switch result {
            case .success((let products, let index)):
                self?.data = products
                self?.endIndex = index
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    sender.endRefreshing()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
                break
            }
            
        })
    }
}

extension ProductsListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = currentData()[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentData().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductDetailViewController()
        vc.data = currentData()[indexPath.row]
        vc.netWorker = netWorker
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) && !netWorker!.isFetching {
            netWorker?.fetchProducts(startIndex: endIndex, category_id: category_id!, complition: { [weak self] result in
                switch result {
                case .success((let products, let index)):
                    self?.data.append(contentsOf: products)
                    self?.endIndex = index
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(_):
                    break
                }
                
            })
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarText = searchText
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
