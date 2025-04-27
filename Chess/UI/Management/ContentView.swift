//
//  ContentView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import SwiftUI

struct ContentView: View {
	
	@State var showAddGame = false
    
    var body: some View {
        NavigationSplitView {
			List {
				Text("Moin")
			}
        } detail: {
            ChessGameView()
        }
		.toolbar {
			ToolbarItem {
				Button {
					showAddGame = true
				} label: {
					Image(systemName: "square.and.pencil")
				}
			}
		}
		.sheet(isPresented: $showAddGame) {
			GameCreationView()
		}
    }
}

#Preview {
    ContentView()
}
