//
//  FastEvaluator.swift
//  Chess
//
//  Created by Privat on 27.04.25.
//

import Foundation

struct FastEvaluator: GameEvaluator {
	
	func evaluate(position: Position, on board: ChessBoard) -> Float {
		Float(board[position]?.value ?? 0)
	}
}
