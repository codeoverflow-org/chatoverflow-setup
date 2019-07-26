@echo off
set "MISSING_REQUIREMENT=false"

CALL :check_requirement git Git

IF "%MISSING_REQUIREMENT%"=="true" (
    ECHO ! Git not found. Git is required to clone individual subrepos.
    PAUSE
    exit /b
) ELSE (
    ECHO * All requirements are installed
)

SET "npm=true"
SET "yarn=true"
CALL :check_optional_requirement yarn
IF "%MISSING_REQUIREMENT%"=="true" (
    ECHO * Note: Yarn is not installed.
    SET "yarn=false"
)

set "MISSING_REQUIREMENT=false"
CALL :check_optional_requirement npm
IF "%MISSING_REQUIREMENT%"=="true" (
    ECHO * Note: npm is not installed.
    SET "npm=false"
) 

IF "%npm%"=="false" (
	IF "%yarn%"=="false" ( 
		ECHO ! NPM or yarn is needed to set up webui
		PAUSE
		exit /b
	)
)


CALL :check_folder chatoverflow https://github.com/codeoverflow-org/chatoverflow chatoverflow
CALL :check_folder chatoverflow/api https://github.com/codeoverflow-org/chatoverflow-api chatoverflow/api
CALL :check_folder chatoverflow/gui https://github.com/codeoverflow-org/chatoverflow-gui chatoverflow/gui
CALL :check_folder chatoverflow/plugins-public https://github.com/codeoverflow-org/chatoverflow-plugins chatoverflow/plugins-public

cd chatoverflow/

SET "MISSING_REQUIREMENT=false"
CALL :check_optional_requirement sbt
IF "%MISSING_REQUIREMENT%"=="true" (
    ECHO ! We would love to set the project up for you, but it seems like you don't have sbt installed.
    ECHO ! Please install sbt and execute $ sbt ';update;fetch;update'
    ECHO ! Or follow the guide at https://github.com/codeoverflow-org/chatoverflow/wiki/Installation
) ELSE (
    ECHO * Found sbt.
    sbt ";update;fetch;update"
)

cd gui/

ECHO * Installing GUI (this may take a while...)

IF "%yarn%"=="true" (
    yarn
) ELSE (
    npm install
)

ECHO * Success! You can now open the project in IntelliJ (or whatever IDE you prefer)


PAUSE
exit /b

:check_folder

IF EXIST %1/NUL (
    ECHO * Folder "%1" already exists
) ELSE ( 
    ECHO * Folder "%1" does NOT exist.
    git clone %2 %3
)

exit /b

:check_requirement
SET "MISSING_REQUIREMENT=true"
WHERE %1 > NUL 2>&1 && SET "MISSING_REQUIREMENT=false"

IF "%MISSING_REQUIREMENT%"=="true" (
    ECHO * Download and install %2
    SET "MISSING_REQUIREMENT=true"
) 

exit /b

:check_optional_requirement
SET "MISSING_REQUIREMENT=true"
WHERE %1 > NUL 2>&1 && SET "MISSING_REQUIREMENT=false"

IF "%MISSING_REQUIREMENT%"=="true" (
    SET "MISSING_REQUIREMENT=true"
) 

exit /b
