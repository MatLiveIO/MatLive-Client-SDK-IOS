//
//  live_room_event_receiver_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI
import Combine
internal import LiveKit


public class LiveRoomEventReceiverManager: ObservableObject {
    nonisolated(unsafe) public static let shared = LiveRoomEventReceiverManager()
    var seatService: RoomSeatService?
    @Published public var messages: [MatLiveChatMessage] = [] // Observing messages list
    @Published public var inviteRequests: [MatLiveRequestTackMic] = [] // Observing messages list
    @Published public var matliveJoinRoomManager = MatLiveJoinRoomManager.shared
    @Published public var matliveRoomManager = MatLiveRoomManager.shared
    private init(){}
    

    public nonisolated func receivedData(data: [String: Any],
                      onInvitedToMic: ((Int) -> Void)?,
                      onSendGift: ((String) -> Void)?
    )async {
        guard let event = data["event"] as? Int else { return }
        guard let user = data["user"] as? [String: Any] else { return }
        
        let matUser = MatLiveUser(
            userId: user["userId"] as! String,
            name: user["name"] as! String,
            avatar: user["avatar"] as! String,
            roomId: data["roomId"] as! String
        )
        
        switch event {
        case MatLiveEvents.sendMessage:
            if let message = data["message"] as? String {
                let chatMessage = MatLiveChatMessage(roomId: matUser.roomId, message: message, user: matUser)
                Task { @MainActor in
                    self.messages.append(chatMessage)
                }
            }
            
        case MatLiveEvents.removeUserFromSeat:
            guard data["userId"] as? String == matliveJoinRoomManager.currentUser?.userId else{return}
            try? await matliveJoinRoomManager.audioTrack?.stop()
            do{
                try await matliveRoomManager.room?.localParticipant.setMicrophone(enabled: false)
            } catch{
                print(error.localizedDescription)
            }
            matliveRoomManager.onMic = false
            
        case MatLiveEvents.clearChat:
            self.messages = []
            
        case MatLiveEvents.inviteUserToTakeMic:
            guard let userid = data["userId"] as? String else{return}
            guard matliveJoinRoomManager.currentUser?.userId == userid && onInvitedToMic != nil else {return}
            guard let seatIndex = data["seatIndex"] as? Int else{return}
            onInvitedToMic!(seatIndex)
            
        case MatLiveEvents.leaveSeat:
            // Handle leave room
            break
            
        case MatLiveEvents.requestTakeMic:
            // Handle request to take mic
            if let seatIndex = data["seatIndex"] as? Int {
                let newRequest = MatLiveRequestTackMic(seatIndex: seatIndex, user: matUser)
                self.inviteRequests.append(newRequest)
            }
            break
        case MatLiveEvents.sendGift:
            if onSendGift != nil , let gift = data["gift"] as? String {
                onSendGift!(gift)
            }
        default:
            break
        }
        
    }
}
