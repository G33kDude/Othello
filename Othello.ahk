; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}

OnExit, ExitSub

BoardW := (BoardH := 8)
tSize := 30
w := BoardW * (tSize + 5) + 5
h := BoardH * (tSize + 5) + 5
Player := 1
Players := 2
Gui, Color, 303030
Gui, Margin, 0, 0
Gui, Add, Progress, w%w% h%h% hwndGdipHwnd Background303030, 0
Board.__New(GdiphWnd, BoardW, BoardH, tSize, ["FFFFFF", "000000", "0000FF"])
;Gui, Add, Button, gPass, Pass
Gui, Show
Board.Board[4,4].Owner := 1
Board.Board[5,5].Owner := 1
Board.Board[4,5].Owner := 2
Board.Board[5,4].Owner := 2
Board.Update()
Board.draw()
OnMessage(0x201, "WM_BUTTONDOWN")
OnMessage(0x204, "WM_BUTTONDOWN")
OnMessage(0xF, "WM_PAINT")
return

GuiClose:
ExitApp
return

ExitSub:
Editor := ""
Gdip_Shutdown(pToken)
ExitApp

Pass:
IncPlayer()
return

WM_PAINT(wParam, lParam, Msg, hWnd)
{
	global Board
	Sleep, 0 ; Ensures redraw in edge cases (fast movement and restore from minimize)
	Board.Draw()
}

WM_BUTTONDOWN(wParam, lParam, Msg, hWnd)
{
	global Board, Player, Players
	if (hWnd == Board.hWnd)
	{
		x := (lParam&0xFFFF) - 5
		y := (((lParam>>16)&0xFFFF) - 5)
		if (Mod(x, Board.tSize + 5) > Board.tSize || x < 0)
			return ; Out of bounds
		if (Mod(y, Board.tSize + 5) > Board.tSize || y < 0)
			return ; Out of bounds
		TileX := x//(Board.tSize+5)+1
		TileY := y//(Board.tSize+5)+1
		Claimed := Board.Claim(TileX, TileY, Player)
		Board.Draw()
		if (Claimed)
			IncPlayer()
	}
}

IncPlayer(n=1)
{
	global Player, Players, Board
	
	Player += n-1
	Loop
	{
		if (A_Index > Players)
		{
			MsgBox, % "It's a draw!"
			ExitApp
		}
		else if (A_Index > 1)
		{
			if (Board.IsOnBoard(Player))
			{
				ToolTip, Skipped player %Player%
				Sleep, 1000
				ToolTip
			}
		}
		Player += 1
		
		While (Player > Players)
			Player -= Players
	}
	Until Board.CanPlay(Player)
	
	Gui, show,, Player: %Player%
}

class Board
{
	__New(hWnd, Width, Height, tSize, OwnerColors)
	{
		this.hWnd := hWnd
		this.Width := Width
		this.Height := Height
		this.tSize := tSize
		this.OwnerColors := OwnerColors
		
		this.FGColor := "6BAA6B"
		this.BGColor := "226C22"
		
		; Needed to make progress bar redraw correctly on resize
		Control, ExStyle, -0x20000,, % "ahk_id " this.hWnd
		
		GuiControlGet, g, Pos, %hWnd%
		this.gX := gX
		this.gY := gY
		this.gW := gW
		this.gH := gH
		
		this.Brushes := []
		
		this.Board := []
		this.Tiles := []
		Loop, % Width
		{
			x := A_Index
			Loop, % Height
			{
				y := A_Index
				Tile := new Tile(x, y)
				Tile.Owner := 0
				this.Tiles.Insert(Tile)
				this.Board[x, y] := Tile
			}
		}
		
		this.hDC_Window := GetDC(this.hWnd)
		this.hDC := CreateCompatibleDC()
		this.hDIB := CreateDIBSection(this.gW, this.gH)
		SelectObject(this.hDC, this.hDIB)
		this.G := Gdip_GraphicsFromHDC(this.hDC)
		
		GuiControl, MoveDraw, % this.hWnd, % "w" gW-1 " h" gH-1
		GuiControl, MoveDraw, % this.hWnd, % "w" gW " h" gH
		this.Update()
		return this
	}
	
