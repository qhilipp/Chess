import java.awt.Point;

public class Board {

	// white - uppercased
	// black - lowercased
	
	char[][] board = Chess.emptyBoard();
	boolean whiteTurn = true;
	boolean whiteKing = true, whiteQueen = true, blackKing = true, blackQueen = true;
	Point enPassant = null;
	int halfMoves = 0;
	int fullMoves = 0;
	
	public char get(int x, int y) {
		return board[x][y];
	}
	
	public void move(int fromX, int fromY, int toX, int toY) {
		enPassant = null;
		if(Character.toLowerCase(get(fromX, fromY)) == 'p') {
			halfMoves = 0;
			if(Math.abs(fromY - toY) == 2) {
				enPassant = new Point(fromX, (fromY + toY) / 2);
				System.out.println(enPassant);
			}
		} else {
			halfMoves++;
		}
		fullMoves++;
		char temp = board[fromX][fromY];
		board[fromX][fromY] = ' ';
		board[toX][toY] = temp;
		whiteTurn = !whiteTurn;
	}
	
	public int evaluate() {
		int sum = 0;
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				sum += evaluate(board[i][j]);
			}
		}
		return sum;
	}
	
	public boolean hasTurn(int x, int y) {
		return Chess.isWhite(get(x, y)) == whiteTurn;
	}
	
	public int evaluate(char code) {
		int sign = Chess.isWhite(code) ? 1 : -1;
		switch(Character.toLowerCase(code)) {
			case ' ': return 0;
			case 'p': return sign;
			case 'n': return sign * 3;
			case 'b': return sign * 3;
			case 'r': return sign * 5;
			case 'q': return sign * 9;
			default: return sign * 1000000;
		}
	}
	
}
