//
//  ContentView.swift
//  AvalancheMacOS
//
//  Created by Pierce Boggan on 1/16/25.
//

import SwiftUI
import AvalancheShared

struct ContentView: View {
    @State private var avalancheData: AvalancheData = .placeholder
    @State private var lastFetchTime: Date? = nil

    var body: some View {
        VStack {
            AvalancheRoseView(avalancheData: avalancheData)
            Text(avalancheData.formattedAdvisoryDate)
                .padding()
        }
        .onAppear(perform: fetchAvalancheData)
        .padding()
    }

    private func fetchAvalancheData() {
        let now = Date()
        if let lastFetchTime = lastFetchTime, now.timeIntervalSince(lastFetchTime) < 3600 {
            return
        }
        lastFetchTime = now

        if let cachedData = UserDefaults.standard.data(forKey: "cachedAvalancheData"),
           let cachedAvalancheData = try? JSONDecoder().decode(AvalancheData.self, from: cachedData) {
            self.avalancheData = cachedAvalancheData
        }

        guard let url = URL(string: "https://utahavalanchecenter.org/forecast/salt-lake/json") else {
            print("Invalid URL")
            return
        }

        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Error code: \(nsError.code)")
                    print("Error domain: \(nsError.domain)")
                    print("User info: \(nsError.userInfo)")
                }
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AvalancheResponse.self, from: data)
                if let firstAdvisory = response.advisories.first {
                    DispatchQueue.main.async {
                        self.avalancheData = firstAdvisory.advisory
                        if let encodedData = try? JSONEncoder().encode(firstAdvisory.advisory) {
                            UserDefaults.standard.set(encodedData, forKey: "cachedAvalancheData")
                        }
                    }
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}

#Preview {
    ContentView()
}
