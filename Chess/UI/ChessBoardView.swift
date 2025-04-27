//
//  ChessBoardView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 07.04.25.
//

import SwiftUI

struct ChessBoardView: View {
	
	var chessGame: ChessGame = ChessGame()
    var isInteractive: Bool = true
    @State private var boardSize: CGFloat = 0
    @State private var viewSize: CGSize = CGSize(width: 0, height: 0)
    @State private var showCheckMate = false
	@State private var showRemis = false
	
	var selectedPiece: Piece? {
		guard let selected = chessGame.selected else {
			return nil
		}
		return chessGame.board[selected]
	}
	
	var possibleMoves: [Position] {
		guard let selected = chessGame.selected else {
			return []
		}
		return chessGame.board.legalMoves(for: selected)
	}
	
    var body: some View {
        Canvas { context, size in
            let boardSize = min(size.width, size.height)
            if boardSize != self.boardSize {
                DispatchQueue.main.async {
                    self.boardSize = boardSize
                }
            }
            
            let fieldSize: Int = Int(boardSize / 8)
            
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
					let radius = fieldSize / 7
					let outlinePadding = fieldSize / 11
					print(fieldSize, radius, outlinePadding)
					let centers = [
						CGPoint(x: pixelPosition.0 + outlinePadding + radius, y: pixelPosition.1 + outlinePadding + radius),
						CGPoint(x: pixelPosition.0 + fieldSize - outlinePadding - radius, y: pixelPosition.1 + outlinePadding + radius),
						CGPoint(x: pixelPosition.0 + fieldSize - outlinePadding - radius, y: pixelPosition.1 + fieldSize - outlinePadding - radius),
						CGPoint(x: pixelPosition.0 + outlinePadding + radius, y: pixelPosition.1 + fieldSize - outlinePadding - radius)
					]
					for i in 0..<4 {
						let startAngle = Double(i * 90 + 180)
						let endAngle = startAngle + 90
						var path = Path()
						
						path.addArc(
							center: centers[i],
							radius: CGFloat(radius),
							startAngle: .degrees(startAngle),
							endAngle: .degrees(endAngle),
							clockwise: false
						)
						context.stroke(path, with: .color(.black.opacity(0.35)), lineWidth: 6)
					}
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.size) { oldValue, newValue in
                        self.viewSize = newValue
                    }
            }
        )
        .onTapGesture { location in
            guard isInteractive else { return }
            guard let newSelection = pixelToField((location.x, location.y)) else {
				chessGame.selected = nil
                return
            }
			if let selected = chessGame.selected, possibleMoves.contains(newSelection), chessGame.board[selected]?.isWhite == chessGame.board.isWhiteTurn {
                do throws(MoveException) {
                    try chessGame.board.move(from: selected, to: newSelection)
                    
                    if chessGame.board.isCheckMate(forWhite: chessGame.board.isWhiteTurn) {
                        showCheckMate = true
                    }
					
					if chessGame.board.remis() != nil {
						showRemis = true
					}
                } catch {
                    print(error.localizedDescription)
                }
                chessGame.selected = nil
                return
            }
			guard newSelection != chessGame.selected else {
				chessGame.selected = nil
                return
            }
            if chessGame.board[newSelection] == nil {
				chessGame.selected = nil
            } else {
				chessGame.selected = newSelection
            }
        }
        .alert("Checkmate!", isPresented: $showCheckMate) { } message: {
            Text("\(!chessGame.board.isWhiteTurn ? "White" : "Black") won after \(chessGame.board.fullMoves) moves.")
        }
		.alert("Remis!", isPresented: $showRemis) {} message: {
			Text("The game ended in Remis due to \(chessGame.board.remis()?.explanation ?? "an unknown reason").")
		}
    }
	
	func pixelToField(_ position: (CGFloat, CGFloat)) -> Position? {
		let fieldSize: Int = Int(boardSize / 8)
        let xOffset: CGFloat = (viewSize.width - boardSize) / 2
		let yOffset: CGFloat = (viewSize.height - boardSize) / 2
		
		return Position(Int(position.0 - xOffset) / fieldSize, Int(position.1 - yOffset) / fieldSize)
	}
	
	func fieldToPixel(_ position: Position, for size: CGSize) -> (Int, Int) {
		let boardSize: Int = Int(min(size.width, size.height))
		let fieldSize: Int = boardSize / 8
		let xOffset: Int = (Int(size.width) - boardSize) / 2
		let yOffset: Int = (Int(size.height) - boardSize) / 2
		
		return (xOffset + fieldSize * position.x, yOffset + fieldSize * position.y)
	}
	
	func inverseFieldColor(for position: Position) -> Color {
		isWhiteField(position) ? chessGame.blackColor : chessGame.whiteColor
	}
	
	func fieldColor(for position: Position) -> Color {
		isWhiteField(position) ? chessGame.whiteColor : chessGame.blackColor
	}
	
	func isWhiteField(_ position: Position) -> Bool {
		(position.x + position.y) % 2 == 0
	}
	
}

#Preview {
    ChessBoardView()
}
