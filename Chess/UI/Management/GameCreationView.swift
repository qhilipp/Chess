//
//  GameCreationView.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import SwiftUI

struct GameCreationView: View {
	
	@State var chessGame = ChessGame()
	@State var error: String? = nil
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		Form {
			TextField("Name", text: $chessGame.name)
			TextField("FEN", text: Binding(get: {
				chessGame.board.fen
			}, set: { newFen in
				if let newBoard = ChessBoard(fen: newFen) {
					chessGame.board = newBoard
					error = nil
				} else {
					error = "Invalid FEN string"
				}
			}))
			Section {
				ChessBoardView(chessGame: chessGame, isInteractive: false)
					.frame(height: 250)
					.listRowInsets(EdgeInsets())
			}
			Section("Appearance") {
				ColorPicker("White", selection: $chessGame.whiteColor)
				ColorPicker("Black", selection: $chessGame.blackColor)
			}
			if let error {
				Text(error)
					.bold()
					.foregroundStyle(.red)
			}
			Button {
				dismiss()
			} label: {
				Label("Create", systemImage: "checkmark.circle")
					.padding()
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.disabled(error != nil)
			.listRowInsets(EdgeInsets())
		}
		.formStyle(.grouped)
    }
}

#Preview {
    GameCreationView()
}
