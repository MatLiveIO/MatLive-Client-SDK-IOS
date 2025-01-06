//
//  seatWidget.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 31/12/2024.
//

import Foundation
import SwiftUI
import MatLiveClientSDK

struct SeatWidget: View {
    @ObservedObject var seat: MatLiveRoomAudioSeat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            if seat.isLocked {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.black)
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    if let user = seat.currentUser , let avatarUrl = user.avatarUrl{
                        AsyncImage(url: URL(string: avatarUrl)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                        }
                    } else {
                        Image(systemName: "mic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.black)
                    }
                    if let user = seat.currentUser {
                        MicIndicator(isMicOn: user.isMicOn)
                            .offset(x: 20, y: 20)
                    }
                }
            }
        }
    }
}
