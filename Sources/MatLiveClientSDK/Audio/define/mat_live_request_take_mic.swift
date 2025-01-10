//
//  mat_live_request_take_mic.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 26/12/2024.
//

import Foundation

public class MatLiveRequestTackMic {
    
    /// The index of the seat associated with the microphone request.
    public var seatIndex: Int
    
    /// The user making the microphone request.
    public var user: MatLiveUser
    
    /// Initializes a new instance of `MatLiveRequestTackMic`.
    /// - Parameters:
    ///   - seatIndex: The index of the seat associated with the request.
    ///   - user: The user making the request.
    public init(seatIndex: Int, user: MatLiveUser) {
        self.seatIndex = seatIndex
        self.user = user
    }
}
