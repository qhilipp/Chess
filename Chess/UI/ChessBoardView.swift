//
//  ChessBoardView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 07.04.25.
//

import SwiftUI

struct ChessBoardView: View {
	let whiteColor = Color.white
	let blackColor = Color.brown
	
	var chessGame: ChessGame = ChessGame()
	@State var selected: Position?
	
	var selectedPiece: Piece? {
		guard let selected else {
			return nil
		}
		return chessGame.board[selected]
	}
	
	var possibleMoves: [Position] {
		guard let selected else {
			return []
		}
		return chessGame.board.legalMoves(for: selected)
	}
	
    var body: some View {
		VStack {
			Text(chessGame.board.fen)
			Canvas { context, size in
				let boardSize: Int = Int(min(size.width, size.height))
				let fieldSize: Int = boardSize / 8
				
				for row in 0..<8 {
					for column in 0..<8 {
						let position = Position(row: row, column: column)!
						let pixelPosition = fieldToPixel(position, for: size)
						
						context.fill(Path(CGRect(x: pixelPosition.0, y: pixelPosition.1, width: fieldSize, height: fieldSize)), with: .color(fieldColor(for: position)))
						
						if row == 7 || column == 0 {
							let text = Text(position.algebraic).foregroundColor(inverseFieldColor(for: position))
							let resolved = context.resolve(text)
							
							context.draw(resolved, in: CGRect(x: pixelPosition.0, y: pixelPosition.1, width: fieldSize, height: fieldSize))
						}
						
						if let piece = chessGame.board.squares[row][column] {
							let resolved = context.resolve(Image(piece.assetName))
							context.draw(resolved, in: CGRect(x: pixelPosition.0, y: pixelPosition.1, width: fieldSize, height: fieldSize))
						}
					}
				}
				
				let ellipseSize = fieldSize / 3
				let padding = (fieldSize - ellipseSize) / 2
				for possibleMove in possibleMoves {
					let pixelPosition = fieldToPixel(possibleMove, for: size)
					if chessGame.board[possibleMove] == nil {
						context.fill(Path(ellipseIn: CGRect(x: pixelPosition.0 + padding, y: pixelPosition.1 + padding, width: ellipseSize, height: ellipseSize)), with: .color(.black.opacity(0.35)))
					} else {
						// TODO: Coolere Umrandung für gegnerische Figur
						context.fill(Path(ellipseIn: CGRect(x: pixelPosition.0 + padding, y: pixelPosition.1 + padding, width: ellipseSize, height: ellipseSize)), with: .color(.black.opacity(0.5)))
					}
				}
			}
			.frame(width: 504, height: 504)
			.onTapGesture { location in
				let newSelection = pixelToField((Int(location.x), Int(location.y)), for: CGSize(width: 504, height: 504))
				guard newSelection != selected else {
					selected = nil
					return
				}
				selected = newSelection
			}
		}
    }
	
	func pixelToField(_ position: (Int, Int), for size: CGSize) -> Position? {
		let boardSize: Int = Int(min(size.width, size.height))
		let fieldSize: Int = boardSize / 8
		let xOffset: Int = Int(size.width) - boardSize
		let yOffset: Int = Int(size.height) - boardSize
		
		return Position((position.0 - xOffset) / fieldSize, (position.1 - yOffset) / fieldSize)
	}
	
	func fieldToPixel(_ position: Position, for size: CGSize) -> (Int, Int) {
		let boardSize: Int = Int(min(size.width, size.height))
		let fieldSize: Int = boardSize / 8
		let xOffset: Int = (Int(size.width) - boardSize) / 2
		let yOffset: Int = (Int(size.height) - boardSize) / 2
		
		return (xOffset + fieldSize * position.x, yOffset + fieldSize * position.y)
	}
	
	func inverseFieldColor(for position: Position) -> Color {
		isWhiteField(position) ? blackColor : whiteColor
	}
	
	func fieldColor(for position: Position) -> Color {
		isWhiteField(position) ? whiteColor : blackColor
	}
	
	func isWhiteField(_ position: Position) -> Bool {
		(position.x + position.y) % 2 == 0
	}
	
}

#Preview {
    ChessBoardView()
}
