//
//  ContentView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import SwiftUI

struct ContentView: View {
	
    @State var fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    @State var showInspector = true
    
    var body: some View {
        NavigationSplitView {
            List {
                Text("Moin")
            }
        } detail: {
            ChessGameView()
        }
    }
}

#Preview {
    ContentView()
}
