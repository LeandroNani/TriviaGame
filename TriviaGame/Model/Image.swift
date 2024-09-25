//
//  Image.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import Foundation


//Declarando uma propriedade constante chamada urls dentro da struct ImageModel para que uma vez que o valor de urls for definido quando um ImageModel for criado, ele não poderá ser alterado.
struct ImageModel: Decodable {
    let urls: [String: String] // defini um dicionário para a estrutura, que receberá uma string indicando o tamanho ("small", "medium", "raw", "full") como chave, e uma string que será a url da imagem de tamanho correspondente
}
