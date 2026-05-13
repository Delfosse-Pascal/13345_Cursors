@echo off
setlocal enabledelayedexpansion
title Organisation universelle des fichiers en tiroirs

:: ⚙️ PARAMÈTRES GÉNÉRAUX
set "NB_PAR_TIROIR=250"      :: nombre de fichiers par dossier
set "MAX_TIROIRS=5000"       :: nombre maximum de tiroirs
set /a compteurGlobal=0

echo.
echo ============================================
echo   🌠  Classement universel des fichiers
echo ============================================
echo.

:: Boucle sur tous les fichiers du dossier courant
for %%F in (*) do (
    :: Ignorer les répertoires
    if not "%%~aF"=="d" (
        set /a tiroirCourant=compteurGlobal / NB_PAR_TIROIR

        :: Arrêt si on dépasse la limite
        if !tiroirCourant! geq %MAX_TIROIRS% (
            echo ⚠️  Limite de %MAX_TIROIRS% tiroirs atteinte !
            goto :fin
        )

        :: Création du nom du tiroir (000, 001, 002, etc.)
        set "nomTiroir=0000!tiroirCourant!"
        set "nomTiroir=!nomTiroir:~-3!"

        :: Créer le tiroir s’il n’existe pas
        if not exist "!nomTiroir!" (
            echo 📁 Creation du tiroir !nomTiroir!
            md "!nomTiroir!" >nul 2>&1
        )

        :: Déplacement du fichier
        echo Déplacement de "%%F" vers "!nomTiroir!\" ...
        move "%%F" "!nomTiroir!\" >nul 2>&1

        :: Incrémentation du compteur global
        set /a compteurGlobal+=1
    )
)

:fin
echo.
echo ✅ Organisation terminee avec succes !
echo Total de fichiers classes : %compteurGlobal%
echo.
pause
endlocal
