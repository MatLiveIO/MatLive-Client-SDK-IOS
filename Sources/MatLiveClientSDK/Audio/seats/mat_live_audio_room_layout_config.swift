//
//  mat_live_audio_room_layout_config.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation

/// Represents the layout configuration for a MatLive audio room.
public class MatLiveAudioRoomLayoutConfig {
    
    // MARK: - Properties
    
    /// The vertical spacing between rows in the layout.
    public var rowSpacing: Double
    
    /// An array of row configurations, defining how seats are arranged in each row.
    public var rowConfigs: [MatLiveAudioRoomLayoutRowConfig]
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `MatLiveAudioRoomLayoutConfig`.
    /// - Parameters:
    ///   - rowSpacing: The vertical spacing between rows. Defaults to `0`.
    ///   - rowConfigs: An optional array of row configurations. If `nil`, a default configuration with two rows is used.
    public init(rowSpacing: CGFloat = 0, rowConfigs: [MatLiveAudioRoomLayoutRowConfig]? = nil) {
        self.rowSpacing = rowSpacing
        self.rowConfigs = rowConfigs ?? [
            MatLiveAudioRoomLayoutRowConfig(),
            MatLiveAudioRoomLayoutRowConfig()
        ]
    }
    
    // MARK: - Methods
    
    /// Converts the layout configuration into a string representation.
    /// - Returns: A string describing the layout configuration.
    public func toString() -> String {
        return "rowSpacing: \(rowSpacing), rowConfigs: \(rowConfigs.map { $0.toString() }.joined(separator: ", "))"
    }
}

/// Represents the configuration for a single row in a MatLive audio room layout.
public class MatLiveAudioRoomLayoutRowConfig {
    
    // MARK: - Properties
    
    /// The number of seats in the row.
    public var count: Int
    
    /// The horizontal spacing between seats in the row.
    public var seatSpacing: Int
    
    // MARK: - Initializer
    
    /// Initializes a new instance of `MatLiveAudioRoomLayoutRowConfig`.
    /// - Parameters:
    ///   - count: The number of seats in the row. Defaults to `0`.
    ///   - seatSpacing: The horizontal spacing between seats in the row. Defaults to `5`.
    public init(count: Int = 0, seatSpacing: Int = 5) {
        self.count = count
        self.seatSpacing = seatSpacing
    }
    
    // MARK: - Methods
    
    /// Converts the row configuration into a string representation.
    /// - Returns: A string describing the row configuration.
    public func toString() -> String {
        return "row config: {count: \(count), seatSpacing: \(seatSpacing)}"
    }
}
