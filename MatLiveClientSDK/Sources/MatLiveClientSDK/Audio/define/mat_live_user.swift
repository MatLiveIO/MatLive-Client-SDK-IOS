//
//  mat_live_user.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI
import Combine

/// A class representing a user in the MatLive Room.
public class MatLiveUser: ObservableObject {
    
    // MARK: - Properties
    
    /// A unique identifier for the user.
    public var userId: String
    
    /// The name of the user.
    public var name: String
    
    /// The avatar image or identifier for the user.
    public var avatar: String
    
    /// The ID of the room the user is currently in.
    public var roomId: String
    
    /// Additional metadata about the user. Optional.
    public var metaData: String?
    
    /// The stream ID associated with the user. Optional and reactive.
    @Published public var streamID: String?
    
    /// The view ID for rendering video content. Defaults to -1.
    @Published public var viewID: Int = -1
    
    /// The video view to display the user's video stream. Optional and reactive.
    @Published public var videoView: AnyView? // Updated to `AnyView` for compatibility with SwiftUI.
    
    /// Indicates whether the user's camera is turned on. Reactive.
    @Published public var isCameraOn: Bool = false
    
    /// Indicates whether the user's microphone is turned on. Defaults to `true` and reactive.
    @Published public var isMicOn: Bool = true
    
    /// The URL of the user's avatar. Optional and reactive.
    @Published public var avatarUrl: String? // Allows dynamic updates to the avatar URL.
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `MatLiveUser`.
    /// - Parameters:
    ///   - userId: A unique identifier for the user.
    ///   - name: The name of the user.
    ///   - avatar: The avatar image or identifier for the user.
    ///   - roomId: The ID of the room the user is currently in.
    ///   - metaData: Additional metadata about the user. Defaults to `nil`.
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





