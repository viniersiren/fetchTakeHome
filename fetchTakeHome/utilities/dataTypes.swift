//
//  dataTypes.swift
//  fetchTakeHome
//
//  Created by Devin Studdard on 4/12/25.
//

import Foundation
import UIKit

struct Recipe: Codable, Identifiable {
    let cuisine: String
    let name: String
    let photoURLLarge: URL?
    let photoURLSmall: URL?
    let uuid: String
    let sourceURL: URL?
    let youtubeURL: URL?
    
    var id: String { uuid }

    private enum CodingKeys: String, CodingKey {
        case cuisine, name, uuid
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

func isIPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
