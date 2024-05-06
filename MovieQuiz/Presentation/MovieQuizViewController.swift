import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak private var indexLable: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var questionLable: UILabel!
    @IBOutlet weak var noUIButton: UIButton!
    @IBOutlet weak var yesUIButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        previewImage.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    
    @IBAction private func noButtonCliked(_ sender: Any) {
        presenter.noButtonCliked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    func show(quiz step: QuizStepViewModel) {
        let image = UIImage(data: step.image) ?? UIImage()
        
        previewImage.layer.borderColor = UIColor.clear.cgColor
        indexLable.text = step.questionNumber
        previewImage.image = image
        questionLable.text = step.question
    }


    func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                self.presenter.resetQuestionIndex()
                self.presenter.correctAnswers = 0
                self.presenter.questionFactory?.requestNextQuestion()
            },
            accessibilityIndicator: "Game results")
        
        AlertPresenter.presentAlert(from: self, with: alertModel)
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let alertError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.presenter.correctAnswers = 0
                
                self.presenter.questionFactory?.requestNextQuestion()
            },
            accessibilityIndicator: "NetworkErrorAlert"
        )
        
        AlertPresenter.presentAlert(from: self, with: alertError)
    }
    func setYesButtonEnabled(_ enabled: Bool) {
        yesUIButton.isEnabled = enabled
    }
    
    func setNoButtonEnabled(_ enabled: Bool) {
        noUIButton.isEnabled = enabled
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
