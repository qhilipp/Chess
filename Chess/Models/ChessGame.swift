//
//  ChessGame.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/20/25.
//

import Foundation

class ChessGame {
	var board: ChessBoard
	var white: ChessPlayer
	var black: ChessPlayer
	
	init() {
		self.board = ChessBoard(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")!
		self.white = HumanChessPlayer()
		self.black = HumanChessPlayer()
	}
}
