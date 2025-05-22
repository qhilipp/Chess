//
//  MinimaxBot.swift
//  Chess
//
//  Created by Privat on 28.04.25.
//

import Foundation

class MinimaxBot: ChessBot {
	
	var evaluator: GameEvaluator
	
	init(evaluator: GameEvaluator) {
		self.evaluator = evaluator
	}
	
	func generateMove(for board: ChessBoard) -> (Position, Position) {
		var copy = board
		return generateMove(for: &copy, depth: 2)
	}
	
	func generateMove(for board: inout ChessBoard, depth: Int) -> (Position, Position) {
		var best: Float? = nil
		var bestMove: (Position, Position)? = nil
		for (from, positions) in board.legalMoves(forWhite: board.isWhiteTurn) {
			for to in positions {
				var copy = board
				try! copy.move(from: from, to: to)
				if depth > 0 {
					_ = generateMove(for: &copy, depth: depth - 1)
				}
				let score = evaluator.evaluate(board: copy)
				if isBetter(score, than: best, isWhite: board.isWhiteTurn) {
					best = score
					bestMove = (from, to)
				}
			}
		}
		if let bestMove {
			try! board.move(from: bestMove.0, to: bestMove.1)
		}
		return bestMove!
	}
	
	func isBetter(_ score: Float, than highscore: Float?, isWhite: Bool) -> Bool {
		if let highscore {
			return isWhite ? score > highscore : score < highscore
		}
		return true
	}
}
