//
//  BasicStatisticsView.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import SwiftUI

struct BasicStatisticsView: View {
	
	@State var chessGame: ChessGame
	@State var showLegalMoves = false
	@State var showPiecePositions = false
	let isWhite: Bool
	
	var body: some View {
		LabeledContent("Has turn", value: (chessGame.board.isWhiteTurn == isWhite).description)
		LabeledContent("Check", value: chessGame.board.isCheck(forWhite: isWhite).description)
		LabeledContent("Checkmate", value: chessGame.board.isCheckMate(forWhite: isWhite).description)
		LabeledContent("Queenside castling", value : chessGame.board.white.castleQueen.description)
		LabeledContent("Kingside castling", value : chessGame.board.white.castleKing.description)
		Button {
			showPiecePositions = true
		} label: {
			LabeledContent("Pieces", value: chessGame.board.piecePositions(forWhite: isWhite).count.description)
		}
		.popover(isPresented: $showPiecePositions) {
			NavigationStack {
				PositionsList(for: chessGame.board.piecePositions(forWhite: isWhite), chessGame: $chessGame)
					.navigationTitle("\(isWhite.name) pieces")
			}
		}
		Button {
			showLegalMoves = true
		} label: {
			LabeledContent("Legal moves", value: chessGame.board.legalMoves(forWhite: isWhite).count.description)
		}
		.popover(isPresented: $showLegalMoves) {
			NavigationStack {
				PositionsList(for: chessGame.board.legalMoves(forWhite: isWhite), chessGame: $chessGame)
					.navigationTitle("\(isWhite.name) legal moves")
			}
		}
	}
}

#Preview {
	Form {
		Section("White") {
			BasicStatisticsView(chessGame: ChessGame(), isWhite: true)
		}
		Section("Black") {
			BasicStatisticsView(chessGame: ChessGame(), isWhite: false)
		}
	}
	.formStyle(.grouped)
}
