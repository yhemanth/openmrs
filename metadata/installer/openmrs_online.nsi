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

;Downloads and installs Java 6
Function InstallJava
	${If} $JavaExists == false
		Call StartJavaDownload
		Call ExecuteJavaSetup
	${EndIf}
FunctionEnd

Function StartJavaDownload
	StrCpy $JavaSetup "$TEMP\jdk-6u20-windows-i586.exe"
    Call DownloadJava
FunctionEnd

Function DownloadJava
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_JAVA)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${JAVA_6_DOWNLOAD_URL} $JavaSetup
FunctionEnd

;Downloads and installs Tomcat 6.0
Function InstallTomcat
	${If} $TomcatExists == false
		Call StartTomcatDownload
		Call ExecuteTomcatSetup
		Call ConfigureTomcat
	${EndIf}
FunctionEnd

Function StartTomcatDownload
	StrCpy $TomcatSetup "$TEMP\apache-tomcat-6.0.26.exe"
    Call DownloadTomcat
FunctionEnd

Function DownloadTomcat
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_TOMCAT)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${TOMCAT_DOWNLOAD_URL} $TomcatSetup
FunctionEnd

Function DownloadMysql
	nsisdl::download /TRANSLATE "$(DESC_DOWNLOADING_MYSQL)" "$(DESC_CONNECTING)" \
       "$(DESC_SECOND)" "$(DESC_MINUTE)" "$(DESC_HOUR)" "$(DESC_PLURAL)" \
       "$(DESC_PROGRESS)" "$(DESC_REMAINING)" \
	   /TIMEOUT=30000 ${MYSQL_DOWNLOAD_URL} $MysqlSetup
FunctionEnd
