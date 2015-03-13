#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

x := (100 - 60) / 2
Gui, Add, Button, x%x% gSaves, Load save
Gui, Add, Button, yp+29 xp-2 gNew, New Game
Gui, Add, Button, gBrd, New Board
Gui, Add, Button, yp+29 xp+18 gGuiClose, Exit
Gui, +ToolWindow
Gui, Show, w100, menu
Return

Saves:
Gui, Destroy
Loop, %A_ScriptDir%\Saves\*.sav
	FL := FL . SubStr(A_LoopFileName, 1, -4) . ", "
StringTrimRight, FL, FL, 2
If FL =
	FL = None
InputBox, FP, Board, Please enter the name of a save. If you specify a non existent save`, The default board will be loaded. If you say "clear"`, it will clear all saves permanently.`nList:`n%FL%
If FP = clear
	FileDelete %A_ScriptDir%\Saves\*.sav
FP = %A_ScriptDir%\Saves\%FP%.sav
Goto, Load
Return

New:
Gui, Destroy
Loop, %A_ScriptDir%\Boards\*.brd
	FL := FL . SubStr(A_LoopFileName, 1, -4) . ", "
StringTrimRight, FL, FL, 2
InputBox, FP, Board, Please enter the name of a board. If you specify a non existent board`, the default board will be loaded. If you say "clear"`, it will clear all boards permanently.`nList:`n%FL%`n
If FP = clear
	FileDelete %A_ScriptDir%\Boards\*.brd
FP = %A_ScriptDir%\Boards\%FP%.brd
Goto, Load
Return

Load:
IfNotExist, %FP%
	FP = %A_ScriptDir%\Boards\Default.brd
IfNotExist, %FP%
	FileAppend, 8`n8`n303030`nGreen`nBlack`nWhite`nRed`n1415`,1514`n1414`,1515`n1, %FP%
FileReadLine, Col, %FP%, 1
FileReadLine, Row, %FP%, 2
FileReadLine, Bkg, %FP%, 3
FileReadLine, P0C, %FP%, 4
FileReadLine, P1C, %FP%, 5
FileReadLine, P2C, %FP%, 6
FileReadLine, SBC, %FP%, 7
FileReadLine, P1S, %FP%, 8
FileReadLine, P2S, %FP%, 9
FileReadLine, Pl, %FP%, 10
NL = -101-100-099-0010001009901000101

Gui, Color, %Bkg%
Gui, Font, s50, WebDings
Gui, Margin, 5, 5
Loop, %Col% {
	Ndx := A_Index + 10
	Loop, %Row% {
		ANdx := Ndx . A_Index + 10
		Bounds = %Bounds%%ANdx%,
		Gui, Font, c%P0C%
			Gui, Add, Text, y%pos% v%ANdx% gClick, g
		pos := Mod(A_Index, Row) ? "+5":"m"
		PN = 0
		If ANdx in %P1S%
			PN = 1
		If ANdx in %P2S%
			PN = 2
		S%PN% += 1
		Clr := P%PN%C
		Gui, Font, c%Clr%
		Gui, Add, Text, xp yp vP%ANdx% BackgroundTrans, n
		P%ANdx% := PN
	}
}
Gui, Font, s16, Lucida Console
Width := (72 * Col) - 5
If Width < 571
	Width = 571
X := (Width - 133) / 2
X2 := (Width - 450) / 2
Gui, Add, GroupBox, xm w%Width% h65 vScores
Gui, Font, s8, Lucida Console
Gui, Add, Button, yP+15 x%X% gPass, Pass
Gui, Add, Button, yP xp+50 gEnd, End
Gui, Add, Button, yP xP+43 gSave, Save
Gui, Font, s16, Lucida Console
Gui, Add, Text, vSB1 yP+25 x%X2% c%SBC%, Player1: 00
Gui, Add, Text, vSB2 yP x+30 c%SBC%, Player2: 00
Gui, Add, Text, vSB3 yP x+30 c%P0C%, Blank: %S0%
GuiControl, Text, SB1, Player1: %S1%
GuiControl, Text, SB2, Player2: %S2%
If Pl = 1
	{
	Gui, Font, s14 c%P2C%
		GuiControl, Font, SB2
} Else {
	Gui, Font, s14 c%P1C%
		GuiControl, Font, SB1
}
Gui, Font, s14 c%P0C%
	GuiControl, Font, SB3
