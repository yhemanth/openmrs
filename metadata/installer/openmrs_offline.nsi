; This script will install openmrs.war into webapps in Tomcat directory.

!include LogicLib.nsh
!include nsDialogs.nsh
!include installer_setup.nsh

;Downloads and installs Java 6
Function InstallJava
	${If} $JavaExists == false
		Call ExtractJavaSetupToTemp
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

Function ExtractJavaSetupToTemp
	SetOutPath "$TEMP"      ; Set output path to the installation directory
	File "jdk-6u20-windows-i586.exe"  ; Put file there
	StrCpy $JavaSetup "jdk-6u20-windows-i586.exe"
FunctionEnd

Function ExecuteJavaSetup
	ExecWait '"$JavaSetup" /s'
	Delete $JavaSetup
FunctionEnd

;Downloads and installs Tomcat 6.0
Function InstallTomcat
	${If} $TomcatExists == false
		Call ExtractTomcatSetupToTemp
		Call ExecuteTomcatSetup
		Call ConfigureTomcat
	${EndIf}
FunctionEnd

Function ExtractTomcatSetupToTemp 
	SetOutPath "$TEMP"      ; Set output path to the installation directory
	File "apache-tomcat-6.0.26.exe"  ; Put file there
	StrCpy $TomcatSetup "$TEMP/apache-tomcat-6.0.26.exe"
FunctionEnd

;Checks if Tomcat with version 6 or more is installed, if not calls InstallTomcat.
Function DetectTomcat
	ReadRegStr $TomcatVersion HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "Version"
	${If} $TomcatVersion >= 6
		StrCpy $TomcatExists true
	${EndIf}	
FunctionEnd

Function ExecuteTomcatSetup
	ExecWait '"$TomcatSetup" /S ++Startup=manual'
	ExecWait 'net start "Apache Tomcat 6"'
	Delete $TomcatSetup
FunctionEnd
	
Function ConfigureTomcat
	ReadRegStr $TomcatInstallPath HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "InstallPath"
	SetOutPath "$TomcatInstallPath\conf"      ; Set output path to the installation directory
	File "tomcat-users.xml"  ; Put file there
FunctionEnd
  
;Downloads and installs Mysql 5.1
Function InstallMySql
	${If} $MysqlExists == false
		Call ExtractMysqlSetupToTemp
		Call ExecuteMysqlSetup
	${EndIf}
FunctionEnd

Function ExtractMysqlSetupToTemp 
	SetOutPath "$TEMP"      ; Set output path to the installation directory
	File "mysql-essential-5.1.46-win32.msi"  ; Put file there
	StrCpy $MysqlSetup "$TEMP\mysql-essential-5.1.46-win32.msi"
FunctionEnd

;Checks if Mysql with version 5.1 or more is installed, if not calls InstallMysql.
Function DetectMysql
	ReadRegStr $MysqlVersion HKLM "SOFTWARE\MySQL AB\MySQL Server 5.1" "Version"
	${If} $MysqlVersion >= 5.1
		StrCpy $MysqlExists true
	${EndIf}
FunctionEnd

Function ExecuteMysqlSetup

	ExecWait '"msiexec" /i "$MysqlSetup" /quiet /norestart'
	ReadRegStr $MysqlInstallPath HKLM "SOFTWARE\MySQL AB\MySQL Server 5.1" "Location"

	ExecWait "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MysqlPassword');"
	ExecWait '$MysqlInstallPathbin\MySQLInstanceConfig.exe -i -q AddBinToPath=yes'
	Delete $MysqlSetup
FunctionEnd

Function DeployOpenmrsWar
	ReadRegStr $OpenmrsWar HKLM "SOFTWARE\Apache Software Foundation\Tomcat\6.0" "InstallPath"
	StrCpy $OpenmrsWar "$OpenmrsWar\webapps" ; Point installation to the webapps subdirectory
	SetOutPath "$OpenmrsWar"      ; Set output path to the installation directory
	File "openmrs.war"  ; Put file there
FunctionEnd

; Write the installation path and uninstall keys into the registry	
Function WriteRegistryKeys
	WriteRegStr HKLM Software\OpenMRS "InstallPath" $OpenmrsWar
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenMRS" \
			"DisplayName" "OpenMRS (remove only)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenMRS" \
			"UninstallString" '"$OpenmrsWar\OpenMRS_uninstall.exe"'
FunctionEnd


