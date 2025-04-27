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
		
		if rows.count != 8 {
			return nil
		}
		
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

public enum MoveException: Error {
	case moveToSameField
	case noPieceToMove
}

enum RemisReason {
	case stalemate
	case repetition
	case fiftyMoves
	case impossibleCheckmate
	case consent
	case timeOut
	
	var explanation: String {
		switch self {
			case .stalemate: "Stalemate"
			case .repetition: "the same position three moves ago"
			case .fiftyMoves: "50 moves without capturing a piece or moving a pawn"
			case .impossibleCheckmate: "checkmate being impossible"
			case .consent: "both players agreeing for a Remis"
			case .timeOut: "a time out"
		}
	}
}

// MARK: Outcomes
extension ChessBoard {
	
	func isCheckmateImpossible(forWhite isWhite: Bool) -> Bool {
		let pieces = piecePositions(forWhite: isWhite).compactMap { self[$0] }
		guard pieces.count <= 2 else { return false }
		if pieces.contains(Piece(isWhite: isWhite, type: .bishop)) || pieces.contains(Piece(isWhite: isWhite, type: .knight)) {
			return true
		}
		return pieces.count == 1
	}
	
	func remis() -> RemisReason? {
		remis(forWhite: isWhiteTurn) ?? remis(forWhite: !isWhiteTurn)
	}
	
	func remis(forWhite isWhite: Bool) -> RemisReason? {
		if isCheckmateImpossible(forWhite: isWhite) {
			.impossibleCheckmate
		} else if !isCheck(forWhite: isWhite) && legalMoves(forWhite: isWhite).isEmpty {
			.stalemate
		} else {
			nil
		}
	}
	
	func isCheckMate(forWhite isWhite: Bool) -> Bool {
		isCheck(forWhite: isWhite) && legalMoves(forWhite: isWhite).isEmpty
	}
	
	func isCheck(forWhite isWhite: Bool) -> Bool {
		guard let kingPosition = kingPosition(forWhite: isWhite) else {
			return true
		}
		for x in 0..<8 {
			for y in 0..<8 {
				if self[Position(x, y)!]?.isWhite == !isWhite {
					if pseudoLegalMoves(for: Position(x, y)!).contains(kingPosition) {
						return true
					}
				}
			}
		}
		return false
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
}

// MARK: Moves
extension ChessBoard {
	
