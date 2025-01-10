//
//  mat_live_chat_message.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation

/// A class representing a chat message in the MatLive Room.
/// Conforms to `Identifiable` to be used easily in SwiftUI lists and views.
public class MatLiveChatMessage: Identifiable {
    
    /// A unique identifier for the chat message.
    /// Automatically generated using `UUID`.
    public var id = UUID()
    
    /// The ID of the room where the message was sent.
    /// - Note: This is optional as the message might not always be associated with a room.
    public var roomId: String?
    
    /// The content of the message.
    public var message: String
    
    /// The user who sent the message.
    public var user: MatLiveUser
    
    /// Initializes a new instance of `MatLiveChatMessage`.
    /// - Parameters:
    ///   - roomId: The ID of the room where the message was sent, if applicable.
    ///   - message: The content of the message.
    ///   - user: The user who sent the message.
    public init(roomId: String?, message: String, user: MatLiveUser) {
        self.roomId = roomId
        self.message = message
        self.user = user
    }
}
