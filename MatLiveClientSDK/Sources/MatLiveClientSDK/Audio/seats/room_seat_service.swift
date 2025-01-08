//
//  room_seat_service.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI
import Combine


//MARK: RoomSeatService will manage the layout of seats and update seats data , update seats rows numbers
@MainActor
public class RoomSeatService: ObservableObject {
    @Published public var seatList: [MatLiveRoomAudioSeat] = [] // List of seats
    @Published public var matLiveJoinRoomManager = MatLiveJoinRoomManager.shared // List of seats
    public var subscriptions:[AnyCancellable] = []
    public var hostSeatIndex:Int = 0
    var isBatchOperation:Bool = false
    public var layoutConfig:MatLiveAudioRoomLayoutConfig?
    private var liveKitService = LiveKitService()
    
    var roomId:String {
        matLiveJoinRoomManager.roomId
    }
    private var maxIndex:Int {
        return seatList.count - 1
    }
    
    
    // this method will init the room layout configuration like number of seats , rows.
    public func initWithConfig(config:MatLiveAudioRoomLayoutConfig) async{
        layoutConfig = config
        initSeat(config: config)
        await seatsFromMetadata(MatLiveRoomManager.shared.room!.metadata);
    }
    func initSeat(config: MatLiveAudioRoomLayoutConfig) {
        for (columIndex , _) in config.rowConfigs.enumerated() {
            let rowConfig = config.rowConfigs[columIndex]
            for rowIndex in 0...rowConfig.count {
                let seat = MatLiveRoomAudioSeat(seatIndex: seatList.count, rowIndex: rowIndex, columnIndex: columIndex)
                seatList.append(seat)
            }
        }
    }
    
    func seatsFromMetadata(_ metadata: String?) async{
        guard let metadata = metadata, metadata.contains("seats"),
              let data = metadata.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let seats = json["seats"] as? [[String: Any]] else { return }
        
        for item in seats {
            guard let seatIndex = item["seatIndex"] as? Int, seatIndex >= 0, seatIndex < seatList.count else { continue }
            let seat = seatList[seatIndex]
            
            // Update seat lock status
            if let isLocked = item["isLocked"] as? Bool {
                seat.isLocked = isLocked
            }
            
            // Handle current user data
            if let currentUser = seat.currentUser, let currentUserData = item["currentUser"] as? [String: Any] {
                currentUser.name = currentUserData["name"] as? String ?? ""
                currentUser.userId = currentUserData["userId"] as? String ?? ""
                currentUser.roomId = currentUserData["roomId"] as? String ?? ""
                currentUser.isMicOn = currentUserData["isMuted"] as? Bool ?? false
                currentUser.avatarUrl = currentUserData["avatar"] as? String ?? ""
            } else if let currentUserData = item["currentUser"] as? [String: Any] {
                let newUser = MatLiveUser(
                    userId: currentUserData["userId"] as? String ?? "",
                    name: currentUserData["name"] as? String ?? "",
                    avatar: currentUserData["avatar"] as? String ?? "",
                    roomId:currentUserData["roomId"] as? String ?? ""
                )
                newUser.isMicOn = currentUserData["isMuted"] as? Bool ?? false
                newUser.avatarUrl = currentUserData["avatar"] as? String ?? ""
                seat.currentUser = newUser
            } else {
                seat.currentUser = nil
            }
        }
    }
    
    
    
    // Add rows to seats (e.g., add more seats to the room)
    func addSeatRow(_ oldCount: Int, _ newCount: Int) async{
        layoutConfig = MatLiveAudioRoomLayoutConfig(
            rowConfigs: (0..<(newCount / 5)).map { _ in
                MatLiveAudioRoomLayoutRowConfig()
            })
        let columIndex = newCount / 5
        for rowIndex in oldCount..<newCount{
            let seat = MatLiveRoomAudioSeat(seatIndex: seatList.count, rowIndex: rowIndex, columnIndex: columIndex)
            seatList.append(seat)
        }
        do {
            let _ = try await liveKitService.updateRoomMetadata(roomId: roomId, metaData: getSeatInfo())
        } catch  {
            print(error.localizedDescription)
        }
    }
    // this method will return the seat data , like which user on this seat .
    func getSeatInfo() -> String{
        var seats: [[String: Any]] = []
        
        for seat in seatList {
            var seatData: [String: Any] = [
                "seatIndex": seat.seatIndex,
                "rowIndex": seat.rowIndex,
                "columnIndex": seat.columnIndex,
                "isLocked": seat.isLocked
            ]
            
            if let currentUser = seat.currentUser {
                seatData["currentUser"] = [
                    "userId": currentUser.userId,
                    "name": currentUser.name,
                    "avatar": currentUser.avatar,
                    "roomId": currentUser.roomId,
                    "isMuted": currentUser.isMicOn
                ]
            } else {
                seatData["currentUser"] = nil
            }
            
            seats.append(seatData)
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["seats": seats], options: []) ,   let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }
    