	Update()
	{
		this.Square(this.BGColor, 0, 0, this.gW)
		
		for each, tile in this.Tiles
		{
			xPos := (tile.x - 1) * (this.tSize + 5) + 5
			yPos := (tile.y - 1) * (this.tSize + 5) + 5
			
			this.Square(this.FGColor, xPos, yPos, this.tSize)
			
			if (tile.Owner)
				this.Circle(this.OwnerColors[tile.Owner], xPos, yPos, this.tSize)
		}
	}
	
	Square(Color, xPos, yPos, Width, Height=0)
	{
		if !Height
			Height := Width
		if !this.Brushes.HasKey(Color)
			this.Brushes[Color] := Gdip_BrushCreateSolid("0xFF" Color)
		Gdip_SetSmoothingMode(this.G, 3)
		Gdip_FillRectangle(this.G, this.Brushes[Color], xPos, yPos, Width, Height)
	}
	
	Circle(Color, xPos, yPos, Size)
	{
		if !this.Brushes.HasKey(Color)
			this.Brushes[Color] := Gdip_BrushCreateSolid("0xFF" Color)
		Gdip_SetSmoothingMode(this.G, 4)
		Gdip_FillEllipse(this.G, this.Brushes[Color], xPos, yPos, Size-1, Size-1)
	}
	
	Draw()
	{
		BitBlt(this.hDC_Window, 0, 0, this.gW, this.gH, this.hDC, 0, 0)
	}
	
	CanClaim(x, y, NewOwner)
	{
		if (this.Board[x, y].Owner) ; Tile already owned
			return false
		
		Confirmed := []
		for each, Dir in [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
		{
			CurrentX := x + Dir[1]
			CurrentY := y + Dir[2]
			Possible := []
			
			while (CurrentX >= 1 && CurrentX <= this.Width && CurrentY >= 1 && CurrentY <= this.Height)
			{
				if !(Tile := this.Board[CurrentX, CurrentY]) ; Tile nonexistent
					Break
				else if (!Tile.Owner) ; Unclaimed tile
					Break
				else if (Tile.Owner == NewOwner) ; Our tile
				{
					if Possible.MaxIndex()
					{
						Max := Confirmed.MaxIndex()
						Confirmed.Insert(Max=""?1:Max+1, Possible*)
					}
					Break
				}
				Else ; Other player's tile
					Possible.Insert(Tile)
				
				CurrentX += Dir[1]
				CurrentY += Dir[2]
			}
		}
		if !(Confirmed.MaxIndex())
			return false
		Confirmed.Insert(this.Board[x, y])
		return Confirmed
	}
	
	Claim(x, y, NewOwner)
	{
		if !(List := this.CanClaim(x, y, NewOwner))
			return False
		for each, Tile in List
			Tile.Owner := NewOwner
		this.Update()
		return true
	}
	
	CanPlay(Player)
	{
		for each, Tile in Board.Tiles
			if (Board.CanClaim(Tile.x, Tile.y, Player))
				return true
		return false
	}
	
	IsOnBoard(Player)
	{
		for each, Tile in this.Tiles
			if (tile.Owner == Player)
				return True
		return False
	}
	
	__Delete()
	{
		for Color, pBrush in this.Brushes
			Gdip_DeleteBrush(pBrush)
		
		Gdip_DeleteGraphics(this.G)
		DeleteObject(this.hDIB)
		DeleteDC(this.hDC)
		ReleaseDC(this.hDC_Window)
	}
}

class Tile
{
	__New(x, y)
	{
		this.x := x
		this.y := y
		return this
	}
}