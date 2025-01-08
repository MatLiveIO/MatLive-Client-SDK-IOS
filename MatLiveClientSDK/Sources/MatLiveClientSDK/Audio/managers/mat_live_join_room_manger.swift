//
//  mat_live_join_room_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

internal import LiveKit
import SwiftUI
import Combine

/// Represents a request for joining a live room with specific configurations.
public class JoinRequest {
    var url: String
    var token: String
    var e2ee: Bool
    var e2eeKey: String?
    var simulcast: Bool
    var adaptiveStream: Bool
    var dynacast: Bool
    var preferredCodec: String
    var enableBackupVideoCodec: Bool

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
    init(url: String = "", token: String = "", e2ee: Bool = false, e2eeKey: String? = nil, simulcast: Bool = true, adaptiveStream: Bool = true, dynacast: Bool = true, preferredCodec: String = "VP8", enableBackupVideoCodec: Bool = true) {
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

    private var selectedAudioDevice: MediaDevice?
    private(set) var audioInputs: [MediaDevice] = []
    private let request = JoinRequest()
    private var subscription: AnyCancellable?
    var audioTrack: LocalAudioTrack?
    public var currentUser: MatLiveUser?
    var roomId: String = ""
    var onInvitedToMic: ((Int) -> Void)?
    var onSendGift: ((String) -> Void)?
    var permissionsManager: PermissionsManager = PermissionsManager()

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
        await MatLiveRoomManager.shared.close()
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

    /// Connects to a room with the provided user details and metadata.
    public func connect(
        token: String,
        name: String,
        avatar: String,
        userId: String,
        roomId: String,
        metadata: String?
    ) async throws {
        self.roomId = roomId
        request.token = token
        currentUser = MatLiveUser(
            userId: userId,
            name: name,
            avatar: avatar,
            roomId: roomId,
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
            
            MatLiveRoomManager.shared.room = room
            try await MatLiveRoomManager.shared.setup(onInvitedToMic: onInvitedToMic, onSendGift: onSendGift)
        } catch {
           throw error
        }
    }
}

