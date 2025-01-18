//
//  ContentView.swift
//  Utah Avalanche
//
//  Created by Pierce Boggan on 11/12/24.
//

import SwiftUI
import AvalancheShared

struct AvalancheResponse: Codable {
    let advisories: [Advisory]
}

struct Advisory: Codable {
    let advisory: AvalancheData
}

struct ContentView: View {
    @State private var conditions: AvalancheData?
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
                            InfoSection(title: "Advisory Date", content: conditions.formattedAdvisoryDate)
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
            .onChange(of: selectedRegion) { newRegion in
                print("Region changed to: \(newRegion)")
                fetchConditions()
            }
            .onAppear {
                fetchConditions()
            }
        }
    }
    
    private func fetchConditions() {
        print("Fetching conditions for region: \(selectedRegion)")
        guard let url = URL(string: "https://utahavalanchecenter.org/forecast/\(selectedRegion)/json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(AvalancheResponse.self, from: data)
                    if let firstAdvisory = response.advisories.first {
                        DispatchQueue.main.async {
                            print("Updating conditions state")
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
