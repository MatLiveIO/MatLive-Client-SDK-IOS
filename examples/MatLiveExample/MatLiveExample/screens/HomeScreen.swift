//
//  HomeScreen.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 30/12/2024.
//

import SwiftUI
import MatLiveClient
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
                    VStack{
                        HStack {
                            TextField("Enter App key", text: $HomeVM.appKey)
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Enter user name", text: $HomeVM.userName)
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    }
                    
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
                        HomeVM.joinRoom { roomId, appKey in
                            HomeVM.isJoinLoading = false
                            coordinator.push(.AudioScreen(roomId:roomId, appKey: appKey, userName: HomeVM.userName))
                        }
                    
                    }, label: {
                        if HomeVM.isJoinLoading{
                            ProgressView()
                        }else{
                            Text("Join Room")
                                .font(.system(size: 18))
                        }
                    })
                    
                }
            }
            .onDisappear(perform: {
                HomeVM.userName = ""
            })
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