Gui, Font, s50, Webdings
Gui, Show,,Othello
Return

Brd:
Run, Board Maker.ahk
ExitApp
Return

Click:
Clr := P%Pl%C
If (P%A_GuiControl% = 0) {
	Loop 8 {
		NLN := (A_Index * 4) - 3
		StringMid, Nxt, NL, %NLN%, 4
		PN := A_GuiControl
		
		Loop {
			PN += Nxt
			Piece := P%PN%
			If PN not in %Bounds%
				Break
			Else If Piece = 0
				Break
			Else If (Piece != Pl)
				List = %List%%PN%
			Else If (Piece = Pl) {
				If List
					{
					GL = %GL%%List%
					Break
				} Else
					Break
			} Else
				Break
		}
		List =
	}
	
	If GL
		{
		P%A_GuiControl% := Pl
		Gui, Font, c%Clr%
			GuiControl, Font, P%A_GuiControl%
		StringLen, Len, GL
		Len /= 4
		Loop %Len% {
			Ndx := (A_Index * 4) - 3
			StringMid, PN, GL, %Ndx%, 4
			P%PN% := Pl
			Gui, Font, c%Clr%
				GuiControl, Font, P%PN%
		}

		S%Pl% += Len + 1
		
		Gui, Font, s14 c%Clr%, Lucida Console
			GuiControl, Font, SB%Pl%
		
		Pl := (Pl = 1) ? "2" : "1"
		
		Gui, Font, s16 c%SBC%, Lucida Console
			GuiControl, Font, SB%Pl%
		S%Pl% -= Len
		S0 -= 1
		GuiControl, Text, SB1, Player1: %S1%
		GuiControl, Text, SB2, Player2: %S2%
		GuiControl, Text, SB3, Blank: %S0%
		
		Gui, Font, s50, WebDings
		GL =
		If S0 = 0
			{
			Win := (S1 > S2) ? "1" : "2"
			WS := S%Win%
			MsgBox, Congratualtions! Player %Win% Wins with %WS% Pieces on the Board!
			Reload
		}
	}
}
Return

End:
Win := (S1 > S2) ? "1" : "2"
WS := S%Win%
MsgBox, Congratualtions! Player %Win% Wins with %WS% Pieces on the Board!
Reload

pass:
MN =
Loop %Col% {
	Ndx := A_Index + 10
	Loop %Row% {
		ANdx := Ndx . A_Index + 10
		If (P%ANdx% = 0) {
			Loop 8 {
				NLN := (A_Index * 4) - 3
				StringMid, Nxt, NL, %NLN%, 4
				
				PN := ANdx
				
				Loop {
					PN := PN + Nxt
					Piece := P%PN%
					If PN not in %Bounds%
						Break
					Else If Piece = 0
						Break
					Else If (Piece != Pl)
						List = 1
					Else If (Piece = Pl AND List = 1) {
						MN += %List%
						Break
					} Else
						Break
				}
				List =
			}
		}
	}
}

If MN
	MsgBox, You still have %MN% moves left.
Else {
	Clr := P%Pl%C
	Gui, Font, s14 c%Clr%, Lucida Console
		GuiControl, Font, SB%Pl%
	Pl := (Pl = 1) ? "2" : "1"
	Gui, Font, s16 c%SBC%, Lucida Console
		GuiControl, Font, SB%Pl%
	Gui, Font, s50, WebDings
}
MN =
Return

Save:
IfNotExist, %A_ScriptDir%\Saves
	FileCreateDir, %A_ScriptDir%\Saves
InputBox, FP
FP = %A_ScriptDir%\Saves\%FP%.sav
FileDelete, %FP%
Loop, %Col%
	{
	Ndx := A_Index + 10
		Loop, %Row%{
		ANdx := Ndx . A_Index + 10
		Piece := P%ANdx%
		If Piece = 1
			P1L = %P1L%%ANdx%,
		If Piece = 2
			P2L = %P2L%%ANdx%,
	}
}
StringTrimRight, P1L, P1L, 1
StringTrimRight, P2L, P2L, 1
FileAppend, %Col%`n%Row%`n%Bkg%`n%P0C%`n%P1C%`n%P2C%`n%SBC%`n%P1L%`n%P2L%`n%Pl%, %FP%
ExitApp
Return

GuiClose:
ExitApp
Return
