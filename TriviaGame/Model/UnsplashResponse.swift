//
//  UnsplashResponse.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import Foundation
struct UnsplashResponse: Decodable {
    let total: Int
    let total_pages: Int
    let results: [ImageModel]
}
