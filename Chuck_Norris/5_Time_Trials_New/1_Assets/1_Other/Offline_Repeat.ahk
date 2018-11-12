#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


;Loop 3,
;{
;	While WinExist("ahk_exe pmill.exe")
;	{
;		Sleep, 10000
;	}
;	Sleep, 5000
;	RunWait, % comspec . A_Space . "/c" . A_Space . "D:\1_QA_Work\8482\sid\dcam\sys\exec64\pmill.exe" . A_Space . "-macro" . A_Space . """D:\3_Time_Trials\Offline_tests_2DataSet.mac""", , hide
;	Sleep, 5000
;}
Loop 3,
{
	While WinExist("ahk_exe pmill.exe")
	{
		Sleep, 10000
	}
	Sleep, 5000
	RunWait, % comspec . A_Space . "/c" . A_Space . "D:\PowerMill_Builds\powermill12319\sys\exec64\pmill.exe" . A_Space . "-macro" . A_Space . """D:\3_Time_Trials\Offline_tests_1DataSet.mac""", , hide
	Sleep, 5000
}
;Loop 3,
;{
;	While WinExist("ahk_exe pmill.exe")
;	{
;		Sleep, 10000
;	}
;	Sleep, 5000
;	RunWait, % comspec . A_Space . "/c" . A_Space . "D:\PowerMill_Builds\powermill12319\sys\exec64\pmill.exe" . A_Space . "-macro" . A_Space . """D:\3_Time_Trials\Offline_tests_2DataSet.mac""", , hide
;	Sleep, 5000
;}
Loop 3,
{
	While WinExist("ahk_exe pmill.exe")
	{
		Sleep, 10000
	}
	Sleep, 5000
	RunWait, % comspec . A_Space . "/c" . A_Space . "D:\1_QA_Work\8482\sid\dcam\sys\exec64\pmill.exe" . A_Space . "-macro" . A_Space . """D:\3_Time_Trials\Offline_tests_1DataSet.mac""", , hide
	Sleep, 5000
}