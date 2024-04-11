import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
  let id: String
  let rank: Int
  let title: String
  let fullTitle: String
  let year: String
  let image: String
  let crew: String
  let imDbRating: Double
  let imDbRatingCount: Int


    struct Top: Decodable {
        let items: [Movie]
    }

    enum CodingKeys: CodingKey {
        case id, rank, title, fullTitle, year, image, crew, imDbRating, imDbRatingCount
    }

    enum ParseError: Error {
        case rankFailure
        case imDbRatingFailure
        case imDbRatingCountFailure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        self.rank = rankValue
        
        title = try container.decode(String.self, forKey: .title)
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        
        year = try container.decode(String.self, forKey: .year)
        image = try container.decode(String.self, forKey: .image)
        crew = try container.decode(String.self, forKey: .crew)
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let imDbRatingValue = Double(imDbRating) else {
            throw ParseError.imDbRatingFailure
        }
        self.imDbRating = imDbRatingValue
    
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let imDbRatingCountValue = Int(imDbRatingCount) else {
            throw ParseError.imDbRatingFailure
        }
        self.imDbRatingCount = imDbRatingCountValue
    }
}
    


