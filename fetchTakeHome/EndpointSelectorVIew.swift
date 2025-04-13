//
//  EndpointSelectorVIew.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 4/12/25.
//
import SwiftUI


struct EndpointSelectorView: View {
    @Binding var selectedEndpoint: Endpoint
    let viewModel: RecipeViewModel
    
    var body: some View {
        Menu {
            ForEach(Endpoint.allCases, id: \.self) { endpoint in
                Button {
                    selectedEndpoint = endpoint
                    viewModel.updateEndpoint(endpoint)
                    Task { await viewModel.fetchRecipes() } //in actual production initiate loading in loading screen
                } label: {
                    HStack {
                        Text(endpoint.rawValue)
                        if endpoint == selectedEndpoint {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: "slider.horizontal.3")
        }
    }
}



/*
 v1 for inefficient network calls
 
struct EndpointSelectorView: View {
    @Binding var selectedEndpoint: String
    var selectAllRecipes: () -> Void
    var selectMalformedData: () -> Void
    var selectEmptyData: () -> Void

    var body: some View {
        Menu {
            Button(action: {
                selectAllRecipes()
                selectedEndpoint = "All Recipes"
            }) {
                HStack {
                    if selectedEndpoint == "All Recipes" {
                        Label("✓ All Recipes", systemImage: "list.bullet")
                    } else {
                        Label("    All Recipes", systemImage: "list.bullet")
                    }
                }
            }

            Button(action: {
                selectMalformedData()
                selectedEndpoint = "Malformed Data"
            }) {
                HStack {
                    if selectedEndpoint == "Malformed Data" {
                        Label("✓ Malformed Data", systemImage: "exclamationmark.triangle")
                    } else {
                        Label("    Malformed Data", systemImage: "exclamationmark.triangle")
                    }
                }
            }

            Button(action: {
                selectEmptyData()
                selectedEndpoint = "Empty Data"
            }) {
                HStack {
                    if selectedEndpoint == "Empty Data" {
                        Label("✓ Empty Data", systemImage: "tray")
                    } else {
                        Label("    Empty Data", systemImage: "tray")
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: isIPad() ? 0.04 * UIScreen.main.bounds.height : 0.034 * UIScreen.main.bounds.height))
                .fontDesign(.rounded)
                .foregroundStyle(Color.white)
        }
        .padding(.leading)
    }
}
*/
