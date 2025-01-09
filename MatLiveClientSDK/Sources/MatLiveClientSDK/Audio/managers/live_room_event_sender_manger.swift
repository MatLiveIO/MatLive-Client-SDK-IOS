//
//  live_room_event_sender_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

import Foundation

/// Manager for sending live room events.
/// Provides functionality to handle various live room events such as sending messages, clearing chat, and managing participants on the mic.
public class LiveRoomEventSenderManager {
    
    /// Singleton instance for the room manager.
    var matlivejoinRoomManager = MatLiveJoinRoomManager.shared
    
    /// Publish event data to the room.
    /// - Parameter data: A dictionary containing the event data to be published.
    private func publish(data: [String: Any]) async throws {
        guard let room = matlivejoinRoomManager.room else { return }
        var data = data
        
        // Adding user and room details to the data.
        if let currentUser = matlivejoinRoomManager.currentUser {
            data["user"] = [
                "userId": currentUser.userId,
                "name": currentUser.name,
                "avatar": currentUser.avatar
            ]
        }
        data["roomId"] = room.name
        
        // Encoding the data to JSON.
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let decodedData = Data(jsonData)
        
        // Publishing the data.
        try await room.localParticipant.publish(data: decodedData)
    }
    
    // MARK: - Event Functions
    
    /// Send a chat message.
    /// - Parameter message: The message to be sent.
    func sendMessage(message: String) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.sendMessage,
                "message": message
            ])
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    /// Clear the chat.
    func clearChat() async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.clearChat
            ])
        } catch {
            print("Failed to clear chat: \(error)")
        }
    }
    
    /// Invite a user to take the mic.
    /// - Parameters:
    ///   - userId: The ID of the user to invite.
    ///   - seatIndex: The index of the seat to assign the user.
    func inviteUserToTakeMic(userId: String, seatIndex: Int) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.inviteUserToTakeMic,
                "seatIndex": seatIndex,
                "userId": userId
            ])
        } catch {
            print("Failed to invite user to take mic: \(error)")
        }
    }
    
    /// Request to take the mic.
    /// - Parameter seatIndex: The index of the seat to request.
    func requestTakeMic(seatIndex: Int) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.requestTakeMic,
                "seatIndex": seatIndex
            ])
        } catch {
            print("Failed to request to take mic: \(error)")
        }
    }
    
    /// Send a gift to the room.
    /// - Parameter gift: The gift to be sent.
    func sendGift(gift: String) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.sendGift,
                "gift": gift
            ])
        } catch {
            print("Failed to send gift: \(error)")
        }
    }
    
    /// Remove a speaker from a seat.
    /// - Parameters:
    ///   - seatIndex: The index of the seat to remove the speaker from.
    ///   - userId: The ID of the user to remove.
    func removeSpecker(seatIndex: Int, userId: String) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.removeUserFromSeat,
                "seatIndex": seatIndex,
                "userId": userId
            ])
        } catch {
            print("Failed to remove speaker: \(error)")
        }
    }
}
