//
//  mat_live_audio_room_layout_config.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation
public class MatLiveAudioRoomLayoutConfig{
    public var rowSpacing:Double
    public var rowConfigs:[MatLiveAudioRoomLayoutRowConfig]
    public init(rowSpacing: CGFloat = 0, rowConfigs: [MatLiveAudioRoomLayoutRowConfig]? = nil) {
        self.rowSpacing = rowSpacing
        self.rowConfigs = rowConfigs ?? [
            MatLiveAudioRoomLayoutRowConfig(),
            MatLiveAudioRoomLayoutRowConfig()
        ]
    }
    public func toString() -> String {
        return "rowSpacing: \(rowSpacing), rowConfigs: \(rowConfigs.map { $0.toString() }.joined(separator: ", "))"
    }
}

public class MatLiveAudioRoomLayoutRowConfig {
    public var count:Int
    public var seatSpacing:Int
    
    public init(count: Int = 0, seatSpacing: Int = 5) {
        self.count = count
        self.seatSpacing = seatSpacing
    }
    public func toString()-> String{
        return  "row config:{count:\(count), rowConfigs:\(seatSpacing)"
    }
}
