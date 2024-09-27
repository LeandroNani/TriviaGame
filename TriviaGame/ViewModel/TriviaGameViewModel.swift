//
//  TriviaGameViewModel.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import Foundation
import SwiftUI

class TriviaViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = [] // Array para armazenar as perguntas
    @Published var currentQuestionIndex = 0 // Índice da pergunta atual
    @Published var currentImageURL: URL? // URL da imagem da Unsplash
    @Published var isLoading = false // Indicador de carregamento
    @Published var score = 0 // Pontuação do jogador
    
    private let triviaBaseURL = "https://opentdb.com/api.php?amount=10"
    private let unsplashBaseURL = "https://api.unsplash.com/search/photos"
    private let unsplashApiKey = "ytcCruuH67rTRETZseNqJiL8XtUAA-kZSFuFpaVJ70o"

    // Função para buscar as perguntas da API Trivia
       func fetchQuestions() {
           isLoading = true // Inicia o indicador de carregamento
           // guard let é uma estrutura pra lidar com o desempacotamento de uma variavel, que se nao vor válida, entra no else.
           guard let url = URL(string: triviaBaseURL) else {
               isLoading = false
               // aqui eu deveria lidar com o erro, sinalizar que a url é invalida
               return
           }
           
           
           //URLSession: É a classe responsável por gerenciar tarefas de rede no iOS. Ela permite que você faça requisições HTTP (como GET, POST, etc.) para servidores web.
           //.shared: É uma instância compartilhada de URLSession que você pode usar na maioria dos casos. Ela já vem configurada com opções padrão para lidar com conexões de rede.
           //.dataTask(with: url): Cria uma tarefa de rede específica para buscar dados de uma URL.
           //                url: É a URL do recurso que vou acessar (a API da Open Trivia Database).
           
           URLSession.shared.dataTask(with: url) {
               [weak self] data, _, error in
               // Aqui temos uma closure (um bloco de código) que será executada quando a tarefa de rede for concluída (com sucesso ou falha).
               
               //[weak self]: Isso é uma técnica para evitar ciclos de retenção (retain cycles) que podem acontecer quando você usa self dentro de uma closure.
               //Um ciclo de retenção ocorre quando dois objetos mantêm uma referência forte um ao outro, impedindo que sejam desalocados da memória, mesmo quando não são mais necessários. Isso pode levar a vazamentos de memória.
               //Nesse caso, a closure da dataTask captura implicitamente self (a instância da TriviaViewModel). Se a TriviaViewModel também mantivesse uma referência forte à closure (o que pode acontecer indiretamente), eu teria um ciclo de retenção.
               //Usar [weak self] na closure resolve esse problema. Uma referência weak não impede que um objeto seja desalocado. Assim, mesmo que a closure ainda esteja em andamento, self pode ser desalocado se não houver mais nenhuma outra referência forte a ele.
               //nao entendi bem essa parte ainda de ciclo de retencao.
               
               //data: Contém os dados brutos (em formato Data) recebidos do servidor, se a requisição for bem-sucedida.
               
               //_: O segundo parâmetro é a resposta HTTP (do tipo URLResponse), mas estamos ignorando-o neste caso usando um sublinhado (_).
               
               //error: Contém um objeto Error se ocorreu algum erro durante a requisição.
               
               
               
               // defer é um bloco de código que sera executado no fim do escopo atual, seja depois de um return ou no fim natural do bloco, ele é util para limpaar variaveis, liberar recursos, etc. Nesse caso ele vai desligar o indicador de loading
               defer {
                   DispatchQueue.main.async {
                       self?.isLoading = false
                   }
               }

               if let error = error {
                   print("Erro ao buscar dados da API Trivia: \(error)")

                   return
               }

               guard let data = data else {
                   print("Dados inválidos recebidos da API Trivia.")

                   return
               }

               //do catch é exatamente como um try catch
               do {
                   let decoder = JSONDecoder() //Cria um decodificador JSON
                   let triviaData = try decoder.decode(TriviaResponse.self, from: data) // Decodifica os dados do JSON
                   
                   //DispatchQueue é o gerenciador de threads, utilizando .main eu solicito que ele utilize a thread principal ( a thread principal é a unica que atualiza a interface do usuario ) e utilizo o .async para indicar que é um bloco de código assincrono
                   DispatchQueue.main.async {
                       self?.questions = triviaData.results // Atualiza a array de perguntas
                       self?.fetchImage(for: self?.questions.first?.category ?? "") // Busca a imagem relacionada a primeira pergunta
                   }
               } catch {
                   print("Erro ao decodificar dados da API Trivia: \(error)")
                   
               }
           }.resume()
           //Este método é essencial, ele inicia a tarefa de rede sem ele a requisição não será feita.
       }
    
    
    //função para buscar as imagens passando parametro de categoria da pergunta
    private func fetchImage(for query: String) {
        // Montando a url da api de imagens
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(unsplashBaseURL)?query=\(encodedQuery)&client_id=\(unsplashApiKey)") else {
            
            return
        }


        URLSession.shared.dataTask(with: url) {
            [weak self] data, _, error in
            
            
            if let error = error {
                print("Erro ao buscar imagem da Unsplash: \(error)")
                return
            }

            guard let data = data else {
                print("Dados inválidos recebidos da API da Unsplash.")
                return
            }

            do {
                let decoder = JSONDecoder()
                let imageData = try decoder.decode(UnsplashResponse.self, from: data)

                DispatchQueue.main.async {
                    self?.currentImageURL = imageData.results.first?.urls["regular"].flatMap { URL(string: $0) }
                }
            } catch {
                print("Erro ao decodificar dados da API da Unsplash: \(error)")
            }
        }.resume()
    }
    
    //Checa se a resposta é a certa da questao
    //for: Atua como um nome de parâmetro externo, tornando a chamada da função mais legível.
    func checkAnswer(for question: TriviaQuestion, selectedAnswer: String) {
        if selectedAnswer == question.correct_answer {
            score += 1
        }
        // Avança para a próxima pergunta, independentemente de acertar ou errar
        goToNextQuestion()
    }
    
    func goToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            // Fim do jogo
            // Falta inserir a logica para lidar com o fim do jogo
        }
    }
        
}
