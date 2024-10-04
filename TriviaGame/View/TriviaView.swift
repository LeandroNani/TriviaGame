//
//  ContentView.swift
//  TriviaGame
//
//  Created by dtidigital on 25/09/2024.
//

import SwiftUI

struct TriviaView: View {
    @StateObject private var viewModel = TriviaViewModel()
    
    // tudo que tem logica tem que estar na viewmodel, apenas na view o que for relativo a tela
    @State private var animateGradient: Bool = false
    
    
    var body: some View {
        ZStack {
            FundoGradient();
            
            VStack {
                if viewModel.gameStarted {
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
                        
                        Text("Question: \(viewModel.currentQuestionIndex) / \(viewModel.selectedNumberOfQuestions)")
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
                                .background(Color(viewModel.showMessage && answer == question.correct_answer ? .green : .white))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                            }
                        }
                    }
                } else {
                    //Tela inicial com o botão "PLAY" e "OPTIONS"
                    PlayButton
                    //O símbolo $ antes de uma variável de estado em SwiftUI é usado para criar um Binding
                    
                    
                    Button("OPTIONS") {
                        viewModel.optionsShow(show: true)
                    }
                    .font(.callout)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            // Modal de Opções
            .sheet(isPresented: $viewModel.showOptions) {
                VStack {
                    Text("Select Number of Questions")
                        .font(.title2)
                        .padding()
                    
                    Picker("Number of Questions", selection: $viewModel.selectedNumberOfQuestions) {
                        ForEach(5..<31, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Button("Confirm") {
                        viewModel.optionsShow(show: false)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .padding()
            }
            
            
            if viewModel.showMessage { //MODAL de resultado e proxima pergunta
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(viewModel.message)
                        .foregroundColor(viewModel.message == "Wrong Answer" ? .red : .green)
                        .font(.largeTitle)
                        .padding()
                    if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                        Button("Next Question") {
                            viewModel.goToNextQuestion()
                            viewModel.messageShow(show: false)
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
                            viewModel.restartGame(amount: viewModel.selectedNumberOfQuestions)
                            viewModel.messageShow(show: false)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Back to Menu") {
                            viewModel.startGame(show: false)
                            viewModel.messageShow(show: false)
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
                viewModel.message = message
                viewModel.messageShow(show: !message.isEmpty ? true : false)
            }
        }
    }
    var PlayButton: some View{
        //** ** deixa o texto BOLD
        Button("**PLAY**") {
            viewModel.fetchQuestions(amount: viewModel.selectedNumberOfQuestions) // Busca as perguntas ao iniciar
            print(viewModel.questions)
            viewModel.startGame(show: true)
        }
        .font(.largeTitle)
        .padding()
        .background(Color.green)
        .cornerRadius(10)
    }
    
    
    
}

#Preview {
    TriviaView()
}


//MODULARIZAÇÃO DA VIEW:

struct FundoGradient: View {
    @State private var animateGradient: Bool = false
    
    private let startColor: Color = .blue
    private let endColor: Color = .white
    
    var body: some View {
        LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
    }
}


