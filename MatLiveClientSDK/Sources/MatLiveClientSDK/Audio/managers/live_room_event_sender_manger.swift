//
//  live_room_event_sender_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

import Foundation
import SwiftUI
import Combine

/// Manager for sending live room events
public class LiveRoomEventSenderManager {
//    // Singleton instance for the room manager
    var roomManager = MatLiveRoomManager.shared
    var currentUser = MatLiveJoinRoomManager.shared
    /// Publish event data to the room
    private func publish(data: [String: Any]) async throws {
        guard let room = roomManager.room else { return }
        var data = data

        // Adding user and room details to the data
        if let currentUser = currentUser.currentUser {
            data["user"] = [
                "userId": currentUser.userId,
                "name": currentUser.name,
                "avatar": currentUser.avatar
            ]
        }
        data["roomId"] = room.name
        // Encoding the data to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let decodedData = Data(jsonData)

        // Publishing the data
        try await room.localParticipant.publish(data: decodedData)
    }

    // MARK: Event Functions

    /// Send a chat message
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

    /// Clear the chat
    func clearChat() async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.clearChat
            ])
        } catch {
            print("Failed to clear chat: \(error)")
        }
    }

    /// Invite a user to take the mic
    func inviteUserToTakeMic(userId: String, seatIndex: Int) async {
        do {
            try await publish(data: [
                "event": MatLiveEvents.inviteUserToTakeMic,
                "seatIndex": seatIndex,
                "userId":userId
            ])
        } catch {
            print("Failed to invite user to take mic: \(error)")
        }
    }


    /// Request to take the mic
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

    func sendGift(gift:String)async{
        do {
            try await publish(data: [
                "event": MatLiveEvents.sendGift,
                "gift": gift
            ])
        } catch {
            print("Failed to request to take mic: \(error)")
        }
    }
    
}
