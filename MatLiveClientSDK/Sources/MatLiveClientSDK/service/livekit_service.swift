//
//  livekit_service.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

public class LiveKitService{
    
    var baseUrl:String
    let network:NetworkManager
    
    public init(baseUrl: String) {
        self.baseUrl = baseUrl
        self.network = NetworkManager()
    }
    
    public func createRoom(roomId:String) async throws -> JSONResponse{
        do {
            let response  = try await network.request(url: baseUrl,
                                                     path: "/livekit/create-room" ,
                                                     method: .POST,
                                                     body: .json(["roomName": roomId]))
//            kPrint(response);
            return response
        } catch  {
           throw error
        }
    }
    
    public func updateRoomMetadata(roomId:String , metaData:String) async throws -> JSONResponse{
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "/livekit/room-metadata" ,
                                                     method: .PUT,
                                                     body: .json([ "roomId": roomId,
                                                                   "metadata": metaData]))
//            kPrint(response);
            return response
        } catch  {
            throw error
        }
    }
    public func createToken(userName:String , roomId:String) async throws -> JSONResponse{
        do {
            let response = try await network.request(url: baseUrl, path: "/livekit/token", method: .GET, queryParameters: ["identity": userName,"room": roomId], body: nil, headers: nil)
            
//            kPrint(response);
            return response
        } catch  {
            throw error
        }
    }
}