	func pseudoLegalMoves(for position: Position, friendlyFire: Bool = false) -> [Position] {
		guard let piece = self[position] else {
			return []
		}
		var pseudoLegalMoves: [Position] = []
		
		switch piece.type {
			case .king:
				add(move: position.left, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				
				add(move: position.left?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.left?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
			
				if position.x != 4 {
					break
				}
				
				let color = piece.isWhite ? white : black
				if color.castleKing &&
					self[position.right!] == nil &&
					self[position.right!.right!] == nil &&
					attackers(forWhite: piece.isWhite, at: position.right!).isEmpty &&
					attackers(forWhite: piece.isWhite, at: position.right!.right!).isEmpty
				{
					pseudoLegalMoves.append(position.right!.right!)
				}
				if color.castleQueen &&
					self[position.left!] == nil &&
					self[position.left!.left!] == nil &&
					self[position.left!.left!.left!] == nil &&
					attackers(forWhite: piece.isWhite, at: position.left!).isEmpty &&
					attackers(forWhite: piece.isWhite, at: position.left!.left!).isEmpty &&
					attackers(forWhite: piece.isWhite, at: position.left!.left!.left!).isEmpty
				{
					pseudoLegalMoves.append(position.left!.left!.left!)
				}
			case .queen:
				add(direction: \.left, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				
				add(direction: \.left?.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right?.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.left?.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right?.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
			case .rook:
				add(direction: \.left, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
			case .bishop:
				add(direction: \.left?.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right?.above, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.left?.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
				add(direction: \.right?.below, to: &pseudoLegalMoves, from: position, friendlyFire: friendlyFire)
			case .knight:
				add(move: position.left?.above?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.left?.left?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.above?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.right?.above, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				
				add(move: position.left?.below?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.left?.left?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.below?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
				add(move: position.right?.right?.below, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
			case .pawn:
				let direction: KeyPath<Position, Position?> = piece.isWhite ? \.above : \.below
				
				if let singleMove = position[keyPath: direction], self[singleMove] == nil {
					add(move: singleMove, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
					
					let isOnHomeRow = position.y == (piece.isWhite ? 6 : 1)
					if let doubleMove = position[keyPath: direction]?[keyPath: direction], isOnHomeRow, self[doubleMove] == nil {
						add(move: doubleMove, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
					}
				}
				
				if let otherPosition = position.left?[keyPath: direction] {
					let canCapture = if let otherPiece = self[otherPosition], (otherPiece.isWhite != piece.isWhite || friendlyFire) { true } else { false }
					let canEnPassant = otherPosition == enPassant
					if canCapture || canEnPassant {
						add(move: otherPosition, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
					}
				}
				
				if let otherPosition = position.right?[keyPath: direction] {
					let canCapture = if let otherPiece = self[otherPosition], (otherPiece.isWhite != piece.isWhite || friendlyFire) { true } else { false }
					let canEnPassant = otherPosition == enPassant
					if canCapture || canEnPassant {
						add(move: otherPosition, to: &pseudoLegalMoves, from: piece, friendlyFire: friendlyFire)
					}
				}
		}
		
		return pseudoLegalMoves
	}
	
	func legalMoves(for position: Position, friendlyFire: Bool = false) -> [Position] {
		pseudoLegalMoves(for: position, friendlyFire: friendlyFire).filter { newPosition in
			var copy = self
			try! copy.move(from: position, to: newPosition)
			return !copy.isCheck(forWhite: !copy.isWhiteTurn)
		}
	}
	
	func legalMoves(forWhite isWhite: Bool, friendlyFire: Bool = false) -> [Position: [Position]] {
		piecePositions(forWhite: isWhite).reduce(into: [:]) { partialResult, position in
			let legalMoves = legalMoves(for: position, friendlyFire: friendlyFire)
			if !legalMoves.isEmpty {
				partialResult[position] = legalMoves
			}
		}
	}
	
	mutating func move(from: Position, to: Position) throws(MoveException) {
		if from.x == to.x && from.y == to.y {
			throw MoveException.moveToSameField
		}
		guard let piece = self[from] else {
			throw MoveException.noPieceToMove
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
		
		if piece.type == .king && from.x == 4 && to.x == 6 {
			self[Position(7, from.y)!] = nil
			self[Position(5, from.y)!] = Piece(isWhite: piece.isWhite, type: .rook)
		}
		
		if piece.type == .king && from.x == 4 && to.x == 1 {
			self[Position(0, from.y)!] = nil
			self[Position(2, from.y)!] = Piece(isWhite: piece.isWhite, type: .rook)
		}
		
		isWhiteTurn.toggle()
	}
	
	@discardableResult
	func add(move position: Position?, to list: inout [Position], from piece: Piece, friendlyFire: Bool) -> PotentialMoveClassification {
		guard let position else { return .blocked }
		if let otherPiece = self[position] {
			if piece.isWhite == otherPiece.isWhite && !friendlyFire {
				return .blocked
			} else {
				list.append(position)
				return .capture
			}
		}
		list.append(position)
		return .free
	}
	
	func add(direction keyPath: KeyPath<Position, Position?>, to list: inout [Position], from start: Position, friendlyFire: Bool) {
		guard let piece = self[start] else {
			return
		}
		var position: Position? = start
		repeat {
			position = position?[keyPath: keyPath]
		} while add(move: position, to: &list, from: piece, friendlyFire: friendlyFire) == .free
	}
	
	enum PotentialMoveClassification {
		case free
		case capture
		case blocked
	}
}

// MARK: Evaluation
extension ChessBoard {
	
	func attackingMap(forWhite isWhite: Bool) -> [[[Position]]: [Position]] {
		var map: [[[Position]]: [Position]] = [:]
		
		return map
	}
	
	func piecePositions(forWhite isWhite: Bool) -> [Position] {
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
	
	func protectors(forWhite isWhite: Bool, at position: Position) -> [Position] {
		var copy = self
		copy[position] = nil
		return copy.attackers(forWhite: !isWhite, at: position)
	}
	
	func protecting(from position: Position) -> [Position] {
		legalMoves(for: position, friendlyFire: true).filter { self[$0]?.isWhite == self[position]?.isWhite }
	}
	
	func attackers(forWhite isWhite: Bool, at position: Position) -> [Position] {
		var attackers: [Position] = []
		for piecePosition in piecePositions(forWhite: !isWhite) {
			if legalMoves(for: piecePosition).contains(position) {
				attackers.append(piecePosition)
				continue
			}
		}
		return attackers
	}
	
	func attacking(from position: Position) -> [Position] {
		legalMoves(for: position).filter { self[$0]?.isWhite == self[position]?.isWhite }
	}
}
