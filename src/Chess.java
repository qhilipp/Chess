import java.awt.Point;

public class Chess {
	
	public static Board fromFen(String fen) {
		Board b = new Board();
		int i = 0;
		String[] parts = fen.split(" ");
		for(int column = 0; column < 8; column++) {
			for(int p = 0; p < 8;) {
				char c = parts[0].charAt(i++);
				if("prnbqk".contains(Character.toLowerCase(c) + "")) {
					b.board[p][column] = c;
					p++;
				} else if(Character.isDigit(c)) {
					p += Character.getNumericValue(c);
				}
			}
		}
		
		b.whiteTurn = parts[1].charAt(0) == 'w';
		
		b.whiteKing = parts[2].contains("K");
		b.whiteQueen = parts[2].contains("Q");
		b.blackKing = parts[2].contains("k");
		b.blackQueen = parts[2].contains("q");
		
		parts[3] = "e4";
		if(parts[3].charAt(0) != '-') {
			b.enPassant = new Point(parts[3].charAt(0) - 97, parts[3].charAt(1) - 56);
			System.out.println(b.enPassant);
		}
		
		b.halfMoves = Integer.parseInt(parts[4]);
		
		b.fullMoves = Integer.parseInt(parts[5]);
		
		return b;
	}
	
	public static boolean isWhite(char code) {
		return Character.isUpperCase(code);
	}
	
	public static char[][] emptyBoard() {
		char[][] b = new char[8][8];
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				b[i][j] = ' ';
			}
		}
		return b;
	}

	public static String toFen(Board b) {
		String fen = "";
		
		for(int i = 0; i < 8; i++) {
			int count = 0;
			for(int j = 0; j < 8; j++) {
				if(b.get(j, i) != ' ') {
					if(count != 0) fen += count;
					fen += b.get(j, i);
					count = 0;
				} else {
					count++;
				}
			}
			if(count != 0) fen += count;
			if(i != 7) fen += "/";
		}
		
		fen += b.whiteTurn ? " w " : " b ";
		
		fen += b.whiteKing ? "K" : "";
		fen += b.whiteQueen ? "Q" : "";
		fen += b.blackKing ? "k" : "";
		fen += b.blackQueen ? "q" : "";
		
		fen += " ";
		fen += b.enPassant != null ? ((char) (b.enPassant.x + 97) + "" + (char) (56 - b.enPassant.y)) : "-";
		fen += " ";
		
		fen += b.halfMoves + " ";
		
		fen += b.fullMoves;
		
		return fen;
	}
	
	public static void print(Board b) {
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				System.out.print(b.board[j][i] + " ");
			}
			System.out.println();
		}
	}
	
}
