//
//  HomeViewModel.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import Foundation
import MatLiveClient
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
    @Published var appKey :String = ""
    var audioVm = AudioRoomViewModel()
    private let livekitService = MatLiveService()
    
    
    func createRoom() async {
        guard !isCreateRoomLoading else {return}
        isCreateRoomLoading = true
        let response = await livekitService.createRoom(roomId: Constants.roomName)
        
        switch response {
        case .success(let roomResponse):
            guard let data = roomResponse["data"] as? [String : Any] else{return}
            let sid = data["sid"] as! String
            
            isCreateRoomLoading = false
            snackBarMessage = "Room created with ID: \(sid)"
            showCreateRoomSuccess = true
        case .failure(let failure):
            isJoinLoading = false
            snackBarMessage = "Error:\(failure.message)"
            showError = true
        }
    }
    
    func joinRoom(completion:@escaping (String,String)->Void) {
        isJoinLoading = true
        guard !appKey.isEmpty else{
            isJoinLoading = false
            snackBarMessage = "Error: App key required"
            showError = true
            return
        }
        guard !userName.isEmpty else{
            isJoinLoading = false
            snackBarMessage = "Error: User Name required"
            showError = true
            return
        }
    
        completion(Constants.roomName ,appKey)
        
    }
}
