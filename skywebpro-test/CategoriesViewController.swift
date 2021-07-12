//
//  ViewController.swift
//  skywebpro-test
//
//  Created by Андрей Лихачев on 11.07.2021.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    private let netWorker = NetWorker()
    
    private var data = [Category]()
    private var searchBarText = ""
    
    private func currentData() -> [Category] {
        if !searchBarText.isEmpty {
            return data.filter({ value -> Bool in
                value.name.lowercased().contains(searchBarText.lowercased())
            })
        } else {
            return data
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
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
        netWorker.fetchCategories(complition: { [weak self] result in
            switch result {
            case .success(let categories):
                self?.data = categories
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                break
            }
            
        })
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        netWorker.fetchCategories(complition: { [weak self] result in
            switch result {
            case .success(let categories):
                self?.data = categories
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

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = currentData()[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentData().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductsListViewController()
        vc.category_id = currentData()[indexPath.row].id
        vc.netWorker = self.netWorker
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarText = searchText
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

