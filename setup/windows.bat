@echo off
cls
title FNF' Vs Sonic.exe Necessary Libraries Installer
echo.
echo Installing necessary libraries. Please wait...
echo.
haxelib install tjson --quiet -y
haxelib install hxjsonast --quiet -y
haxelib set flixel 5.5.0 --never --quiet -y
haxelib git lime https://github.com/GreenColdTea/lime-9.0.0 -y
haxelib set openfl 9.4.1 -y
haxelib install hxcpp --quiet -y
haxelib install hxvlc --quiet --skip-dependencies -y
haxelib git sl-windows-api https://github.com/GreenColdTea/windows-api-improved.git -y
haxelib run lime setup flixel
haxelib set flixel-tools 1.5.1 -y
haxelib set flixel-ui 2.6.3 -y
haxelib set flixel-addons 3.3.2 -y
haxelib set hscript 2.4.0 -y
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc -y
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git -y
haxelib install format -y
haxelib install hxp -y
haxelib install hxcpp-debug-server
haxelib list
echo.
echo Done! Press any key to close the app!
pause
