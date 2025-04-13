//
//  RecipeListView.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 4/12/25.
//

import SwiftUI


enum Endpoint: String, CaseIterable {
    case allRecipes = "All Recipes"
    case malformedData = "Malformed Data"
    case emptyData = "Empty Data"
    
    var url: URL {
        switch self {
        case .allRecipes:
            return URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
        case .malformedData:
            return URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
        case .emptyData:
            return URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
        }
    }
}
struct RecipeListView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    @State private var selectedEndpoint: Endpoint = .allRecipes
    @State private var showProgress = true //simulate laoding screen logic
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.recipes) { recipe in
                        RecipeRow(recipe: recipe)
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage { //delete if ever released in production code
                    Text(errorMessage) //display error messages while work in progress
                        .foregroundColor(.red)
                } else if viewModel.recipes.isEmpty {
                    if showProgress {
                        ProgressView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { //simulate loading occuring in loading screen
                                    showProgress = false
                                }
                            }
                    } else {
                        Text("No recipes available.")
                    }
                }
            }
            //.navigationTitle("Recipes")
            .task {  
                await viewModel.fetchRecipes()
            }
            .refreshable {
                await viewModel.fetchRecipes()
            }
            .toolbar {
                EndpointSelectorView(selectedEndpoint: $selectedEndpoint, viewModel: viewModel)
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @State private var image: UIImage?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            if let image = image { //not async because often cached to reduce network asks
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    //.lineLimit(1)
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                //are the links necessary requirements??
                HStack(spacing: 12) {
                    if let sourceURL = recipe.sourceURL {
                        Link(destination: sourceURL) {
                            Label("Website", systemImage: "link") //basic sf
                                .font(.caption2)
                                .symbolVariant(.circle.fill)
                                .foregroundColor(.secondary)
                                .hoverEffect(.lift)
                        }
                    }
                }
                .padding(.top, 5)
            }
            Spacer() //not necessary for list 
        }
        .task {
            guard let url = recipe.photoURLSmall else { return }
            let image = await ImageCache.shared.image(for: url)
            //reset
            if !Task.isCancelled {
                self.image = image
            }
        }
    }
}


//youtube link is less important than article
/*if let youtubeURL = recipe.youtubeURL {
    Link(destination: youtubeURL) {
        Label("YouTube", systemImage: "play.rectangle")
            .font(.caption2)
            .symbolVariant(.fill)
            .foregroundColor(.red)
            .hoverEffect(.lift)
    }
}*/
