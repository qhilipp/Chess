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
	var enPassant: Position?
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
		
		let enPassant = enPassant?.algebraic ?? "-"
		
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
				gap = 0
			}
		}
		let positionString = rowStrings.joined(separator: "/")
		let infoStrings = [positionString] + stringDescriptions
		
		return infoStrings.joined(separator: " ")
	}
	
	init(squares: [[Piece]], white: PlayerInformation, black: PlayerInformation, enPassant: Position?, isWhiteTurn: Bool, fullMoves: Int) {
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
					boardColumn += 1
				}
			}
		}
		if !["w", "b"].contains(String(segments[1])) {
			return nil
		}
		isWhiteTurn = segments[1] == "w"
		
		white = PlayerInformation(castleKing: segments[2].contains("K"), castleQueen: segments[2].contains("Q"))
		black = PlayerInformation(castleKing: segments[2].contains("k"), castleQueen: segments[2].contains("q"))
		
		enPassant = Position(algebraic: String(segments[3]))
		
		guard let halfMoves = Int(String(segments[4])) else { return nil }
		self.halfMoves = halfMoves
		
		guard let fullMoves = Int(String(segments[5])) else { return nil }
		self.fullMoves = fullMoves
	}
	
	func pseudoLegalMoves(for position: Position) -> [Position] {
		guard let piece = self[position] else {
			return []
		}
		var pseudoLegalMoves: [Position] = []
		
		switch piece.type {
			case .king:
				add(move: position.left, to: &pseudoLegalMoves, from: piece)
				add(move: position.right, to: &pseudoLegalMoves, from: piece)
				add(move: position.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.below, to: &pseudoLegalMoves, from: piece)
			case .queen:
				add(for: \.left, to: &pseudoLegalMoves, from: position)
				add(for: \.right, to: &pseudoLegalMoves, from: position)
				add(for: \.above, to: &pseudoLegalMoves, from: position)
				add(for: \.below, to: &pseudoLegalMoves, from: position)
				
				add(for: \.left?.above, to: &pseudoLegalMoves, from: position)
				add(for: \.right?.above, to: &pseudoLegalMoves, from: position)
				add(for: \.left?.below, to: &pseudoLegalMoves, from: position)
				add(for: \.right?.below, to: &pseudoLegalMoves, from: position)
			case .rook:
				add(for: \.left, to: &pseudoLegalMoves, from: position)
				add(for: \.right, to: &pseudoLegalMoves, from: position)
				add(for: \.above, to: &pseudoLegalMoves, from: position)
				add(for: \.below, to: &pseudoLegalMoves, from: position)
			case .bishop:
				add(for: \.left?.above, to: &pseudoLegalMoves, from: position)
				add(for: \.right?.above, to: &pseudoLegalMoves, from: position)
				add(for: \.left?.below, to: &pseudoLegalMoves, from: position)
				add(for: \.right?.below, to: &pseudoLegalMoves, from: position)
			case .knight:
				add(move: position.left?.above?.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.left?.left?.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.above?.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.right?.above, to: &pseudoLegalMoves, from: piece)
				
				add(move: position.left?.below?.below, to: &pseudoLegalMoves, from: piece)
				add(move: position.left?.left?.below, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.below?.below, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.right?.below, to: &pseudoLegalMoves, from: piece)
			case .pawn:
				add(move: piece.isWhite ? position.above : position.below, to: &pseudoLegalMoves, from: piece)
			case .none:
				break
		}
		
		return pseudoLegalMoves
	}
	
	func legalMoves(for position: Position) -> [Position] {
		pseudoLegalMoves(for: position)
	}
	
	mutating func move(from: Position, to: Position) throws {
		if from.x == to.x && from.y == to.y {
			throw BoardException.moveToSameField
		}
		guard let piece = self[from] else {
			throw BoardException.noPieceToMove
		}
		
		halfMoves += 1
		
		if piece.type == .pawn || self[to] != nil {
			halfMoves = 0
		}
		
		if !isWhiteTurn {
			fullMoves += 1
		}
		
		self[from] = nil
		self[to] = piece
		
		isWhiteTurn.toggle()
	}
	
	subscript(_ position: Position) -> Piece? {
		get {
			squares[position.y][position.x]
		}
		set {
			squares[position.y][position.x] = newValue
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
	
	var assetName: String {
		"\(isWhite ? "White" : "Black")_\(self.type.rawValue)"
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

enum BoardException: Error {
	case moveToSameField
	case noPieceToMove
}

enum PotentialMoveClassification {
	case free
	case attack
	case blocked
}

extension ChessBoard {
	
	@discardableResult
	func add(move position: Position?, to list: inout [Position], from piece: Piece) -> PotentialMoveClassification {
		guard let position else { return .blocked }
		if let otherPiece = self[position] {
			if piece.isWhite == otherPiece.isWhite {
				return .attack
			}
		}
		list.append(position)
		return .free
	}
	
	func add(for keyPath: KeyPath<Position, Position?>, to list: inout [Position], from start: Position) {
		guard let piece = self[start] else {
			return
		}
		var position: Position? = start
		repeat {
			position = position?[keyPath: keyPath]
		} while add(move: position, to: &list, from: piece) == .free
	}
}
