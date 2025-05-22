//
//  ChessBot.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/20/25.
//

import Foundation

protocol ChessBot {
	
	var evaluator: GameEvaluator { get set }
	func generateMove(for board: ChessBoard) -> (Position, Position)
}
