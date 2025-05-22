//
//  RandomBot.swift
//  Chess
//
//  Created by Privat on 27.04.25.
//

import Foundation

class RandomBot: ChessBot {
	
	var evaluator: GameEvaluator
	
	init(evaluator: GameEvaluator) {
		self.evaluator = evaluator
	}
	
	func generateMove(for board: ChessBoard) -> (Position, Position) {
		let legalMoves = board.legalMoves(forWhite: board.isWhiteTurn)
		let from = legalMoves.keys.randomElement()
		return (from!, legalMoves[from!]!.randomElement()!)
	}
}
