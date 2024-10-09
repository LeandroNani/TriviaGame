//
//  TriviaGameTests.swift
//  TriviaGameTests
//
//  Created by dtidigital on 09/10/2024.
//

import XCTest
@testable import TriviaGame

final class TriviaGameTests: XCTestCase {

    var viewModel: TriviaViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TriviaViewModel() // Inicializa a ViewModel antes de cada teste
    }

    override func tearDown() {
        viewModel = nil // Libera a ViewModel após cada teste
        super.tearDown()
    }

    // MARK: - Testes de UI Logic (Interação com a View)

        func testaBotaoPlay() async {
            // Jogo não iniciado
            XCTAssertFalse(viewModel.gameStarted)

            // Simula a ação do botão "Play" na View
            await viewModel.restartGame(amount: 10) // Simula a chamada da API
            viewModel.toggleState(state: "startGame", to: true)

            // Jogo deve iniciar
            XCTAssertTrue(viewModel.gameStarted)
        }

        func testaBotaoOptions() {
            // Tela de opções inicialmente oculta
            XCTAssertFalse(viewModel.showOptions)

            // Botão "Options" é pressionado
            viewModel.toggleState(state: "optionsShow", to: true)

            // Tela de opções deve aparecer
            XCTAssertTrue(viewModel.showOptions)
        }

        func testaSelecionarNumTrivia() {
            // Número inicial de perguntas
            let numeroInicial = viewModel.selectedNumberOfQuestions

            // Novo número de perguntas é selecionado
            let novoNumero = 20
            viewModel.selectedNumberOfQuestions = novoNumero

            // Número de perguntas deve ser atualizado
            XCTAssertEqual(viewModel.selectedNumberOfQuestions, novoNumero)
            XCTAssertNotEqual(viewModel.selectedNumberOfQuestions, numeroInicial)
        }

        // MARK: - Testes de Lógica da ViewModel

        func testCheckAnswer_RespostaCorreta() {
            // Uma pergunta com sua resposta correta
            let perguntaExemplo = TriviaQuestion(category: "dummy", type: "dummy", difficulty: "dummy", question: "dummy", correct_answer: "Resposta Correta", incorrect_answers: ["A", "B", "C"])
            viewModel.questions = [perguntaExemplo]
            let pontuacaoInicial = viewModel.score

            // O usuário seleciona a resposta correta
            viewModel.checkAnswer(for: perguntaExemplo, selectedAnswer: "Resposta Correta")

            // A pontuação deve aumentar
            XCTAssertEqual(viewModel.score, pontuacaoInicial + 1)
            // E a mensagem deve ser "Correct Answer"
            XCTAssertEqual(viewModel.message, "Correct Answer")
        }

        func testCheckAnswer_RespostaIncorreta() {
            // Configuração inicial
            let perguntaExemplo = TriviaQuestion(category: "dummy", type: "dummy", difficulty: "dummy", question: "dummy", correct_answer: "Resposta Correta", incorrect_answers: ["A", "B", "C"])
            viewModel.questions = [perguntaExemplo]
            let pontuacaoInicial = viewModel.score

            // Usuário seleciona uma resposta incorreta
            viewModel.checkAnswer(for: perguntaExemplo, selectedAnswer: "A")

            // Pontuação não deve mudar
            XCTAssertEqual(viewModel.score, pontuacaoInicial)
            // A mensagem deve ser "Wrong Answer"
            XCTAssertEqual(viewModel.message, "Wrong Answer")
        }

        func testGoToNextQuestion() async {
            // Pelo menos 2 perguntas no jogo
            await viewModel.restartGame(amount: 2)
            let indiceInicial = viewModel.currentQuestionIndex

            // Avança para a próxima pergunta
            await viewModel.goToNextQuestion()

            // Índice da pergunta deve ser incrementado
            XCTAssertEqual(viewModel.currentQuestionIndex, indiceInicial + 1)
        }

        func testGoToNextQuestion_FimDoJogo() async {
            // Apenas 1 pergunta no jogo
            await viewModel.restartGame(amount: 1)
            
            // Tenta ir para a próxima pergunta (já no final)
            await viewModel.goToNextQuestion()

            // Índice da pergunta não deve mudar (continua na última)
            XCTAssertEqual(viewModel.currentQuestionIndex, 0)
        }

        func testRestartGame() async {
            // Jogo em um estado qualquer
            await viewModel.restartGame(amount: 5)
            viewModel.currentQuestionIndex = 2
            viewModel.score = 10

            // Reinicia o jogo
            await viewModel.restartGame(amount: viewModel.selectedNumberOfQuestions)

            // Estado do jogo deve ser reiniciado
            XCTAssertEqual(viewModel.currentQuestionIndex, 0)
            XCTAssertEqual(viewModel.score, 0)
            XCTAssertGreaterThanOrEqual(viewModel.questions.count, 1) // Deve haver perguntas
        }
    
    func testFetchTrivia() async {
            // Tenta buscar perguntas da API
            let resultado = await viewModel.fetch(type: .trivia, amount: 5)

            // Verifica se o resultado é um TriviaResponse válido e contém perguntas
            XCTAssertNotNil(resultado as? TriviaResponse)
            if let triviaData = resultado as? TriviaResponse {
                XCTAssertGreaterThanOrEqual(triviaData.results.count, 1)
            }
        }
    
    func testFetchImage() async {
            // Tenta buscar uma imagem com uma query válida
            let resultado = await viewModel.fetch(type: .image, query: "Nature")

            // Verifica se o resultado é um UnsplashResponse válido
            XCTAssertNotNil(resultado as? UnsplashResponse)
        }
    
}
