//
//  NetWorker.swift
//  skywebpro-test
//
//  Created by Андрей Лихачев on 11.07.2021.
//

import Foundation

class NetWorker {
    var isFetching = false
    
    func fetchCategories( complition: @escaping (Result<[Category],Error>) -> Void) {
        
        let url = URL(string: "http://62.109.7.98/api/categories")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                
                if let jsonCategories = try? decoder.decode(CategoriesDataResult.self, from: data) {
                    complition(.success(jsonCategories.data.sorted(by: {$0.id < $1.id})))
                }
            }
        }.resume()
    }
    
    func fetchProducts(startIndex: Int, category_id: Int, complition: @escaping (Result<([Product], Int),Error>) -> Void) {
        guard !isFetching else {
            return
        }
        isFetching = true
        let url = URL(string: "http://62.109.7.98/api/product/category/\(category_id)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        func endIndex(_ count: Int) -> Int {
            count - startIndex > 20 ? startIndex + 20 : count-1
        }
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                complition(.failure(error))
                self.isFetching = false
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                
                if let jsonProducts = try? decoder.decode(ProductsDataResult.self, from: data) {
                    let parsedProducts = jsonProducts.data.sorted(by: {$0.id < $1.id})
                    let products = startIndex >= endIndex(parsedProducts.count) ? [] : Array(parsedProducts[startIndex...endIndex(parsedProducts.count)])
                    
                    self.isFetching = false
                    complition(.success((products, endIndex(parsedProducts.count)+1)))
                }
            }
        }.resume()
    }
    func fetchProduct(product_id: Int, complition: @escaping (Result<Product,Error>) -> Void) {
      
        let url = URL(string: "http://62.109.7.98/api/product/\(product_id)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                
                if let jsonProduct = try? decoder.decode(ProductDataResult.self, from: data) {
                    complition(.success(jsonProduct.data))
                }
            }
        }.resume()
    }
}
