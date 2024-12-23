//
//  livekit_service.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

class LiveKitService{
    
    var baseUrl:String
    let network:Network
    
    init(baseUrl: String, network: Network) {
        self.baseUrl = baseUrl
        self.network = network
    }
    
    func createRoom(roomId:String) async throws -> [String:Any]{
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "/livekit/create-room" ,
                                                     method: .POST,
                                                     body: .json(["roomName": roomId]))
            kPrint(response);
            return response
        } catch  {
           throw error
        }
    }
    
    func updateRoomMetadata(roomId:String , metaData:String) async throws -> [String:Any]{
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "/livekit/room-metadata" ,
                                                     method: .PUT,
                                                     body: .json([ "roomId": roomId,
                                                                   "metadata": metaData]))
            kPrint(response);
            return response
        } catch  {
            throw error
        }
    }
    func createToken(userName:String , roomId:String) async throws -> [String:Any]{
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "/livekit/token" ,
                                                     method: .GET,
                                                     body: .json([ "identity": userName,
                                                                   "room": roomId]))
            kPrint(response);
            return response
        } catch  {
            throw error
        }
    }
}
