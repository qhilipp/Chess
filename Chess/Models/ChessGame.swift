//
//  ChessGame.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/20/25.
//

import Foundation
import SwiftUICore
import SwiftData

@Observable
class ChessGame {
    var name: String
	var board: ChessBoard
	var white: ChessPlayer
	var black: ChessPlayer
	var selected: Position? = nil
	var whiteColor: Color
	var blackColor: Color
	
	var currentPlayer: ChessPlayer {
		board.isWhiteTurn ? white : black
	}
	
    init(name: String? = nil, fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1") {
		self.board = ChessBoard(fen: fen)!
		self.white = .human
		self.black = .bot(MinimaxBot(evaluator: FastEvaluator()))
		self.whiteColor = .white
		self.blackColor = .brown
        if let name {
            self.name = name
        } else {
            self.name = "New Game"
        }
	}
}
