//
//  mat_live_room_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

import Foundation
import SwiftUI
import Combine
internal import LiveKit

public enum ParticipantTrackType {
    case userMedia
    case screenShare
}

public class ParticipantTrack {
    var participant: Participant
    var type: ParticipantTrackType
    
    init(participant: Participant, type: ParticipantTrackType = .userMedia) {
        self.participant = participant
        self.type = type
    }
}

private protocol LiveRoomDelegate:RoomDelegate{
    
}

public class MatLiveRoomManager: ObservableObject {
    nonisolated(unsafe) public static let shared = MatLiveRoomManager()
    @Published public var participantTracks: [ParticipantTrack] = []
    @Published var room: Room?
    @Published public var seatService: RoomSeatService?
    @Published public var matLiveJoinRoomManager = MatLiveJoinRoomManager.shared
    
    var isSetup: Bool = false
    var flagStartedReplayKit: Bool = false
    var onInvitedToMic:((Int)->Void)?
    var onSendGift:((String)->Void)?
    
    private init() {}

    func setup(onInvitedToMic:((Int)->Void)?,onSendGift:((String)->Void)?) async throws {
        guard room != nil && !isSetup else { return }
        try await askPublish(enable: false)
        self.seatService = await RoomSeatService()
        room?.add(delegate: self)
        isSetup = true
    }

    public  func close() async {

        isSetup = false
        await seatService?.clear()
        LiveRoomEventReceiverManager.shared.messages = []
        room?.remove(delegate: self)
        await room?.disconnect()
    }

    public func takeSeat(seatIndex: Int) async throws {
        try await askPublish(enable: true)
        await seatService?.takeSeat(
            seatIndex: seatIndex,
            user: matLiveJoinRoomManager.currentUser!
        )
    }

    public  func lockSeat(seatIndex: Int) async throws {
        await seatService?.lockSeat(seatIndex)
    }

    public func unlockSeat(seatIndex: Int) async throws {
        await seatService?.unlockSeat(seatIndex)
    }

    public  func leaveSeat(seatIndex: Int) async throws {
        try await askPublish(enable: false)
        await seatService?.leaveSeat(
            seatIndex,
            matLiveJoinRoomManager.currentUser!.userId
        )
    }

    @MainActor
    public func sendMessage(_ message: String) async throws {
        LiveRoomEventReceiverManager.shared.messages.append(MatLiveChatMessage(
            roomId: matLiveJoinRoomManager.roomId,
            message: message, user: matLiveJoinRoomManager.currentUser!
        ))
        await LiveRoomEventSenderManager().sendMessage(message: message)
    }

    public func muteSeat(seatIndex: Int) async throws {
        try await askPublishMute(enable: true)
        await seatService?.muteSeat(seatIndex)
    }

    public func unmuteSeat(seatIndex: Int) async throws {
        try await askPublishMute(enable: false)
        await seatService?.unMuteSeat(seatIndex)
    }

    public func removeUserFromSeat(seatIndex: Int) async throws {
        await seatService?.removeUserFromSeat(seatIndex)
    }

    public func switchSeat(toSeatIndex: Int) async throws {
        guard let userId = matLiveJoinRoomManager.currentUser?.userId,
              let seatId = await  seatService?.seatList.firstIndex(where: { $0.currentUser?.userId == userId }) else { return }
        await seatService?.switchSeat(from: seatId, to: toSeatIndex, userId: userId)
    }


    private func askPublishMute(enable: Bool) async throws {
        if enable {
            try await room?.localParticipant.setMicrophone(enabled: true)
        } else {
            try await room?.localParticipant.setMicrophone(enabled: false)
        }
    }

    private func askPublish(enable: Bool) async throws {
        if enable {
            try await matLiveJoinRoomManager.audioTrack?.start()
        } else {
            try await matLiveJoinRoomManager.audioTrack?.stop()
        }
        try await room?.localParticipant.setMicrophone(enabled: enable)
        try await room?.localParticipant.setCamera(enabled: false)

    }
    
    private func sortedParticipants(){
        var userMediaTracks:[ParticipantTrack] = []
        room!.remoteParticipants.values.forEach { participant in
            participant.videoTracks.forEach { track in
                if !(track.kind == .video && track.track?.source == .screenShareVideo) {
                    userMediaTracks.append(ParticipantTrack(participant: participant))
                }
            }
            //            if !participant.isScreenShareEnabled(){
            //                userMediaTracks.append(ParticipantTrack(participant: participant))
            //            }
        }
        userMediaTracks.sort(by: {$0.participant.joinedAt ?? Date() < $1.participant.joinedAt ?? Date()})
        
        let localParticipantTracks = room!.localParticipant.localVideoTracks
        localParticipantTracks.forEach { track in
            if !(track.kind == .video && track.track?.source == .screenShareVideo) {
                userMediaTracks.append(ParticipantTrack(participant: room!.localParticipant))
            }
        }
        participantTracks = userMediaTracks
    }
}

extension MatLiveRoomManager:LiveRoomDelegate{
    
    func room(_ room: Room, participant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        sortedParticipants()
 
    }
    
    func room(_ room: Room, participant: LocalParticipant, didUnpublishTrack publication: LocalTrackPublication) {
        sortedParticipants()
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        sortedParticipants()
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        sortedParticipants()
    }
    
    func room(_ room: Room, trackPublication: TrackPublication, didUpdateE2EEState state: E2EEState) {
        print("e2ee state: \(state)");
    }
    
    func room(_ room: Room, participant: Participant, didUpdateName name: String){
        sortedParticipants()
    }
    
    
    func room(_ room: Room, didUpdateMetadata metadata: String?){
        guard let metadata = metadata  , !metadata.isEmpty , metadata.contains("seats") else{return}
        Task{
           await seatService?.seatsFromMetadata(metadata)
        }
      
    }
    
    func room(_ room: Room, didDisconnectWithError error: LiveKitError?){
        if error != nil{
            print("RoomDisconnected \(error!.type.description)")
        }
        
    }
    
    func room(_ room: Room, didUpdateIsRecording isRecording: Bool){
        print("isRecording status \(isRecording)")
    }
    
    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String){
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return
            }
            LiveRoomEventReceiverManager.shared.receivedData(data: jsonObject, onInvitedToMic: onInvitedToMic, onSendGift: onSendGift)
        } catch {
            print("Error in decode data \(error.localizedDescription) ")
        }
        
    }
    func participant(_ participant: LocalParticipant, remoteDidSubscribeTrack publication: LocalTrackPublication){
        
        sortedParticipants()
        
    }
    
}

