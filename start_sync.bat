@echo off
title MyKottakkal Auto-Sync
echo Starting Auto-Sync Watcher...
start powershell -NoExit -ExecutionPolicy Bypass -File "%~dp0watch_and_push.ps1"
