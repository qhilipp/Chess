//
//  ChessBoard.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import Foundation

struct ChessBoard: CustomStringConvertible {
	
	var squares: [[Piece?]]
	var white: PlayerInformation
	var black: PlayerInformation
	var enPassant: (Int, Int)?
	var isWhiteTurn: Bool = true
	var halfMoves: Int = 0
	var fullMoves: Int = 1
	
	var stringDescriptions: [String] {
		let turn = isWhiteTurn ? "w" : "b"
		
		var castleString = ""
		if white.castleKing {
			castleString += "K"
		}
		if white.castleQueen {
			castleString += "Q"
		}
		if black.castleKing {
			castleString += "k"
		}
		if black.castleQueen {
			castleString += "q"
		}
		
		let enPassant = ChessBoard.positionDescription(for: self.enPassant) ?? "-"
		
		let halfMoves = String(self.halfMoves)
		
		let fullMoves = String(self.fullMoves)
		
		return [turn, castleString, enPassant, halfMoves, fullMoves]
	}
	
	var description: String {
		var positionString = ""
		for row in squares {
			positionString += row.map { $0?.description ?? "-" }.joined()
			positionString += "\n"
		}
		
		let infoStrings = [positionString] + stringDescriptions
		
		return infoStrings.joined(separator: " ")
	}
	
	var fen: String {
		var rowStrings: [String] = []
		for row in squares {
			var gap = 0
			rowStrings.append("")
			for (rowIndex, square) in row.enumerated() {
				guard let piece = square else {
					gap += 1
					if rowIndex == 7 {
						rowStrings[rowStrings.endIndex.advanced(by: -1)] += String(gap)
					}
					continue
				}
				if gap > 0 {
					rowStrings[rowStrings.endIndex.advanced(by: -1)] += String(gap)
				}
				rowStrings[rowStrings.endIndex.advanced(by: -1)] += piece.description
			}
		}
		let positionString = rowStrings.joined(separator: "/")
		let infoStrings = [positionString] + stringDescriptions
		
		return infoStrings.joined(separator: " ")
	}
	
	init(squares: [[Piece]], white: PlayerInformation, black: PlayerInformation, enPassant: (Int, Int)?, isWhiteTurn: Bool, fullMoves: Int) {
		self.squares = squares
		self.white = white
		self.black = black
		self.enPassant = enPassant
		self.isWhiteTurn = isWhiteTurn
		self.fullMoves = fullMoves
	}
	
	init?(fen: String) {
		let segments = fen.split(separator: " ")
		
		guard segments.count == 6 else { return nil }
		
		let rows = segments[0].split(separator: "/")
		squares = Array(repeating: Array(repeating: nil, count: 8), count: 8)
		for (boardRow, row) in rows.enumerated() {
			var boardColumn = 0
			for symbol in row {
				if symbol.isNumber {
					boardColumn += Int(String(symbol))!
				} else {
					guard let piece = Piece(symbol: String(symbol)) else { return nil }
					squares[boardRow][boardColumn] = piece
				}
				boardColumn += 1
			}
		}
		if !["w", "b"].contains(String(segments[1])) {
			return nil
		}
		isWhiteTurn = segments[1] == "w"
		
		white = PlayerInformation(castleKing: segments[2].contains("K"), castleQueen: segments[2].contains("Q"))
		black = PlayerInformation(castleKing: segments[2].contains("k"), castleQueen: segments[2].contains("q"))
		
		enPassant = ChessBoard.positionDescription(for: String(segments[3]))
		
		guard let halfMoves = Int(String(segments[4])) else { return nil }
		self.halfMoves = halfMoves
		
		guard let fullMoves = Int(String(segments[5])) else { return nil }
		self.fullMoves = fullMoves
	}
	
	static func positionDescription(for description: String) -> (Int, Int)? {
		if description.count != 2 {
			return nil
		}
		if !"abcdefgh".contains(description.first!) {
			return nil
		}
		guard let number = Int(String(description.last!)) else {
			return nil
		}
		return (Int(description.first!.asciiValue!) - 97, number - 1)
	}
	
	static func positionDescription(for position: (Int, Int)?) -> String? {
		guard let position else {
			return nil
		}
		if position.0 > 0 && position.0 < 8 && position.1 > 0 && position.1 < 8 {
			return String(Character(UnicodeScalar(position.0 + 97)!)) + String(position.1 + 1)
		} else {
			return nil
		}
	}
}

struct PlayerInformation {
	var castleKing: Bool
	var castleQueen: Bool
	
	init(castleKing: Bool, castleQueen: Bool) {
		self.castleKing = castleKing
		self.castleQueen = castleQueen
	}
}

struct Piece: CustomStringConvertible {
	let isWhite: Bool
	let type: PieceType
	
	var description: String {
		isWhite ? type.rawValue.uppercased() : type.rawValue
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
}

enum PieceType: String {
	case king = "k"
	case queen = "q"
	case rook = "r"
	case bishop = "b"
	case knight = "n"
	case pawn = "p"
	case none = "-"
}
