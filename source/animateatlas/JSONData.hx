package animateatlas;

/**
 * All data needed for the json importer + some extra for after parsing.
 * Stolen mostly from https://github.com/TomByrne/Starling-Extension-Adobe-Animate-Hx/blob/master/hx/src/starling/extensions/animate/AnimationAtlasData.hx
 */
typedef AnimationData = {
	?ANIMATION:{
		?name:String,
		?StageInstance:Dynamic,
		?SYMBOL_name:String,
		?TIMELINE:SymbolTimelineData
	},
	?SYMBOL_DICTIONARY:{
		Symbols:Array<SymbolData>
	},
	?metadata:{
		?framerate:Null<Int>,
		?duration:Int,
        ?frameLabels:Array<{name:String, frame:Int}>
	}
}

typedef AtlasData = {
	?ATLAS:{
		SPRITES:Array<SpriteDummy>
	},
	?meta:{
		app:String,
		version:String,
		image:String,
		format:String,
		size:{w:Int, h:Int},
		?scale:String,
		?resolution:String
	}
}

typedef SpriteDummy = {
	SPRITE:SpriteData
}

typedef SpriteData = {
	name:String,
	x:Int,
	y:Int,
	w:Int,
	h:Int,
	rotated:Bool
}

typedef SymbolData = {
	?name:String,
	SYMBOL_name:String,
	?TIMELINE:SymbolTimelineData
}

typedef SymbolTimelineData = {
	?sortedForRender:Bool,
	LAYERS:Array<LayerData>
}

typedef LayerData = {
	Layer_name:String,
	Frames:Array<LayerFrameData>,
	FrameMap:Map<Int, LayerFrameData>
}

typedef LayerFrameData = {
	index:Int,
	?name:String,
	duration:Int,
	elements:Array<ElementData>
}

typedef ElementData = {
	?ATLAS_SPRITE_instance:Dynamic,
	?SYMBOL_Instance:SymbolInstanceData
}

typedef SymbolInstanceData = {
	SYMBOL_name:String,
	Instance_Name:String,
	bitmap:BitmapPosData,
	symbolType:String,
	transformationPoint:PointData,
	Matrix3D:Matrix3DData,
	?DecomposedMatrix:Decomposed3DData,
	?color:ColorData,

	?loop:String,
	firstFrame:Int,
	?filters:FilterData,

	?mesh:Dynamic,
    ?blendMode:String,
    ?layerEffects:Dynamic
}

typedef ColorData = {
	mode:String,

    ?tintColor:Int,
    ?tintAmount:Float,

	?redMultiplier:Float,
	?greenMultiplier:Float,
	?blueMultiplier:Float,
	?alphaMultiplier:Float,
	?redOffset:Float,
	?greenOffset:Float,
	?blueOffset:Float,
	?alphaOffset:Float
}

typedef BitmapPosData = {
	name:String,
	Position:PointData,
}

typedef PointData = {
	x:Int,
	y:Int
}

typedef Matrix3DData = {
	m00:Float,
	m01:Float,
	m02:Float,
	m03:Float,
	m10:Float,
	m11:Float,
	m12:Float,
	m13:Float,
	m20:Float,
	m21:Float,
	m22:Float,
	m23:Float,
	m30:Float,
	m31:Float,
	m32:Float,
	m33:Float,
}
//tryna add more support gimme a sec
typedef FilterData = {
    @:optional var type:String;
    @:optional var blurX:Float;
    @:optional var blurY:Float;
    @:optional var color:Int;
    @:optional var alpha:Float;
    @:optional var quality:Int;
    @:optional var strength:Float;
    @:optional var knockout:Bool;
    @:optional var inner:Bool;
    @:optional var matrix:Array<Float>;
    @:optional var angle:Float;
    @:optional var distance:Float;
}

typedef Decomposed3DData = {
    Position:{x:Float, y:Float, z:Float},
    Rotation:{x:Float, y:Float, z:Float, ?w:Float},
    Scaling:{x:Float, y:Float, z:Float},
    ?Skew:{x:Float, y:Float}
}
