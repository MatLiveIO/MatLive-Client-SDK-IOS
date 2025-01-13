//
//  mat_live_join_room_manger.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 24/12/2024.
//

internal import LiveKit
import SwiftUI
import Combine

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
    
    init(url: String = "", token: String = "" , e2ee: Bool = false, e2eeKey: String? = nil, simulcast: Bool = true, adaptiveStream: Bool = true, dynacast: Bool = true, preferredCodec: String = "VP8", enableBackupVideoCodec: Bool = true) {
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

public class MatLiveJoinRoomManager: ObservableObject {
    nonisolated(unsafe) public static let shared = MatLiveJoinRoomManager()
    
    private var selectedAudioDevice: MediaDevice?
    private(set) var audioInputs: [MediaDevice] = []
    private let request = JoinRequest()
    private var subscription: AnyCancellable?
    var audioTrack: LocalAudioTrack?
    public var currentUser: MatLiveUser?
    var roomId: String = ""
    var onInvitedToMic:((Int)->Void)?
    var onSendGift:((String)->Void)?
    var permissionsManager: PermissionsManager = PermissionsManager()
    private init() {}
    
  public  func initialize(onInvitedToMic:((Int)->Void)? , onSendGift:((String)->Void)?) async {
        request.url = Utils.url
        self.onInvitedToMic = onInvitedToMic
        self.onSendGift = onSendGift
//        permissionsManager.checkBluetoothPermission()
        permissionsManager.checkMicrophonePermission()
        LiveKitSDK.prepare()
    }

    public func close() async {
        subscription?.cancel()
        await stopAudioStream()
        await MatLiveRoomManager.shared.close()
    }
    
        private func loadDevices(devices: [MediaDevice]) async {
            audioInputs = devices.filter { $0.name == "audioinput" }
    
            if let firstDevice = audioInputs.first, selectedAudioDevice == nil {
                selectedAudioDevice = firstDevice
                await changeLocalAudioTrack()
            }
        }
    //
    private func stopAudioStream() async {
        if audioTrack != nil{
            try? await audioTrack?.stop()
            audioTrack = nil
        }
        
     
    }
    
    private func changeLocalAudioTrack() async {
        if let track = audioTrack {
            try? await track.stop()
        }
        
        if let _ = selectedAudioDevice {
            audioTrack = LocalAudioTrack.createTrack(options: AudioCaptureOptions())
        }
    }
    
    
    public func connect(
        token: String,
        name: String,
        avatar: String,
        userId: String,
        roomId: String,
        metadata:String?
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
                let keyProvider =  BaseKeyProvider()
                e2eeOptions = E2EEOptions(keyProvider: keyProvider)
                keyProvider.setKey(key: e2eeKey)
            }
            let room = Room(roomOptions: RoomOptions(
                defaultAudioPublishOptions: AudioPublishOptions(name: "custom_audio_track_name",encoding: .presetMusicHighQualityStereo),
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

