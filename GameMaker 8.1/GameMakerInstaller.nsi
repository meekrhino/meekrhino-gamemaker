; YoYoPlayerInstaller.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------
!include MUI2.nsh 

!ifndef MAJOR_VERSION
!define MAJOR_VERSION			"8.1"
!endif
!ifndef MAJOR_VERSION_NO_DOT
!define MAJOR_VERSION_NO_DOT	"81"
!endif
!ifndef FULL_VERSION
!define FULL_VERSION			"8.1.10"
!endif
!ifndef UPDATER_SOURCE_DIR
!define UPDATER_SOURCE_DIR		"C:\source\GameMaker\Game Maker 8.0\Updater\Updater\Updater\bin\Debug"
!endif
!ifndef ZIP_DIR
!define ZIP_DIR					"C:\temp\gm81\output"
!endif
!ifndef ZIP_FILENAME
!define ZIP_FILENAME			"GameMaker-8.1.10.zip"
!endif
!ifndef INSTALLER_FILENAME
!define INSTALLER_FILENAME		"GameMaker-Installer-8.1.10.exe"
!endif

!ifdef SPICE
!define PRODUCT_NAME			`GameMaker-HTML5`
!else
 !ifdef STUDIO
  !define	PRODUCT_NAME			`GameMaker-Studio`
 !else
  !define PRODUCT_NAME			`GameMaker`
 !endif
!endif
!define APP_NAME				`${PRODUCT_NAME} ${MAJOR_VERSION}`
!define SHORT_NAME				`${PRODUCT_NAME}${MAJOR_VERSION_NO_DOT}`
!define ZIP_SOURCE				`${ZIP_DIR}\${ZIP_FILENAME}`

;;USAGE:
!define MIN_FRA_MAJOR "2"
!define MIN_FRA_MINOR "0"
!define MIN_FRA_BUILD "*"

!addplugindir		"."



;--------------------------------

; The name of the installer
Name "${APP_NAME}"
Caption "${APP_NAME}"
BrandingText "${APP_NAME}"

; The file to write
OutFile ${INSTALLER_FILENAME}

; The default installation directory
InstallDir `$PROFILE\${APP_NAME}`

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
!ifdef SPICE
InstallDirRegKey HKCU "Software\GM4HTML5" "Install_Dir"
!else
 !ifdef STUDIO
InstallDirRegKey HKCU "Software\GMStudio" "Install_Dir"
 !else
InstallDirRegKey HKCU "Software\GM81" "Install_Dir"
 !endif
!endif

; Request application privileges for Windows Vista
RequestExecutionLevel user

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!ifdef SPICE
!define MUI_ICON "spice_icon.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP	"GM5PICE_finish.bmp"
!define MUI_HEADERIMAGE_BITMAP	"GM5PICE_header.bmp"
!else
 !ifdef STUDIO
  !define MUI_ICON "studio_icon.ico"
  !define MUI_WELCOMEFINISHPAGE_BITMAP	"GMStudio_finish.bmp"
  !define MUI_HEADERIMAGE_BITMAP	"GMStudio_header.bmp"
 !else
  !define MUI_ICON "Maker.ico"
  !define MUI_WELCOMEFINISHPAGE_BITMAP	"GM_finish.bmp"
  !define MUI_HEADERIMAGE_BITMAP	"GM_header.bmp"
 !endif
!endif
!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH


;--------------------------------

; Pages
!ifdef SPICE
 !insertmacro MUI_PAGE_LICENSE "GameMakerFinal.txt"
!else
 !ifdef STUDIO
  !insertmacro MUI_PAGE_LICENSE "GameMakerAlphaBeta.txt"
 !else
  !insertmacro MUI_PAGE_LICENSE "GameMakerFinal.txt"
 !endif
!endif
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
    # These indented statements modify settings for MUI_PAGE_FINISH
    !define MUI_FINISHPAGE_NOAUTOCLOSE
    !define MUI_FINISHPAGE_RUN_TEXT "Start ${PRODUCT_NAME}"
    !define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_NAME}.exe"
!insertmacro MUI_PAGE_FINISH


UninstPage uninstConfirm
UninstPage instfiles

!insertmacro MUI_LANGUAGE "English"
;--------------------------------

