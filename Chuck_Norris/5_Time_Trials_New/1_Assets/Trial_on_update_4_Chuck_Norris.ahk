#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#persistent
FileContents := {}
InputBox, User_entered_time, Enter test time, Enter the time to start time trials. Use the following format`: HHmm (e.g. 2300)
If (ErrorLevel = 1) or (ErrorLevel = 2)
{
	ExitApp
}
Loop
{
	FormatTime, TimeNow,,HHmm
	Menu, Tray, Tip, Test scheduled for %User_entered_time%.
	If (TimeNow = User_entered_time and WinExist("ahk_exe pmill.exe") = false)
	{	
		Menu, Tray, Tip, Scheduled tests in progress.
		Loop, Read, C:\Users\Barnesc\Desktop\Card_Colors\assets\builds_to_trial.txt
		{
			ChuckNorris := StrReplace(A_LoopReadLine, "D:\PowerMill_Builds\", "Z:\")
			FileContents.push(ChuckNorris)
			;FileContents.push(A_LoopReadLine)
		}
		FileCopy, C:\Users\Barnesc\Desktop\Card_Colors\assets\blankfile.txt, C:\Users\Barnesc\Desktop\Card_Colors\assets\builds_to_trial.txt, 1
		Loop % FileContents.length()
		{
			While WinExist("ahk_exe pmill.exe")
			{
				Sleep, 10000
			}
			Sleep, 5000
			RunWait, % comspec . A_Space . "/c" . A_Space . FileContents[A_Index] . "\sys\exec64\pmill.exe" . A_Space . "-macro" . A_Space . """D:\5_Time_Trials_New\PM_Time_Trial_Master.mac""", , hide
			Sleep, 5000
			FileAppend, % FileContents[A_Index] . "`n", % TimeNow . " ¬ D:\5_Time_Trials_New\1_Assets\1_Other\successfile.txt"
		}
		FileContents := ""
	}
	Sleep, 30000
}
