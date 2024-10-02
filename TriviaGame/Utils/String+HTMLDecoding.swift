//
//  String+HTMLDecoding.swift
//  TriviaGame
//
//  Created by dtidigital on 02/10/2024.
//

import Foundation

extension String {
    //  Declaro uma extensão para o tipo String
    //    - Permite adicionar novas funcionalidades à classe String existente

    func decodeHtmlEntities() -> String? {
        // Defino uma função chamada "decodeHtmlEntities":
        //    - Não recebe nenhum argumento (além do próprio `self`, que é a string)
        //    - Retorna um String opcional (String?) - pode retornar uma string ou nil

        guard let data = self.data(using: .utf8) else {
            //  Tento converter a string (`self`) para dados (Data) usando codificação UTF-8
            //    - `guard let ... else`: verifica se a conversão foi bem-sucedida
            //    - Se a conversão falhar (`data` for nil), entra no bloco `else`
            return nil
            //  Retorna nil se a conversão para UTF-8 falhar
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        // Defino um dicionário de opções para inicializar um NSAttributedString
        //    - `NSAttributedString`: representa uma string com formatação (como HTML)
        //    - `.documentType`: especifica que o tipo de documento é HTML
        //    - `.characterEncoding`: define a codificação de caracteres como UTF-8

        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            // Tento criar um NSAttributedString a partir dos dados e opções
            //    - Se a criação for bem-sucedida, `attributedString` conterá o resultado
            //    - Se a criação falhar, `attributedString` será nil
            return attributedString.string
            // Se a criação do NSAttributedString for concluida
            //    - Retorna a string decodificada, extraindo-a do attributedString
        } else {
            return nil
            // Se a criação do NSAttributedString falhar
            //    - Retorna nil, indicando que a decodificação falhou
        }
    }
}
