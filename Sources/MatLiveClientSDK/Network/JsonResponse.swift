//
//  File.swift
//  MatLivePackage
//
//  Created by anas amer on 05/01/2025.
//

import Foundation

public struct JSONResponse: @unchecked Sendable {
    let json: [String: Any]
    
    public subscript(key: String) -> Any? {
           return json[key]
       }
}
