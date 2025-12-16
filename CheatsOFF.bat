@echo off
title Anti-Cheat ORG - Scan Passivo FINAL
color 0C
setlocal EnableDelayedExpansion

:: =============================
:: CONFIG
:: =============================
set ROOT=%~dp0
set LOG=%ROOT%anti_cheat_log.txt
set HASHFILE=%ROOT%log_hash.txt
set IMG=%ROOT%screenshot.png
set HTML=%ROOT%relatorio.html
set ZIP=%ROOT%provas_scan.zip

:: ID UNICO
set SCANID=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set SCANID=%SCANID: =0%

set COUNT=0
set SCORE=0

cls
echo ==========================================
echo   ANTI-CHEAT ORG - SCAN PASSIVO (FINAL)
echo   ID DO SCAN: %SCANID%
echo ==========================================
echo.

:: =============================
:: LOG INICIAL
:: =============================
(
echo SCAN ID: %SCANID%
echo INICIO: %date% %time%
echo Usuario: %USERNAME%
echo Computador: %COMPUTERNAME%
echo ------------------------------------------
) > "%LOG%"

:: =============================
:: PROCESSOS SUSPEITOS
:: =============================
set CHEATS=cheatengine.exe ce.exe injector.exe xenos.exe extremeinjector.exe artmoney.exe processhacker.exe autohotkey.exe ahk.exe rewasd.exe joytokey.exe

echo [1] Verificando processos suspeitos...

tasklist > "%temp%\proc.txt"

for %%C in (%CHEATS%) do (
    findstr /I "%%C" "%temp%\proc.txt" >nul
    if not errorlevel 1 (
        color 07
        set /a COUNT+=1
        set /a SCORE+=2
        echo [PROCESSO] %%C
        echo PROCESSO DETECTADO: %%C >> "%LOG%"
    )
)

del "%temp%\proc.txt" >nul 2>&1

:: =============================
:: ARQUIVOS SUSPEITOS (CAMINHO)
:: =============================
echo.
echo [2] Verificando arquivos suspeitos...

set FILES=aim.dll wallhack.dll speedhack.dll *.asi *.ahk

for %%F in (%FILES%) do (
    for %%D in ("%USERPROFILE%" "C:\Program Files" "C:\Program Files (x86)" "C:\") do (
        for /f "delims=" %%P in ('where /r %%D %%F 2^>nul') do (
            color 07
            set /a COUNT+=1
            set /a SCORE+=1
            echo [ARQUIVO] %%P
            echo ARQUIVO SUSPEITO: %%P >> "%LOG%"
        )
    )
)

:: =============================
:: RESULTADO
:: =============================
(
echo ------------------------------------------
echo TOTAL DETECTADO: %COUNT%
echo SCORE: %SCORE%
) >> "%LOG%"

if %COUNT% GEQ 1 (
    color 07
    echo STATUS: SUSPEITO >> "%LOG%"
) else (
    color 0C
    echo STATUS: LIMPO >> "%LOG%"
)

echo FIM: %date% %time% >> "%LOG%"

:: =============================
:: HASH SHA256
:: =============================
certutil -hashfile "%LOG%" SHA256 > "%HASHFILE%"

:: =============================
:: SCREENSHOT (FIX)
:: =============================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $b=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; $bmp=New-Object System.Drawing.Bitmap($b.Width,$b.Height); $g=[System.Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($b.Location,[System.Drawing.Point]::Empty,$b.Size); $bmp.Save('%IMG%'); $g.Dispose(); $bmp.Dispose();"

:: =============================
:: RELATORIO HTML (STAFF)
:: =============================
(
echo ^<html^>^<head^>^<title^>Relatorio Anti-Cheat^</title^>^</head^>
echo ^<body style="font-family:Arial;background:#111;color:#fff;"^>
echo ^<h2^>Anti-Cheat ORG – Relatorio^</h2^>
echo ^<p^>Scan ID: %SCANID%^</p^>
echo ^<p^>Usuario: %USERNAME%^</p^>
echo ^<p^>PC: %COMPUTERNAME%^</p^>
echo ^<p^>Total Detectado: %COUNT%^</p^>
echo ^<pre^>
type "%LOG%"
echo ^</pre^>
echo ^</body^>^</html^>
) > "%HTML%"

:: =============================
:: ZIP AUTOMATICO
:: =============================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Compress-Archive -Path '%LOG%','%HASHFILE%','%IMG%','%HTML%' -DestinationPath '%ZIP%' -Force"

:: =============================
:: MENU FINAL
:: =============================
:MENU
echo.
echo ==========================================
echo ID DO SCAN: %SCANID%
echo TOTAL DETECTADO: %COUNT%
echo ==========================================
echo [1] Abrir LOG
echo [2] Abrir PRINT
echo [3] Abrir RELATORIO HTML
echo [4] Sair
echo ==========================================

choice /c 1234 /n /m "Escolha: "

if errorlevel 4 goto END
if errorlevel 3 start "" "%HTML%" & goto MENU
if errorlevel 2 start "" "%IMG%" & goto MENU
if errorlevel 1 start notepad "%LOG%" & goto MENU

:END
endlocal
exit
