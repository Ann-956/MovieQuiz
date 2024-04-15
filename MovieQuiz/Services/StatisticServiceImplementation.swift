import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    let userDefaults = UserDefaults.standard
    
    func store(correct count: Int, total amount: Int) {
        var currentBestGame = bestGame
        let record = GameRecord(correct: count, total: amount, date: Date())
  
        if record.isBettertThan(currentBestGame) {
            currentBestGame = record
            bestGame = currentBestGame
        }
        
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        userDefaults.set(totalCorrect, forKey: Keys.correct.rawValue)

        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        userDefaults.set(totalQuestions, forKey: Keys.total.rawValue)
        
        gamesCount += 1
    }

    
    var totalAccuracy: Double {
        get {
            let totalCorrect = Double(userDefaults.integer(forKey: Keys.correct.rawValue))
            let totalQuestions = Double(userDefaults.integer(forKey: Keys.total.rawValue))
            
            guard totalQuestions > 0 else {
                return 0.0
            }
            
            return (totalCorrect / totalQuestions) * 100.0
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                    return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            } catch {
                print("Невозможно сохранить результат: \(error)")
            }
        }
    }
}
