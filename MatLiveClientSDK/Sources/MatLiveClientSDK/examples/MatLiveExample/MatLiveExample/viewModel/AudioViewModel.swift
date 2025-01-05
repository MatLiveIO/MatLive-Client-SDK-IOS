//
//  AudioViewModel.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import Foundation
import Combine
import SwiftUI


@MainActor
class AudioRoomViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var showSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var showSheet: Bool = false
    @Published var snackBarMessage: String = ""
    @Published var selectedUser: MatLiveUser?
    @Published var selectedGlobalIndex: Int?
    @Published var matliveRoomManager = MatLiveRoomManager.shared
    @Published var matliveJoinRoomManager = MatLiveJoinRoomManager.shared
    @Published var textMessage = ""
    
    func initializeRoom(roomId: String, token: String) async {
    
        await matliveJoinRoomManager.initialize(onInvitedToMic: { seatIndex in
            
        }, onSendGift: { data in
            
        })
        do {
            try await matliveJoinRoomManager.connect(
                token: token,
                name: "Anas Amer",
                avatar: "https://gravatar.com/avatar/27205e5c51cb03f862138b22bcb5dc20f94a342e744ff6df1b8dc8af3c865109?s=200",
                userId: "10",
                roomId: roomId,
                metadata: "{'userRole':admin}")
            
            let seatService = matliveRoomManager.seatService
            await seatService?.initWithConfig(config:
                                            MatLiveAudioRoomLayoutConfig(
                                                rowSpacing: 16 ,
                                                rowConfigs: [
                                                    MatLiveAudioRoomLayoutRowConfig(
                                                        count: 4,seatSpacing: 14),
                                                    MatLiveAudioRoomLayoutRowConfig(
                                                        count: 4,seatSpacing: 14),
                                                ]))
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
        isLoading = false
      
    }

    func closeRoom() async {
        await matliveJoinRoomManager.close()
    }

    func sendMessage() async {
//        messages.append(MatLiveChatMessage(roomId: matliveJoinRoomManager.roomId, message: textMessage, user: matliveJoinRoomManager.currentUser!))
        try? await matliveRoomManager.sendMessage(textMessage)
        textMessage = ""
    }

    // Mic controls
    func handleTakeMic(index:Int) async{
        do {
            try await matliveRoomManager.takeSeat(seatIndex: index)
            updateSuccessSnackBar(message: "Took mic at seat \(index)")
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleMuteMic(index:Int)  async {
      
//        guard let seatService = matliveRoomManager.seatService else {return}
        let seat = matliveRoomManager.seatService!.seatList[index]
        
        do {
            if !seat.currentUser!.isMicOn{
                try await matliveRoomManager.muteSeat(seatIndex: index)
                updateSuccessSnackBar(message: "Unmuted mic at seat \(index)")
            }else{
                try await matliveRoomManager.unmuteSeat(seatIndex: index)
                updateSuccessSnackBar(message: "Muted mic at seat \(index)")
            }
           
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleRemoveSpeaker(index:Int)  async{
        do {
            try await matliveRoomManager.removeUserFromSeat(seatIndex: index)
            updateSuccessSnackBar(message: "Removed speaker from seat \(index)")
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleLeaveMic(index:Int)  async{
        
        do {
            try await matliveRoomManager.leaveSeat(seatIndex: index)
            updateSuccessSnackBar(message: "Left mic at seat \(index)")
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleLockMic(index:Int)  async{
        do {
            try await matliveRoomManager.lockSeat(seatIndex: index)
            updateSuccessSnackBar(message: "Seat locked \(index)")
            
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleUnlockMic(index:Int)  async{
        do {
            try await matliveRoomManager.unlockSeat(seatIndex: index)
            updateSuccessSnackBar(message: "Seat unlocked \(index)")
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    func handleSwitchSeat(toIndex:Int)  async {
        do {
            try await matliveRoomManager.switchSeat(toSeatIndex: toIndex)
            updateSuccessSnackBar(message: "Switched seat to \(toIndex)")
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
    
    
    func calculateGlobalIndex(rowIndex: Int, seatIndex: Int) -> Int {
        guard  let layoutConfig = matliveRoomManager.seatService?.layoutConfig else{return 0}
        return (0..<rowIndex).reduce(0) { $0 + (layoutConfig.rowConfigs[$1].count) } + seatIndex
    }

    func showSeatActions(globalIndex: Int, user: MatLiveUser?) {
        withAnimation {
            selectedGlobalIndex = globalIndex
            selectedUser = user
            showSheet = true
        }
    }
    
    
    private func updateSuccessSnackBar(message:String){
        withAnimation {
            showSheet = false
            snackBarMessage = message
            showSuccess = true
        }
    } 
    private func updateErrorSnackBar(message:String){
        withAnimation {
            snackBarMessage = message
            showError = true
        }
    }
}
