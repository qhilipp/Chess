//
//  ChessStatsView.swift
//  Chess
//
//  Created by Privat on 19.04.25.
//

import SwiftUI

struct ChessStatsView: View {
    
    @State var chessGame: ChessGame
	@State var showSelectedInformation = false
    
    var body: some View {
        Form {
			Section {
				LabeledContent("Turn", value: chessGame.board.isWhiteTurn.name)
				Button {
					showSelectedInformation = true
				} label: {
					LabeledContent("Selected", value: chessGame.selected?.algebraic ?? "None")
				}
				.popover(isPresented: $showSelectedInformation) {
					if let selected = chessGame.selected {
						NavigationStack {
							PieceInformationView(chessGame: $chessGame, selected: selected)
						}
						.frame(maxWidth: 250)
					} else {
						ContentUnavailableView("No piece selected", systemImage: "questionmark.circle")
					}
				}
				.onChange(of: chessGame.selected) { _, newValue in
					if newValue == nil {
						showSelectedInformation = false
					}
				}
				.disabled(chessGame.selected == nil)
			}
            Section("FEN") {
                CopyableTokenView(text: chessGame.board.fen)
            }
			Section("Evaluation") {
				ForEach(GameEvaluators.allCases, id: \.id) { evaluator in
					LabeledContent(evaluator.rawValue, value: evaluator.evaluator.evaluate(board: chessGame.board).description)
				}
			}
            Section("White") {
				BasicStatisticsView(chessGame: chessGame, isWhite: true)
            }
            Section("Black") {
				BasicStatisticsView(chessGame: chessGame, isWhite: false)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    ChessStatsView(chessGame: ChessGame())
}
