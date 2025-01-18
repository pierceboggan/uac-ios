import Foundation

public struct AvalancheData: Codable {
    public let advisoryDateString: String
    public let overallDangerRoseImage: String
    public let conditions: String
    public let mountainWeather: String?
    
    enum CodingKeys: String, CodingKey {
        case advisoryDateString = "date_issued"
        case overallDangerRoseImage = "overall_danger_rose_image"
        case conditions = "current_conditions"
        case mountainWeather = "mountain_weather"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.advisoryDateString = try container.decode(String.self, forKey: .advisoryDateString)
        self.overallDangerRoseImage = try container.decode(String.self, forKey: .overallDangerRoseImage)
        self.conditions = try container.decode(String.self, forKey: .conditions)
        self.mountainWeather = try container.decodeIfPresent(String.self, forKey: .mountainWeather)
    }
    
    public init(advisoryDateString: String, overallDangerRoseImage: String, conditions: String, mountainWeather: String?) {
        self.advisoryDateString = advisoryDateString
        self.overallDangerRoseImage = overallDangerRoseImage
        self.conditions = conditions
        self.mountainWeather = mountainWeather
    }
    
    public static var placeholder: AvalancheData {
        return AvalancheData(
            advisoryDateString: "Loading...",
            overallDangerRoseImage: "",
            conditions: "",
            mountainWeather: nil
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
    
    public var cleanConditions: String {
        cleanText(conditions)
    }
    
    public var cleanMountainWeather: String {
        cleanText(mountainWeather ?? "")
    }
    
    private func cleanText(_ text: String) -> String {
        text.replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
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