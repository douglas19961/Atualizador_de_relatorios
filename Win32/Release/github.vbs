' Monitor Dtc_Atualizador_Server - Atualização via GitHub
' Executa o batch de forma oculta para aplicar atualização

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strBatPath = strScriptPath & "\github.bat"

objShell.Run Chr(34) & strBatPath & Chr(34), 0, False

Set objShell = Nothing
Set objFSO = Nothing
