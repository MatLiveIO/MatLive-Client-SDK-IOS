//
//  livekit_service.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//


public class LiveKitService {
    
    /// The base URL for the LiveKit service.
    private var baseUrl: String = "https://webapi.dev.ml.matnsolutions.co/"
    
    /// The network manager responsible for handling network requests.
    private let network: NetworkManager = NetworkManager()
    
    /// Initializes the LiveKitService with a given base URL.
    /// - Parameter baseUrl: The base URL of the LiveKit service to be used for network requests.
    public init() {}
    
    /// Creates a room with the specified room ID.
    /// - Parameter roomId: The ID of the room to be created.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    public func createRoom(roomId: String) async throws -> JSONResponse {
        do {
            let response  = try await network.request(url: baseUrl,
                                                     path: "rooms/create-room" ,
                                                     method: .POST,
                                                     body: .json(["roomName": roomId]))
            // Uncomment to debug: kPrint(response)
            return response
        } catch {
            throw error
        }
    }
    
    /// Updates metadata for a specified room.
    /// - Parameters:
    ///   - roomId: The ID of the room to update.
    ///   - metaData: The metadata string to be set for the room.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    public func updateRoomMetadata(roomId: String, metaData: String) async throws -> JSONResponse {
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "rooms/room-metadata" ,
                                                     method: .PUT,
                                                     body: .json([ "roomId": roomId,
                                                                   "metadata": metaData]))
            // Uncomment to debug: kPrint(response)
            return response
        } catch {
            throw error
        }
    }
    
    /// Creates a token for a user to join a specified room.
    /// - Parameters:
    ///   - userName: The username of the user for whom the token will be created.
    ///   - roomId: The ID of the room the user will join.
    /// - Returns: A `JSONResponse` object containing the response data from the request.
    /// - Throws: An error if the network request fails.
    public func createToken(userName: String, roomId: String) async throws -> JSONResponse {
        do {
            let response = try await network.request(url: baseUrl,
                                                     path: "rooms/token",
                                                     method: .GET,
                                                     queryParameters: ["identity": userName, "room": roomId],
                                                     body: nil,
                                                     headers: nil)
            // Uncomment to debug: kPrint(response)
            return response
        } catch {
            throw error
        }
    }
}
