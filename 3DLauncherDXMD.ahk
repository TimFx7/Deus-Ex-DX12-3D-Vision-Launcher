; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

DetectHiddenWindows, On
SetTitleMatchMode, 2   

EnvGet, prog32, ProgramFiles(x86)


if !FileExist("Start3D.exe") or !FileExist("QRes.exe") or !FileExist("wait.jps") or !FileExist("splash.jpg")
{
	MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, Some files may be missing. Be sure to copy the files named Start3D.exe , QRES.exe , WAIT.jps , SPLASH.jpg to the game folder. 
	exitApp 
}


Process,Exist, Start3D.exe
If !ErrorLevel
{
        try
	{
		Run, "Start3D.exe"
	}
	catch
	{
		MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, Start3D.exe could not be started, file may be corrupted.
		exitApp 
	}   

   regwrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Deus Ex: MD\Graphics, Fullscreen, 1
   regwrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Deus Ex: MD\Graphics, EnableDX12, 1
   regwrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Deus Ex: MD\Graphics, ExclusiveFullscreen, 0
   regwrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Eidos Montreal\Deus Ex: MD\Graphics, Stereoscopic3DMode, 0

   SplashImage, splash.jpg, b0
      
  ;it is necessary to start the game in 2D. Disable 3D
   Run, "%prog32%\NVIDIA Corporation\3D Vision\nvstlink.exe" /disable

   Sleep, 5000
   
   ;game is starting.
   Run, DXMD.exe 
   
   Winwait, , Unable to initialize SteamAPI, 2   
   if not ErrorLevel  
   {
	   Msgbox,262144 , Failed to initialize 3D Vision for DX12, Deus Ex not be started. Please make sure Steam is running and you are logged in to an account entitled to the game.
	   Runwait, taskkill /im DXMD.exe /f, ,Hide
	   Runwait, taskkill /im Start3D.exe /f, ,Hide
	   ExitApp  	
   }  
      
  
   WinWait, Deus Ex: Mankind Divided v1.19 build , , 30 

   SplashImage, Off
   
   if ErrorLevel
   {
	MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, There is a problem. Deus Ex or Steam started too late. Please try again now.
	Runwait, taskkill /im DXMD.exe /f, ,Hide
	Runwait, taskkill /im Start3D.exe /f, ,Hide		
	ExitApp  
   }

  
  Sleep, 5000  
  Runwait, QRes.exe /r:120, ,Hide
  Sleep, 2000   
  
  Runwait, "%prog32%\NVIDIA Corporation\3D Vision\nvstlink.exe" /enable    
  Sleep, 8000  

  Run, "%prog32%\NVIDIA Corporation\3D Vision\nvstview.exe" "wait.jps"
  Sleep, 500
  WinWait, NVIDIA 3D Vision , , 25 ;  If the 3D Vision Photo viewer is not opened in time, the 3D cannot be activated.


   if ErrorLevel
   {
	MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, 3D Vision Photo viewer failed to initialize as it should.
	Runwait, taskkill /im DXMD.exe /f, ,Hide
	Runwait, taskkill /im Start3D.exe /f, ,Hide			
	ExitApp  			
   }

  Sleep, 8000
  WinHide NVIDIA 3D Vision ;To Auto hide 3D Vision Photo viewer.

  WinWait, Deus Ex: Mankind Divided v1.19 build
   
  ; returns to desktop
  Send, {LWin Down}d{LWin Up}
  
  Sleep, 1000
  
  ; returns to game
  Send, {LWin Down}d{LWin Up}
   
  WinActivate    
  Winrestore
  
	IfWinNotExist, Deus Ex: Mankind Divided v1.19 build
	{
		MsgBox,262144 ,	Failed to initialize 3D Vision for DX12, Deus Ex could not be started properly. Note: RTSS Custom Direct3D Support must be turned off. Please try again.
		Runwait, taskkill /im DXMD.exe /f, ,Hide
		Runwait, taskkill /im Start3D.exe /f, ,Hide		
		Runwait, taskkill /im nvstview.exe /f, ,Hide   ;3D Vision Photo viewer turn off			
		ExitApp  			
	}
		
  WinWaitClose  ; Wait for the exact "Deus Ex" window found by WinWait to be closed.
  Runwait, taskkill /im nvstview.exe /f, ,Hide   ;3D Vision Photo viewer turn off

  ExitApp 
  
}
else  ;If start3D.exe is started, restarting 3DLauncher.exe is prevented.
{

	IfWinExist, Deus Ex: Mankind Divided v1.19 build
	WinActivate Deus Ex: Mankind Divided v1.19 build

}

ExitApp  
