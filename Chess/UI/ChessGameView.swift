//
//  ChessGameView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 07.04.25.
//

import SwiftUI

struct ChessGameView: View {
    
    @AppStorage("showInspector") var showInspector = false
    @State var chessGame = ChessGame()
    
    var body: some View {
        ChessBoardView(chessGame: chessGame)
            .toolbar {
                ToolbarItem {
                    Button {
                        showInspector.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .inspector(isPresented: $showInspector) {
                ChessStatsView(chessGame: chessGame)
            }
            .listStyle(.sidebar)
    }
}

#Preview {
    ChessGameView()
}
