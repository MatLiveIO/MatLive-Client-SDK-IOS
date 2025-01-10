//
//  mat_live_room_audio_seat.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
import SwiftUI


/// A class representing an audio seat in the MatLive Room, designed to manage seat properties such as location,
/// user assignment, and locking status.
public class MatLiveRoomAudioSeat: ObservableObject {
    
    /// The index of the seat within its row.
    public var seatIndex: Int
    
    /// The index of the row in which the seat is located.
    public var rowIndex: Int
    
    /// The index of the column in which the seat is located.
    public var columnIndex: Int
    
    /// A unique identifier for the seat.
    /// - Note: This replaces the use of a `GlobalKey` in other frameworks.
    public var seatKey: NSObject
    
    /// The last user who occupied the seat.
    @Published public var lastUser: MatLiveUser?
    
    /// The current user occupying the seat.
    @Published public var currentUser: MatLiveUser?
    
    /// Indicates whether the seat is locked.
    @Published public var isLocked: Bool = false
    
    /// Initializes a new instance of `MatLiveRoomAudioSeat` with the specified seat position.
    /// - Parameters:
    ///   - seatIndex: The index of the seat within its row.
    ///   - rowIndex: The index of the row in which the seat is located.
    ///   - columnIndex: The index of the column in which the seat is located.
    public init(seatIndex: Int, rowIndex: Int, columnIndex: Int) {
        self.seatIndex = seatIndex
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.seatKey = NSObject() // Generates a unique identifier for the seat.
    }
}
