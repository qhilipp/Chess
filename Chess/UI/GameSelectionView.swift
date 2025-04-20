//
//  GameSelectionView.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import SwiftUI

struct GameSelectionView: View {
    
    @State var games: [ChessGame] = [ChessGame(), ChessGame(fen: "rnbqkbnr/pppp1ppp/4p3/8/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2")]
    
    var body: some View {
        List {
            
        }
    }
}

#Preview {
    GameSelectionView()
}
