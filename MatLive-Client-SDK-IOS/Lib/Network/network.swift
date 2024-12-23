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
enum NetworkError: Error {
    case invalidResponse
    case invalidJSON
    case invalidURL
    case decodingError
}

actor Network{
    
    private var decoder = JSONDecoder()
    private var urlSession = URLSession.shared

    /// Performs a network request and returns the raw JSON as a dictionary `[String: Any]`.
    func request(
        url: String,
        path:String,
        method: HTTPMethod = .GET,
        body: RequestBody? = nil,
        headers: [String: String]? = nil
    ) async throws -> [String: Any] {
        
        guard let url = URL(string: url + path) else{throw NetworkError.invalidURL}
        
        let (data, _) = try await fetchData(url: url, method: method, body: body, headers: headers)
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw NetworkError.invalidJSON
            }
            return jsonObject
        } catch {
            throw NetworkError.invalidJSON
        }
    }
    
    /// A helper method to perform the actual network request.
    private func fetchData(
        url: URL,
        method: HTTPMethod,
        body: RequestBody?,
        headers: [String: String]?
    ) async throws -> (Data, URLResponse) {
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
                    throw NetworkError.invalidJSON
                }
            case .data(let rawData):
                urlRequest.httpBody = rawData
            }
        }
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return (data, response)
    }
}
