//
//  livekit_service.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//


public class MatLiveService {
    
    /// The network manager responsible for handling network requests.
    private let network: NetworkManager = NetworkManager()
    
    /// Initializes the LiveKitService with a given base URL.
    /// - Parameter baseUrl: The base URL of the LiveKit service to be used for network requests.
    public init() {}
    
    /// Creates a room with the specified room ID.
    /// - Parameter roomId: The ID of the room to be created.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    public func createRoom(roomId: String) async  -> Result<JSONResponse,NetworkError> {
        let response  =  await network.request(url: Utils.url,
                                                 path: "rooms/create-room" ,
                                                 method: .POST,
                                                 body: .json(["roomName": roomId]))
        switch response {
        case .success(let data):
            return .success(data)
        case .failure(let failure):
            return .failure(failure)
        }

    }
    
    /// Updates metadata for a specified room.
    /// - Parameters:
    ///   - roomId: The ID of the room to update.
    ///   - metaData: The metadata string to be set for the room.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    public func updateRoomMetadata(roomId: String, metaData: String) async throws -> Result<JSONResponse,NetworkError> {
        let response =  await network.request(url: Utils.url,
                                                 path: "rooms/room-metadata" ,
                                                 method: .PUT,
                                                 body: .json([ "roomId": roomId,
                                                               "metadata": metaData]))
        switch response {
        case .success(let data):
            return .success(data)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Creates a token for a user to join a specified room.
    /// - Parameters:
    ///   - userName: The username of the user for whom the token will be created.
    ///   - roomId: The ID of the room the user will join.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    func createToken(userName: String, roomId: String) async  -> Result<JSONResponse,NetworkError> {
        let response = await network.request(url: Utils.url,
                                                 path: "rooms/token",
                                                 method: .GET,
                                             queryParameters: ["identity": userName, "room": roomId,"appKey":Utils.appKey],
                                                 body: nil,
                                                 headers: nil)
        switch response {
        case .success(let data):
            return .success(data)
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
