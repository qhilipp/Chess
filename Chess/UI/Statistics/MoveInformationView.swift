//
//  MoveInformationView.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import SwiftUI

struct MoveInformationView: View {
	
	let title: String
	@Binding var chessGame: ChessGame
	let positions: [Position]
	
	var body: some View {
		NavigationLink {
			PositionsList(for: positions, chessGame: $chessGame)
		} label: {
			LabeledContent(title, value: positions.count.description)
		}
		.disabled(positions.isEmpty)
	}
}

#Preview {
	NavigationStack {
		MoveInformationView(title: "Moves", chessGame: .constant(ChessGame()), positions: ChessGame().board.legalMoves(for: Position(4, 6)!))
	}
}
