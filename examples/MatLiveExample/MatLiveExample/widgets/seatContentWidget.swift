//
//  seatContentWodget.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 31/12/2024.
//

import Foundation
import SwiftUI
import MatLiveClient

struct SeatContentWidget: View {
    let seat: MatLiveRoomAudioSeat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
            if let user = seat.currentUser {
                AsyncImage(url: URL(string: user.avatarUrl!)) { image in
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
