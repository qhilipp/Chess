//
//  PieceInformationView.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import SwiftUI

struct PieceInformationView: View {
	
	@Binding var chessGame: ChessGame
	@State var selectedEvaluator: GameEvaluators = .simpleEvaluator
	let selected: Position
	
	var body: some View {
		if let piece = chessGame.board[selected] {
			Form {
				if let piece = chessGame.board[selected] {
					Section {
						Image(piece.assetName)
					}
				}
				Section("Moves") {
					MoveInformationView(title: "Pseudo legal moves", chessGame: $chessGame, positions: chessGame.board.pseudoLegalMoves(for: selected))
					MoveInformationView(title: "Legal moves", chessGame: $chessGame, positions: chessGame.board.legalMoves(for: selected))
					MoveInformationView(title: "Protectod by", chessGame: $chessGame, positions: chessGame.board.protectors(forWhite: piece.isWhite, at: selected))
					MoveInformationView(title: "Protecting", chessGame: $chessGame, positions: chessGame.board.protecting(from: selected))
					MoveInformationView(title: "Attacked by", chessGame: $chessGame, positions: chessGame.board.attackers(forWhite: piece.isWhite, at: selected))
					MoveInformationView(title: "Attacking", chessGame: $chessGame, positions: chessGame.board.attacking(from: selected))
				}
				Section("Evaluation") {
					ForEach(GameEvaluators.allCases, id: \.id) { evaluator in
						LabeledContent(evaluator.rawValue, value: evaluator.evaluator.evaluate(position: selected, on: chessGame.board).description)
					}
				}
			}
			.formStyle(.grouped)
			.navigationTitle("\(selected.algebraic) - \(chessGame.board[selected]!.name)")
			.onAppear {
				chessGame.selected = self.selected
			}
		} else {
			ContentUnavailableView("No piece selected", systemImage: "quenstionmar.circle", description: Text("There is no piece at the selected position"))
		}
	}
}

#Preview {
	PieceInformationView(chessGame: .constant(ChessGame()), selected: Position(4, 6)!)
}
