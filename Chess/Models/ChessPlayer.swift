//
//  ChessPlayer.swift
//  Chess
//
//  Created by Privat on 27.04.25.
//

import Foundation

enum ChessPlayer: Equatable {
	
	case human
	case bot(_: any ChessBot)
	
	static func == (lhs: ChessPlayer, rhs: ChessPlayer) -> Bool {
		if case .human = lhs, case .human = rhs {
			return true
		}
		if case .bot(let leftBot) = lhs, case .bot(let rightBot) = lhs {
			return type(of: leftBot) == type(of: rightBot)
		}
		return false
	}
}
