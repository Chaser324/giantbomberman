package entities;

import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;

class TiledLevel extends TiledMap
{
	private static inline var TILESHEET_PATH = "assets/levels/";
	
	public var backgroundTiles:FlxGroup;
	public var foregroundTiles:FlxGroup;
	
	private var collidableTileLayers:Array<FlxTilemap>;
	
	private var playerCount:Int = 0;

	public function new(tiledLevel:Dynamic) 
	{
		super(tiledLevel);
		
		foregroundTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();
		
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);
		
		for (tileLayer in layers)
		{
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= TILESHEET_PATH + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			
			if (tileLayer.properties.contains("nocollide"))
			{
				backgroundTiles.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				
				foregroundTiles.add(tilemap);
				collidableTileLayers.push(tilemap);
			}
		}
	}
	
	public function loadObjects(state:PlayState)
	{
		for (group in objectGroups)
		{
			for (o in group.objects)
			{
				loadObject(o, group, state);
			}
		}
	}
	
	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		var retVal:Bool = false;
		
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers)
			{
				retVal = FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate) || retVal;
			}
		}
		
		return retVal;
	}
	
	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState)
	{
		var x:Int = o.x;
		var y:Int = o.y;
		
		if (o.gid != -1)
		{
			y -= g.map.getGidOwner(o.gid).tileHeight;
		}
		
		switch (o.type.toLowerCase())
		{
			case "player_start":
				if (state.players.length > playerCount)
				{
					state.players.members[playerCount];
					state.players.members[playerCount].x = x;
					state.players.members[playerCount].y = y;
					
					++playerCount;
				}
			case "soft_wall":
				var wall:SoftWall = state.addSoftWall();
				wall.x = x;
				wall.y = y;
				
				var tileSheetName:String = g.properties.get("tileset");
				var processedPath 	= TILESHEET_PATH + tileSheetName + ".png";
				
				wall.setImage(processedPath, 0);
		}
	}
	
	
	
}