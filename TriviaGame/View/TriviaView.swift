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
    @State private var showMessage = false
    @State private var message = ""
    
    @State private var animateGradient: Bool = false
    
    private let startColor: Color = .blue
    private let endColor: Color = .white
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(animateGradient ? 45 : 0))
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack {
                if gameStarted {
                    if viewModel.isLoading {
                        ProgressView() // indica o carregamento
                    } else if viewModel.currentQuestionIndex < viewModel.questions.count{
                        
                        Text("Score: \(viewModel.score)")
                            .font(.title)
                            .padding()
                        
                        let question = viewModel.questions[viewModel.currentQuestionIndex]
                        
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
                        Text(question.questionDecoded)
                            .font(.title2)
                            .padding()
                        
                        // Exibe as opções de resposta
                        Section(header: Text("**Click on the right answer**").font(.title).padding()){
                            ForEach(question.answers,id: \.self){ answer in
                                Button(answer){
                                    viewModel.checkAnswer(for: question, selectedAnswer: answer)
                                }
                                .font(.title3)
                                .padding()
                                .frame(width: 300, alignment: .center)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
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
            if showMessage { //MODAL de resultado e proxima pergunta
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(message)
                        .foregroundColor(message == "Wrong Answer" ? .red : .green)
                        .font(.largeTitle)
                        .padding()
                    if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                        Button("Next Question") {
                            viewModel.goToNextQuestion()
                            showMessage = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    else {
                        Text("Finished!")
                            .foregroundColor(.blue)
                            .font(.largeTitle)
                            .padding()
                        
                        Text("Congrats! Score: \(viewModel.score)")
                            .foregroundColor(.green)
                            .font(.largeTitle)
                            .padding()
                        
                        Button("Restart Game") {
                            viewModel.restartGame()
                            showMessage = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Back to Menu") {
                            gameStarted = false
                            showMessage = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(width: 300, height: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? 200 : 600)
                .background(Color.white)
                .cornerRadius(20)
            }
        } // Fim da ZStack
        .ignoresSafeArea()
        .onAppear {
            viewModel.showModal = { message in
                self.message = message
                self.showMessage = !message.isEmpty
            }
        }
    }
    
}

#Preview {
    TriviaView()
}
