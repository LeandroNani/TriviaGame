//
//  TriviaQuestion.swift.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import Foundation

//Decodable é um protocolo (como um conjunto de regras) em Swift que permite que você converta dados em formato JSON (que você recebe de uma API) para objetos Swift que você pode usar no seu código. Pense nisso como uma "tradução" de dados.

// Identifiable é outro protocolo usado quando quero exibir listas de dados em SwiftUI (mas também pode ser útil em outros contextos). Ele basicamente diz: "Cada objeto nesta lista tem uma maneira de ser identificado unicamente". Isso é importante pois quando um item mudar, a lista saberá qual item atualizar, sem precisar recarregar a lista toda novamente. Para utilizar eu só preciso fornecer uma propriedade única para cada objeto, como um id numérico que recebo, ou um id UUID gerado automaticamnente

struct TriviaQuestion: Decodable { // Ao declarar minha struct como DECODABLE eu sinalizo que ela sabe interpretar os dados json que se assimilarem com o que eu defini. Então o proprio swift usa as propriedades da struct (category, type, difficulty...) para mapear o json recebido e criar um objeto
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var answers: [String] { // Propriedade calculada, pois da forma que estava(como os atributos a cima) antes nao tava conseguindo decodificar o atributo answers
        var allAnswers = incorrect_answers.map { $0.decodeHtmlEntities() ?? "" } // o metodo map percorre por cada elemento do array e aplica o que ta dentro das chaves em cada um.
        allAnswers.append(answerDecoded)
        allAnswers.shuffle()
        return allAnswers
    }
    
    // Computed property para decodificar a pergunta
    var questionDecoded: String {
        return question.decodeHtmlEntities() ?? ""
    }
    
    var answerDecoded: String {
        return correct_answer.decodeHtmlEntities() ?? ""
    }
        
}

