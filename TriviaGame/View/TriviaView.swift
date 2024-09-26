//
//  ContentView.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import SwiftUI

struct TriviaView: View {
    @StateObject private var viewModel = TriviaViewModel()
    @State private var gameStarted = false // Controla se o jogo começou

    var body: some View {
            VStack {
                if gameStarted {
                    if viewModel.isLoading {
                        ProgressView() // indica o carregamento
                    } else if let question = viewModel.questions.first {
                        // Exibe a imagem relacionada a pergunta
                        if let imageURL = viewModel.currentImageURL {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                        }

                        // Exibe a pergunta atual
                        Text(question.question)
                            .font(.title)
                            .padding()

                        // Exibe as opções de resposta
                        
                    }
                } else {
                    //Tela inicial com o botão "PLAY"
                    //** ** deixa o texto BOLD
                    Button("**PLAY**") {
                        viewModel.fetchQuestions() // Busca as perguntas ao iniciar
                        print(viewModel.questions)
                        gameStarted = true
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
    }
}

#Preview {
    TriviaView()
}
