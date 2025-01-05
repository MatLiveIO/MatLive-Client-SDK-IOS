//
//  mat_live_chat_message.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation

public class MatLiveChatMessage: Identifiable{
    public var id = UUID()
    public var roomId:String?
    public var message:String
    public var user:MatLiveUser
    public init(roomId: String?, message: String, user: MatLiveUser) {
        self.roomId = roomId
        self.message = message
        self.user = user
    }
}
