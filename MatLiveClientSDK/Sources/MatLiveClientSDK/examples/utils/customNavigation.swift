//
//  Coordinator.swift
//  SwiftUICoordinator
//
//  Created by anas amer on 31.11.2024.
//

import SwiftUI

enum Page: Identifiable ,Hashable{
    case HomeScreen
    case AudioScreen(roomId: String, roomName: String)

    var id: String {
        switch self {
        case .HomeScreen:
            return "HomeScreen"
        case .AudioScreen(let roomId, let roomName):
            return "AudioScreen:\(roomId):\(roomName)"
        }
    }
}

enum Sheet: Identifiable {
    case SeatActionSheet(MatLiveRoomAudioSeat)
    
    var id: String {
        switch self {
        case .SeatActionSheet(_):
            return "SeatActionSheet"
        }
    }
}

enum FullScreenCover: Identifiable {
    case HomeScreen
    case AudioScreen(roomId: String, roomName: String)
    
    var id: String {
        switch self {
        case .HomeScreen:
            return "HomeScreen"
        case .AudioScreen(let roomId, let roomName):
            return "AudioScreen_\(roomId)_\(roomName)"
        }
    }
}

class Coordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func present(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .HomeScreen:
            HomeScreen()
        case .AudioScreen(let roomId, let token):
            AudioScreen(roomId: roomId, token: token)
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
        case .SeatActionSheet(let seat):
            NavigationStack {
                SeatContentWidget(seat: seat)
            }
        }
    }
    
    @ViewBuilder
    func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .HomeScreen:
            NavigationStack {
              HomeScreen()
            }
        case .AudioScreen(let roomId, let token):
            AudioScreen(roomId: roomId, token: token)
        }
    }
    
}
