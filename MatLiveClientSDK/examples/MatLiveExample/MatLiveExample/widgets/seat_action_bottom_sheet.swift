//
//  seat_action_bottom_sheet.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import Foundation
import SwiftUI
import MatLiveClientSDK

struct SeatActionBottomSheet: View {
    var seat: MatLiveRoomAudioSeat
    var onTakeMic: (() async -> Void)?
    var onMuteMic: (() async -> Void)?
    var onRemoveSpeaker: (() async -> Void)?
    var onLeaveMic: (() async -> Void)?
    var onUnLockMic: (() async -> Void)?
    var onLockMic: (() async -> Void)?
    var onSwitch: (() async -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            if seat.currentUser == nil {
                UserSpecificActions(seat: seat)
            } else {
                GeneralActions()
            }
        }
    }

    @ViewBuilder
    private func UserSpecificActions(seat: MatLiveRoomAudioSeat) -> some View {
        List{
            
            if !MatLiveRoomManager.shared.onMic , !seat.isLocked{
                ActionButton(
                    icon: "mic.fill",
                    label: "Take Mic",
                    action: { await onTakeMic?() }
                )
            }
            if MatLiveRoomManager.shared.onMic , !seat.isLocked{
                ActionButton(
                    icon: "arrow.triangle.branch",
                    label: "Switch Mic",
                    isDestructive: true,
                    action: { await onSwitch?() }
                )
            }
            
            if !seat.isLocked {
                ActionButton(
                    icon: "lock.fill",
                    label: "Lock Mic",
                    isDestructive: true,
                    action: { await onLockMic?() }
                )
            } else {
                ActionButton(
                    icon: "lock.open.fill",
                    label: "Unlock Mic",
                    isDestructive: true,
                    action: { await onUnLockMic?() }
                )
            }
        }
    }

    @ViewBuilder
    private func GeneralActions() -> some View {
        if seat.currentUser?.userId == MatLiveJoinRoomManager.shared.currentUser?.userId{
            List{
                if seat.currentUser!.isMicOn{
                    ActionButton(
                        icon: "mic.slash.fill",
                        label: "Mute Mic",
                        action: { await onMuteMic?() }
                    )
                }else{
                    ActionButton(
                        icon: "mic.slash.fill",
                        label: "unMute Mic",
                        action: { await onMuteMic?() }
                    )
                }
                if seat.currentUser != nil , seat.currentUser?.userId == MatLiveJoinRoomManager.shared.currentUser?.userId{
                    ActionButton(
                        icon: "person.crop.circle.badge.minus",
                        label: "Remove Speaker",
                        isDestructive: true,
                        action: { await onRemoveSpeaker?() }
                    )

                  
                }
                
                if seat.currentUser?.userId == MatLiveJoinRoomManager.shared.currentUser?.userId{
                    ActionButton(
                        icon: "arrow.uturn.left",
                        label: "Leave Mic",
                        isDestructive: true,
                        action: { await onLeaveMic?() }
                    )
                }
                
            }
        }
    }
}

struct ActionButton: View {
    var icon: String
    var label: String
    var isDestructive: Bool = false
    var action: (() async -> Void)?

    var body: some View {
        Button {
            Task { await action?() }
        } label: {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isDestructive ? .red : .primary)
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? .red : .primary)
                    .padding(.leading, 12)
//                Spacer()
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
