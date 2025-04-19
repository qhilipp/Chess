//
//  ChessStatsView.swift
//  Chess
//
//  Created by Privat on 19.04.25.
//

import SwiftUI

struct ChessStatsView: View {
    
    @State var chessGame: ChessGame
    
    var body: some View {
        NavigationStack {
            Form {
                Section("White") {
                    basicStats(forWhite: true)
                }
                Section("Black") {
                    basicStats(forWhite: false)
                }
            }
            .formStyle(.grouped)
        }
    }
    
    @ViewBuilder
    func basicStats(forWhite isWhite: Bool) -> some View {
        LabeledContent("Has turn", value: chessGame.board.isWhiteTurn.description)
        LabeledContent("Check", value: chessGame.board.isCheck(forWhite: isWhite).description)
        LabeledContent("Checkmate", value: chessGame.board.isCheckMate(forWhite: isWhite).description)
        LabeledContent("King position", value: chessGame.board.kingPosition(forWhite: isWhite)!.algebraic)
        NavigationLink {
            movesList(for: chessGame.board.legalMoves(forWhite: isWhite))
        } label: {
            LabeledContent("Legal moves", value: chessGame.board.legalMoves(forWhite: isWhite).count.description)
        }
    }
    
    @ViewBuilder
    func movesList(for moveMap: [Position: [Position]]) -> some View {
        List(Array(moveMap.keys)) { from in
            if let moves = moveMap[from], !moves.isEmpty {
                Section("\(from.algebraic) - \(chessGame.board[from]!.type)") {
                    moveList(for: moves)
                }
            }
        }
    }
    
    @ViewBuilder
    func moveList(for moves: [Position]) -> some View {
        ForEach(moves) { to in
            if let pieceType = chessGame.board[to]?.type {
                Text("\(to.algebraic) - \(pieceType)")
            } else {
                Text("\(to.algebraic)")
            }
        }
    }
}

#Preview {
    ChessStatsView(chessGame: ChessGame())
}
