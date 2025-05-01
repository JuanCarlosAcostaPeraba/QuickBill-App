//
//  ClientsViewContent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var searchText: String = ""
    @State private var showAddClient = false
    
    private var filtered: [Client] {
        if searchText.isEmpty { return viewModel.clients }
        let lower = searchText.lowercased()
        return viewModel.clients.filter {
            $0.companyName.lowercased().contains(lower) ||
            $0.clientName.lowercased().contains(lower)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    Text("Empty client list")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(filtered) { client in
                        NavigationLink(destination: ClientView(client: client)) {
                            Text(client.companyName)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView(isPresented: $showAddClient, viewModel: viewModel)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search"
            )
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add client") {
                        showAddClient = true
                    }
                }
            }
            .onAppear {
                viewModel.fetchClients()
            }
        }
    }
}
