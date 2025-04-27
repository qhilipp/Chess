//
//  GameEvaluator.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import Foundation

protocol GameEvaluator {
	
	func evaluate(position: Position, on board: ChessBoard) -> Float
	func evaluate(board: ChessBoard) -> Float
}

extension GameEvaluator {
	func evaluate(board: ChessBoard) -> Float {
		var value: Float = 0
		for x in 0..<8 {
			for y in 0..<8 {
				value += evaluate(position: Position(x, y)!, on: board)
			}
		}
		return value
	}
}

enum GameEvaluators: String, CaseIterable, Identifiable, Hashable {
	case simpleEvaluator = "Simple Evaluator"
	case fastEvaluator = "Fast Evaluator"
	
	var id: String {
		rawValue
	}
	
	var evaluator: any GameEvaluator {
		switch self {
			case .simpleEvaluator: SimpleEvaluator()
			case .fastEvaluator: FastEvaluator()
		}
	}
}
