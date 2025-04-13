//  RecipeViewModel.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 4/12/25.
//

import Foundation
@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var session: URLSession = .shared //for tests to inject mock data/urls
    var currentEndpoint: Endpoint = .allRecipes //non private for better testing
    
    func fetchRecipes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: currentEndpoint.url)
            
            //valid json format check
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let _ = jsonObject["recipes"] as? [Any] else {
                throw RecipeError.invalidFormat
            }
            

            let decoder = JSONDecoder()
            let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            
            // isvalid but empty
            if recipeResponse.recipes.isEmpty {
                throw RecipeError.emptyData
            }
            recipes = recipeResponse.recipes
            
        } catch let error as DecodingError {
            errorMessage = "Malformed data - check returned code"
            print(error)
            recipes = []
        } catch RecipeError.emptyData {
            errorMessage = "No recipes available"
            recipes = []
        } catch RecipeError.invalidFormat {
            errorMessage = "Invalid data format returned"
            recipes = []
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            recipes = []
        }

      
    }
    func updateEndpoint(_ endpoint: Endpoint) { //clean code format just doesnt feel right
        currentEndpoint = endpoint
    }
}

enum RecipeError: Error { //simpler without this?
    case emptyData
    case invalidFormat
}




/*
 V1, too many network calls, not efficient
 
 
 @MainActor
 class RecipeViewModel: ObservableObject {
     @Published var recipes: [Recipe] = []
     @Published var isLoading = false
     @Published var errorMessage: String?

     var currentURL: URL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!

     func fetchRecipes() async {
         isLoading = true
         errorMessage = nil
         do {
             let (data, _) = try await URLSession.shared.data(from: currentURL)
             let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
             
             if recipeResponse.recipes.isEmpty {
                 errorMessage = "No recipes available."
             } else {
                 recipes = recipeResponse.recipes
             }
         } catch {
             errorMessage = "Failed to load recipes. Please try again."
         }
         isLoading = false
     }

     func updateURL(to newURL: String) {
         currentURL = URL(string: newURL)!
     }
 }



 */
