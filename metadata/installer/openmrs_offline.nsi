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

Function ExtractJavaSetupToTemp
	SetOutPath "$TEMP"      ; Set output path to the installation directory
	File "jdk-6u20-windows-i586.exe"  ; Put file there
	StrCpy $JavaSetup "jdk-6u20-windows-i586.exe"
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

Function ExtractMysqlSetupToTemp
    SetOutPath "$TEMP"      ; Set output path to the installation directory
    File "mysql-essential-5.1.46-win32.msi"  ; Put file there
FunctionEnd
