import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBettertThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}
