//
//  WayFairAPIView.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 2/22/25.
//

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
