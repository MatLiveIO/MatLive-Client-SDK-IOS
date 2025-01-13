//
//  mat_live_user.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI
import Combine

public class MatLiveUser: ObservableObject {
    public var userId: String
    public var name: String
    public var avatar: String
    public var roomId: String
    public var metaData:String?
    
    @Published public var streamID: String?
    @Published public var viewID: Int = -1
    @Published public var videoView: AnyView? // Updated to AnyView for SwiftUI compatibility
    @Published public var isCameraOn: Bool = false
    @Published public var isMicOn: Bool = true
    @Published public var avatarUrl: String? // Changed to String? to align with SwiftUI's reactive state
    
   public init(userId: String, name: String, avatar: String, roomId: String, metaData: String? = nil) {
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.roomId = roomId
        self.metaData = metaData
    }
}


enum MatLiveUserRole {
    case audience
    case coHost
    case host
}





