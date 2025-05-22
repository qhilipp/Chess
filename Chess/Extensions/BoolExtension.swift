//
//  BoolExtension.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import Foundation

extension Bool: @retroactive Identifiable {
    public var id: Bool { self }
	
	var value: Int {
		self ? 1 : -1
	}
	
	var name: String {
		self ? "White" : "Black"
	}
}
