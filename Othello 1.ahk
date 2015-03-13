BkgColor     = Black 
Player0Color = Green 
Player1Color = Black 
Player2Color = White 

Rows         = 8
Cols         = 8
Player1Start = 45,54
Player2Start = 44,55 

Score0 := Rows * Cols
GUI, Color, %BkgColor%
GUI, Font, s50, WebDings
GUI, Margin, 5, 5
Loop, %Cols% {
	Index := A_Index
	Loop, %Rows% {
		AIndex = %Index%%A_Index%
		GUI, Font, c%Player0Color%
			GUI, Add, Text, y%pos% v%AIndex% gClick, g
		pos := Mod(A_Index, rows) ? "+5":"m"
		CNum = 0
		If AIndex in %Player1Start%
			{
			CNum = 1
			Score1 += 1
		}
		Else If AIndex in %Player2Start%
			{
			CNum = 2
			Score2 += 1
		}
		If Cnum
			Score0 -= 1
		Color := Player%CNum%Color
		GUI, Font, c%Color%
		GUI, Add, Text, xp yp vPiece%AIndex% BackgroundTrans, n
		Piece%AIndex% := CNum
	}
}
GUI, Font, s12, Lucida Console
GUI, Add, Text, x5 cRed vScores, Player1: %Score1%`tPlayer2: %Score2%`tBlank: %Score0%`t
GUI, Font, s50, Webdings
GUI, Show,,Othello
Bounds = 0,1,2,3,4,5,6,7,8,9,10,19,20,29,30,39,40,49,50,59,60,69,70,79,80,89,90,91,92,93,94,95,96,97,98,99 
Player = 1
Color := Player%Player%Color
Loop {
	Tooltip, Player %Player%`, %Color%
}
Return

GuiClose:
ExitApp
Return

Click:
If (Piece%A_GuiControl% = 0) {
	Loop 8 {
		If A_Index = 1
			Next = -11
		If A_Index = 2
			Next = -10
		If A_Index = 3
			Next = -9
		If A_Index = 4
			Next = -1
		If A_Index = 5
			Next = 1
		If A_Index = 6
			Next = 9
		If A_Index = 7
			Next = 10
		If A_Index = 8
			Next = 11
		
		PieceNum := A_GuiControl
		
		Loop {
			PieceNum := PieceNum + Next
			Piece := Piece%PieceNum%
			If PieceNum in %Bounds%
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
		GUI, Font, c%Color%
			GuiControl, Font, Piece%A_GuiControl%
		StringLen, Len, GlobList
		Len /= 2
		Loop %Len% {
			Index := (A_Index * 2) - 1
			StringMid, PNum, GlobList, %Index%, 2
			Piece%PNum% := Player
			GUI, Font, c%Color%
				GuiControl, Font, Piece%PNum%
		}

		If Player = 1
			OPlayer = 2
		Else
			OPlayer = 1
		
		Score%Player% += 1 + Len
		Score%Oplayer% -= Len
		Score0 -= 1
		GuiControl, Text, Scores, Player1: %Score1%`tPlayer2: %Score2%`tBlank: %Score0%
		
		If Player = 1
			Player = 2
		Else
			Player = 1
		
		Color := Player%Player%Color
		GlobList =
	}

}
Return