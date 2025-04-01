//
//  URLCommunication.swift
//  Location
//
//  Created by 윤서진 on 11/16/24.
//

import Foundation

class UrlCommunicationManager {
    // Singleton instance
    static let shared = UrlCommunicationManager()

    private init() {}
    
    func communicate(url: String,
                     httpMethod: String = "GET",
                     contentType: String = "application/json",
                     username: String? = nil,
                     password: String? = nil,
                     jsonBody: Dictionary<String, Any>? = nil,
                     dataProcess: ((Data) -> Void)? = nil,
                     errorProcess: ((Any) -> Void)? = nil) {
        /*
         Base communicate function
         */
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if username != nil && password != nil {
            let loginString = "\(username!):\(password!)"
            guard let loginData = loginString.data(using: .utf8) else { return }
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        if jsonBody != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody!, options: [])
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorProcess?("Error: \(error.localizedDescription)")
                return
            }
            
            // Cast `response` to `HTTPURLResponse` to access `statusCode`
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    errorProcess?("Request failed with status code: \(httpResponse.statusCode)")
                    return
                }
            } else {
                errorProcess?("Failed to cast response to HTTPURLResponse")
                return
            }
            
            guard let data = data else { return }
            dataProcess?(data)
        
        }
        task.resume()
    }
}

