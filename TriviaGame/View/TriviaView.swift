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
                        ProgressView()
                    } else if viewModel.currentQuestionIndex < viewModel.questions.count {
                        Text("Score: \(viewModel.score)")
                            .font(.title)
                            .padding()
                        
                        let question = viewModel.questions[viewModel.currentQuestionIndex]
                        QuestionView(viewModel: viewModel, question: question)
                    }
                } else {
                    PlayButton
                    Button("OPTIONS") {
                        viewModel.toggleState(state: "optionsShow", to: true)
                    }
                    .font(.callout)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            .sheet(isPresented: $viewModel.showOptions) {
                OptionsModalView(showOptions: $viewModel.showOptions, selectedNumberOfQuestions: $viewModel.selectedNumberOfQuestions)
            }
            if viewModel.showMessage {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                
                ResultModalView(viewModel: viewModel)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.showModal = { message in
                viewModel.message = message
                viewModel.toggleState(state: "messageShow", to: !message.isEmpty)
            }
        }
    }
    var PlayButton: some View{
        //** ** deixa o texto BOLD
        Button("**PLAY**") {
            Task {
                await viewModel.restartGame(amount: viewModel.selectedNumberOfQuestions)
                viewModel.toggleState(state: "startGame", to: true)
            }
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

struct QuestionView: View {
    @ObservedObject var viewModel: TriviaViewModel
    var question: TriviaQuestion
    
    var body: some View {
        VStack {
            // Exibe a imagem relacionada à pergunta
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
            
            Text("Question: \(viewModel.currentQuestionIndex + 1) / \(viewModel.selectedNumberOfQuestions)")
            Text(question.questionDecoded)
                .font(.title2)
                .padding()
            
            AnswerButtonsView(viewModel: viewModel, question: question)
        }
    }
}

struct AnswerButtonsView: View {
    @ObservedObject var viewModel: TriviaViewModel
    var question: TriviaQuestion
    
    var body: some View {
        Section(header: Text("**Click on the right answer**").font(.title).padding()) {
            ForEach(question.answers, id: \.self) { answer in
                Button(answer) {
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
}

struct OptionsModalView: View {
    @Binding var showOptions: Bool
    @Binding var selectedNumberOfQuestions: Int
    
    var body: some View {
        VStack {
            Text("Select Number of Questions")
                .font(.title2)
                .padding()
            
            Picker("Number of Questions", selection: $selectedNumberOfQuestions) {
                ForEach(5..<31, id: \.self) { number in
                    Text("\(number)")
                }
            }
            .pickerStyle(.wheel)
            
            Button("Confirm") {
                showOptions = false
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct ResultModalView: View {
    @ObservedObject var viewModel: TriviaViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.message)
                .foregroundColor(viewModel.message == "Wrong Answer" ? .red : .green)
                .font(.largeTitle)
                .padding()
            
            if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                Button("Next Question") {
                    Task {
                        await viewModel.goToNextQuestion()
                        viewModel.toggleState(state: "messageShow", to: false)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("Finished!")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                    .padding()
                
                Text("Congrats! Score: \(viewModel.score)")
                    .foregroundColor(.green)
                    .font(.largeTitle)
                    .padding()
                
                Button("Restart Game") {
                    Task{
                        await viewModel.restartGame(amount: viewModel.selectedNumberOfQuestions)
                        viewModel.toggleState(state: "messageShow", to: false)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Back to Menu") {
                    viewModel.toggleState(state: "startGame", to: false)
                    viewModel.toggleState(state: "messageShow", to: false)
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
}
