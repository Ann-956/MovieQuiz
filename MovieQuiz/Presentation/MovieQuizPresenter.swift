import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
   
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    
    init(viewController: MovieQuizViewControllerProtocol) {
           self.viewController = viewController
            statisticService = StatisticServiceImplementation()
           questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
           questionFactory?.loadData()
           viewController.showLoadingIndicator()
       }

        
        func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
        func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel(
                image: model.image,
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        }
    
        func yesButtonClicked() {
            didAnswer(isYes: true)
            viewController?.setYesButtonEnabled(false)
        }
        
        func noButtonCliked() {
            didAnswer(isYes: false)
            viewController?.setNoButtonEnabled(false)
        }
    
        private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.hideLoadingIndicator()
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
        func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                guard let service = statisticService as? StatisticServiceImplementation else {
                    return
                }
                
                statisticService?.store(correct: correctAnswers, total: questionsAmount)
                
                let gamesCount = service.gamesCount
                let bestGame = service.bestGame
                let text = correctAnswers == self.questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10! \n" :
                    "Ваш результат \(correctAnswers)/\(questionsAmount)\n" +
                    "Количество сыграных квизов: \(gamesCount)\n" +
                    "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n" +
                    "Средняя точность: \(String(format: "%.2f", service.totalAccuracy))%"
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.showResult(quiz: viewModel)
                    viewController?.setNoButtonEnabled(true)
                    viewController?.setYesButtonEnabled(true)
            } else {
                switchToNextQuestion()
                viewController?.showLoadingIndicator()
                questionFactory?.requestNextQuestion()
                viewController?.setNoButtonEnabled(true)
                viewController?.setYesButtonEnabled(true)
            }
        }
    
        func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
    
        // MARK: - QuestionFactoryDelegate
            
        func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    
        func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
        }
    
        func didRecieveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
        func showAnswerResult(isCorrect: Bool) {
            didAnswer(isCorrectAnswer: isCorrect)

            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               
               self.showNextQuestionOrResults()
           }
       }
}
