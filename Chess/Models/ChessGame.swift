//
//  ChessGame.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/20/25.
//

import Foundation

@Observable
class ChessGame {
	var board: ChessBoard
	var white: ChessPlayer
	var black: ChessPlayer
	
	init(fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1") {
		self.board = ChessBoard(fen: fen)!
		self.white = HumanChessPlayer()
		self.black = HumanChessPlayer()
	}
}
