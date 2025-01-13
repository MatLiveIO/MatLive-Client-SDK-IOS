//
//  ChatListView.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 02/01/2025.
//
import SwiftUI
import MatLiveClient

struct ChatListWidget:View {
    @ObservedObject private var viewModel = LiveRoomEventReceiverManager.shared
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.messages, id: \.id) { message in
                    ChatMessageWidget(message: message)
                }
            }
            .frame(maxWidth:.infinity,alignment: .leading)
            .padding(.horizontal)
        }.frame(maxWidth:.infinity,alignment: .leading)
    }
}
