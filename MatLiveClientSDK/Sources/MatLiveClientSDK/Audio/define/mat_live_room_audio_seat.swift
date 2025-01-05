//
//  mat_live_room_audio_seat.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI

public class MatLiveRoomAudioSeat: ObservableObject {
    public  var seatIndex: Int
    public  var rowIndex: Int
    public  var columnIndex: Int
    public var seatKey: NSObject // Replace GlobalKey with a unique identifier
    
    @Published public var lastUser: MatLiveUser? // Using @Published for observable user
    @Published public var currentUser: MatLiveUser? // Using @Published for observable user
    @Published public var isLocked: Bool = false // Using @Published for lock status

    public  init(seatIndex: Int, rowIndex: Int, columnIndex: Int) {
        self.seatIndex = seatIndex
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.seatKey = NSObject() // or use a custom identifier
    }
}
