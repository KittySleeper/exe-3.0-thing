cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
haxelib install tjson --quiet
haxelib install hxjsonast --quiet
haxelib install flixel 5.5.0 --never --quiet
haxelib git lime https://github.com/GreenColdTea/lime-9.0.0
haxelib install openfl 9.4.1
haxelib install hxcpp --quiet
haxelib install hxvlc --quiet --skip-dependencies
haxelib git sl-windows-api https://github.com/GreenColdTea/windows-api-improved.git
haxelib run lime setup flixel
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.6.3
haxelib install flixel-addons 3.3.2
haxelib install hscript 2.4.0
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit.git
haxelib install hxcpp-debug-server
haxelib list
echo.
echo Done!
