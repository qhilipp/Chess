//
//  PositionsList.swift
//  Chess
//
//  Created by Privat on 21.04.25.
//

import SwiftUI

struct PositionsList: View {
	
	@Binding var chessGame: ChessGame
	var dict: [Position: [Position]]?
	var positions: [Position]?
	
	init(for dict: [Position: [Position]], chessGame: Binding<ChessGame>) {
		self.dict = dict
		self._chessGame = chessGame
	}
	
	init(for positions: [Position], chessGame: Binding<ChessGame>) {
		self.positions = positions.sorted(by: { $0.algebraic < $1.algebraic })
		self._chessGame = chessGame
	}
	
    var body: some View {
		Group {
			if let dict {
				List(dict.keys.sorted(by: { $0.algebraic < $1.algebraic })) { from in
					if let moves = dict[from], !moves.isEmpty {
						Section {
							ForEach(moves) { position in
								positionView(for: position)
							}
						} header: {
							positionView(for: from)
								.buttonStyle(.plain)
						}
					}
				}
				.listStyle(.inset)
			} else if let positions {
				List(positions) { position in
					positionView(for: position)
				}
				.listStyle(.inset)
			} else {
				ContentUnavailableView("No position", systemImage: "questionmark.circle", description: Text("No positions found."))
			}
		}
    }
	
	@ViewBuilder
	func positionView(for position: Position) -> some View {
		NavigationLink {
			PieceInformationView(chessGame: $chessGame, selected: position)
		} label: {
			HStack {
				if let piece = chessGame.board[position] {
					Image(piece.assetName)
						.resizable()
						.frame(width: 20, height: 20)
					Text("\(position.algebraic) - \(piece.name)")
					Spacer()
					Image(systemName: "chevron.forward")
						.foregroundStyle(.secondary)
						.frame(width: 15, height: 15)
				} else {
					Image(systemName: "slash.circle")
						.resizable()
						.frame(width: 20, height: 20)
					Text("\(position.algebraic)")
				}
			}
		}
		.disabled(chessGame.board[position] == nil)
	}
}

#Preview {
	NavigationStack {
		PositionsList(for: [Position(0, 0)!, Position(2, 3)!], chessGame: .constant(ChessGame()))
	}
}
