Option Explicit

CheckFileExists
CopyToPortal

Sub CheckFileExists()

  Dim FSO
  Set FSO = CreateObject("Scripting.FileSystemObject")
  If fso.FileExists("E:\ftp_download\usage_reporting\pivot\Weekly_Reports.xlsx") Then
'    msgbox "Fileisthere"
	RenameFile
	Mergev8
	ExcelMacroExample
  Else
'	msgbox "Fileisnotthere"
	Mergev8
	ExcelMacroExample
  End If

End Sub

Sub Mergev8()

	Dim objShell
	Set objShell = WScript.CreateObject ("WScript.shell")
	objShell.run "cmd /c copy E:\ftp_download\usage_reporting\all_dc_week8i.csv+E:\ftp_download\usage_reporting\all_dc_week8p.csv E:\ftp_download\usage_reporting\all_dc_week8.csv"
	Set objShell = Nothing
	
End Sub

Sub RenameFile()

  Dim objShell
  Set objShell = WScript.CreateObject ("WScript.shell")
  objShell.run "cmd /c move E:\ftp_download\usage_reporting\pivot\Weekly_Reports.xlsx E:\ftp_download\usage_reporting\pivot\Weekly_Reports_Old.xlsx"
  Set objShell = Nothing

End Sub

Sub ExcelMacroExample() 

  Dim xlApp 
  Dim xlBook 
  Set xlApp = CreateObject("Excel.Application") 
  Set xlBook = xlApp.Workbooks.Open("E:\ftp_download\usage_reporting\pivot\Report_Gen_Sort_Pivot.xlsm", 0, True) 
  xlApp.Visible = True
  xlApp.Run "Main"
  xlApp.ActiveWorkbook.Close
  xlApp.Quit 

  Set xlBook = Nothing 
  Set xlApp = Nothing 

End Sub 

Sub CopyToPortal()

	Dim objShell
	Dim wk, orig_file, dest_file
	wk = date
	orig_file = "E:\ftp_download\usage_reporting\pivot\Weekly_Reports.xlsx"
	dest_file = "\\frrmdef-fs017\portail_HELIOS\ControlM_Report\Weekly_Reports_W" & DatePart("ww", wk) & ".xlsx"
	
	Set objShell = WScript.CreateObject ("Scripting.FileSystemObject")
	objShell.CopyFile orig_file, dest_file
	Set objShell = Nothing
	
End Sub