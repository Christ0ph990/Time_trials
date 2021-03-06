﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
RegRead, OneDriveFolder, HKEY_CURRENT_USER\Environment, OneDrive
MsgBox, 0, Starting, Starting, 1
DirPath := {}
ParentDir := ""
Loop, Parse, A_ScriptDir, `\, %A_Space%%A_Tab%
{
	DirPath.push(A_LoopField)
	DirCount += 1
}

ParentDirNumber := DirPath.length() - 1

Loop % ParentDirNumber
{
	ParentDir .= DirPath[A_Index] . "\"
}

SetWorkingDir %ParentDir%
SavePath := OneDriveFolder . "\Combined_reports_master_main"
TestLoopObj := {}
TimeLoopObj := {}
txt_data_NameObj := {}
txt_data_TimeObj := {}
txt_data_names := ""
txt_data_Array := ""

Loop, Files, % ParentDir . "4_Results\txt_data\*"
{
	txt_data_names := txt_data_names . A_LoopFileTimeModified . "`t" . A_LoopFileName . "`n"
}

Sort, txt_data_names, R

Loop, Parse, txt_data_names, `n
{
	if (A_LoopField = "")
	{
		continue 																									; Omit the last linefeed (blank item) at the end of the list.
	}
	txt_data_Array := StrSplit(A_LoopField, A_Tab, " `t")
	txt_data_NameObj.Insert(txt_data_Array[2])
	txt_data_TimeObj.Insert(txt_data_Array[1])
}

txt_data_names := ""	
txt_data_Array := ""

Loop, Read, % ParentDir . "4_Results\txt_data\" . txt_data_NameObj[1]
{
	split_array := StrSplit(A_LoopReadLine,"¬"," `t")
	TestLoopObj.Push(split_array[1])
	TimeLoopObj.Push(split_array[2])
}

lRow := ""
testlRow := ""
XL := ComObjCreate("Excel.Application")
;XL.Visible := True
XL.DisplayAlerts:= False
XL.Workbooks.Open(filename:= OneDriveFolder . "\Combined_reports_master_main.xlsx")
XL.Sheets("Combined_reports_master_main").Select

Loop % (TestLoopObj.length() - 3)
{
	Body_Index := A_Index + 3
	XL.Cells(Body_Index,1).value := TestLoopObj[Body_Index]
}

lRow := XL.Cells(XL.Rows.Count, 2).End(-4162).Row
testlRow := XL.Cells(XL.Rows.Count, 1).End(-4162).Row
XL.Cells(lRow, 2).Cut(XL.Cells(testlRow, 2))
XL.Range("B:B").NumberFormat := "h:mm:ss"
XL.Range("B:B").Borders.LineStyle := -4142
XL.Range("B1").NumberFormat := "dd/mm/yyyy"
XL.Range("B2").NumberFormat := 0
XL.Range("B3").NumberFormat := "General"
XL.Range("B:B").Insert(-4161, 1)

Loop, 2
{
	TestLoopObj[A_Index] := RTrim(TestLoopObj[A_Index], ".0")
	TestLoopObj[A_Index] := StrReplace(TestLoopObj[A_Index], ".", "")
	XL.Cells(A_Index,2).value := TestLoopObj[A_Index]
}

Loop % (TimeLoopObj.length() - 3)
{
	Body_Index := A_Index + 3
	XL.Cells(Body_Index,2).value := TimeLoopObj[Body_Index]
	;XL.Cells(Body_Index,2).formula := "=TimeValue(""" . TimeLoopObj[Body_Index] . """)" 
	
}
XL.Range("B1:B" . TimeLoopObj.length()).BorderAround(1,2,-4105)
XL.Application.Workbooks(1).SaveAs(SavePath,6)
XL.Application.Workbooks(1).SaveAs(SavePath,51)
XL.Quit
txt_data_NameObj := ""
txt_data_TimeObj := ""
DirPath := ""
TimeLoopObj := ""
TestLoopObj := ""
ObjRelease(XL)

RunWait, % comspec . A_Space . "/c" . A_Space . A_ScriptDir . "\curl.exe -K" . A_Space . """" . A_ScriptDir . "\WikiRequest.txt""", , hide
MsgBox, 0, Done, Done, 1
return
ExitApp