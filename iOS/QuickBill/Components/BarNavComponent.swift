//
//  BarNavComponent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 28/4/25.
//

import SwiftUI

/// Enum representing each tab in the bar
enum TabItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case products = "Products"
    case add = "Add"
    case clients = "Clients"
    case settings = "Settings"

    var id: Self { self }

    /// System image name for each tab
    var iconName: String {
        switch self {
        case .home:      return "house"
        case .products:  return "doc.plaintext"
        case .add:       return "plus"
        case .clients:   return "person.2"
        case .settings:  return "gearshape"
        }
    }
}

/// A bottom navigation bar with tabs
struct BarNavComponent: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack {
            ForEach(TabItem.allCases) { tab in
                Spacer()

                Button(action: {
                    selectedTab = tab
                }) {
                    if tab == .add {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 56, height: 56)
                            Image(systemName: tab.iconName)
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .offset(y: -16)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.title3)
                            Text(tab.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == tab ? Color.blue : Color.gray)
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
    }
}

struct BarNavComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var tab: TabItem = .home
        var body: some View {
            VStack { Spacer() }
            BarNavComponent(selectedTab: $tab)
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}
