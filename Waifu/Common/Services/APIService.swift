//
//  APIService.swift
//  Waifu
//
//  Created by Andira Yunita on 08/02/24.
//

import Foundation

class APIService {
    static let shared = APIService() // Singleton
    
    private init() { }
    
    func fetchAllWaifus() async throws -> [Waifu] {
        let urlString = URL(string: "https://waifu-generator.vercel.app/api/v1")
        guard let url =  urlString else {
            print("Error could not convert \(String(describing: urlString)) to a URL")
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let waifus = try JSONDecoder().decode([Waifu].self, from: data)
        return waifus
    }
}
