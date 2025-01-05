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
    @Published var selectedSeat: MatLiveRoomAudioSeat?
    @Published var selectedGlobalIndex: Int?
    @Published var matliveRoomManager = MatLiveRoomManager.shared
    @Published var matliveJoinRoomManager = MatLiveJoinRoomManager.shared
    @Published var textMessage = ""
    
    let id = Int.random(in: 0..<10)

    let images = [
      "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ718nztPNJfCbDJjZG8fOkejBnBAeQw5eAUA&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQll3t93lH9yx9shW9OMmDw5ft8sYdTs7bHcZZFyACGnKwdnWwPU7JW3KT2oAB0jEQSJiU&usqp=CAU",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUXxSDbIbLLYxjHI9ht0lLf0VMmioBijVmoJeoItlMoUmfuu_AG3Or3K5kSx3YHbUBt3Q&usqp=CAU",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1Dw7-4lVfRq74_YEiPEt4e-bQ0_6UA2y73Q&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-C_UAhXq9GfuGO452EEzfbKnh1viQB9EDBQ&s",
      "https://www.shutterstock.com/shutterstock/photos/2137527991/display_1500/stock-photo-portrait-of-smiling-mature-man-standing-on-white-background-2137527991.jpg",
      "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSplJ-5PtH61bgDfJtFiSWZtSOTjN_cyxamkg&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqPRe6_8SSJ591Lt4jckiMaLvfvnjP2Z_oIQ&s",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG7CH2bTx8kyDAU6Zc6rR0fX2X_4NGiANCTw&s",
    ];
    
    func initializeRoom(roomId: String, token: String, userName:String) async {
    
        await matliveJoinRoomManager.initialize(onInvitedToMic: { seatIndex in
            
        }, onSendGift: { data in
            
        })
        do {
            try await matliveJoinRoomManager.connect(
                token: token,
                name:userName,
                avatar: images[id],
                userId: "\(id)",
                roomId: roomId,
                metadata: "")
            
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

    func showSeatActions(globalIndex: Int, seat: MatLiveRoomAudioSeat) {
        withAnimation {
            selectedGlobalIndex = globalIndex
            selectedSeat = seat 
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
