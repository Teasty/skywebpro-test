//
//  ProductDetailViewController.swift
//  skywebpro-test
//
//  Created by Андрей Лихачев on 12.07.2021.
//

import UIKit

class ProductDetailViewController: UIViewController {

    var netWorker: NetWorker?
    var data: Product?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        netWorker?.fetchProduct(product_id: data!.id, complition: { [weak self] result in
            switch result {
            case .success(let product):
                self?.data = product
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                break
            }
            
        })
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        netWorker?.fetchProduct(product_id: data!.id, complition: { [weak self] result in
            switch result {
            case .success(let product):
                self?.data = product
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

extension ProductDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.row {
        case 0:
            let url = URL(string: "https://picsum.photos/240/128")
            let imageData = try? Data(contentsOf: url!)
            cell.imageView?.image = UIImage(data: imageData!)
        case 1:
            cell.textLabel?.text = "id - \(data!.id)"
        case 2:
            cell.textLabel?.text = "name - \(data!.name)"
        case 3:
            cell.textLabel?.text = "ccal - \(data!.ccal)"
        case 4:
            cell.textLabel?.text = "date - \(data!.date)"
        case 5:
            cell.textLabel?.text = "category_id - \(data!.category_id)"
        case 6:
            cell.textLabel?.text = "created_at - \(data!.created_at)"
        case 7:
            cell.textLabel?.text = "updated_at - \(data!.updated_at)"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        }
        return 50
    }
}
