function define(name, def)
    modMgr:define(name)
    modMgr:set(name,def)
end

modMgr:set("unboundedReverse",100) -- as long as its not 0, reverse can go >100 and itll work same as <0
modMgr:set("stealth", 25, 1)
modMgr:set("opponentSwap", 50)
modMgr:set("reverse", 100, 1)

modMgr:queueEase(160, 170, "opponentSwap", 0,'quadOut')
modMgr:queueEase(160, 170, "stealth",0,'quadOut', 1)

modMgr:queueEase(412, 418, "alpha", 100,'quadOut')
modMgr:queueSet(424, "reverse", 0, 1)
modMgr:queueSet(424, "centered", 100, 0)
modMgr:queueSet(424, "split", 100, 0)
modMgr:queueSet(424, "opponentSwap", 50)

modMgr:queueEase(432, 448, "alpha", 0, 'quadOut', 0)

modMgr:queueEase(560, 572, "centered", 0, 'quadOut', 0)

modMgr:queueEase(688, 706, "alpha", 0, 'quadOut', 1)
modMgr:queueEase(688, 706, "opponentSwap", 0, 'quadOut')
modMgr:queueEase(688, 706, "split", 0, 'quadOut', 0)

modMgr:queueEase(724, 724.5, "drunk", 450, 'quartIn', 1)
modMgr:queueEase(725, 730, "drunk", 0, 'quadOut')

modMgr:queueEase(852, 852.5, "drunk", -450, 'quartIn', 0)
modMgr:queueEase(853, 858, "drunk", 0, 'quadOut')

modMgr:queueEase(944, 976, "opponentSwap", 50, 'quadOut')
modMgr:queueEase(944, 976, "alpha", 100, 'quadOut', 1)

modMgr:queueSet(944, "drunk", 75, 0)
modMgr:queueEase(944.5, 976, "drunk", 0, 'quadOut')

modMgr:queueSet(976, "drunk", 75, 0)
modMgr:queueEase(976, 1006, "drunk", 0, 'quadOut')

modMgr:queueSet(1008, "drunk", 75, 0)
modMgr:queueEase(1008, 1012, "drunk", 0, 'quadOut')

modMgr:queueSet(1012, "drunk", 75, 0)
modMgr:queueEase(1012, 1020, "drunk", 0, 'quadOut')

modMgr:queueEase(1040, 1072, "alpha", 75, 'linear', 1)

modMgr:queueSet(1200, "squish", 100, 'quintOut')
modMgr:queueEase(1200, 1204, "squish", 0, 'quintOut')
modMgr:queueEase(1200, 1204, "alpha", 0, 'quartOut', 1)
modMgr:queueEase(1200, 1204, "opponentSwap", 100, 'quartOut')

modMgr:queueSet(1456, "squish", 100, 'quintOut')
modMgr:queueEase(1456, 1460, "squish", 0, 'quintOut')
modMgr:queueEase(1456, 1460, "alpha", 75, 'quartOut', 1)
modMgr:queueEase(1456, 1460, "opponentSwap", 50, 'quartOut')

modMgr:queueEase(1472, 1476, "rotateX", math.rad(180), 'quartOut')
modMgr:queueSet(1476, "reverse", 100)
modMgr:queueSet(1476, "rotateX", 0)

modMgr:queueEase(1488, 1492, "rotateX", math.rad(180), 'quartOut')
modMgr:queueSet(1492, "reverse", 0)
modMgr:queueSet(1492, "rotateX", 0)

modMgr:queueEase(1504, 1508, "rotateX", math.rad(180), 'quartOut')
modMgr:queueSet(1508, "reverse", 100)
modMgr:queueSet(1508, "rotateX", 0)

modMgr:queueEase(1520, 1524, "rotateX", math.rad(180), 'quartOut')
modMgr:queueSet(1524, "reverse", 0)
modMgr:queueSet(1524, "rotateX", 0)

modMgr:queueEase(1584, 1588, "centerrotateZ", math.rad(-90), 'elasticOut', 0)
modMgr:queueEase(1584, 1588, "centerrotateZ", math.rad(90), 'elasticOut', 1)
modMgr:queueEase(1584, 1588, "transformY", 25, 'elasticOut')

modMgr:queueEase(1584, 1588, "confusion", -90, 'elasticOut', 0)
modMgr:queueEase(1584, 1588, "confusion", 90, 'elasticOut', 1)

modMgr:queueEase(1600, 1604, "centerrotateZ", math.rad(180), 'elasticOut', 0)
modMgr:queueEase(1600, 1604, "centerrotateZ", math.rad(0), 'elasticOut', 1)
modMgr:queueEase(1600, 1604, "transformY", 0, 'elasticOut')
modMgr:queueEase(1600, 1604, "flip", 100, 'elasticOut', 0)
modMgr:queueEase(1600, 1604, "confusion", 0, 'elasticOut')
modMgr:queueSet(1604, "reverse", 100, 0)
modMgr:queueSet(1604, "flip", 0, 0)
modMgr:queueSet(1604, "centerrotateZ", 0, 0)

modMgr:queueSet(1644, "squish", 100, 'quintOut')
modMgr:queueEase(1644, 1648, "squish", 0, 'quintOut')
modMgr:queueEase(1644, 1648, "opponentSwap", 100, 'quartOut')
modMgr:queueEase(1644, 1648, "alpha", 0, 'quartOut', 1)
modMgr:queueEase(1644, 1650, "reverse", 0, 'quartOut', 0)
modMgr:queueEase(1644, 1650, "reverse", 100, 'quartOut', 1)

modMgr:queueSet(1760, "reverse", 100, 0)
modMgr:queueSet(1760, "reverse", 0, 1)
modMgr:queueSet(1760, "opponentSwap", 0)

