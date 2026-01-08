function onCreate()
	makeLuaSprite('tempback', 'stages/bg', -400, -650);
	addLuaSprite('tempback', false);
end

function onUpdate()
  setProperty('gf.visible', false);
end