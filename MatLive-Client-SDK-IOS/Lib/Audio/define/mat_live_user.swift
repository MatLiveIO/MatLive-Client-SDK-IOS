//
//  mat_live_user.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI

class MatLiveUser: ObservableObject {
    @ObservationIgnored var userId: String
    @ObservationIgnored var name: String
    @ObservationIgnored var avatar: String
    @ObservationIgnored var roomId: String
    
    @Published var streamID: String?
    @Published var viewID: Int = -1
    @Published var videoView: AnyView? // Updated to AnyView for SwiftUI compatibility
    @Published var isCameraOn: Bool = false
    @Published var isMicOn: Bool = true
    @Published var avatarUrl: String? // Changed to String? to align with SwiftUI's reactive state
    
    init(userId: String, name: String, avatar: String, roomId: String) {
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.roomId = roomId
        self.avatarUrl = avatar
    }
}


enum MatLiveUserRole {
    case audience
    case coHost
    case host
}





