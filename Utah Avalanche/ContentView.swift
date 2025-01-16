//
//  ContentView.swift
//  Utah Avalanche
//
//  Created by Pierce Boggan on 11/12/24.
//

import SwiftUI

struct AvalancheResponse: Codable {
    let advisories: [Advisory]
}

struct Advisory: Codable {
    let advisory: AvalancheConditions
}

struct AvalancheConditions: Codable {
    let advisoryDateString: String
    let overallDangerRoseImage: String
    let conditions: String
    let mountainWeather: String
    
    enum CodingKeys: String, CodingKey {
        case advisoryDateString = "date_issued"
        case overallDangerRoseImage = "overall_danger_rose_image"
        case conditions = "current_conditions"
        case mountainWeather = "mountain_weather"
    }
    
    var cleanConditions: String {
        cleanText(conditions)
    }
    
    var cleanMountainWeather: String {
        cleanText(mountainWeather)
    }
    
    var cleanAdvisoryDate: String {
        avalancheData.formattedAdvisoryDate
    }
    
    private func cleanText(_ text: String) -> String {
        text.replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ContentView: View {
    @State private var conditions: AvalancheConditions?
    @State private var selectedRegion = "salt-lake"
    @State private var lastFetchTime: Date? = nil
    
    let regions = ["logan", "ogden", "uintas", "salt-lake", "provo", "skyline", "moab", "abajos", "southwest"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Region", selection: $selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region.capitalized)
                                .tag(region)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if let conditions = conditions {
                        AsyncImage(url: URL(string: "https://utahavalanchecenter.org/" + conditions.overallDangerRoseImage)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            InfoSection(title: "Advisory Date", content: conditions.cleanAdvisoryDate)
                            InfoSection(title: "Conditions", content: conditions.cleanConditions)
                            InfoSection(title: "Mountain Weather", content: conditions.cleanMountainWeather)
                        }
                        .padding()
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Avalanche Conditions")
            .onChange(of: selectedRegion) { _ in
                fetchConditions()
            }
            .onAppear {
                fetchConditions()
            }
        }
    }
    
    private func fetchConditions() {
        let now = Date()
        if let lastFetchTime = lastFetchTime, now.timeIntervalSince(lastFetchTime) < 3600 {
            return
        }
        lastFetchTime = now
        
        guard let url = URL(string: "https://utahavalanchecenter.org/forecast/\(selectedRegion)/json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(AvalancheResponse.self, from: data)
                    if let firstAdvisory = response.advisories.first {
                        DispatchQueue.main.async {
                            self.conditions = firstAdvisory.advisory
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
        }
    }
}

#Preview {
    ContentView()
}
