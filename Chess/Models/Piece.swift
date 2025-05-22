//
//  Piece.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import Foundation

struct Piece: CustomStringConvertible, Equatable {
	let isWhite: Bool
	let type: PieceType
	
	var description: String {
		isWhite ? type.rawValue.uppercased() : type.rawValue
	}
	
	var assetName: String {
		"\(isWhite.name)_\(self.type.rawValue)"
	}
	
	var name: String {
		"\(isWhite.name) \(type.name)"
	}
	
	var value: Int {
		type.value * isWhite.value
	}
	
	init(isWhite: Bool, type: PieceType) {
		self.isWhite = isWhite
		self.type = type
	}
	
	init?(symbol: String) {
		if symbol.count != 1 {
			return nil
		}
		guard let pieceType = PieceType(rawValue: symbol.lowercased()) else {
			return nil
		}
		type = pieceType
		isWhite = symbol[symbol.startIndex].isUppercase
	}
	
	static func ==(lhs: Piece, rhs: Piece) -> Bool {
		lhs.isWhite == rhs.isWhite && lhs.type == rhs.type
	}
}

enum PieceType: String, CaseIterable {
	case king = "k"
	case queen = "q"
	case rook = "r"
	case bishop = "b"
	case knight = "n"
	case pawn = "p"
	
	var value: Int {
		switch self {
			case .king: 100
			case .queen: 9
			case .rook: 5
			case .bishop: 3
			case .knight: 3
			case .pawn: 1
		}
	}
	
	var name: String {
		switch self {
			case .king: "King"
			case .queen: "Queen"
			case .rook: "Rook"
			case .bishop: "Bishop"
			case .knight: "Knight"
			case .pawn: "Pawn"
		}
	}
}
