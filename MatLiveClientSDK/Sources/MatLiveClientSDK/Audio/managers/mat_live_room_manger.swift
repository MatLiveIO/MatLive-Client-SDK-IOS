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


/// Represents the type of track a participant can have in a live room.
public enum ParticipantTrackType {
    /// Represents user media tracks, such as camera or microphone.
    case userMedia

    /// Represents screen sharing tracks.
    case screenShare
}

/// Represents a track associated with a participant in a live room.
public class ParticipantTrack {
    /// The participant associated with this track.
    var participant: Participant

    /// The type of track (user media or screen share).
    var type: ParticipantTrackType

    /// Initializes a new `ParticipantTrack`.
    /// - Parameters:
    ///   - participant: The participant associated with the track.
    ///   - type: The type of track, defaulting to `.userMedia`.
    init(participant: Participant, type: ParticipantTrackType = .userMedia) {
        self.participant = participant
        self.type = type
    }
}

/// Private protocol extending `RoomDelegate` for live room events.
private protocol LiveRoomDelegate: RoomDelegate {}

/// Manages the live room session, including participants, seats, and interactions.
public class MatLiveRoomManager: ObservableObject {
    /// Shared singleton instance of `MatLiveRoomManager`.
    public static let shared = MatLiveRoomManager()

    /// List of participant tracks in the room.
    @Published public var participantTracks: [ParticipantTrack] = []

    /// The current room instance.
    @Published var room: Room?

    /// Service managing room seats.
    @Published public var seatService: RoomSeatService?

    /// Instance of `MatLiveJoinRoomManager` for managing room join operations.
    @Published public var matLiveJoinRoomManager = MatLiveJoinRoomManager.shared

    /// Indicates whether the local user is on the microphone.
    public var onMic: Bool = false

    /// Tracks whether the manager is set up.
    var isSetup: Bool = false

    /// Flag indicating if ReplayKit has started.
    var flagStartedReplayKit: Bool = false

    /// Callback for handling microphone invitations.
    public var onInvitedToMic: ((Int) -> Void)?

    /// Callback for sending gifts in the live room.
    public var onSendGift: ((String) -> Void)?

    /// Private initializer for singleton.
    private init() {}

    /// Sets up the live room manager.
    /// - Parameters:
    ///   - onInvitedToMic: Callback for microphone invitations.
    ///   - onSendGift: Callback for sending gifts.
    func setup(onInvitedToMic: ((Int) -> Void)?, onSendGift: ((String) -> Void)?) async throws {
        guard room != nil && !isSetup else { return }
        try await askPublish(enable: false)
        self.seatService = await RoomSeatService()
        room?.add(delegate: self)
        isSetup = true
    }

    /// Closes the live room session and clears resources.
    public func close() async {
        isSetup = false
        await seatService?.clear()
        LiveRoomEventReceiverManager.shared.messages = []
        room?.remove(delegate: self)
        await room?.disconnect()
    }

    /// Takes a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to occupy.
    public func takeSeat(seatIndex: Int) async throws {
        try await askPublish(enable: true)
        onMic = true
        await seatService?.takeSeat(
            seatIndex: seatIndex,
            user: matLiveJoinRoomManager.currentUser!
        )
    }

    /// Locks a seat to prevent others from occupying it.
    /// - Parameter seatIndex: The index of the seat to lock.
    public func lockSeat(seatIndex: Int) async throws {
        await seatService?.lockSeat(seatIndex)
    }

    /// Unlocks a previously locked seat.
    /// - Parameter seatIndex: The index of the seat to unlock.
    public func unlockSeat(seatIndex: Int) async throws {
        await seatService?.unlockSeat(seatIndex)
    }

    /// Leaves a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to leave.
    public func leaveSeat(seatIndex: Int) async throws {
        try await askPublish(enable: false)
        onMic = false
        await seatService?.leaveSeat(
            seatIndex,
            matLiveJoinRoomManager.currentUser!.userId
        )
    }

    /// Sends a message to the live room.
    /// - Parameter message: The message to send.
    @MainActor
    public func sendMessage(_ message: String) async throws {
        LiveRoomEventReceiverManager.shared.messages.append(MatLiveChatMessage(
            roomId: matLiveJoinRoomManager.roomId,
            message: message, user: matLiveJoinRoomManager.currentUser!
        ))
        await LiveRoomEventSenderManager().sendMessage(message: message)
    }

    /// Mutes a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to mute.
    public func muteSeat(seatIndex: Int) async throws {
        try await askPublishMute(enable: true)
        await seatService?.muteSeat(seatIndex)
    }

    /// Unmutes a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to unmute.
    public func unmuteSeat(seatIndex: Int) async throws {
        try await askPublishMute(enable: false)
        await seatService?.unMuteSeat(seatIndex)
    }

    /// Removes a user from a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to remove the user from.
    public func removeUserFromSeat(seatIndex: Int) async throws {
        let userId = await seatService?.removeUserFromSeat(seatIndex)
        if let userId {
            await LiveRoomEventSenderManager().removeSpecker(seatIndex: seatIndex, userId: userId)
        }
    }

    /// Switches a user from one seat to another.
    /// - Parameter toSeatIndex: The index of the seat to switch to.
    public func switchSeat(toSeatIndex: Int) async throws {
        guard let userId = matLiveJoinRoomManager.currentUser?.userId,
              let seatId = await seatService?.seatList.firstIndex(where: { $0.currentUser?.userId == userId }) else { return }
        await seatService?.switchSeat(from: seatId, to: toSeatIndex, userId: userId)
    }

    /// Requests to enable or disable publishing for microphone and camera.
    /// - Parameter enable: Whether to enable or disable publishing.
    private func askPublish(enable: Bool) async throws {
        if enable {
            try await matLiveJoinRoomManager.audioTrack?.start()
        } else {
            try await matLiveJoinRoomManager.audioTrack?.stop()
        }
        try await room?.localParticipant.setMicrophone(enabled: enable)
        try await room?.localParticipant.setCamera(enabled: false)
    }

    /// Requests to mute or unmute the microphone.
    /// - Parameter enable: Whether to enable or disable the microphone.
    private func askPublishMute(enable: Bool) async throws {
        if enable {
            try await room?.localParticipant.setMicrophone(enabled: true)
        } else {
            try await room?.localParticipant.setMicrophone(enabled: false)
        }
    }

    /// Sorts participants in the room based on join time.
    private func sortedParticipants() {
        var userMediaTracks: [ParticipantTrack] = []
        room!.remoteParticipants.values.forEach { participant in
            participant.videoTracks.forEach { track in
                if !(track.kind == .video && track.track?.source == .screenShareVideo) {
                    userMediaTracks.append(ParticipantTrack(participant: participant))
                }
            }
        }
        userMediaTracks.sort(by: { $0.participant.joinedAt ?? Date() < $1.participant.joinedAt ?? Date() })

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
            Task{
                await  LiveRoomEventReceiverManager.shared.receivedData(data: jsonObject, onInvitedToMic: onInvitedToMic, onSendGift: onSendGift)
            }
        } catch {
            print("Error in decode data \(error.localizedDescription) ")
        }
        
    }
    func participant(_ participant: LocalParticipant, remoteDidSubscribeTrack publication: LocalTrackPublication){
        
        sortedParticipants()
        
    }
    
}

