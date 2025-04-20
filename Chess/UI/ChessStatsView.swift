//
//  ChessStatsView.swift
//  Chess
//
//  Created by Privat on 19.04.25.
//

import SwiftUI

struct ChessStatsView: View {
    
    @State var chessGame: ChessGame
    @State var shownLegalMoves: Bool? = nil
    @State var showWhiteLegalMoves = false
    @State var showBlackLegalMoves = false
    
    var body: some View {
        Form {
            Section("FEN") {
                CopyableTokenView(text: chessGame.board.fen)
            }
            Section("White") {
                BasicStats(chessGame: chessGame, isWhite: true)
            }
            Section("Black") {
                BasicStats(chessGame: chessGame, isWhite: false)
            }
        }
        .formStyle(.grouped)
    }
}

struct BasicStats: View {
    
    @State var chessGame: ChessGame
    @State var showLegalMoves = false
    @State var showPiecePositions = false
    let isWhite: Bool
    
    var body: some View {
        LabeledContent("Has turn", value: (chessGame.board.isWhiteTurn == isWhite).description)
        LabeledContent("Check", value: chessGame.board.isCheck(forWhite: isWhite).description)
        LabeledContent("Checkmate", value: chessGame.board.isCheckMate(forWhite: isWhite).description)
		LabeledContent("Queenside castling", value : chessGame.board.white.castleQueen.description)
		LabeledContent("Kingside castling", value : chessGame.board.white.castleKing.description)
        Button {
            showPiecePositions = true
        } label: {
            LabeledContent("Pieces", value: chessGame.board.piecePositions(forWhite: isWhite).count.description)
        }
        .popover(isPresented: $showPiecePositions) {
			List(chessGame.board.piecePositions(forWhite: isWhite).sorted(by: { $0.algebraic < $1.algebraic })) { position in
                Text("\(position.algebraic) - \(chessGame.board[position]!.type)")
            }
        }
        Button {
            showLegalMoves = true
        } label: {
            LabeledContent("Legal moves", value: chessGame.board.countOfLegalMoves(forWhite: isWhite).description)
        }
        .popover(isPresented: $showLegalMoves) {
            movesList(for: chessGame.board.legalMoves(forWhite: isWhite))
        }
    }
    
    @ViewBuilder
    func movesList(for moveMap: [Position: [Position]]) -> some View {
		List(moveMap.keys.sorted(by: { $0.algebraic < $1.algebraic })) { from in
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
