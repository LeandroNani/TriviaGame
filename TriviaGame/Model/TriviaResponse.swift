//
//  TriviaResponse.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import Foundation

struct TriviaResponse: Decodable {
    let response_code: Int
    let results: [TriviaQuestion]
}
