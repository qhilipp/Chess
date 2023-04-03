import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.swing.JFrame;

public class Main extends JFrame implements MouseListener, MouseMotionListener, KeyListener {

	String black = "#7D945D";
	String white = "#EBECD3";
	
	Board board = Chess.fromFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0");
	
	Point highlighted = null;
	Point selected = null;
	
	int width, height, size = 1, barHeight, xOff, yOff;
	
	public Main() {
		setSize(676, 704);
		setLocationRelativeTo(null);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLayout(null);
		setBackground(Color.BLACK);
		setVisible(true);
		addMouseListener(this);
		addMouseMotionListener(this);
		addKeyListener(this);
	}

	public static void main(String[] args) {
		new Main();
	}

	@Override
	public void paint(Graphics g0) {

		width = getWidth();
		height = getContentPane().getHeight();
		
		barHeight = getHeight() - getContentPane().getHeight();
				
		size = Math.min(width, height) / 8;
		
		BufferedImage img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		Graphics2D g = img.createGraphics();
		
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				g.setColor(Color.decode((i + j) % 2 == 0 ? white : black));
				g.fillRect(size * i, size * j, size, size);
				if(selected != null && selected.x == i && selected.y == j) continue;
				if(board.get(i, j) != 0) {
					Image pice = getPieceImage(board.get(i, j));
					int off = 0;
					if(highlighted != null && highlighted.x == i && highlighted.y == j) off = 5;
					g.drawImage(pice, i * size - off, j * size - off, size + 2 * off, size + 2 * off, null);
				}
			}
		}
		
		if(selected != null) {
			Image pice = getPieceImage(board.get(selected.x, selected.y));
			int off = 5;
			int x = MouseInfo.getPointerInfo().getLocation().x - getX();
			int y = MouseInfo.getPointerInfo().getLocation().y - getY();
			g.drawImage(pice, x - off - size / 2, y - off - size / 2 - barHeight, size + 2 * off, size + 2 * off, null);
		}
		
		xOff = (width - (8 * size)) / 2;
		yOff = (height - (8 * size)) / 2 + barHeight;
		
		g0.setColor(getBackground());
		g0.fillRect(0, 0, getWidth(), getHeight());
		g0.drawImage(img, xOff, yOff, null);
	}

	private Image getPieceImage(char code) {
		try {
			return ImageIO.read(new File("Pieces/" + (Chess.isWhite(code) ? "" : "-") + code + ".png"));
		} catch (IOException e) {}
		return null;
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {}

	@Override
	public void mousePressed(MouseEvent e) {
		int x = (e.getX() - xOff) / size;
		int y = (e.getY() - yOff) / size;
		if(!board.hasTurn(x, y)) return;
		selected = new Point(x, y);
		repaint();
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		if(selected == null) return;
		int x = (e.getX() - xOff) / size;
		int y = (e.getY() - yOff) / size;
		if(e.getX() >= 0 && x < 8 && e.getY() >= 0 && y < 8) {
			board.move(selected.x, selected.y, x, y);
		}
		selected = null;
		repaint();
	}

	@Override
	public void mouseEntered(MouseEvent e) {}

	@Override
	public void mouseExited(MouseEvent e) {
		highlighted = null;
	}

	@Override
	public void mouseDragged(MouseEvent e) {
		if(selected != null) repaint();
	}

	@Override
	public void mouseMoved(MouseEvent e) {
		int x = (e.getX() - xOff) / size;
		int y = (e.getY() - yOff) / size;
		if(x < 0 || x > 7 || y < 0 || y > 7 || !board.hasTurn(x, y)) return;
		if(highlighted != null && highlighted.x == x && highlighted.y == y) return;
		if(selected == null) highlighted = new Point(x, y);
		repaint();
	}

	@Override
	public void keyTyped(KeyEvent e) {
		if(e.getKeyChar() == ' ') {
			System.out.println(Chess.toFen(board));
			repaint();
		}
	}

	@Override
	public void keyPressed(KeyEvent e) {}

	@Override
	public void keyReleased(KeyEvent e) {}
	
}
