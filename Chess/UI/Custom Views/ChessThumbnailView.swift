//
//  ChessThumbnailView.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import SwiftUI

struct ChessThumbnailView: View {
    
    @State var chessGame: ChessGame
    
    var body: some View {
        VStack {
            ChessBoardView(chessGame: chessGame)
            Text(chessGame.name)
        }
    }
}

#Preview {
    ChessThumbnailView(chessGame: ChessGame())
}
