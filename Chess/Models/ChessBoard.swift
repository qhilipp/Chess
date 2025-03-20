//
//  ChessBoard.swift
//  Chess
//
//  Created by Philipp Kathöfer on 3/19/25.
//

import Foundation

struct ChessBoard {
	var squares: [[Piece]]
	var isWhiteTurn: Bool = true
	var fullMoves: Int = 1
	
	init(squares: [[Piece]], isWhiteTurn: Bool, fullMoves: Int) {
		self.squares = squares
		self.isWhiteTurn = isWhiteTurn
		self.fullMoves = fullMoves
	}
	
	init(fen: String) {
		
	}
}

struct PlayerInformation {
	var castleKing: Bool
	var castleQueen: Bool
	var enPassant: (Int, Int)?
	var halfMoves: Int
	
	init(castleKing: Bool, castleQueen: Bool, enPassant: (Int, Int)? = nil, halfMoves: Int) {
		self.castleKing = castleKing
		self.castleQueen = castleQueen
		self.enPassant = enPassant
		self.halfMoves = halfMoves
	}
}

enum Piece {
	case king
	case queen
	case rook
	case bishop
	case knight
	case pawn
}
