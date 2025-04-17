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
		
		if castleString.isEmpty {
			castleString = "-"
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
	
	var currentPlayer: PlayerInformation {
		get {
			isWhiteTurn ? white : black
		}
		
		set {
			if isWhiteTurn {
				white = newValue
			} else {
				black = newValue
			}
		}
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
	
	func kingPosition(forWhite isWhite: Bool) -> Position? {
		for x in 0..<8 {
			for y in 0..<8 {
				if self[Position(x, y)!] == Piece(isWhite: isWhite, type: .king) {
					return Position(x, y)!
				}
			}
		}
		return nil
	}
	
	func attackingPositions(ofWhite isWhite: Bool) -> [Position] {
		var positions: Set<Position> = []
		for piecePosition in piecePositions(ofWhite: isWhite) {
			positions.formUnion(pseudoLegalMoves(for: piecePosition))
		}
		return Array(positions)
	}
	
	// This could be cached in the future
	func piecePositions(ofWhite isWhite: Bool) -> [Position] {
		var positions: [Position] = []
		for x in 0..<8 {
			for y in 0..<8 {
				if self[Position(x, y)!]?.isWhite == isWhite {
					positions.append(Position(x, y)!)
				}
			}
		}
		return positions
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
				
				add(move: position.left?.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.above, to: &pseudoLegalMoves, from: piece)
				add(move: position.left?.below, to: &pseudoLegalMoves, from: piece)
				add(move: position.right?.below, to: &pseudoLegalMoves, from: piece)
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
				let direction: KeyPath<Position, Position?> = piece.isWhite ? \.above : \.below
				
				if let singleMove = position[keyPath: direction], self[singleMove] == nil {
					add(move: singleMove, to: &pseudoLegalMoves, from: piece)
					
					let isOnHomeRow = position.y == (piece.isWhite ? 6 : 1)
					if let doubleMove = position[keyPath: direction]?[keyPath: direction], isOnHomeRow, self[doubleMove] == nil {
						add(move: doubleMove, to: &pseudoLegalMoves, from: piece)
					}
				}
				
				if let otherPosition = position.left?[keyPath: direction] {
					let canCapture = if let otherPiece = self[otherPosition], otherPiece.isWhite != piece.isWhite { true } else { false }
					let canEnPassant = otherPosition == enPassant
					if canCapture || canEnPassant {
						add(move: otherPosition, to: &pseudoLegalMoves, from: piece)
					}
				}
				
				if let otherPosition = position.right?[keyPath: direction] {
					let canCapture = if let otherPiece = self[otherPosition], otherPiece.isWhite != piece.isWhite { true } else { false }
					let canEnPassant = otherPosition == enPassant
					if canCapture || canEnPassant {
						add(move: otherPosition, to: &pseudoLegalMoves, from: piece)
					}
				}
			case .none:
				break
		}
		
		return pseudoLegalMoves
	}
	
	func isCheck(forWhite isWhite: Bool) -> Bool {
		let kingPosition = kingPosition(forWhite: isWhite)!
		for x in 0..<8 {
			for y in 0..<8 {
				if self[Position(x, y)!]?.isWhite == isWhite {
					if pseudoLegalMoves(for: Position(x, y)!).contains(kingPosition) {
						return true
					}
				}
			}
		}
		return false
	}
	
	func legalMoves(for position: Position) -> [Position] {
		pseudoLegalMoves(for: position).filter { newPosition in
			var copy = self
			try! copy.move(from: position, to: newPosition)
			return !copy.isCheck(forWhite: !copy.isWhiteTurn)
		}
	}
	
	mutating func move(from: Position, to: Position) throws(BoardException) {
		if from.x == to.x && from.y == to.y {
			throw BoardException.moveToSameField
		}
		guard let piece = self[from] else {
			throw BoardException.noPieceToMove
		}
		
		if to == enPassant {
			self[Position(to.x, from.y)!] = nil
		}
		
		enPassant = nil
		
		halfMoves += 1
		
		if piece.type == .pawn || self[to] != nil {
			halfMoves = 0
		}
		
		if piece.type == .king {
			currentPlayer.castleKing = false
			currentPlayer.castleQueen = false
		}
		
		if piece.type == .rook {
			if from.x == 0 {
				currentPlayer.castleQueen = false
			} else {
				currentPlayer.castleKing = false
			}
		}
		
		if piece.type == .pawn && abs(from.y - to.y) == 2 {
			enPassant = Position(from.x, (from.y + to.y) / 2)
		}
		
		if !isWhiteTurn {
			fullMoves += 1
		}
		
		self[from] = nil
		if piece.type == .pawn && (to.y == 0 || to.y == 7) {
			self[to] = Piece(isWhite: piece.isWhite, type: .queen)
		} else {
			self[to] = piece
		}
		
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

struct Piece: CustomStringConvertible, Equatable {
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
	
	static func ==(lhs: Piece, rhs: Piece) -> Bool {
		lhs.isWhite == rhs.isWhite && lhs.type == rhs.type
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
	case capture
	case blocked
}

extension ChessBoard {
	
	@discardableResult
	func add(move position: Position?, to list: inout [Position], from piece: Piece) -> PotentialMoveClassification {
		guard let position else { return .blocked }
		if let otherPiece = self[position] {
			if piece.isWhite == otherPiece.isWhite {
				return .blocked
			} else {
				list.append(position)
				return .capture
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
