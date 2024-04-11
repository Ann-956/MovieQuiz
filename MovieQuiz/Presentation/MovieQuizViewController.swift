import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    @IBOutlet weak private var indexLable: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var questionLable: UILabel!
    
    @IBOutlet weak private var noUIButton: UIButton!
    @IBOutlet weak private var yesUIButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var statisticService = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        func getMovies(from jsonString: String) -> Movie? {
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let top = try JSONDecoder().decode(Movie.self, from: jsonData)
                    return top
                } catch {
                    print("Failed to parse: \(error.localizedDescription)")
                }
            } else {
                print("Failed to convert string to data")
            }
            return nil
        }
    


        
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        
        if isCorrect == true {
            correctAnswers += 1
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            
            self.previewImage.layer.borderWidth = 0
            
        }
    }
    @IBAction private func noButtonCliked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        noUIButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        noUIButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLable.text = step.questionNumber
        previewImage.image = step.image
        questionLable.text = step.question
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let record = GameRecord(correct: correctAnswers, total: questionsAmount, date: Date())
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10! \n" :
            "Ваш результат \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыграных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(record.correct)/\(record.total) (\(record.date.dateTimeString))\n" +
             "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResult(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
            yesUIButton.isEnabled = true
            noUIButton.isEnabled = true
        }
    }

    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) {
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory.requestNextQuestion()
            }
        
        AlertPresenter.presentAlert(from: self, with: alertModel)
    }
    
    
    

}





/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
