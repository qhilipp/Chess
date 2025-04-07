//
//  ChessBoardView.swift
//  Chess
//
//  Created by Philipp Kathöfer on 07.04.25.
//

import SwiftUI

struct ChessBoardView: View {
	let whiteColor = Color.white
	let blackColor = Color.black
	
    var body: some View {
		Canvas { context, size in
			let boardSize: Int = Int(min(size.width, size.height))
			let fieldSize: Int = boardSize / 8
			
			for row in 0..<8 {
				for column in 0..<8 {
					guard let pixelPosition = fieldToPixel((column, row), for: size) else {
						continue
					}
					
					context.fill(Path(CGRect(x: pixelPosition.0, y: pixelPosition.1, width: fieldSize, height: fieldSize)), with: .color(fieldColor(for: (column, row))))
					if row == 7 || column == 0 {
						let string = ChessBoard.positionDescription(for: (column, row)) ?? "-"
						let text = Text(string).foregroundColor(inverseFieldColor(for: (column, row)))
						let resolved = context.resolve(text)
						
						context.draw(resolved, in: CGRect(x: pixelPosition.0, y: pixelPosition.1, width: fieldSize, height: fieldSize))
					}
				}
			}
		}
		.frame(width: 504, height: 654)
    }
	
	func pixelToField(_ position: (Int, Int), for size: CGSize) -> (Int, Int)? {
		guard position.0 >= 0 && position.0 <= Int(size.width) && position.1 >= 0 && position.1 <= Int(size.height) else {
			return nil
		}
		
		let boardSize: Int = Int(min(size.width, size.height))
		let fieldSize: Int = boardSize / 8
		let xOffset: Int = Int(size.width) - boardSize
		let yOffset: Int = Int(size.height) - boardSize
		
		return ((position.0 - xOffset) / fieldSize, (position.1 - yOffset) / fieldSize)
	}
	
	func fieldToPixel(_ position: (Int, Int), for size: CGSize) -> (Int, Int)? {
		guard position.0 >= 0 && position.0 < 8 && position.1 >= 0 && position.1 < 8 else {
			return nil
		}
		
		let boardSize: Int = Int(min(size.width, size.height))
		let fieldSize: Int = boardSize / 8
		let xOffset: Int = (Int(size.width) - boardSize) / 2
		let yOffset: Int = (Int(size.height) - boardSize) / 2
		
		return (xOffset + fieldSize * position.0, yOffset + fieldSize * position.1)
	}
	
	func inverseFieldColor(for position: (Int, Int)) -> Color {
		isWhiteField(position) ? blackColor : whiteColor
	}
	
	func fieldColor(for position: (Int, Int)) -> Color {
		isWhiteField(position) ? whiteColor : blackColor
	}
	
	func isWhiteField(_ position: (Int, Int)) -> Bool {
		(position.0 + position.1) % 2 == 0
	}
	
}

#Preview {
    ChessBoardView()
}