; The stuff to install
Section `${APP_NAME}`
  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  Call AbortIfBadFramework
 
  ; Put file there
  File "GameMakerInstaller.nsi"
  File `${UPDATER_SOURCE_DIR}\${PRODUCT_NAME}.exe`
  File `${UPDATER_SOURCE_DIR}\${PRODUCT_NAME}.exe.config`
  File `${UPDATER_SOURCE_DIR}\BouncyCastle.Crypto.dll`
  File `${UPDATER_SOURCE_DIR}\Ionic.Zip.Reduced.dll`
  CreateDirectory $APPDATA\${PRODUCT_NAME}\UpgradeZip
  File /oname=$APPDATA\${PRODUCT_NAME}\UpgradeZip\upgrade.zip ${ZIP_SOURCE}
  
  ; Write the installation path into the registry
  
!ifdef SPICE
  WriteRegStr HKCU SOFTWARE\GM4HTML5 "Install_Dir" "$INSTDIR"
  WriteRegDWORD HKCU "SOFTWARE\GM4HTML5" "5pice" 1
  WriteRegStr HKCU "SOFTWARE\GM4HTML5\Version 1.0\Preferences" "5piceAssetCompilerLocation" "$APPDATA\${PRODUCT_NAME}\GMAssetCompiler.exe"
  WriteRegStr HKCU "SOFTWARE\GM4HTML5\Version 1.0\Preferences" "5piceCPPRunnerLocation" "$APPDATA\${PRODUCT_NAME}\Runner.exe"
  WriteRegStr HKCU "SOFTWARE\GM4HTML5\Version 1.0\Preferences" "5piceHTMLRunnerLocation" "$APPDATA\${PRODUCT_NAME}\scripts.html5.zip"
!else
 !ifdef STUDIO
  WriteRegStr HKCU SOFTWARE\GMStudio "Install_Dir" "$INSTDIR"
  WriteRegDWORD HKCU "SOFTWARE\GMStudio" "5pice" 1
  WriteRegStr HKCU "SOFTWARE\GMStudio\Version 1.0\Preferences" "5piceAssetCompilerLocation" "$APPDATA\${PRODUCT_NAME}\GMAssetCompiler.exe"
  WriteRegStr HKCU "SOFTWARE\GMStudio\Version 1.0\Preferences" "5piceCPPRunnerLocation" "$APPDATA\${PRODUCT_NAME}\Runner.exe"
  WriteRegStr HKCU "SOFTWARE\GMStudio\Version 1.0\Preferences" "5piceHTMLRunnerLocation" "$APPDATA\${PRODUCT_NAME}\scripts.html5.zip"
 !else
  WriteRegStr HKCU SOFTWARE\GM81 "Install_Dir" "$INSTDIR"
 !endif
!endif

  ; Write the uninstall keys for Windows
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "DisplayName" "${APP_NAME}"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoModify" 1
  WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe" "" "$INSTDIR\${PRODUCT_NAME}.exe" 0
!ifdef SPICE
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Help.lnk" "$APPDATA\${PRODUCT_NAME}\5pice.chm" "" "$APPDATA\${PRODUCT_NAME}\5pice.chm" 0
!else
 !ifdef STUDIO
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Help.lnk" "$APPDATA\${PRODUCT_NAME}\5pice.chm" "" "$APPDATA\${PRODUCT_NAME}\5pice.chm" 0
 !else
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} Help.lnk" "$APPDATA\${PRODUCT_NAME}\Game_Maker.chm" "" "$APPDATA\${PRODUCT_NAME}\Game_Maker.chm" 0
 !endif
!endif  
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME} License.lnk" "notepad.exe" "$APPDATA\${PRODUCT_NAME}\License.txt"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Tutorials.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\tutorials"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Backgrounds.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Backgrounds"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Examples.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Examples"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Extensions.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Extensions"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Lib.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Lib"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Sounds.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Sounds"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}\Sprites.lnk" "$windir\explorer.exe" "/e, $APPDATA\${PRODUCT_NAME}\Sprites"
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; RK :: TODO :: Tell any currently running version to shutdown (suggestion add command line option to YoYoClient.exe to kill any processes currently running).

  ; Remove registry keys
  DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}"

  ; Remove files and uninstaller
  Delete $INSTDIR\GameMakerInstaller.nsi
  Delete $INSTDIR\uninstall.exe
  Delete $INSTDIR\BouncyCastle.Crypto.dll
  Delete $INSTDIR\Ionic.Zip.Reduced.dll
  Delete $INSTDIR\${PRODUCT_NAME}.exe
  Delete $INSTDIR\${PRODUCT_NAME}.config
  RMDir /r "$APPDATA\${PRODUCT_NAME}"

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${APP_NAME}\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\${APP_NAME}"
  RMDir "$INSTDIR"

