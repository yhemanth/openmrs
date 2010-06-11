; This script will install openmrs.war into webapps in Tomcat directory.

!include LogicLib.nsh
!include nsDialogs.nsh
!include installer_setup.nsh

!define TOMCAT_VERSION 6.0
!define MYSQL_VERSION 5.1
!define PRODUCT_NAME "OpenMRS"
!define JAVA_VERSION

;Parameters used by the downloading window and progress bar. 
LangString DESC_REMAINING ${LANG_ENGLISH} " (%d %s%s remaining)"
LangString DESC_PROGRESS ${LANG_ENGLISH} "%d.%01dkB" ;"%dkB (%d%%) of %dkB @ %d.%01dkB"
LangString DESC_PLURAL ${LANG_ENGLISH} "s"
LangString DESC_HOUR ${LANG_ENGLISH} "hour"
LangString DESC_MINUTE ${LANG_ENGLISH} "minute"
LangString DESC_SECOND ${LANG_ENGLISH} "second"
LangString DESC_DOWNLOADING_JAVA ${LANG_ENGLISH} "Downloading Java"
LangString DESC_DOWNLOADING_TOMCAT ${LANG_ENGLISH} "Downloading Tomcat"
LangString DESC_DOWNLOADING_MYSQL ${LANG_ENGLISH} "Downloading MYSQL"
LangString DESC_DOWNLOADING_OPENMRS_WAR ${LANG_ENGLISH} "Downloading Openmrs.war"

Var JavaDownload
Var TomcatDownload
Var MysqlDownload

;Downloads and installs Java 6
Function InstallJava
	${If} $JavaExists == false
		Call StartJavaDownload
		Call ExecuteJavaSetup
	${EndIf}
FunctionEnd

;Checks if Java with version 6 or more is installed, if not calls InstallJava.
Function DetectJava
	ReadRegStr $JavaVersion HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
	${If} $JavaVersion >= 1.6
		StrCpy $JavaExists true
	${EndIf}
	
FunctionEnd

Function StartJavaDownload
	MessageBox MB_OK "${PRODUCT_NAME} uses Java ${JAVA_VERSION}, it will now \
                         be downloaded and installed"
	StrCpy $JavaSetup "$TEMP\jdk-6u20-windows-i586.exe"
    Call DownloadJava
FunctionEnd

Function DownloadJava
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_JAVA)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${JAVA_6_DOWNLOAD_URL} $JavaSetup
FunctionEnd

Function ExecuteJavaSetup
	Call JavaDownloadStatus
	${If} $JavaDownload == true
		ExecWait '"$JavaSetup" /s'
		Delete $JavaSetup
	${EndIf}
FunctionEnd

Function JavaDownloadStatus
	Pop $R0 ;Get the return value
	StrCmp $R0 "success" +4
		StrCpy $JavaDownload false
		MessageBox MB_OK "Download failed: $R0"
		Quit
	StrCpy $JavaDownload true
FunctionEnd

;Downloads and installs Tomcat 6.0
Function InstallTomcat
	${If} $TomcatExists == false
		Call StartTomcatDownload
		Call ExecuteTomcatSetup
		Call ConfigureTomcat
	${EndIf}
FunctionEnd

;Checks if Tomcat with version 6 or more is installed, if not calls InstallTomcat.
Function DetectTomcat
	ReadRegStr $TomcatVersion HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "Version"
	${If} $TomcatVersion >= 6
		StrCpy $TomcatExists true
	${EndIf}
FunctionEnd

Function StartTomcatDownload
	MessageBox MB_OK "${PRODUCT_NAME} uses Tomcat ${TOMCAT_VERSION}, it will now \
                         be downloaded and installed"
	StrCpy $TomcatSetup "$TEMP\apache-tomcat-6.0.26.exe"
    Call DownloadTomcat
FunctionEnd

Function DownloadTomcat
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_TOMCAT)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${TOMCAT_DOWNLOAD_URL} $TomcatSetup
FunctionEnd

Function ExecuteTomcatSetup
	Call TomcatDownloadStatus
	${If} $TomcatDownload == true
		ExecWait '"$TomcatSetup" /S ++Startup=manual'
		ExecWait 'net start "Apache Tomcat 6"'
		Delete $TomcatSetup
	${EndIf}
FunctionEnd

Function TomcatDownloadStatus
	Pop $R0 ;Get the return value
	StrCmp $R0 "success" +4
		StrCpy $TomcatDownload false
		MessageBox MB_OK "Download failed: $R0"
		Quit
	StrCpy $TomcatDownload true
FunctionEnd
	
Function ConfigureTomcat
	ReadRegStr $TomcatInstallPath HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "InstallPath"
	SetOutPath "$TomcatInstallPath\conf"      ; Set output path to the installation directory
	File "tomcat-users.xml"  ; Put file there
FunctionEnd
  
;Downloads and installs Mysql 5.1
Function InstallMySql
	${If} $MysqlExists == false
		Call StartMysqlDownload
		Call ExecuteMysqlSetup
	${EndIf}
	
FunctionEnd

;Checks if Mysql with version 5.1 or more is installed, if not calls InstallMysql.
Function DetectMysql
	ReadRegStr $MysqlVersion HKLM "SOFTWARE\MySQL AB\MySQL Server 5.1" "Version"
	${If} $MysqlVersion >= 5.1
		StrCpy $MysqlExists true
	${EndIf}
FunctionEnd

Function StartMysqlDownload
	MessageBox MB_OK "${PRODUCT_NAME} uses MySql ${MYSQL_VERSION}, it will now \
                         be downloaded and installed"
						 
    StrCpy $MysqlSetup "$TEMP\mysql-essential-5.1.46-win32.msi"
	Call DownloadMysql
FunctionEnd

Function DownloadMysql
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_MYSQL)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${MYSQL_DOWNLOAD_URL} $MysqlSetup
FunctionEnd

Function ExecuteMysqlSetup
	Call MysqlDownloadStatus
	${If} $MysqlDownload == true
		ReadRegStr $MysqlInstallPath HKLM "SOFTWARE\MySQL AB\MySQL Server 5.1" "Location"
		ExecWait '"msiexec" /i "$MysqlSetup" /quiet /norestart'
		ExecWait "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MysqlPassword');"
		ExecWait '$MysqlInstallPathbin\MySQLInstanceConfig.exe -i -q AddBinToPath=yes'
		Delete $MysqlSetup
	${EndIf}
FunctionEnd

Function MysqlDownloadStatus
	Pop $R0 ;Get the return value
	StrCmp $R0 "success" +4
		StrCpy $MysqlDownload false
		MessageBox MB_OK "Download failed: $R0"
		Quit
	StrCpy $MysqlDownload true
FunctionEnd
 
Function DeployOpenmrsWar
	ReadRegStr $OpenmrsWar HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "InstallPath"
	StrCpy $OpenmrsWar "$OpenmrsWar\webapps\openmrs.war" ; Point installation to the webapps subdirectory
	Call DownloadOpenmrsWar
FunctionEnd

Function DownloadOpenmrsWar
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_OPENMRS_WAR)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${OPENMRS_WAR_DOWNLOAD_URL} $OpenmrsWar
FunctionEnd

; Write the installation path and uninstall keys into the registry	
Function WriteRegistryKeys
	WriteRegStr HKLM Software\OpenMRS "InstallPath" $OpenmrsWar
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenMRS" \
			"DisplayName" "OpenMRS (remove only)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenMRS" \
			"UninstallString" '"$OpenmrsWar\OpenMRS_uninstall.exe"'
FunctionEnd

