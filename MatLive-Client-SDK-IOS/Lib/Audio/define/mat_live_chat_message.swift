//
//  mat_live_chat_message.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation

class MatLiveChatMessage{
    let roomId:String?
    let message:String
    let user:MatLiveUser
    init(roomId: String?, message: String, user: MatLiveUser) {
        self.roomId = roomId
        self.message = message
        self.user = user
    }
}
