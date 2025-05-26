//
//  BarNavComponent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 28/4/25.
//

import SwiftUI

struct NavBarComponent: View {
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
