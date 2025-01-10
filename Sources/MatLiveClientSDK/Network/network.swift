import Foundation


enum RequestBody {
    case json([String: Any])
    case data(Data)
}

/// Enum for HTTP methods
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Network-related errors
public enum NetworkError: Error {
    case invalidResponse
    case invalidJSON
    case invalidURL
    case decodingError
    case generalError(String)
    
   public var message: String {
        switch self {
        case .invalidResponse:
            return "The server response was invalid."
        case .invalidJSON:
            return "The JSON data could not be parsed."
        case .invalidURL:
            return "The URL provided was invalid."
        case .decodingError:
            return "The response data could not be decoded."
        case .generalError(let error):
            return error
        }
    }
}
// MARK: network amager is response to call apis it accept base url and path , request type [post , get ,...]
// and handle the errors.
actor NetworkManager {
    
    private var decoder = JSONDecoder()
    private var urlSession = URLSession.shared

    /// Performs a network request and decodes the response into a Codable object.
    func request(
        url: String,
        path: String,
        method: HTTPMethod = .GET,
        queryParameters: [String: String]? = nil,
        body: RequestBody? = nil,
        headers: [String: String]? = nil
    ) async -> Result<JSONResponse, NetworkError> {
        var urlString = url + path

        // Add query parameters if provided
        if let queryParameters = queryParameters {
            var components = URLComponents(string: urlString)
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard let updatedURLString = components?.url?.absoluteString else {
                return .failure(.invalidURL)
            }
            urlString = updatedURLString
        }
        
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        let result = await fetchData(url: url, method: method, body: body, headers: headers)
        
        switch result {
        case .success(let data):
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return .failure(.invalidJSON)
                }
                return .success(JSONResponse(json: jsonObject))
            } catch {
                return .failure(.invalidJSON)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// A helper method to perform the actual network request.
    private func fetchData(
        url: URL,
        method: HTTPMethod,
        body: RequestBody?,
        headers: [String: String]?
    ) async -> Result<Data, NetworkError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Add headers if provided
        if let headers = headers {
            headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        // Handle body encoding
        if let body = body {
            switch body {
            case .json(let dictionary):
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    return .failure(.invalidJSON)
                }
            case .data(let rawData):
                urlRequest.httpBody = rawData
            }
        }
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            if !(200...299).contains(httpResponse.statusCode) {
                // Parse backend error message
                if let errorObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorMessage = errorObject["message"] as? String {
                    return .failure(.generalError(errorMessage))
                } else {
                    return .failure(.invalidResponse)
                }
            }
            
            return .success(data)
        } catch {
            return .failure(.generalError(error.localizedDescription))
        }
    }
}
