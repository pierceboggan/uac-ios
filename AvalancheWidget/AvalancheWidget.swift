//
//  AvalancheWidget.swift
//  AvalancheWidget
//
//  Created by Pierce Boggan on 11/12/24.
//

import WidgetKit
import SwiftUI
import AvalancheShared

struct AvalancheWidget: Widget {
    private let kind: String = "AvalancheWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AvalancheTimelineProvider()) { entry in
            AvalancheWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Avalanche Forecast")
        .description("Current avalanche conditions for Salt Lake area")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct AvalancheWidgetEntryView: View {
    let entry: AvalancheEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let imageData = entry.imageData,
           let uiImage = UIImage(data: imageData) {
            GeometryReader { geometry in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .padding(4)
            }
        } else {
            VStack {
                Image(systemName: "mountain.2")
                    .font(.system(size: 40))
                Text("Loading Forecast...")
                    .font(.caption)
            }
            .padding(8)
        }
    }
}

#Preview(as: .systemLarge) {
    AvalancheWidget()
} timeline: {
    AvalancheEntry(date: .now, avalancheData: .placeholder, imageData: nil)
}
