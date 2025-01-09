//
//  mat_live_room_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

import Foundation
import SwiftUI
import Combine
public import LiveKit


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
    public var participant: Participant

    /// The type of track (user media or screen share).
    public var type: ParticipantTrackType

    /// Initializes a new `ParticipantTrack`.
    /// - Parameters:
    ///   - participant: The participant associated with the track.
    ///   - type: The type of track, defaulting to `.userMedia`.
    public init(participant: Participant, type: ParticipantTrackType = .userMedia) {
        self.participant = participant
        self.type = type
    }
}

/// Private protocol extending `RoomDelegate` for live room events.
private protocol LiveRoomDelegate: RoomDelegate {}

public class JoinRequest {
    public var url: String
    public var token: String
    public var e2ee: Bool
    public var e2eeKey: String?
    public var simulcast: Bool
    public var adaptiveStream: Bool
    public var dynacast: Bool
    public var preferredCodec: String
    public var enableBackupVideoCodec: Bool

    /// Initializes a new `JoinRequest` with optional parameters for configuration.
    /// - Parameters:
    ///   - url: The server URL to connect to.
    ///   - token: The authentication token for the connection.
    ///   - e2ee: Indicates whether end-to-end encryption is enabled.
    ///   - e2eeKey: The encryption key used for end-to-end encryption.
    ///   - simulcast: Enables simulcast functionality for multiple video streams.
    ///   - adaptiveStream: Enables adaptive streaming for bandwidth management.
    ///   - dynacast: Enables dynamic stream adjustments.
    ///   - preferredCodec: The preferred video codec (default: "VP8").
    ///   - enableBackupVideoCodec: Enables a backup video codec in case of issues.
    public init(url: String = "", token: String = "", e2ee: Bool = false, e2eeKey: String? = nil, simulcast: Bool = true, adaptiveStream: Bool = true, dynacast: Bool = true, preferredCodec: String = "VP8", enableBackupVideoCodec: Bool = true) {
        self.url = url
        self.token = token
        self.e2ee = e2ee
        self.e2eeKey = e2eeKey
        self.simulcast = simulcast
        self.adaptiveStream = adaptiveStream
        self.dynacast = dynacast
        self.preferredCodec = preferredCodec
        self.enableBackupVideoCodec = enableBackupVideoCodec
    }
}

/// Manages the joining process and user participation in a live room.
public class MatLiveJoinRoomManager: ObservableObject {
    /// Singleton instance for shared access.
    nonisolated(unsafe) public static let shared = MatLiveJoinRoomManager()
    /// List of participant tracks in the room.
    @Published public var participantTracks: [ParticipantTrack] = []

    /// The current room instance.
    @Published public var room: Room?

    /// Service managing room seats.
    @Published public var seatService: RoomSeatService?

    /// Indicates whether the local user is on the microphone.
    public var onMic: Bool = false

    /// Tracks whether the manager is set up.
    var isSetup: Bool = false

    /// Flag indicating if ReplayKit has started.
    var flagStartedReplayKit: Bool = false
    
    
    private var selectedAudioDevice: MediaDevice?
    private(set) var audioInputs: [MediaDevice] = []
    private let request = JoinRequest()
    private var subscription: AnyCancellable?
    public var audioTrack: LocalAudioTrack?
    public var currentUser: MatLiveUser?
    public var roomId: String = ""
    public var onInvitedToMic: ((Int) -> Void)?
    public var onSendGift: ((String) -> Void)?
    var permissionsManager: PermissionsManager = PermissionsManager()
    private var matLiveService = MatLiveService()
    /// Private initializer for singleton pattern.
    private init() {}

    /// Initializes the manager with optional callbacks for mic invitations and gift sending.
    public func initialize(onInvitedToMic: ((Int) -> Void)? = nil, onSendGift: ((String) -> Void)? = nil) async {
        request.url = Utils.url
        self.onInvitedToMic = onInvitedToMic
        self.onSendGift = onSendGift
        permissionsManager.checkMicrophonePermission()
        LiveKitSDK.prepare()
    }

    /// Closes the current room and cleans up resources.
    public func close() async {
        subscription?.cancel()
        await stopAudioStream()
        isSetup = false
        await seatService?.clear()
        LiveRoomEventReceiverManager.shared.messages = []
        room?.remove(delegate: self)
        await room?.disconnect()
    }

    /// Loads available audio devices and sets the selected device.
    private func loadDevices(devices: [MediaDevice]) async {
        audioInputs = devices.filter { $0.name == "audioinput" }

        if let firstDevice = audioInputs.first, selectedAudioDevice == nil {
            selectedAudioDevice = firstDevice
            await changeLocalAudioTrack()
        }
    }

    /// Stops the current audio stream.
    private func stopAudioStream() async {
        if audioTrack != nil {
            try? await audioTrack?.stop()
            audioTrack = nil
        }
    }

