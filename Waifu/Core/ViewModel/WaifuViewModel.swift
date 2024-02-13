//
//  WaifuViewModel.swift
//  Waifu
//
//  Created by Andira Yunita on 08/02/24.
//

import SwiftUI

@MainActor
class WaifuViewModel: ObservableObject {
    @Published var waifus: [Waifu] = []
    @Published var imageToShare: UIImage?
    @Published var showOptions: Bool = false
    
    func fetchWaifus() async {
        do {
            let fetchedWaifus = try await APIService.shared.fetchAllWaifus()
            self.waifus = fetchedWaifus
        } catch {
            print(error)
        }
    }
    
    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error download image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func prepareImageShowSheet(from urlString: String) async {
        imageToShare = await downloadImage(from: urlString)
        showOptions = true
    }
    
    func deleteWaifu(_ waifu: Waifu) {
        if let index = waifus.firstIndex(where: { $0.id == waifu.id }) {
            self.waifus.remove(at: index)
        }
    }
}
