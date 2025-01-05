//
//  HomeScreen.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject private var HomeVM = HomeViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {

            ScrollView{
                VStack(alignment:.center,spacing:24){
                    Text("Welcome to MatLive Audio Rooms")
                        .font(.system(size: 24,weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Create a new room and start talking with others")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        Task{
                            await HomeVM.createRoom()
                        }
                    }, label: {
                        if HomeVM.isCreateRoomLoading{
                            ProgressView()
                        }else{
                            Text("Create Room")
                                .font(.system(size: 18))
                        }
                    })
                    .disabled(HomeVM.isCreateRoomLoading)

                    Button(action: {
                        Task{
                            await HomeVM.joinRoom{ roomid,token in
                                coordinator.push(.AudioScreen(roomId: roomid, roomName: token))
                            }
                        }
                        

                    }, label: {
                        if HomeVM.isJoinLoading{
                            ProgressView()
                        }else{
                            Text("Join Room")
                                .font(.system(size: 18))
                        }
                    })
                    .disabled(HomeVM.isJoinLoading)
                    
                }
            }
            .snackbar(show: $HomeVM.showCreateRoomSuccess, bgColor: .green, txtColor: .white, icon: "checkmark", iconColor: .white, message:HomeVM.snackBarMessage)
            .snackbar(show: $HomeVM.showError, bgColor: .red, txtColor: .white, icon: "xmark", iconColor: .white, message: HomeVM.snackBarMessage)
            .navigationTitle("MatLive Audio Rooms")
            .navigationBarTitleDisplayMode(.inline)
           
        }
}




#Preview {
    HomeScreen()
        .environmentObject(Coordinator())
}
