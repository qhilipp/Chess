//
//  ContentView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import SwiftUI

struct ContentView: View {
	@State var fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    var body: some View {
		VStack {
			TextField("Fen", text: $fen)
			ChessBoardView(chessGame: ChessGame(fen: fen))
		}
    }
}

#Preview {
    ContentView()
}
