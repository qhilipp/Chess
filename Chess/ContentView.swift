//
//  ContentView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
		.onAppear {
			let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
			guard let board = ChessBoard(fen: fen) else { return }
			print(board.description)
			print(board.fen)
		}
    }
}

#Preview {
    ContentView()
}
