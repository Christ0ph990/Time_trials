Script_Ini: ;{
SetStoreCapsLockMode, On
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode, Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include %A_ScriptDir%\1_Assets\TT_Functions.ahk
SetTitleMatchMode, 2
;}

Output_Ini: ;{ 

	;{ System Info											; Bunch of info to write to report to track system hardware.
	RegRead, CPUName, HKEY_LOCAL_MACHINE, HARDWARE\DESCRIPTION\System\CentralProcessor\0, ProcessorNameString
	RegRead, OSName, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
	VarSetCapacity( MEMORYSTATUSEX,64,2 ), NumPut( 64,MEMORYSTATUSEX ) 
	DllCall( "GlobalMemoryStatusEx", UInt,&MEMORYSTATUSEX )
	TotalPhys := NumGet( MEMORYSTATUSEX,8,"Int64"),   VarSetCapacity( PhysMem,16,0 )
	TotalPhys := Round(TotalPhys/1073741824, 2)
	FormatTime, SessionDate,,yyyy/MM/dd
	;}
	
	;{ Product Info											; Info found in properties of exe.
	WinGet, PMID, ProcessPath, ahk_exe pmill.exe			; Line currently hardcoded to find PowerMill Executables.
	WinGetClass, WinClass, ahk_exe pmill.exe
	ProductVersion := StrReplace(FileGetInfo(PMID).ProductVersion, ",", ".")
	ProductName := FileGetInfo(PMID).ProductName
	ProductName := Varize(ProductName)
	FileVersion := StrReplace(FileGetInfo(PMID).FileVersion, ",", ".")
	UID := StrReplace(Varize(WinClass),"0000000", "")
	;}
	
	;{ Folder names											; Variables names for the folder structure.
	O_FolderName := {}
	Loop, Files, %A_ScriptDir%\*, D 						; Creating variable names for the folder structure, to easily jump around.
	{					
		O_FolderName.Push(A_LoopFilePath)
	}
	
	Assets_Folder := O_FolderName[1]
	Data_Folder := O_FolderName[2]
	Macros_Folder := O_FolderName[3]
	Results_Folder := O_FolderName[4]
	Other_Folder := O_FolderName[5]
	
	offline_html_results_file := Results_Folder . "\offline_data\" .  ProductName . "_(" . FileVersion . ")-[" . UID "].html"
	offline_data_file := Results_Folder . "\offline_data\" .  ProductName . "_(" . FileVersion . ")-[" . UID "].txt"
	;}
	
	;{ Initialise Reports									; Headers for txt and html reports.
	cumulative_time := 0

	FileAppend % SessionDate . "`n", % offline_data_file
	FileAppend % FileVersion . "`n", % offline_data_file
	FileAppend % "------------------------------------------------`n", % offline_data_file
	
	FileAppend % "<html>", % offline_html_results_file
	FileAppend % "`n<head>", % offline_html_results_file
	FileAppend % "`n<title>Time trials Macro results</title>", % offline_html_results_file
	FileAppend % "`n<LINK REL=STYLESHEET TYPE=""text/css"" HREF=""" . Assets_Folder . "\1_Other\reportstyle.css"">", % offline_html_results_file
	FileAppend % "`n</head>", % offline_html_results_file
	FileAppend % "`n<body>", % offline_html_results_file
	FileAppend % "`n<h1>Time Trial Results</h1><br>", % offline_html_results_file
	FileAppend % "`n<b>CPU:</b> " . CPUName . "<br>" . "<b>Memory:</b> " . TotalPhys . " GB<br>" . "<b>Operating System:</b> " . OSName . "<br>", % offline_html_results_file
	FileAppend % "`n<b>Codebase: </b>" . FileVersion . "<br>", % offline_html_results_file
	FileAppend % "`n<p>", % offline_html_results_file
	FileAppend % "`n<table border=1 COLS=2>", % offline_html_results_file
	FileAppend % "`n<tr>", % offline_html_results_file
	FileAppend % "`n<th>Trial Name</th>", % offline_html_results_file
	FileAppend % "`n<th>Completion Time</th>", % offline_html_results_file
	FileAppend % "`n</tr>", % offline_html_results_file
	
	;}
	
;}

PowerMill_Ini: ;{ 											; Custom functions to write to PowerMill CMD window.
	Get_CMD_Window() 										; Use a function to get the name of the control of the command window in PWRM. As it changes between builds for some reason.
	Sleep, 7000
	CMD_POST("CD " . Results_Folder)
	CMD_POST("TRACEFILE OPEN ""PM_ERRORLOG.TXT""")
	CMD_POST("DEBUG MESSAGETIMEOUT 0")
	;CMD_POST("DIALOGS ERROR OFF")
	;CMD_POST("DIALOGS MESSAGE OFF")
;}

PowerMill_Macros:
	Offline_PM_Macro("Offline")


PowerMill_Fini: ;{											; Custom functions to write to PowerMill CMD window.
CMD_POST("TRACEFILE CLOSE")
	Finish_Reports()
CMD_POST("PROJECT RESET NO")
	Wait_Project_Reset()
;CMD_POST("EXIT")
;}