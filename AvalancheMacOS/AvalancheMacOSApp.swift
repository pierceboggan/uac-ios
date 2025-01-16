//
//  AvalancheMacOSApp.swift
//  AvalancheMacOS
//
//  Created by Pierce Boggan on 1/16/25.
//

import SwiftUI
import AppKit

@main
struct AvalancheMacOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "snow", accessibilityDescription: "Avalanche Forecast")
            button.action = #selector(showPopover(_:))
        }
    }

    @objc func showPopover(_ sender: AnyObject?) {
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.behavior = .transient
        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
