' Monitor Dtc_Atualizador_Server - Execução Silenciosa
' Este arquivo executa o monitor de forma oculta
' No Gerenciador de Tarefas, aparecerá como "wscript.exe"
' Para identificar: veja a coluna "Linha de comando" que mostrará o caminho deste arquivo

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Obtém o diretório onde este script está localizado
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strBatPath = strScriptPath & "\github.bat"

' Executa o batch de forma oculta (0 = oculto, False = não aguarda término)
objShell.Run Chr(34) & strBatPath & Chr(34), 0, False

Set objShell = Nothing
Set objFSO = Nothing
