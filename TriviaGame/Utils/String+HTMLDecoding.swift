//
//  String+HTMLDecoding.swift
//  TriviaGame
//
//  Created by dtidigital on 02/10/2024.
//

import Foundation

extension String {
    func decodeHtmlEntities() -> String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        } else {
            return nil
        }
    }
}
