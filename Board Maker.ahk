#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Text, xm, Number of Columns:
Gui, Add, Edit, yP x110 vCols
Gui, Add, Text, xm, Number of rows:
Gui, Add, Edit, yP x110 vRows
Gui, Add, Text, xm, Background color:
Gui, Add, Edit, yP x110 vBkg
Gui, Add, Text, xm, Board color:
Gui, Add, Edit, yP x110 vP0C
Gui, Add, Text, xm, Player 1 color:
Gui, Add, Edit, yP x110 vP1C
Gui, Add, Text, xm, Player 2 color:
Gui, Add, Edit, yP x110 vP2C
Gui, Add, Text, xm, Turn color:
Gui, Add, Edit, yP x110 vSBC
Gui, Add, Button, gSubmit, Submit
Gui, Show
Return

Submit:
Gui, Submit
Gui, Destroy
If Cols =
	Cols = 8
If Rows =
	Rows = 8
If Bkg =
	Bkg = 303030
If P0C =
	P0C = Green
If P1C =
	P1C = Black
If P2C =
	P2C = White
If SBC =
	SBC = Red

If Cols is not digit
	Cols = 8
If Rows is not digit
	Rows = 8
If Bkg is not alpha
	If Bkg is not digit
		Bkg = 303030
If P0C is not alpha
	If P0C is not digit
		P0C = Green
If P1C is not alpha
	If P1C is not digit
		P1C = Black
If P2C is not alpha
	If P2C is not digit
		P2C = White
If SBC is not alpha
	If SBC is not digit
		SBC = Red

S0 := Rows * Cols
Gui, Color, %Bkg%
Gui, Font, s50 c%P0C%, WebDings
Gui, Margin, 5, 5
Loop, %Cols% {
	Index := A_Index + 10
	Loop, %Rows% {
		AIndex := Index . A_Index + 10
			Gui, Add, Text, y%pos% v%AIndex% gClick, g
		pos := Mod(A_Index, rows) ? "+5":"m"
			Gui, Add, Text, xp yp vPiece%AIndex% BackgroundTrans, n
		Piece%AIndex% = 0
	}
}
Gui, Font, s16, Lucida Console
Width := (72 * Cols) - 5
If Width < 571
	Width = 571
X := (Width - 90) / 2
X2 := (Width - 450) / 2
S1 = 0
S2 = 0
Gui, Add, GroupBox, xm w%Width% h65 vScores
Gui, Font, s8, Lucida Console
Gui, Add, Button, yP+15 x%X% gSave, Save
Gui, Add, Button, yP xp+50 gGuiClose, Exit
Gui, Font, s16, Lucida Console
Gui, Add, Text, vSB1 yP+25 x%X2% c%SBC% gPOne, Player1:  %S1% 
Gui, Add, Text, vSB2 yP x+30 c%P1C% gPTwo, Player2:  %S2%
Gui, Add, Text, vSB3 yP x+30 c%P0C% gBlnk, Blank: %S0%
Gui, Font, s14 c%P2C%
	GuiControl, Font, SB2
Gui, Font, s14 c%P0C%
	GuiControl, Font, SB3
Gui, Font, s50, Webdings
Pl = 1
Gui, Show,, Othello
Return


GuiClose:
ExitApp
Return

Click:
Color := P%Pl%C
Gui, Font, c%Color%
	GuiControl, Font, Piece%A_GuiControl%
Piece := Piece%A_GuiControl%
S%Piece% -= 1
S%Pl% += 1
GuiControl, Text, SB1, Player1: %S1%
GuiControl, Text, SB2, Player2: %S2%
GuiControl, Text, SB3, Blank: %S0%
Piece%A_GuiControl% := Pl
Return

POne:
Pl = 1
Gui, Font, s16 c%SBC%, Lucida Console
	GuiControl, Font, SB1
Gui, Font, s14 c%P2C%, Lucida Console
	GuiControl, Font, SB2
Gui, Font, s14 c%P0C%, Lucida Console
	GuiControl, Font, SB3
Gui, Font, s50, WebDings
Return

PTwo:
Pl = 2
Gui, Font, s16 c%SBC%, Lucida Console
	GuiControl, Font, SB2
Gui, Font, s14 c%P1C%, Lucida Console
	GuiControl, Font, SB1
Gui, Font, s14 c%P0C%, Lucida Console
	GuiControl, Font, SB3
Gui, Font, s50, WebDings
Return

Blnk:
Pl = 0
Gui, Font, s14 c%P1C%, Lucida Console
	GuiControl, Font, SB1
Gui, Font, s14 c%P2C%, Lucida Console
	GuiControl, Font, SB2
Gui, Font, s16 c%SBC%, Lucida Console
	GuiControl, Font, SB3
Gui, Font, s50, WebDings
Return

Save:
InputBox, FN
IfNotExist, %A_ScriptDir%\Boards
	FileCreateDir, %A_ScriptDir%\Boards
File = %A_ScriptDir%\Boards\%FN%.brd
FileDelete, %File%
Loop, %Cols%
	{
	Index := A_Index + 10
		Loop, %Rows%{
		AIndex := Index . A_Index + 10
		Piece := Piece%AIndex%
		If Piece = 1
			P1List = %P1List%%AIndex%,
		If Piece = 2
			P2List = %P2List%%AIndex%,
	}
}
StringTrimRight, P1List, P1List, 1
StringTrimRight, P2List, P2List, 1
FileAppend, %Cols%`n%Rows%`n%Bkg%`n%P0C%`n%P1C%`n%P2C%`n%SBC%`n%P1List%`n%P2List%`n1, %File%
ExitApp
