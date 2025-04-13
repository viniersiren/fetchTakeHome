//
//  WayFairViewModel.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 2/22/25.
//

import Foundation
import UIKit

@MainActor
class WayFairViewModel: ObservableObject {
    @Published var products: [Product] = []
    //loading??
    @Published var err: String?
    //https://api.wayfair.io/interview-sandbox/android/json-to-list/products.v1.json
    
    //force unwrapping because api is constant
    var url: URL = URL(string: "https://api.wayfair.io/interview-sandbox/android/json-to-list/products.v1.json")!
    
    func fetchProducts() async {
        err = nil
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 20
        let URLSession = URLSession(configuration: config)
        //let timeoutRequest = URLRequest(url: url, timeoutInterval: 8) //time out if >8 secs
        
        do {
            //need to handle networkign error, timeouts etc.
            //let (data, response) = try await URLSession.shared.data(from: url) //without timeout
            let (data, response) = try await URLSession.data(from: url)
            
           
            if let httpCode = response as? HTTPURLResponse {
                guard (200...299).contains(httpCode.statusCode) else {
                    print("\(httpCode.statusCode)")
                    err = "Network error, Code: \(httpCode.statusCode)"
                    return
                }
            }
            let responseProducts = try JSONDecoder().decode([Product].self, from: data)
            
            if responseProducts.isEmpty {
                err = "No Products"
            }
            else {
                self.products = responseProducts
            }
        }
        catch let URLError as URLError {
            //print(response)
            err = "TimeOut or No Connection: \(URLError.localizedDescription)"
        }
        catch {
            err = "Unknown Error, failed to load products"
        }
    }
}

struct Product: Codable, Identifiable{
    let name: String
    let tagline: String
    let rating: Double
    let date: String
    
    var id: String { UUID().uuidString } //for identifiable
    
}

import SwiftUI

struct WayFairAPIView: View {
    @StateObject private var viewModel = WayFairViewModel()
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                rowView(product: product)
            }
        }
        .onAppear() {
            Task { //logic would be done during app loading but is in onappear to minimize the file submission
                await viewModel.fetchProducts()
                //print(viewModel.products)
            }
        }
    }
    
}
struct rowView: View {
    var product: Product //binding? only if editing for future
    var body: some View {
        HStack { //for centering
            Spacer()
            VStack {
                Text(product.tagline) //placed above other data in case its long
                    .multilineTextAlignment(.center)
                HStack {
                    //round rating(double) to nearest half, rating*2.rounded/2
                    Text(product.name)
                    Text("\(Int(((product.rating*2).rounded()/2)))") //check this
                    Text(product.date)
                }
            }
            Spacer()
        }
    }
}
