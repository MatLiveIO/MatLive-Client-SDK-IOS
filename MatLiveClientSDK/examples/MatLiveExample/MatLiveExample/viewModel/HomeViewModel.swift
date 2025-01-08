//
//  HomeViewModel.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import Foundation
import MatLiveClientSDK
@MainActor
class HomeViewModel:ObservableObject{
    
    
    
    // MARK: loading
    @Published  var isCreateRoomLoading = false
    @Published  var isJoinLoading = false
    
    // MARK: States
    @Published  var showCreateRoomSuccess = false
    @Published  var showError = false
    
    // MARK: Message
    @Published  var snackBarMessage:String = ""
    @Published var userName :String = ""
    private let livekitService = LiveKitService()
    
    
    func createRoom() async {
        guard !isCreateRoomLoading else {return}
        isCreateRoomLoading = true
        do {
            let roomResponse = try await livekitService.createRoom(roomId: Constants.roomName)
            guard let data = roomResponse["data"] as? [String : Any] else{return}
            let sid = data["sid"] as! String
            
            isCreateRoomLoading = false
            snackBarMessage = "Room created with ID: \(sid)"
            showCreateRoomSuccess = true
            
        } catch  {
            isCreateRoomLoading = false
            snackBarMessage = "Error: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func joinRoom(roomId:String,completion:@escaping (String,String,String)->Void) async {
        isJoinLoading = true
        do {
            let tokenResponse = try await livekitService.createToken(userName: "user-\(Date.now)", roomId: Constants.roomName)
            guard let token = tokenResponse["data"] as? String else{
                return
            }
            isJoinLoading = false
            completion(roomId,token,userName)
        } catch  {
            isJoinLoading = false
            snackBarMessage = "Error:\(error.localizedDescription)"
            showError = true
        }
    }
}
