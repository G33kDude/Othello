
; --- Config ---
BkgColor = 303030
P0Color = Green
P1Color = Black
P2Color = White
Rows    = 8
Cols    = 8
P1Start = 1415,1514
P2Start = 1414,1515
SBC = Red
; --------------



Score0 := Rows * Cols
Gui, Color, %BkgColor%
Gui, Font, s50, WebDings
Gui, Margin, 5, 5
Loop, %Cols% {
	Index := A_Index + 10
	Loop, %Rows% {
		AIndex := A_Index + 10
		AIndex = %Index%%AIndex%
		Bounds = %Bounds%%AIndex%,
		Gui, Font, c%P0Color%
			Gui, Add, Text, y%pos% v%AIndex% gClick, g
		pos := Mod(A_Index, rows) ? "+5":"m"
		CNum = 0
		If AIndex in %P1Start%
			{
			CNum = 1
			Score1 += 1
		}
		Else If AIndex in %P2Start%
			{
			CNum = 2
			Score2 += 1
		}
		If Cnum
			Score0 -= 1
		Color := P%CNum%Color
		Gui, Font, c%Color%
		Gui, Add, Text, xp yp vPiece%AIndex% BackgroundTrans, n
		Piece%AIndex% := CNum
	}
}
Gui, Font, s16, Lucida Console
Gui, Add, GroupBox, xm w570 h40 vScores
Gui, Add, Text, vSB1 yP+15 xP+10 c%SBC%, Player1: 00
Gui, Add, Text, vSB2 yP x+30 c%P2Color%, Player2: 00
Gui, Add, Text, vSB3 yP x+30 c%P0Color%, Blank: %Score0%
GuiControl, Text, SB1, Player1: %Score1%
GuiControl, Text, SB2, Player2: %Score2%
Gui, Font, s14 c%P2Color%
	GuiControl, Font, SB2
Gui, Font, s50, Webdings
Gui, Show,,Othello
Player = 1
Return

GuiClose:
ExitApp
Return

Click:
Color := P%Player%Color
If (Piece%A_GuiControl% = 0) {
	Loop 8 {
		If A_Index = 1
			Next := -101
		If A_Index = 2
			Next := -100
		If A_Index = 3
			Next := -99
		If A_Index = 4
			Next := -1
		If A_Index = 5
			Next := 1
		If A_Index = 6
			Next := 99
		If A_Index = 7
			Next := 100
		If A_Index = 8
			Next := 101
		
		PieceNum := A_GuiControl
		
		Loop {
			PieceNum := PieceNum + Next
			Piece := Piece%PieceNum%
			If PieceNum not in %Bounds%
				Break
			Else If Piece = 0
				Break
			Else If (Piece != Player)
				List = %List%%PieceNum%
			Else If (Piece = Player) {
				If List
					{
					GlobList = %GlobList%%List%
					Break
				} Else
					Break
			} Else
				Break
		}
		List =
	}
	
	If GlobList
		{
		Piece%A_GuiControl% := Player
		Gui, Font, c%Color%
			GuiControl, Font, Piece%A_GuiControl%
		StringLen, Len, GlobList
		Len /= 4
		Loop %Len% {
			Index := (A_Index * 4) - 3
			StringMid, PNum, GlobList, %Index%, 4
			Piece%PNum% := Player
			Gui, Font, c%Color%
				GuiControl, Font, Piece%PNum%
		}

		Score%Player% := Score%Player% + (1 + Len)
		
		Gui, Font, s14 c%Color%, Lucida Console
			GuiControl, Font, SB%Player%
		
		If Player = 1
			Player = 2
		Else
			Player = 1
		
		Gui, Font, s16 c%SBC%, Lucida Console
			GuiControl, Font, SB%Player%
		Score%Player% := Score%Player% - Len
		Score0 -= 1
		GuiControl, Text, SB1, Player1: %Score1%
		GuiControl, Text, SB2, Player2: %Score2%
		GuiControl, Text, SB3, Blank: %Score0%
		
		Gui, Font, s50, WebDings
		GlobList =
		If Score0 = 0
			{
			Win := (Score1 > Score2) ? "1" : "2"
			WinScore := Score%Win%
			MsgBox, Congratualtions! Player %Win% Wins with %WinScore% Pieces on the Board!
			Reload
		}
	}

}
Return

^e::
Win := (Score1 > Score2) ? "1" : "2"
WinScore := Score%Win%
MsgBox, Congratualtions! Player %Win% Wins with %WinScore% Pieces on the Board!
Reload

^p::
Valid = 0
Loop %Cols% {
	Index := A_Index + 10
	Loop %Rows% {
		AIndex := Index . A_Index + 10
		If (Piece%AIndex% = 0) {
			Loop 8 {
				If A_Index = 1
					Next := -101
				If A_Index = 2
					Next := -100
				If A_Index = 3
					Next := -99
				If A_Index = 4
					Next := -1
				If A_Index = 5
					Next := 1
				If A_Index = 6
					Next := 99
				If A_Index = 7
					Next := 100
				If A_Index = 8
					Next := 101
				
				PieceNum := AIndex
				
				Loop {
					PieceNum := PieceNum + Next
					Piece := Piece%PieceNum%
					If PieceNum not in %Bounds%
						Break
					Else If Piece = 0
						Break
					Else If (Piece != Player)
						List = 1
					Else If (Piece = Player AND List = 1) {
						Valid = 1
						Break
					} Else
						Break
				}
				List =
			}
		}
	}
}

If Valid = 1
	MsgBox, You still have moves left.
Else {
		Color := P%Player%Color
	Gui, Font, s14 c%Color%, Lucida Console
		GuiControl, Font, SB%Player%
	
	If Player = 1
		Player = 2
	Else
		Player = 1
			
	Gui, Font, s16 c%SBC%, Lucida Console
		GuiControl, Font, SB%Player%
	
	Gui, Font, s50, WebDings
}
Valid = 0
Return
