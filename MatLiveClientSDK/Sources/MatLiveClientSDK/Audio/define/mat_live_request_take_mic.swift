//
//  mat_live_request_take_mic.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 26/12/2024.
//

import Foundation

public class MatLiveRequestTackMic{
    public  var seatIndex:Int
    public  var user:MatLiveUser
    public  init(seatIndex: Int, user: MatLiveUser) {
        self.seatIndex = seatIndex
        self.user = user
    }
}
