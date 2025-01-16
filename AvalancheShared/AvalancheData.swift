import Foundation

public struct AvalancheData: Codable {
    public let advisoryDateString: String
    public let overallDangerRoseImage: String
    
    enum CodingKeys: String, CodingKey {
        case advisoryDateString = "date_issued"
        case overallDangerRoseImage = "overall_danger_rose_image"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.advisoryDateString = try container.decode(String.self, forKey: .advisoryDateString)
        self.overallDangerRoseImage = try container.decode(String.self, forKey: .overallDangerRoseImage)
    }
    
    public init(advisoryDateString: String, overallDangerRoseImage: String) {
        self.advisoryDateString = advisoryDateString
        self.overallDangerRoseImage = overallDangerRoseImage
    }
    
    public static var placeholder: AvalancheData {
        return AvalancheData(
            advisoryDateString: "Loading...",
            overallDangerRoseImage: ""
        )
    }
    
    public var formattedAdvisoryDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: advisoryDateString) {
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: date)
        }
        return advisoryDateString
    }
}

public struct AvalancheResponse: Codable {
    public let advisories: [Advisory]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.advisories = try container.decode([Advisory].self, forKey: .advisories)
    }
    
    enum CodingKeys: String, CodingKey {
        case advisories
    }
}

public struct Advisory: Codable {
    public let advisory: AvalancheData
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.advisory = try container.decode(AvalancheData.self, forKey: .advisory)
    }
    
    enum CodingKeys: String, CodingKey {
        case advisory
    }
}