SectionEnd



;
;;NB Use an asterisk to match anything.
;
;; No pops. It just aborts inside the function, or returns if all is well.
;; Change this if you like.
Function AbortIfBadFramework
 
  ;Save the variables in case something else is using them
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $R1
  Push $R2
  Push $R3
  Push $R4
  Push $R5
  Push $R6
  Push $R7
  Push $R8
 
  StrCpy $R5 "0"
  StrCpy $R6 "0"
  StrCpy $R7 "0"
  StrCpy $R8 "0.0.0"
  StrCpy $0 0
 
  loop:
 
  ;Get each sub key under "SOFTWARE\Microsoft\NET Framework Setup\NDP"
  EnumRegKey $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP" $0
  StrCmp $1 "" done ;jump to end if no more registry keys
  IntOp $0 $0 + 1
  StrCpy $2 $1 1 ;Cut off the first character
  StrCpy $3 $1 "" 1 ;Remainder of string
 
  ;Loop if first character is not a 'v'
  StrCmpS $2 "v" start_parse loop
 
  ;Parse the string
  start_parse:
  StrCpy $R1 ""
  StrCpy $R2 ""
  StrCpy $R3 ""
  StrCpy $R4 $3
 
  StrCpy $4 1
 
  parse:
  StrCmp $3 "" parse_done ;If string is empty, we are finished
  StrCpy $2 $3 1 ;Cut off the first character
  StrCpy $3 $3 "" 1 ;Remainder of string
  StrCmp $2 "." is_dot not_dot ;Move to next part if it's a dot
 
  is_dot:
  IntOp $4 $4 + 1 ; Move to the next section
  goto parse ;Carry on parsing
 
  not_dot:
  IntCmp $4 1 major_ver
  IntCmp $4 2 minor_ver
  IntCmp $4 3 build_ver
  IntCmp $4 4 parse_done
 
  major_ver:
  StrCpy $R1 $R1$2
  goto parse ;Carry on parsing
 
  minor_ver:
  StrCpy $R2 $R2$2
  goto parse ;Carry on parsing
 
  build_ver:
  StrCpy $R3 $R3$2
  goto parse ;Carry on parsing
 
  parse_done:
 
  IntCmp $R1 $R5 this_major_same loop this_major_more
  this_major_more:
  StrCpy $R5 $R1
  StrCpy $R6 $R2
  StrCpy $R7 $R3
  StrCpy $R8 $R4
 
  goto loop
 
  this_major_same:
  IntCmp $R2 $R6 this_minor_same loop this_minor_more
  this_minor_more:
  StrCpy $R6 $R2
  StrCpy $R7 R3
  StrCpy $R8 $R4
  goto loop
 
  this_minor_same:
  IntCmp R3 $R7 loop loop this_build_more
  this_build_more:
  StrCpy $R7 $R3
  StrCpy $R8 $R4
  goto loop
 
  done:
 
  ;Have we got the framework we need?
  IntCmp $R5 ${MIN_FRA_MAJOR} max_major_same fail end
  max_major_same:
  IntCmp $R6 ${MIN_FRA_MINOR} max_minor_same fail end
  max_minor_same:
  IntCmp $R7 ${MIN_FRA_BUILD} end fail end
 
  fail:
  StrCmp $R8 "0.0.0" no_framework
  goto wrong_framework
 
  no_framework:
  MessageBox MB_OK|MB_ICONSTOP "Installation failed.$\n$\n\
         This software requires Windows Framework version \
         ${MIN_FRA_MAJOR}.${MIN_FRA_MINOR}.${MIN_FRA_BUILD} or higher.$\n$\n\
         No version of Windows Framework is installed.$\n$\n\
         Please update your computer at http://windowsupdate.microsoft.com/."
  abort
 
  wrong_framework:
  MessageBox MB_OK|MB_ICONSTOP "Installation failed!$\n$\n\
         This software requires Windows Framework version \
         ${MIN_FRA_MAJOR}.${MIN_FRA_MINOR}.${MIN_FRA_BUILD} or higher.$\n$\n\
         The highest version on this computer is $R8.$\n$\n\
         Please update your computer at http://windowsupdate.microsoft.com/."
  abort
 
  end:
 
  ;Pop the variables we pushed earlier
  Pop $R8
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
 
FunctionEnd
