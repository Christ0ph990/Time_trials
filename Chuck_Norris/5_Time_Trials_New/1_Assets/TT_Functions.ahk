FileGetInfo( lptstrFilename) {
	List := "Comments InternalName ProductName CompanyName LegalCopyright ProductVersion"
		. " FileDescription LegalTrademarks PrivateBuild FileVersion OriginalFilename SpecialBuild"
	dwLen := DllCall("Version.dll\GetFileVersionInfoSize", "Str", lptstrFilename, "Ptr", 0)
	dwLen := VarSetCapacity( lpData, dwLen + A_PtrSize)
	DllCall("Version.dll\GetFileVersionInfo", "Str", lptstrFilename, "UInt", 0, "UInt", dwLen, "Ptr", &lpData) 
	DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\VarFileInfo\Translation", "PtrP", lplpBuffer, "PtrP", puLen )
	sLangCP := Format("{:04X}{:04X}", NumGet(lplpBuffer+0, "UShort"), NumGet(lplpBuffer+2, "UShort"))
	i := {}
	Loop, Parse, % List, %A_Space%
		DllCall("Version.dll\VerQueryValue", "Ptr", &lpData, "Str", "\StringFileInfo\" sLangCp "\" A_LoopField, "PtrP", lplpBuffer, "PtrP", puLen )
		? i[A_LoopField] := StrGet(lplpBuffer, puLen) : ""
	return i
}

Varize(_var, _bReplaceChars=false){
	local var

	Loop Parse, _var
	{
		If A_LoopField is alnum
		{
			Gosub Varize_AddChar
			Continue
		}
		If A_LoopField in #_@$?[]A_Space
		{
			Gosub Varize_AddChar
			Continue
		}
		If (Asc(A_LoopField) > 128)
		{
			Gosub Varize_AddChar
			Continue
		}
		If (_bReplaceChars)
			var := var "?" Asc(A_LoopField)
	}
	Return var

Varize_AddChar:
	var = %var%%A_LoopField%
Return
}

Get_CMD_Window(){
Global
WinGet, CList, ControlList, ahk_exe pmill.exe
Loop, Parse, Clist, "`n"
{
	IsCommandWindow := False
	If(InStr(A_LoopField,"Edit"))
	{
		ControlGetText, Ctext, %A_LoopField%, ahk_exe pmill.exe
		Loop, Parse, Ctext, "`n"
		{
			If(InStr(A_LoopField, "exec64") OR InStr(A_LoopField, "TonyTag") OR InStr(A_LoopField, "Syntax error"))
			{
				IsCommandWindow := True
			}
		}
	If(IsCommandWindow = True)
	{
		CMDWindow := A_LoopField
	}
	}
}
Return CMDWindow
}

CMD_POST(cmd_content){
	global
	Control, EditPaste, % cmd_content, % CMDWindow, ahk_exe pmill.exe,
	sleep, 20
	ControlSend, % CMDWindow, {Enter}, ahk_exe pmill.exe
	sleep, 20
	sleep, 100
	return
}

Wait_Test_Complete(){
Global
	Loop
	{
		Loop, Files, % Assets_Folder . "\*"
		{
			If(FileExist(Assets_Folder . "\lock_file"))
			{
				Continue
			}
			else
			{
				Sleep, 5000
				Break 2
			}
		}
	}
	Sleep, 5000
	Return
}

Wait_CMD_Complete_old(needle){
;Global
;VarSetCapacity,(haystack, 1048576)
;haystack := ""
;needle_found := ""
;needle_line := ""
;	Loop
;	{
;		ControlGetText, haystack, %CMDWindow%, ahk_exe pmill.exe
;		haystack := StrReplace(StrReplace(haystack, "`r`r", "`r"),"`r`n`r`n","`r`n") ; Remove blanks lines
;		Loop, parse, haystack, "`n"
;		{
;			If(InStr(A_LoopField, needle))
;			{
;				needle_found := "True"
;				needle_line := (A_Index + 1) ; We actually want the content of the next line.
;			}
;			If(A_Index = needle_line) AND (needle_found := "True")
;			{
;				If (InStr(A_LoopField, "powermill > ")) AND (InStr(A_LoopField, "`r") = False)
;				{
;					Break 2 ;Found the text, break the outer loop and return to the caller.
;				}
;			}
;			else
;			{
;				Continue ;Didn't find the text, start the loop again with the same variables.
;			}
;		}
;		
;		If(needle_found = "True")
;		{
;			needle_found := ""
;			haystack := ""
;			Break
;		}
;		else
;		{
;			Continue
;		}
;		
;	}
	Return
}

Wait_CMD_Complete(macro_code){
Global
needle := macro_code . " complete"
haystack := ""
	Loop
	{
		ControlGetText, haystack, RICHEDIT1, ahk_exe pmill.exe
		;haystack := StrReplace(StrReplace(haystack, "`r`r", "`r"),"`r`n`r`n","`r`n") ; Remove blanks lines
		
		Loop, parse, haystack, "`n"
		{
			If(InStr(A_LoopField, needle))
			{
				Sleep, 5000
				Break 2
			}
			else
			{
				Continue ;Didn't find the text, start the loop again with the same variables.
			}
		}
	}
	Sleep, 2000
	Return
}

Wait_Project_Reset(){
Global
	Loop
	{
		If(WinExist(" [  - None ]")) AND (WinExist("ahk_exe pmill.exe"))
		{
			Break
		}
		else
		{
			Continue
		}
	}
}


Get_Offline_Test_Times(macro_name){
global
	o_parser := {}
	o_test_names := {}
	o_test_times := {}
	marked := 0
	needle := macro_name . " time:"
	FileRead, haystack, % Assets_Folder . "\append_file.txt"
	haystack := StrReplace(StrReplace(haystack, "`r`r", "`r"),"`r`n`r`n","`r`n") ; Remove blanks lines
	Loop, Parse, haystack, `n, `r
			{
				o_parser.push(A_LoopField)
			}
	Loop % o_parser.length()
	{
		If (InStr(o_parser[A_Index], "~~~" )) AND (marked == 0)
		{
			marked := 1
			o_test_names.push(o_parser[A_Index + 1])
			continue
		}
		If (InStr(o_parser[A_Index], "~~~" )) AND (marked == 1)
		{
			marked := 0
			continue
		}
		If (InStr(o_parser[A_Index], needle ))
		{
			o_test_times.push(o_parser[A_Index + 1])
			continue
		}
	}
	Loop % o_test_names.length()
	{
		raw_time_string := o_test_times[A_Index]
		format_time_string := StrSplit(raw_time_string, A_Space)
		recorded_time := Round(format_time_string[1], 0)
		cumulative_time := Round(cumulative_time + recorded_time, 0)
		recorded_time := FormatSeconds(recorded_time)
		test_name := o_test_names[A_Index]
		;-------------------------------------------------------------------------------------------------
		FileAppend % "[" . macro_name . "] - <" . test_name . ">¬" . recorded_time . "`n", % offline_data_file
		;--------------------------------------------------------------------------------------------------
		
		FileAppend % "`n<tr>", % offline_html_results_file
		FileAppend % "`n<td>[" . macro_name . "] - <" . test_name, % offline_html_results_file
		FileAppend % "`n><td class=""center"">" . recorded_time . "</td>", % offline_html_results_file
		FileAppend % "`n</tr>", % offline_html_results_file
	}
	FileDelete, % Assets_Folder . "\append_file.txt"
	Return
}


Get_Test_Times(macro_name){
global
	o_parser := {}
	o_test_names := {}
	o_test_times := {}
	marked := 0
	needle := macro_name . " time:"
	FileRead, haystack, % Assets_Folder . "\append_file.txt"
	haystack := StrReplace(StrReplace(haystack, "`r`r", "`r"),"`r`n`r`n","`r`n") ; Remove blanks lines
	Loop, Parse, haystack, `n, `r
			{
				o_parser.push(A_LoopField)
			}
	Loop % o_parser.length()
	{
		If (InStr(o_parser[A_Index], "~~~" )) AND (marked == 0)
		{
			marked := 1
			o_test_names.push(o_parser[A_Index + 1])
			continue
		}
		If (InStr(o_parser[A_Index], "~~~" )) AND (marked == 1)
		{
			marked := 0
			continue
		}
		If (InStr(o_parser[A_Index], needle ))
		{
			o_test_times.push(o_parser[A_Index + 1])
			continue
		}
	}
	Loop % o_test_names.length()
	{
		raw_time_string := o_test_times[A_Index]
		format_time_string := StrSplit(raw_time_string, A_Space)
		recorded_time := Round(format_time_string[1], 0)
		cumulative_time := Round(cumulative_time + recorded_time, 0)
		recorded_time := FormatSeconds(recorded_time)
		test_name := o_test_names[A_Index]
		;-------------------------------------------------------------------------------------------------
		FileAppend % "[" . macro_name . "] - <" . test_name . ">¬" . recorded_time . "`n", % txt_results_file
		;--------------------------------------------------------------------------------------------------
		
		FileAppend % "`n<tr>", % html_results_file
		FileAppend % "`n<td>[" . macro_name . "] - <" . test_name, % html_results_file
		FileAppend % "`n><td class=""center"">" . recorded_time . "</td>", % html_results_file
		FileAppend % "`n</tr>", % html_results_file
		
		FileAppend, % recorded_time . "¬", % Assets_Folder . "\test_times.txt"
		FileAppend, % recorded_time . "`n", % Assets_Folder . "\test_times.txt"
	}
	FileDelete, % Assets_Folder . "\append_file.txt"
	Return
}

Finish_Reports(){
global
	cumulative_time := FormatSeconds(cumulative_time)
	;-------------------------------------------------------------------------------------------------
	FileAppend %  "[Total]¬" . cumulative_time . "`n", % txt_results_file
	;--------------------------------------------------------------------------------------------------
	
	FileAppend % "`n<tr>", % html_results_file
	FileAppend % "`n<td>[Total]", % html_results_file
	FileAppend % "`n<td class=""center"">" . cumulative_time . "</td>", % html_results_file
	FileAppend % "`n</table>", % html_results_file
	FileAppend % "`n<p>", % html_results_file
	FileAppend % "`n</body>", % html_results_file
	FileAppend % "`n</html>", % html_results_file
		
}

FormatSeconds(NumberOfSeconds){
    time = 19990101  ; *Midnight* of an arbitrary date.
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    return NumberOfSeconds//3600 ":" mmss
}

PM_Macro(macro_name){
Global
	CMD_POST("CD " . Macros_Folder)
	CMD_POST("DCAMTESTING TESTSTART ""barnesc"" " . """" . macro_name . ".mac""")
		Wait_CMD_Complete(macro_name)
		Wait_Test_Complete()
	CMD_POST("DCAMTESTING TESTEND")
		Wait_Test_Complete()
		Get_Test_Times(macro_name)
return
}

Offline_PM_Macro(macro_name){
Global
	CMD_POST("CD " . Macros_Folder)
	CMD_POST("DCAMTESTING TESTSTART ""barnesc"" " . """" . macro_name . ".mac""")
		Wait_CMD_Complete(macro_name)
		Wait_Test_Complete()
	CMD_POST("DCAMTESTING TESTEND")
		Wait_Test_Complete()
		Get_Offline_Test_Times(macro_name)
return
}