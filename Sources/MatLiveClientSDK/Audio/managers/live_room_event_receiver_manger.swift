//
//  live_room_event_receiver_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
internal import LiveKit

/// Manages live room events and updates relevant state based on received data.
public class LiveRoomEventReceiverManager: ObservableObject {
    
    /// Shared instance of `LiveRoomEventReceiverManager`.
    nonisolated(unsafe) public static let shared = LiveRoomEventReceiverManager()
    
    /// Service responsible for managing room seat operations.
    var seatService: RoomSeatService?
    
    /// List of chat messages in the room, updated when a new message is received.
    @Published public var messages: [MatLiveChatMessage] = []
    
    /// List of mic-taking requests, updated when a new request is made.
    @Published public var inviteRequests: [MatLiveRequestTackMic] = []
    
    /// Manager responsible for joining rooms in the MatLive system.
    @Published public var matliveRoomManager = MatLiveRoomManager.shared
    
    // Private initializer to ensure only one instance of this manager.
    private init() {}
    
    /// Receives event data from the live room and handles various events like messages, mic requests, and gifts.
    /// - Parameters:
    ///   - data: A dictionary containing the event data.
    ///   - onInvitedToMic: A closure called when the user is invited to take the microphone.
    ///   - onSendGift: A closure called when a gift is sent.
    public nonisolated func receivedData(data: [String: Any],
                                         onInvitedToMic: ((Int) -> Void)?,
                                         onSendGift: ((String) -> Void)?) async {
        // Extract event type and user data from the received data.
        guard let event = data["event"] as? Int else { return }
        guard let user = data["user"] as? [String: Any] else { return }
        
        let matUser = MatLiveUser(
            userId: user["userId"] as! String,
            name: user["name"] as! String,
            avatar: user["avatar"] as! String,
            roomId: data["roomId"] as! String
        )
        
        // Switch statement to handle different event types.
        switch event {
        case MatLiveEvents.sendMessage:
            if let message = data["message"] as? String {
                let chatMessage = MatLiveChatMessage(roomId: matUser.roomId, message: message, user: matUser)
                Task { @MainActor in
                    self.messages.append(chatMessage)
                }
            }
            
        case MatLiveEvents.removeUserFromSeat:
            guard data["userId"] as? String == matliveRoomManager.currentUser?.userId else { return }
            try? await matliveRoomManager.audioTrack?.stop()
            do {
                try await matliveRoomManager.room?.localParticipant.setMicrophone(enabled: false)
            } catch {
                print(error.localizedDescription)
            }
            matliveRoomManager.onMic = false
            
        case MatLiveEvents.clearChat:
            self.messages = []
            
        case MatLiveEvents.inviteUserToTakeMic:
            guard let userid = data["userId"] as? String else { return }
            guard matliveRoomManager.currentUser?.userId == userid && onInvitedToMic != nil else { return }
            guard let seatIndex = data["seatIndex"] as? Int else { return }
            onInvitedToMic!(seatIndex)
            
        case MatLiveEvents.leaveSeat:
            // Handle user leaving the seat (if necessary).
            break
            
        case MatLiveEvents.requestTakeMic:
            if let seatIndex = data["seatIndex"] as? Int {
                let newRequest = MatLiveRequestTackMic(seatIndex: seatIndex, user: matUser)
                self.inviteRequests.append(newRequest)
            }
            break
            
        case MatLiveEvents.sendGift:
            if let gift = data["gift"] as? String {
                onSendGift?(gift)
            }
            
        default:
            break
        }
    }
}