    func removeSeatRow(oldCount: Int, newCount: Int) async {
        let emptySeats = seatList.filter { $0.currentUser == nil }
        
        if emptySeats.count >= oldCount - newCount {
            layoutConfig = MatLiveAudioRoomLayoutConfig(
                rowConfigs: (0..<(newCount / 5)).map { _ in
                    MatLiveAudioRoomLayoutRowConfig()
                }
            )
            
            for rowIndex in stride(from: oldCount - 1, through: newCount, by: -1) {
                if seatList[rowIndex].currentUser == nil {
                    seatList.remove(at: rowIndex)
                } else {
                    if let emptyIndex = seatList.firstIndex(where: { $0.currentUser == nil }) {
                        await  switchSeat(from: rowIndex, to: emptyIndex, userId: seatList[rowIndex].currentUser!.userId)
                        seatList.remove(at: rowIndex)
                    }
                }
            }
            
            await UpdateRoomMetaData()
        }
    }
    
    func takeSeat(seatIndex: Int, user: MatLiveUser) async {
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        
        let seat = seatList[seatIndex]
        
        if seat.seatIndex == seatIndex, seat.currentUser == nil {
            seat.currentUser = user
            
            await UpdateRoomMetaData()
        }
    }
    // Set microphone as open for a specific seat
    func setMicOpened(_ seatIndex: Int) async {
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        guard seat.currentUser == nil else { return }
        seat.isLocked = false
        await UpdateRoomMetaData()
    }
    
    // Lock the seat
    func lockSeat(_ seatIndex: Int) async{
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        if seat.seatIndex == seatIndex , seat.currentUser == nil{
            seat.isLocked = true
            await UpdateRoomMetaData()
        }
    }
    
    // unLock the seat
    func unlockSeat(_ seatIndex: Int) async {
        // Lock logic can go here
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        if seat.seatIndex == seatIndex , seat.currentUser == nil{
            seat.isLocked = false
            await UpdateRoomMetaData()
        }
    }
    
    // Mute the seat
    func muteSeat(_ seatIndex: Int) async {
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        guard seat.currentUser != nil else { return }
        seat.currentUser?.isMicOn = true
        await UpdateRoomMetaData()
    }
    
    // Unmute the seat
    func unMuteSeat(_ seatIndex: Int) async {
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        guard seat.currentUser != nil else { return }
        seat.currentUser?.isMicOn = false
        await UpdateRoomMetaData()
    }
    
    
    // Switch seats between two users
    func switchSeat(from fromSeatIndex: Int, to toSeatIndex: Int, userId: String) async{
        guard fromSeatIndex != -1, fromSeatIndex <= maxIndex,toSeatIndex != -1, toSeatIndex <= maxIndex else {
            return
        }
        var tempUser:MatLiveUser?
        let fromSeat = seatList[fromSeatIndex]
        let toSeat = seatList[toSeatIndex]
        tempUser = fromSeat.currentUser
        if toSeat.currentUser == nil {
            fromSeat.currentUser = nil
        } else {
            tempUser = nil
        }
        
        if tempUser != nil{
            toSeat.currentUser = tempUser
            await UpdateRoomMetaData()
        }
    }
    
    
    
    // User leaves the seat
    func leaveSeat(_ seatIndex: Int, _ userId: String) async{
        guard seatIndex != -1, seatIndex <= maxIndex else { return }
        let seat = seatList[seatIndex]
        guard seat.currentUser != nil , seat.currentUser?.userId == userId else { return }
        seat.currentUser = nil
        await UpdateRoomMetaData()
    }
    
    // Remove user from seat
    func removeUserFromSeat(_ seatIndex: Int) async -> String?  {
        guard seatIndex != -1, seatIndex <= maxIndex else { return nil }
        let seat = seatList[seatIndex]
        guard seat.currentUser != nil else { return nil}
        let userId = seat.currentUser?.userId
        seat.currentUser = nil
        await UpdateRoomMetaData()
        return userId
    }
    
    // check if the user take a seat when he leave the room
    private func leaveSeatIfHave()async{
        if let seat = seatList.first(where: {
            $0.currentUser?.userId == matLiveJoinRoomManager.currentUser?.userId
        }) {
            seat.currentUser = nil
            await UpdateRoomMetaData()
        }
    }
    
    // MARK: this method will remove all messages , remove user from seat , and cancle subscriptions
    func clear()async{
        await leaveSeatIfHave()
        seatList.removeAll()
        isBatchOperation = false
        for subscription in subscriptions {
            subscription.cancel()
        }
        subscriptions.removeAll()
    }
}
extension RoomSeatService{
    //MARK: update room data
    private func UpdateRoomMetaData()async{
        do {
            let _ = try await liveKitService.updateRoomMetadata(roomId: roomId, metaData: getSeatInfo())
        } catch  {
            print(error.localizedDescription)
        }
    }
    
}
