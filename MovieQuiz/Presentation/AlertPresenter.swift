import Foundation
import UIKit

final class AlertPresenter {
    static func presentAlert(from viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = model.accessibilityIndicator

        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
}