    /// Changes the local audio track to use the selected audio device.
    private func changeLocalAudioTrack() async {
        if let track = audioTrack {
            try? await track.stop()
        }

        if selectedAudioDevice != nil {
            audioTrack = LocalAudioTrack.createTrack(options: AudioCaptureOptions())
        }
    }

    private func JoinRoom(roomId:String,appKey:String,userName:String,completion:@escaping(String,String)->Void)  async throws {
        let response =  await matLiveService.createToken(userName: userName, roomId: roomId, appKey: appKey)
            
        switch response {
        case .success(let jsonResponse):
            guard let data = jsonResponse["data"] as? [String:Any] ,
                  let newId = data["newRoomName"] as? String ,
                  let token = data["token"] as? String else{
                return
            }
            completion(newId,token)
        case .failure(let failure):
            print("Error create token \(failure.message)")
            throw failure
           
        }
    }
    /// Connects to a room with the provided user details and metadata.
    public func connect(
        name: String,
        appKey:String,
        avatar: String,
        userId: String,
        roomId: String,
        metadata: String?
    ) async throws {
       
        do {
            try await JoinRoom(roomId: roomId, appKey: appKey, userName: name) { [weak self] newId, token in
                self?.request.token = token
                self?.roomId = newId
            }
        } catch  {
            throw error
        }
      
        currentUser = MatLiveUser(
            userId: userId,
            name: name,
            avatar: avatar,
            roomId: self.roomId,
            metaData: metadata
        )

        do {
            var e2eeOptions: E2EEOptions?
            if request.e2ee, let e2eeKey = request.e2eeKey {
                let keyProvider = BaseKeyProvider()
                e2eeOptions = E2EEOptions(keyProvider: keyProvider)
                keyProvider.setKey(key: e2eeKey)
            }
            let room = Room(roomOptions: RoomOptions(
                defaultAudioPublishOptions: AudioPublishOptions(name: "custom_audio_track_name", encoding: .presetMusicHighQualityStereo),
                adaptiveStream: request.adaptiveStream,
                dynacast: request.dynacast,
                e2eeOptions: e2eeOptions
            ))
            try await room.connect(
                url: request.url,
                token: request.token,
                connectOptions: ConnectOptions()
            )
            self.room = room
            try await setup(onInvitedToMic: onInvitedToMic, onSendGift: onSendGift)
        } catch {
           throw error
        }
    }
    



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

    /// Takes a seat in the live room.
    /// - Parameter seatIndex: The index of the seat to occupy.
    public func takeSeat(seatIndex: Int) async throws {
        try await askPublish(enable: true)
        onMic = true
        await seatService?.takeSeat(
            seatIndex: seatIndex,
            user: currentUser!
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
            currentUser!.userId
        )
    }

    /// Sends a message to the live room.
    /// - Parameter message: The message to send.
    @MainActor
    public func sendMessage(_ message: String) async throws {
        LiveRoomEventReceiverManager.shared.messages.append(MatLiveChatMessage(
            roomId: roomId,
            message: message, user: currentUser!
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
        guard let userId = currentUser?.userId,
              let seatId = await seatService?.seatList.firstIndex(where: { $0.currentUser?.userId == userId }) else { return }
        await seatService?.switchSeat(from: seatId, to: toSeatIndex, userId: userId)
    }

    /// Requests to enable or disable publishing for microphone and camera.
    /// - Parameter enable: Whether to enable or disable publishing.
    private func askPublish(enable: Bool) async throws {
        if enable {
            try await audioTrack?.start()
        } else {
            try await audioTrack?.stop()
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


extension MatLiveJoinRoomManager:LiveRoomDelegate{
    
    public func room(_ room: Room, participant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        sortedParticipants()
 
    }
    
    public func room(_ room: Room, participant: LocalParticipant, didUnpublishTrack publication: LocalTrackPublication) {
        sortedParticipants()
    }
    
    public func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        sortedParticipants()
    }
    
    public func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        sortedParticipants()
    }
    
    public func room(_ room: Room, trackPublication: TrackPublication, didUpdateE2EEState state: E2EEState) {
        print("e2ee state: \(state)");
    }
    
    public func room(_ room: Room, participant: Participant, didUpdateName name: String){
        sortedParticipants()
    }
    
    
    public func room(_ room: Room, didUpdateMetadata metadata: String?){
        guard let metadata = metadata  , !metadata.isEmpty , metadata.contains("seats") else{return}
        Task{
           await seatService?.seatsFromMetadata(metadata)
        }
      
    }
    
    public func room(_ room: Room, didDisconnectWithError error: LiveKitError?){
        if error != nil{
            print("RoomDisconnected \(error!.type.description)")
        }
        
    }
    
    public func room(_ room: Room, didUpdateIsRecording isRecording: Bool){
        print("isRecording status \(isRecording)")
    }
    
    public func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String){
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
