//
//  ContentView.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 24/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = Coordinator()
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .HomeScreen)
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet: sheet)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { fullScreenCover in
                    coordinator.build(fullScreenCover: fullScreenCover)
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    ContentView()
        .environmentObject(Coordinator())
}
