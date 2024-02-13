//
//  HomeView.swift
//  Waifu
//
//  Created by Andira Yunita on 08/02/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WaifuViewModel()
    @State private var deleteWaifu: Waifu?
    @State private var searchWaifu = ""
    @State private var showAlert = false
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    private var gridItemLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var filteredWaifu: [Waifu] {
        guard !searchWaifu.isEmpty else { return viewModel.waifus }
        return viewModel.waifus.filter { $0.name.localizedCaseInsensitiveContains(searchWaifu) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if filteredWaifu.isEmpty {
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No results for '\(searchWaifu)'")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Check the spelling or try a new search.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                    }
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(filteredWaifu) { waifu in
                            Group {
                                VStack(alignment: .leading) {
                                    let url = URL(string: waifu.img)
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            waitView()
                                            
                                        case .success(let img):
                                            img.resizable().scaledToFill()
                                            
                                        case .failure( _):
                                            ZStack {
                                                Rectangle()
                                                    .foregroundStyle(Color.indigo)
                                                Image(systemName: "photo.on.rectangle.angled")
                                                    .font(.title)
                                                    .foregroundStyle(.white)
                                            }
                                            
                                        @unknown default:
                                            fatalError()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text(waifu.name)
                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                        .lineLimit(2, reservesSpace: true)
                                        .multilineTextAlignment(.leading)
                                    Text(waifu.anime)
                                        .font(.system(.caption, design: .rounded))
                                        .lineLimit(1)
                                }
                            }
                            .padding()
                            .sheet(isPresented: $viewModel.showOptions) {
                                Group {
                                    let defaultText = "Just watching anime \(waifu.name)"
                                    
                                    if let imageToShare = viewModel.imageToShare {
                                        ActivityView(activityItems: [defaultText, imageToShare])
                                    } else {
                                        ActivityView(activityItems: [defaultText])
                                    }
                                }
                                .presentationDetents([.medium, .large])
                            }
                            .contextMenu {
                                Button {
                                    Task {
                                        await viewModel.prepareImageShowSheet(from: waifu.img)
                                    }
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                
                                Button {
                                    deleteWaifu = waifu
                                    showAlert.toggle()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Waifu")
            .task {
                await viewModel.fetchWaifus()
            }
            .refreshable {
                await viewModel.fetchWaifus()
            }
        }
        .searchable(text: $searchWaifu, prompt: "e.g Yor Briar")
        .confirmationDialog("Are you sure you want to delete this?", isPresented: $showAlert, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let deleteWaifu = deleteWaifu {
                    viewModel.deleteWaifu(deleteWaifu)
                }
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("This operation cannot be undone.")
        }
    }
}

#Preview {
    HomeView()
}

@ViewBuilder
func waitView() -> some View {
    VStack(spacing: 20) {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.gray)
    }
}
