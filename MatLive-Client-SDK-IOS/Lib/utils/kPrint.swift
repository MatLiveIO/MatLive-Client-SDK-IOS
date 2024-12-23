//
//  kPrint.swift
//  MatLive-Client-SDK-IOS
//
//  Created by anas amer on 23/12/2024.
//

import Foundation

func kPrint(_ data: Any) {
    #if DEBUG
    if let dataString = data as? String {
        _pr(dataString)
    } else if let dataMap = data as? [String: Any] {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dataMap, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            _pr(jsonString)
        }
    } else {
        _pr(String(describing: data))
    }
    #endif
}

private func _pr(_ data: String) {
    print(data)
    if let stackTrace = Thread.callStackSymbols[safe: 2] {
        print(stackTrace)
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
