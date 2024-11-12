import WidgetKit
import SwiftUI
import AvalancheShared

struct AvalancheEntry: TimelineEntry {
    let date: Date
    let avalancheData: AvalancheData
    let imageData: Data?
}

struct AvalancheTimelineProvider: TimelineProvider {
    private let networkManager = WidgetNetworkManager.shared
    
    func placeholder(in context: Context) -> AvalancheEntry {
        AvalancheEntry(date: Date(), avalancheData: .placeholder, imageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AvalancheEntry) -> ()) {
        let entry = AvalancheEntry(date: Date(), avalancheData: .placeholder, imageData: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AvalancheEntry>) -> ()) {
        print("Widget: Starting timeline fetch")
        // Fetch forecast data
        networkManager.fetchData(from: "https://utahavalanchecenter.org/forecast/salt-lake/json") { result in
            switch result {
            case .success(let data):
                print("Widget: Got forecast data, length: \(data.count)")
                do {
                    let response = try JSONDecoder().decode(AvalancheResponse.self, from: data)
                    print("Widget: Decoded response")
                    
                    if let firstAdvisory = response.advisories.first?.advisory {
                        print("Widget: Found advisory")
                        // Fetch image data
                        let imageUrl = "https://utahavalanchecenter.org/" + firstAdvisory.overallDangerRoseImage
                        print("Widget: Fetching image from: \(imageUrl)")
                        
                        networkManager.fetchData(from: imageUrl) { imageResult in
                            switch imageResult {
                            case .success(let imageData):
                                print("Widget: Got image data, length: \(imageData.count)")
                                let entry = AvalancheEntry(
                                    date: Date(),
                                    avalancheData: firstAdvisory,
                                    imageData: imageData
                                )
                                
                                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                                completion(timeline)
                                
                            case .failure(let error):
                                print("Widget: Image fetch error: \(error)")
                                fallbackTimeline(completion)
                            }
                        }
                    } else {
                        print("Widget: No advisory found")
                        fallbackTimeline(completion)
                    }
                } catch {
                    print("Widget: Decoding error: \(error)")
                    fallbackTimeline(completion)
                }
            case .failure(let error):
                print("Widget: Network error: \(error)")
                fallbackTimeline(completion)
            }
        }
    }
    
    private func fallbackTimeline(_ completion: @escaping (Timeline<AvalancheEntry>) -> ()) {
        let entry = AvalancheEntry(date: Date(), avalancheData: .placeholder, imageData: nil)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1800)))
        completion(timeline)
    }
} 