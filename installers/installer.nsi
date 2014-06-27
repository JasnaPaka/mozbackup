;--------------------------------
;Include Modern UI

!include "language.nsi"
!include "MUI2.nsh"
  
!define MULTIUSER_EXECUTIONLEVEL Admin
!define MULTIUSER_MUI
!include "MultiUser.nsh"  

;--------------------------------
;General

; The name of the installer
Name "MozBackup ${version}"

; The file to write
OutFile "MozBackup-${version}.exe"

; The default installation directory
InstallDir $PROGRAMFILES\MozBackup

; Request admin rights
RequestExecutionLevel admin

; Remove info about NullSoft Installer version
BrandingText " "

; Wizard graphics
!define MUI_ICON ".\..\..\..\graphics\icon-new.ico"
!define MUI_UNICON ".\..\..\..\graphics\icon-new.ico"

!define MUI_WELCOMEFINISHPAGE_BITMAP ".\..\..\..\graphics\side-installer.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP ".\..\..\..\graphics\side-installer.bmp"

; Runfile
!define MUI_FINISHPAGE_RUN "$INSTDIR\MozBackup.exe"

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING

;--------------------------------
;Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH 
  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
  
;--------------------------------
;Languages
 
  ;!insertmacro MUI_LANGUAGE "${language}"
  
!define MUI_LANGDLL_WINDOWTITLE "Language"
!define MUI_LANGDLL_INFO "Choose language"

!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Slovak"
!insertmacro MUI_RESERVEFILE_LANGDLL

!include langs.nsi

;--------------------------------
;Init

; inicializace výchozích hodnot
Function .onInit
	; Init pro MultiUser skript
	!insertmacro MULTIUSER_INIT  
	
	!insertmacro MUI_LANGDLL_DISPLAY
	;!insertmacro MUI_UNGETLANGUAGE
FunctionEnd

Function un.onInit
  ; Init pro MultiUser skript
  !insertmacro MULTIUSER_UNINIT
FunctionEnd


;--------------------------------
;Installer Sections

Section "Dummy Section" SecDummy
  ; Delete configuration from registry (MozBackup 1.4.7 or older)
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup_is1"

  ; Delete shortcuts
  call MultiUser.InstallMode.CurrentUser 
  Delete "$DESKTOP\MozBackup.lnk"
  Delete "$SMPROGRAMS\MozBackup\*.*"
  RmDir  "$SMPROGRAMS\MozBackup"
  
  call MultiUser.InstallMode.AllUsers
  Delete "$DESKTOP\MozBackup.lnk"
  Delete "$SMPROGRAMS\MozBackup\*.*"
  RmDir  "$SMPROGRAMS\MozBackup"

	; Install for all users
	call MultiUser.InstallMode.AllUsers

  SetOutPath "$INSTDIR"
  
  File MozBackup.exe
  File backup.ini  
  File profilefiles.txt
  File changelog.txt
  File license.txt
  File readme.txt
  File Default.mozprofile
  
  SetOutPath $INSTDIR\dll
  File .\dll\DelZip190.dll
  
  SetOutPath $INSTDIR\l10n
  File .\l10n\cs.zip
  File .\l10n\en.zip
  File .\l10n\de.zip
  File .\l10n\sk.zip
  File .\l10n\unzip.exe
  
	${Switch} $LANGUAGE
		${Case} ${LANG_ENGLISH}
			nsExec::ExecToLog "unzip.exe en.zip"
			${Break}
		${Case} ${LANG_CZECH}
			nsExec::ExecToLog "unzip.exe cs.zip"
			${Break}		
		${Case} ${LANG_SLOVAK}
			nsExec::ExecToLog "unzip.exe sk.zip"
			${Break}		
		${Case} ${LANG_GERMAN}
			nsExec::ExecToLog "unzip.exe de.zip"
			${Break}					
	${EndSwitch}
	nsExec::ExecToLog "mv Default.lng .."
	Delete "$INSTDIR\l10n\*.*"
  RmDir  "$INSTDIR\l10n"
    
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

	; Add info for Add/Remove applications dialog
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "DisplayName" "MozBackup ${version}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "Publisher" "Pavel Cvrcek"                                 
                                  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "URLInfoAbout" "http://mozbackup.jasnapaka.com/"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "URLUpdateInfo" "http://mozbackup.jasnapaka.com/"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "HelpLink" "http://mozbackup.jasnapaka.com/"
                 
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup" \
               "DisplayIcon" "$INSTDIR\MozBackup.exe,0"
SectionEnd

;--------------------------------

!macro CreateInternetShortcut FILENAME URL ICONFILE ICONINDEX
WriteINIStr "${FILENAME}.url" "InternetShortcut" "URL" "${URL}"
WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconFile" "${ICONFILE}"
WriteINIStr "${FILENAME}.url" "InternetShortcut" "IconIndex" "${ICONINDEX}"
!macroend

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\MozBackup"
  CreateShortCut "$SMPROGRAMS\MozBackup\$(INSTALLER_NSI_UNINSTALL).lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0

  !insertmacro CreateInternetShortcut \
  "$SMPROGRAMS\MozBackup\$(INSTALLER_NSI_HOMEPAGE)" \
  "http://mozbackup.jasnapaka.com" \
  "" "0"
    
  !ifdef TUTORIAL
    !insertmacro CreateInternetShortcut \
    "$SMPROGRAMS\MozBackup\${TUTORIAL}" \
    "${TUTORIAL_URL}" \
    "" "0"  
  !endif
  
  !insertmacro CreateInternetShortcut \
  "$SMPROGRAMS\MozBackup\$(INSTALLER_NSI_SUPPORT)" \
  "${SUPPORT_URL}" \
  "" "0"

  CreateShortCut "$SMPROGRAMS\MozBackup\MozBackup.lnk" "$INSTDIR\MozBackup.exe" "" "$INSTDIR\MozBackup.exe" 0
  CreateShortCut "$DESKTOP\MozBackup.lnk" "$INSTDIR\MozBackup.exe" ""
  
SectionEnd


;Uninstaller Section

Section "Uninstall"
	; Delete self
	Delete "$INSTDIR\uninstall.exe"	
  Delete "$INSTDIR\MozBackup.exe"
  Delete "$INSTDIR\backup.ini"
  Delete "$INSTDIR\Default.lng"
  Delete "$INSTDIR\changelog.txt"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\readme.txt"	
  Delete "$INSTDIR\profilefiles.txt"
  Delete "$INSTDIR\Default.mozprofile"

  Delete "$INSTDIR\dll\DelZip179.dll"
	Delete "$INSTDIR\dll\DelZip190.dll"		
  Delete "$INSTDIR\dll\ResDlls.res"	
  
  ; Delete shortcuts
  call un.MultiUser.InstallMode.CurrentUser 
  Delete "$DESKTOP\MozBackup.lnk"
  Delete "$SMPROGRAMS\MozBackup\*.*"
  RmDir  "$SMPROGRAMS\MozBackup"
  
  call un.MultiUser.InstallMode.AllUsers
  Delete "$DESKTOP\MozBackup.lnk"
  Delete "$SMPROGRAMS\MozBackup\*.*"
  RmDir  "$SMPROGRAMS\MozBackup"

  
  ; Remove remaining directories
  RMDir "$INSTDIR\dll\"
  Delete "$INSTDIR\l10n\*.*"
	RMDir "$INSTDIR\"
	
	; Remove from "Add/Remove application" dialog
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MozBackup"
SectionEnd
