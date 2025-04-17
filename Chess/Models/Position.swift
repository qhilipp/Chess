//
//  Position.swift
//  Chess
//
//  Created by Philipp Kathöfer on 11.04.25.
//

import Foundation

struct Position: Equatable, Hashable {
	
	var x: Int
	var y: Int
	
	var algebraic: String {
		String(Character(UnicodeScalar(x + 97)!)) + String(8 - y)
	}
	
	var above: Position? { Position(x, y - 1) }
	var below: Position? { Position(x, y + 1) }
	var left: Position? { Position(x - 1, y) }
	var right: Position? { Position(x + 1, y) }
	
	init?(_ x: Int, _ y: Int) {
		guard x >= 0 && x < 8 && y >= 0 && y < 8 else {
			return nil
		}
		self.x = x
		self.y = y
	}
	
	init?(row: Int, column: Int) {
		guard row >= 0 && row < 8 && column >= 0 && column < 8 else {
			return nil
		}
		self.y = row
		self.x = column
	}
	
	init?(algebraic description: String) {
		if description.count != 2 {
			return nil
		}
		if !"abcdefgh".contains(description.first!) {
			return nil
		}
		guard let number = Int(String(description.last!)) else {
			return nil
		}
		
		x = Int(description.first!.asciiValue!) - 97
		y = number - 1
	}
}