modMgr:queueEase(1868, 1870, "reverse", 100, 'quartOut', 1)
modMgr:queueEase(1868, 1870, "reverse", 0, 'quartOut', 0)

modMgr:queueEase(2032, 2048, "drunk", 35, 'quartOut')
modMgr:queueEase(2032, 2048, "tipsy", 15, 'quartOut')
modMgr:queueEase(2032, 2048, "opponentSwap", 50, 'quartOut')
modMgr:queueEase(2032, 2048, "stealth", 25, 'quartOut', 1)
modMgr:queueEase(2032, 2048, "wave", 50, 'quartOut')

modMgr:queueSet(2096, "squish", 100, 'quintOut')
modMgr:queueEase(2096, 2100, "squish", 0, 'quintOut')
modMgr:queueEase(2096, 2100, "flip", 100, 'quartOut')

modMgr:queueEase(2160, 2172, "flip", 0, 'quartOut')

modMgr:queueEase(2160, 2177, "opponentSwap", 0, 'quadOut')
modMgr:queueEase(2160, 2177, "stealth", 0, 'quadOut', 1)

modMgr:queueEase(2176, 2180, 'brake', 0, 'quadOut')
modMgr:queueEase(2176, 2180, 'wave', 25, 'quadOut')
modMgr:queueEase(2176, 2180, 'boost', 100, 'quadOut')

modMgr:queueEase(2288, 2292, 'wave', 0, 'quadOut')
modMgr:queueEase(2288, 2292, 'boost', 0, 'quadOut')
modMgr:queueEase(2288, 2292, 'drunk', 0, 'quadOut')
modMgr:queueEase(2288, 2292, 'tipsy', 0, 'quadOut')

modMgr:queueEase(2312, 2315, 'flip', 100, 'linear')

modMgr:queueEase(2352, 2360, 'flip', 0, 'linear')
modMgr:queueEase(2360, 2362, 'centered', 100, 'quadOut')
modMgr:queueEase(2360, 2362, 'split', 100, 'quadOut')
modMgr:queueEase(2416, 2424, 'centered', 0, 'backOut')
modMgr:queueSet(2416, 'split', 0)
modMgr:queueSet(2416, 'reverse', 100, 0)
modMgr:queueSet(2416, 'reverse', 0, 1)
modMgr:queueSet(2432, "squish", 100, 'quintOut')
modMgr:queueEase(2432, 2436, "squish", 0, 'quintOut')
modMgr:queueEase(2432, 2436, 'opponentSwap', -100, 'quartOut', 0)
modMgr:queueEase(2432, 2436, 'opponentSwap', 50, 'quartOut', 1)
modMgr:queueSet(2436, "reverse", 0, 0)

modMgr:queueSet(2446, "squish", 150, 'quintOut')
modMgr:queueEase(2446, 2450, "squish", 0, 'quintOut')
modMgr:queueEase(2446, 2450, 'opponentSwap', 50, 'quartOut', 0)
modMgr:queueEase(2446, 2450, 'opponentSwap', -100, 'quartOut', 1)
modMgr:queueSet(2450, "reverse", 0, 1)


modMgr:queueSet(2464, "squish", 150, 1)
modMgr:queueSet(2464, "squish", 100, 0)
modMgr:queueEase(2464, 2468, "squish", 0, 'quintOut')
modMgr:queueEase(2464, 2468, 'opponentSwap', 0, 'quartOut', 0)
modMgr:queueEase(2464, 2468, 'opponentSwap', 0, 'quartOut', 1)

modMgr:queueEase(2550, 2554, 'reverse', -50, 'backIn', 0)
modMgr:queueSet(2554, 'reverse', 150, 0)
modMgr:queueEase(2554, 2558, 'reverse', 100, 'backOut', 0)

modMgr:queueEase(2576, 2580, 'reverse', 150, 'backIn', 0)
modMgr:queueSet(2580, 'reverse', -50, 0)
modMgr:queueEase(2580, 2584, 'reverse', 0, 'backOut', 0)

modMgr:queueEase(2672, 2686, 'opponentSwap', 50, 'backInOut', 0)
modMgr:queueEase(2672, 2676, 'reverse', -150, 'backIn', 1)
modMgr:queueEase(2672, 2676, 'alpha', 100, 'backIn', 1)

modMgr:queueEase(2688, 2672, 'drunk', 50, 'linear')
modMgr:queueEase(2688, 2672, 'tipsy', 50, 'linear')

modMgr:queueEase(2736, 2744, 'reverse1', 100, 'backInOut', 0)
modMgr:queueEase(2745, 2753, 'reverse3', 100, 'backInOut', 0)
modMgr:queueEase(2747, 2755, 'reverse2', 100, 'backInOut', 0)
modMgr:queueEase(2749, 2757, 'reverse0', 100, 'backInOut', 0)

if(getOption"downScroll")then
modMgr:queueEase(2819, 2827, 'transform1Y', -200, 'backIn', 0)
modMgr:queueEase(2828, 2836, 'transform0Y', -200, 'backIn', 0)
modMgr:queueEase(2829, 2837, 'transform2Y', -200, 'backIn', 0)
modMgr:queueEase(2832, 2840, 'transform3Y', -200, 'backIn', 0)
else
modMgr:queueEase(2819, 2827, 'transform1Y', 200, 'backIn', 0)
modMgr:queueEase(2828, 2836, 'transform0Y', 200, 'backIn', 0)
modMgr:queueEase(2829, 2837, 'transform2Y', 200, 'backIn', 0)
modMgr:queueEase(2832, 2840, 'transform3Y', 200, 'backIn', 0)
end
modMgr:queueEase(2832,2848,'alpha',100,'quadOut')

function startCountdown()
    return 'hidden' 
end