//
//  AudioScreen.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import SwiftUI
import Combine

struct AudioScreen: View {
    let roomId: String
    let token: String
    let userName:String
    @StateObject private var viewModel = AudioRoomViewModel()
   

    init(roomId: String, token: String,userName:String) {
        self.roomId = roomId
        self.token = token
        self.userName = userName
    }
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    VStack(spacing: 16) {
                        // Audio Room Layout
                      
                        AudioRoomLayoutWidget { index, seat in
                            viewModel.selectedSeat = seat
                            viewModel.selectedGlobalIndex = index
                            viewModel.showSheet = true
                        }

                        // Chat Messages
                        ChatListWidget()

                        // Message Input
                        HStack {
                            TextField("Type a message...", text: $viewModel.textMessage)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(minHeight: 36)

                            Button(action: {
                                Task{
                                 await  viewModel.sendMessage()
                                }
                              
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                            }
                            .disabled(viewModel.textMessage.isEmpty)
                        }
                        .padding(.horizontal)
                    }
                }
            }
          
            .sheet(isPresented: $viewModel.showSheet) {
                if let index = viewModel.selectedGlobalIndex {
                    SeatActionBottomSheet(
                        seat: viewModel.selectedSeat!,
                        onTakeMic: { await viewModel.handleTakeMic(index: index) },
                        onMuteMic: { await viewModel.handleMuteMic(index: index) },
                        onRemoveSpeaker: { await viewModel.handleRemoveSpeaker(index: index) },
                        onLeaveMic: { await viewModel.handleLeaveMic(index: index) },
                        onUnLockMic: { await viewModel.handleUnlockMic(index: index) },
                        onLockMic: { await viewModel.handleLockMic(index: index) },
                        onSwitch: { await viewModel.handleSwitchSeat(toIndex: index) }
                    )
                    .presentationDetents([.fraction(0.40)])
                }

            }
            .snackbar(show: $viewModel.showSuccess, bgColor: .green, txtColor: .white, icon: "checkmark", iconColor: .white, message:viewModel.snackBarMessage)
            .snackbar(show: $viewModel.showError, bgColor: .red, txtColor: .white, icon: "xmark", iconColor: .white, message: viewModel.snackBarMessage)
            .navigationTitle("Room: \(roomId)")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear(perform: {
                Task{
                    await viewModel.closeRoom()
                }
            })
            .task {
                await  viewModel.initializeRoom(roomId: roomId, token: token,userName: userName)
            }
        }
    }
}

#Preview {
    AudioScreen(roomId: "", token: "",userName: "")
        .environmentObject(Coordinator())
}





