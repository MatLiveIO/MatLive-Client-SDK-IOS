//
//  AudioScreen.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//
import SwiftUI
import Combine
import MatLiveClientSDK

struct AudioRoomLayoutWidget: View {
    @ObservedObject private var audioVM = AudioRoomViewModel()

    let onSeatTap: ((Int, MatLiveRoomAudioSeat?) -> Void)

    var body: some View {
        if let layoutConfig = audioVM.matliveRoomManager.seatService!.layoutConfig {
            VStack(spacing: layoutConfig.rowSpacing) {
                ForEach(0..<(layoutConfig.rowConfigs.count), id: \.self) { rowIndex in
                    let rowConfig = layoutConfig.rowConfigs[rowIndex]
                    HStack(spacing: CGFloat(rowConfig.seatSpacing)) {
                        ForEach(0..<rowConfig.count, id: \.self) { seatIndex in
                            let globalIndex = audioVM.calculateGlobalIndex(rowIndex: rowIndex, seatIndex: seatIndex)
                            let seat = audioVM.matliveRoomManager.seatService!.seatList[globalIndex]
                                SeatWidget(
                                    seat: seat,
                                    onTap: { onSeatTap(globalIndex, seat) }
                                )
                        }
                    }
                }
            }
        
        }
    }
}


struct MicIndicator: View {
    let isMicOn: Bool

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 16, height: 16)
            .overlay(
                Image(systemName: isMicOn ? "mic.fill" : "mic.slash.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(isMicOn ? .green : .red)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
