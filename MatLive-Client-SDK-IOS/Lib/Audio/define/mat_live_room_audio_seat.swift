//
//  mat_live_room_audio_seat.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI

class MatLiveRoomAudioSeat: ObservableObject {
    @ObservationIgnored var seatIndex: Int
    @ObservationIgnored var rowIndex: Int
    @ObservationIgnored var columnIndex: Int
    @ObservationIgnored var seatKey: NSObject // Replace GlobalKey with a unique identifier
    
    @Published var lastUser: MatLiveUser? // Using @Published for observable user
    @Published var currentUser: MatLiveUser? // Using @Published for observable user
    @Published var isLocked: Bool = false // Using @Published for lock status

    init(seatIndex: Int, rowIndex: Int, columnIndex: Int) {
        self.seatIndex = seatIndex
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.seatKey = NSObject() // or use a custom identifier
    }
}
