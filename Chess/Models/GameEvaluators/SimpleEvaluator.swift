//
//  SimpleEvaluator.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import Foundation

struct SimpleEvaluator: GameEvaluator {
	
	var map: [PieceType: [[Float]]] = [:]
	
	var name: String { "Simple evaluator" }
	
	init() {
		map[.pawn] = [
			[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
			[0.1, 0.1, 0.1, 0.2, 0.2, 0.1, 0.1, 0.1],
			[0.1, 0.1, 0.2, 0.3, 0.3, 0.2, 0.1, 0.1],
			[0.15, 0.2, 0.3, 0.4, 0.4, 0.3, 0.2, 0.15],
			[0.15, 0.2, 0.3, 0.4, 0.4, 0.3, 0.2, 0.15],
			[0.1, 0.15, 0.2, 0.3, 0.3, 0.2, 0.15, 0.1],
			[0.05, 0.1, 0.1, 0.2, 0.2, 0.1, 0.1, 0.05],
			[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		]

		map[.knight] = [
			[0.05, 0.1, 0.15, 0.2, 0.2, 0.15, 0.1, 0.05],
			[0.1, 0.2, 0.25, 0.3, 0.3, 0.25, 0.2, 0.1],
			[0.15, 0.25, 0.3, 0.35, 0.35, 0.3, 0.25, 0.15],
			[0.2, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.2],
			[0.2, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.2],
			[0.15, 0.25, 0.3, 0.35, 0.35, 0.3, 0.25, 0.15],
			[0.1, 0.2, 0.25, 0.3, 0.3, 0.25, 0.2, 0.1],
			[0.05, 0.1, 0.15, 0.2, 0.2, 0.15, 0.1, 0.05]
		]

		map[.bishop] = [
			[0.1, 0.15, 0.15, 0.2, 0.2, 0.15, 0.15, 0.1],
			[0.15, 0.2, 0.25, 0.3, 0.3, 0.25, 0.2, 0.15],
			[0.15, 0.25, 0.3, 0.35, 0.35, 0.3, 0.25, 0.15],
			[0.2, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.2],
			[0.2, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.2],
			[0.15, 0.25, 0.3, 0.35, 0.35, 0.3, 0.25, 0.15],
			[0.15, 0.2, 0.25, 0.3, 0.3, 0.25, 0.2, 0.15],
			[0.1, 0.15, 0.15, 0.2, 0.2, 0.15, 0.15, 0.1]
		]

		map[.rook] = [
			[0.2, 0.2, 0.2, 0.3, 0.3, 0.2, 0.2, 0.2],
			[0.25, 0.25, 0.25, 0.3, 0.3, 0.25, 0.25, 0.25],
			[0.2, 0.2, 0.2, 0.3, 0.3, 0.2, 0.2, 0.2],
			[0.15, 0.15, 0.15, 0.25, 0.25, 0.15, 0.15, 0.15],
			[0.15, 0.15, 0.15, 0.25, 0.25, 0.15, 0.15, 0.15],
			[0.2, 0.2, 0.2, 0.3, 0.3, 0.2, 0.2, 0.2],
			[0.25, 0.25, 0.25, 0.3, 0.3, 0.25, 0.25, 0.25],
			[0.2, 0.2, 0.2, 0.3, 0.3, 0.2, 0.2, 0.2]
		]

		map[.queen] = [
			[0.2, 0.25, 0.25, 0.3, 0.3, 0.25, 0.25, 0.2],
			[0.25, 0.3, 0.3, 0.35, 0.35, 0.3, 0.3, 0.25],
			[0.25, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.25],
			[0.3, 0.35, 0.4, 0.45, 0.45, 0.4, 0.35, 0.3],
			[0.3, 0.35, 0.4, 0.45, 0.45, 0.4, 0.35, 0.3],
			[0.25, 0.3, 0.35, 0.4, 0.4, 0.35, 0.3, 0.25],
			[0.25, 0.3, 0.3, 0.35, 0.35, 0.3, 0.3, 0.25],
			[0.2, 0.25, 0.25, 0.3, 0.3, 0.25, 0.25, 0.2]
		]

		map[.king] = [
			[0.4, 0.4, 0.35, 0.3, 0.3, 0.35, 0.4, 0.4],
			[0.45, 0.45, 0.4, 0.35, 0.35, 0.4, 0.45, 0.45],
			[0.3, 0.35, 0.35, 0.3, 0.3, 0.35, 0.35, 0.3],
			[0.2, 0.25, 0.3, 0.3, 0.3, 0.3, 0.25, 0.2],
			[0.15, 0.2, 0.25, 0.25, 0.25, 0.25, 0.2, 0.15],
			[0.1, 0.15, 0.2, 0.2, 0.2, 0.2, 0.15, 0.1],
			[0.05, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.05],
			[0.0, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.0]
		]

	}
	
	func protectionValue(of position: Position, on board: ChessBoard) -> Int? {
		var protectionValue = 0
		for protectedPosition in board.protecting(from: position) {
			protectionValue += board[protectedPosition]!.value
		}
		return protectionValue
	}
	
	func attackValue(of position: Position, on board: ChessBoard) -> Float? {
		var attackValue: Float = 0
		for protectedPosition in board.legalMoves(for: position) {
			if let value = board[protectedPosition]?.value {
				attackValue += Float(value)
			} else {
				attackValue += 0.1
			}
		}
		return attackValue
	}
	
	func protectedAttackedValue(of position: Position, on board: ChessBoard) -> Int? {
		guard let piece = board[position] else { return nil }
		return board.protectors(forWhite: piece.isWhite, at: position).count - board.attackers(forWhite: piece.isWhite, at: position).count
	}
	
	func mapValue(of position: Position, on board: ChessBoard) -> Float {
		guard let piece = board[position] else { return 0 }
		let reverseMap = piece.isWhite
		let yPosition = reverseMap ? 7 - position.y : position.y
		return map[piece.type]![yPosition][position.x]
	}
	
	func evaluate(position: Position, on board: ChessBoard) -> Float {
		guard let piece = board[position] else { return 0 }
//		guard let protectionValue = protectionValue(of: position, on: board) else { return 0 }
//		guard let attackValue = attackValue(of: position, on: board) else { return 0 }
		
		let mapValue = mapValue(of: position, on: board)
		let typeValue = piece.value
		return Float(typeValue) * mapValue// * Float(protectionValue) * Float(attackValue)
	}
}
