#===============================================================================
# Max Lair - Map setup.
#===============================================================================
class LairMapScene
  #-----------------------------------------------------------------------------
  # Coordinates for all map tiles on a Max Lair Map.
  # Each map requires its own set of tile coordinates.
  #-----------------------------------------------------------------------------
  def pbSetMapTiles(map)
    #---------------------------------------------------------------------------
    # Variables for X axis coordinates.
    #---------------------------------------------------------------------------
    _A,_B,_C,_D,_E,_F,_G,_H,_I  = 0,32,64,96,128,160,192,224,256
    _J,_K,_L,_M,_N,_O,_P,_Q,_R  = 288,320,352,384,416,448,480,512,544
    _S,_T,_U,_V,_W,_X,_Y,_Z     = 576,608,640,672,704,736,768,800
    #---------------------------------------------------------------------------
    # Variables for Y axis coordinates.
    #---------------------------------------------------------------------------
    _01,_02,_03,_04,_05,_06,_07 = 352,320,288,256,224,192,160
    _08,_09,_10,_11,_12,_13,_14 = 128,96,64,32,0,-32,-64
    _15,_16,_17,_18,_19,_20,_21 = -96,-128,-160,-192,-224,-256,-288
    _22,_23,_24,_25,_26,_27,_28 = -320,-352,-384,-416,-448,-480,-512
    case map
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 00
    #---------------------------------------------------------------------------
    when 0
      @entryPoint     = [_I,_01]
      @mapStart       = [_I,_06]
      @mapPathsUL     = [[_G,_14],[_O,_14],[_O,_18]]
      @mapPathsUR     = [[_K,_10],[_C,_14],[_C,_18]]
      @mapPathsDL     = []
      @mapPathsDR     = []
      @mapPathsUD     = []
      @mapPathsLR     = [[_I,_06]]
      @mapPathsULR    = [[_G,_10],[_K,_14]]
      @mapPathsUDL    = [] 
      @mapPathsUDR    = []
      @mapPathsDLR    = []
      @mapPathsUDLR   = []
      @mapTurnUp      = [[_G,_06],[_K,_06],[_C,_10],[_I,_10],[_O,_10],[_K,_11],[_I,_14],[_G,_16],[_E,_18],[_M,_18],[_I,_18]]
      @mapTurnDown    = []
      @mapTurnLeft    = [[_I,_16],[_K,_18],[_O,_21],[_M,_21],[_N,_14]] 
      @mapTurnRight   = [[_I,_11],[_G,_18],[_C,_21],[_E,_21],[_D,_14]]
      @mapTurnRandom  = []
      @mapTurnFlip    = []
      @mapWarpPoint   = [[_H,_18],[_J,_13],[_L,_13],[_B,_18],[_J,_18],[_J,_15],[_H,_15],[_P,_18]]
      @mapEventSwap   = [[_O,_20]]
      @mapEventItems  = [[_D,_10]]
      @mapEventTrain  = [[_N,_10]]
      @mapEventTutor  = [[_C,_20]]
      @mapEventWard   = [[_I,_15]]
      @mapEventHeal   = [[_K,_13]]
      @mapEventRandom = []
      @mapEventBerry  = [[_E,_14],[_M,_14]]
      @mapEventChest  = []
      @mapEventKey    = []
      @mapLockedDoor  = []
      @mapRoadblock   = [[_J,_14]]
      @mapHiddenTrap  = [[_D,_21],[_N,_21]]
      @mapSwitches    = [[_C,_13],[_O,_13],[_G,_15],[_K,_15]]
      @mapSwitchTargs = [[_D,_14],[_N,_14],[_H,_18],[_J,_13],[_L,_13],[_B,_18],[_J,_18],[_J,_15],[_H,_15],[_P,_18]]
      @mapPkmnCoords  = [[_G,_07],[_K,_07],[_C,_11],[_G,_12],[_K,_12],[_O,_11],[_C,_16],[_G,_17],[_K,_17],[_O,_16],[_I,_21]]
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 01
    #---------------------------------------------------------------------------
    when 1
      @entryPoint     = [_N,_28]
      @mapStart       = [_N,_22]
      @mapPathsUL     = []
      @mapPathsUR     = []
      @mapPathsDL     = []
      @mapPathsDR     = []
      @mapPathsUD     = []
      @mapPathsLR     = []
      @mapPathsULR    = [[_N,_19]]
      @mapPathsUDL    = [[_W,_12]] 
      @mapPathsUDR    = []
      @mapPathsDLR    = [[_N,_22],[_N,_15]]
      @mapPathsUDLR   = [[_I,_22],[_S,_22],[_E,_12],[_G,_10]]
      @mapTurnUp      = [[_K,_24],[_Q,_24],[_E,_19],[_W,_19],[_S,_15],[_W,_06],[_I,_15],[_G,_08]]
      @mapTurnDown    = [[_I,_26],[_S,_26],[_N,_25],[_N,_16],[_C,_12],[_C,_10],[_N,_07]]
      @mapTurnLeft    = [[_P,_25],[_Q,_25],[_I,_19],[_P,_16],[_W,_05],[_Y,_10],[_W,_15],[_G,_12],[_I,_08],[_K,_10]] 
      @mapTurnRight   = [[_K,_25],[_L,_25],[_L,_16],[_S,_19],[_Q,_10],[_U,_12],[_E,_15],[_C,_08],[_E,_05]]
      @mapTurnRandom  = [[_W,_10]]
      @mapTurnFlip    = [[_I,_24],[_I,_20],[_S,_24],[_S,_20],[_E,_10]]
      @mapWarpPoint   = [[_E,_22],[_L,_24],[_W,_22],[_P,_24],[_E,_21],[_U,_08],[_W,_21],[_I,_07],[_I,_16],[_L,_15],[_H,_12],[_S,_16],[_P,_15],[_T,_12],[_J,_05],[_L,_07],[_R,_05],[_P,_07]]
      @mapEventSwap   = [[_N,_08],[_F,_05],[_V,_05]]
      @mapEventItems  = [[_U,_09]]
      @mapEventTrain  = [[_D,_08]]
      @mapEventTutor  = [[_H,_08]]
      @mapEventWard   = [[_V,_10]]
      @mapEventHeal   = [[_D,_10]]
      @mapEventRandom = [[_M,_07],[_O,_07]]
      @mapEventBerry  = [[_I,_25],[_S,_25]]
      @mapEventChest  = []
      @mapEventKey    = []
      @mapLockedDoor  = []
      @mapRoadblock   = [[_N,_13],[_N,_11],[_N,_09]]
      @mapHiddenTrap  = [[_I,_21],[_S,_21],[_D,_12],[_X,_10]]
      @mapSwitches    = [[_L,_22],[_P,_22],[_N,_20],[_E,_20],[_W,_20],[_M,_16],[_O,_16]]
      @mapSwitchTargs = [[_I,_24],[_I,_20],[_S,_24],[_S,_20],[_E,_10],[_W,_06],[_W,_10],[_E,_21],[_W,_21]]
      @mapPkmnCoords  = [ [_G,_22],[_U,_22],[_G,_19],[_U,_19],[_G,_15],[_U,_15],[_H,_05],[_T,_05],[_I,_10],[_S,_10],[_N,_04] ]
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 02
    #---------------------------------------------------------------------------
    when 2
      @entryPoint     = [_A,_09]
      @mapStart       = [_C,_14]
      @mapPathsUL     = []
      @mapPathsUR     = [[_E,_05]]
      @mapPathsDL     = []
      @mapPathsDR     = []
      @mapPathsUD     = []
      @mapPathsLR     = []
      @mapPathsULR    = [[_S,_03],[_W,_09]]
      @mapPathsUDL    = [[_G,_14],[_Y,_13],[_Y,_15],[_Y,_25]]
      @mapPathsUDR    = [[_C,_23],[_G,_07],[_U,_15]]
      @mapPathsDLR    = [[_I,_21],[_I,_27]]
      @mapPathsUDLR   = [[_C,_14],[_E,_14],[_L,_05],[_S,_07],[_T,_25],[_U,_13],[_W,_05]]
      @mapTurnUp      = [[_C,_09],[_C,_11],[_K,_11],[_M,_02],[_M,_13],[_O,_26],[_S,_04],[_T,_23],[_U,_09],[_W,_21]]
      @mapTurnDown    = [[_E,_23],[_E,_25],[_K,_03],[_L,_07],[_M,_27],[_O,_17],[_Q,_19],[_R,_27],[_S,_19],[_S,_21],[_W,_11],[_Y,_22],[_Y,_27]]
      @mapTurnLeft    = [[_N,_25],[_Q,_13],[_R,_25],[_W,_03],[_W,_07],[_W,_19],[_W,_25],[_Y,_09]] 
      @mapTurnRight   = [[_C,_27],[_D,_14],[_G,_03],[_G,_21],[_I,_09],[_I,_23],[_K,_02],[_K,_19],[_L,_02],[_M,_03],[_M,_17],[_M,_26],[_O,_27],[_S,_09],[_S,_13],[_T,_27],[_U,_21]]
      @mapTurnRandom  = [[_W,_15]]
      @mapTurnFlip    = [[_L,_03],[_Y,_05]]
      @mapWarpPoint   = [[_B,_14],[_S,_11],[_B,_11],[_W,_13],[_G,_23],[_V,_21]]
      @mapEventSwap   = [[_I,_14],[_M,_07]]
      @mapEventItems  = [[_I,_25]]
      @mapEventTrain  = [[_K,_07]]
      @mapEventTutor  = [[_R,_09]]
      @mapEventWard   = [[_Y,_06]]
      @mapEventHeal   = [[_V,_27]]
      @mapEventRandom = [[_I,_03],[_W,_18]]
      @mapEventBerry  = [[_E,_18],[_M,_15],[_X,_05]]
      @mapEventChest  = [[_G,_22],[_R,_26],[_T,_03],[_W,_10]]
      @mapEventKey    = [[_E,_21],[_Q,_03],[_O,_13],[_R,_23],[_S,_15],[_S,_05]]
      @mapLockedDoor  = [[_E,_17],[_J,_07],[_L,_11],[_N,_17],[_T,_26],[_Y,_08]]
      @mapRoadblock   = [[_D,_23],[_G,_04],[_G,_06],[_I,_24],[_I,_26]]
      @mapHiddenTrap  = [[_L,_02],[_L,_04],[_L,_06],[_S,_25],[_T,_09],[_V,_19],[_V,_25],[_W,_14],[_X,_13]]
      @mapSwitches    = [[_W,_27]]
      @mapSwitchTargs = [[_V,_21],[_W,_05],[_Y,_09]]
      @mapPkmnCoords  = [ [_N,_26],[_O,_05],[_I,_17],[_Y,_20],[_G,_10],[_O,_09],[_S,_17],[_N,_23],[_U,_03],[_N,_19],[_O,_15] ]
    ############################################################################
    # ADD CUSTOM MAPS BELOW
    #---------------------------------------------------------------------------
    # Tile Coordinates for Map 03
    #---------------------------------------------------------------------------
    when 3
      #-------------------------------------------------------------------------
      # Coordinates for Start & Entry tiles
      # Must only contain a single set of coordinates each.
      @entryPoint     = [] # The player's default position when the map is loaded.
      @mapStart       = [] # The Start Tile the player moves to.
      #-------------------------------------------------------------------------
      # Coordinates for Selection Tiles.
      @mapPathsUL     = [] # Up/Left directions.
      @mapPathsUR     = [] # Up/Right directions.
      @mapPathsDL     = [] # Down/Left directions.
      @mapPathsDR     = [] # Down/Right directions.
      @mapPathsUD     = [] # Up/Down directions.
      @mapPathsLR     = [] # Left/Right directions.
      @mapPathsULR    = [] # Up/Left/Right directions.
      @mapPathsUDL    = [] # Up/Down/Left directions. 
      @mapPathsUDR    = [] # Up/Down/Right directions.
      @mapPathsDLR    = [] # Down/Left/Right directions.
      @mapPathsUDLR   = [] # All four directions.
      #-------------------------------------------------------------------------
      # Coordinates for Directional Turn Tiles.
      @mapTurnUp      = []
      @mapTurnDown    = []
      @mapTurnLeft    = [] 
      @mapTurnRight   = []
      @mapTurnRandom  = []
      @mapTurnFlip    = []
      #-------------------------------------------------------------------------
      # Coordinates for Warp Tiles.
      # Warp Tiles are linked to each other in the order they're inputted here.
      # So the first Warp Tile will warp to the second Warp Tile, which will Warp to the third, etc.
      # The last Warp Tile entered here will loop back and warp to the first Warp Tile.
      @mapWarpPoint   = []
      #-------------------------------------------------------------------------
      # Coordinates for Event Tiles.
      @mapEventSwap   = [] # Scientist
      @mapEventItems  = [] # Backpacker
      @mapEventTrain  = [] # Blackbelt
      @mapEventTutor  = [] # Ace Trainer
      @mapEventWard   = [] # Channeler
      @mapEventHeal   = [] # Nurse
      @mapEventRandom = [] # Random NPC
      @mapEventBerry  = [] # Berries
      @mapEventChest  = [] # Treasure Chests
      @mapEventKey    = [] # Lair Keys
      #-------------------------------------------------------------------------
      # Coordinates for Locked Door Tiles.
      @mapLockedDoor  = []
      #-------------------------------------------------------------------------
      # Coordinates for Roadblock Tiles.
      @mapRoadblock   = []
      #-------------------------------------------------------------------------
      # Coordinates for Hidden Trap tiles. These tiles are never visible.
      @mapHiddenTrap  = []
      #-------------------------------------------------------------------------
      # Coordinates for Switch Tiles. These always begin in the OFF position.
      @mapSwitches    = []
      #-------------------------------------------------------------------------
      # Coordinates for Switch Target Tiles.
      # Tiles that you want to be revealed when a Switch Tile is triggered go here.
      # Just input the coordinates of a tile above to make it a Switch Target.
      # For example, if you have a Warp Tile at [_A,_01], put those coordinates here
      # and that Warp Tile will only appear when a Switch is flipped to the ON position.
      @mapSwitchTargs = []
      #-------------------------------------------------------------------------
      # Coordinates for Raid Tiles.
      # Always contains 11 sets of coordinates.
      # The first two coordinates are for the lowest ranked species in the lair.
      # The final coordinates are for the lair's Legendary Pokemon.
      @mapPkmnCoords  = [ [],[],[],[],[],[],[],[],[],[],[] ]
    end
  end

#===============================================================================
# Max Lair Map Utilities.
#===============================================================================

  #-----------------------------------------------------------------------------
  # General Utilities.
  #-----------------------------------------------------------------------------
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbBGMFade(1.0)
    pbSEPlay("Door exit")
    pbWait(25)
  end
  
  def pbHideUISprites
    @arrow0.visible                = false
    @arrow1.visible                = false
    @arrow2.visible                = false
    @arrow3.visible                = false
    @cursor.visible                = false
    @sprites["select"].visible     = false
    @sprites["options"].visible    = false
    @sprites["speedup"].visible    = false
    @sprites["return"].visible     = false
    @sprites["uparrow"].visible    = false
    @sprites["downarrow"].visible  = false
    @sprites["leftarrow"].visible  = false
    @sprites["rightarrow"].visible = false
  end
  
  #-----------------------------------------------------------------------------
  # Views the party Summary while on the Lair Map.
  #-----------------------------------------------------------------------------
  def pbSummary(pokemon,pkmnid,hidesprites)
    oldsprites = pbFadeOutAndHide(hidesprites) { pbUpdate }
    scene  = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,true)
    screen.pbStartScreen(pokemon,pkmnid)
    yield if block_given?
    pbFadeInAndShow(hidesprites,oldsprites) { pbUpdate }
  end
  
  #-----------------------------------------------------------------------------
  # Updates the player's total and remaining hearts.
  #-----------------------------------------------------------------------------
  def pbUpdateLairHP
    @knockouts = pbDynAdventureState.knockouts
    for i in 0...@maxHearts
     if @knockouts>i; @sprites["hpcount#{i}"].src_rect.set(0,0,34,30)   
     else; @sprites["hpcount#{i}"].src_rect.set(34,0,68,30)
     end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updates the number of Lair Keys in the player's posession.
  #-----------------------------------------------------------------------------
  def pbUpdateLairKeys
    @lairKeys  = pbDynAdventureState.keycount
    keyCounter = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num"))
    if @lairKeys > 0
      startX, startY = 52, 11
      @sprites["lairkey"].bitmap.clear
      @sprites["lairkey"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
      @sprites["lairkey"].src_rect.set(0,0,135,30)
      n = (@lairKeys==-1) ? 10 : @lairKeys.to_i.digits.reverse
      charWidth  = keyCounter.width/11
      charHeight = keyCounter.height/4
      n.each do |i|
        numberRect = Rect.new(i*charWidth, 0, charWidth, charHeight)
        @sprites["lairkey"].bitmap.blt(startX, startY, keyCounter.bitmap, numberRect)
        startX += charWidth
      end
      @sprites["lairkey"].visible  = true
    else
      @sprites["lairkey"].visible  = false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updates the floor number of the current lair in Endless Mode.
  #-----------------------------------------------------------------------------
  def pbUpdateLairFloor
    floor_num = pbDynAdventureState.lairfloor
    @sprites["floorwindow"] = Window_AdvancedTextPokemon.new(_INTL("B#{floor_num}F"))
    @sprites["floorwindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["floorwindow"].resizeToFit(@sprites["floorwindow"].text,Graphics.width)
    @sprites["floorwindow"].x = Graphics.width-(@sprites["floorwindow"].width+4)
    @sprites["floorwindow"].y = 4
    @sprites["floorwindow"].viewport = @viewport
  end
  
  #-----------------------------------------------------------------------------
  # Map Tile related utilities
  #-----------------------------------------------------------------------------
  def pbClearTile
    coords = [@player.x,@player.y]
    for sprite in @mapSprites
      next if sprite==@player
      next if sprite==@startTile
      next if sprite==@sprites["background"]
      tile = [sprite.x,sprite.y]
      sprite.visible = false if coords==tile
    end
  end
      
  def pbCursorReact
    select = nil
    coords = [@cursor.x+16,@cursor.y+16]
    @cursor.src_rect.set(0,0,64,64)
    for sprite in @mapSprites
      mapCoords = [sprite.x,sprite.y]
      next if !sprite.visible
      next if pbHiddenTrapTile?(mapCoords)
      withinXRange = (coords[0]<=mapCoords[0]+20 && coords[0]>=mapCoords[0]-20)
      withinYRange = (coords[1]<=mapCoords[1]+20 && coords[1]>=mapCoords[1]-20)
      select = mapCoords if withinXRange && withinYRange
    end
    return select
  end
  
  def pbChangePokeOpacity(fade=true)
    for i in 0...@mapPkmnCoords.length
      poke = @sprites["pokemon#{i}"]
      if fade; poke.opacity = 100
      else;    poke.opacity = 255
      end
    end
  end
  
  def pbBattleLairPokemon(index)
    if @sprites["pokemon#{index}"].visible
      poke    = GameData::Species.get(@lairSpecies[index])
      gender  = @spriteData[index][0]
      gmax    = @spriteData[index][1]
      nextlvl = (poke.id==@bossSpecies) ? 5 : 0
      level   = $Trainer.party[0].level + nextlvl
      $game_switches[Settings::MAXRAID_SWITCH] = true
      $game_variables[Settings::MAXRAID_PKMN]  = [poke.species, poke.form, gender, level, gmax]
      pbDynAdventureState.bossBattled = true if poke.id==@bossSpecies 
      pbFadeOutIn {
        pbMessage(_INTL("\\me[Max Raid Intro]You ventured deeper into the lair...\\wt[34] ...\\wt[34] ...\\wt[60]!\\wtnp[8]")) if !($DEBUG && Input.press?(Input::CTRL))
        @sprites["pokemon#{index}"].color.alpha = 0
        @sprites["pokemon#{index}"].visible  = false
        @sprites["poketype#{index}"].visible = false
        pbWildBattle(poke.id,level)
        pbUpdateLairHP
      }
      pbAutoMapPosition(@player,2) if !pbDynAdventureState.ended?
    end
  end
  
  def pbMapIntro
    pbWait(50)
    boss = @size-1
    pbAutoMapPosition(@sprites["mapPokemon#{boss}"],2)
    pbWait(15)
    poke = GameData::Species.get(@bossSpecies)
    Pokemon.play_cry(poke.species, poke.form, 100, 60)
    pbWait(15)
    pbMessage(_INTL("There's a strong {1}-type reaction coming from within the den!",@bosstype))
    pbAutoMapPosition(@player,4)
  end
  
#===============================================================================
# Initializes the Max Lair Map.
#===============================================================================
  def pbStartMapScene(map)
    @endlessMode = pbDynAdventureState.endlessMode?
    @bossSpecies = pbDynAdventureState.bossSpecies
    @lairSpecies = pbDynAdventureState.lairSpecies
    @size        = pbDynAdventureState.lairSpecies.length
    @lairKeys    = pbDynAdventureState.keycount
    @maxHearts   = @knockouts = pbDynAdventureState.knockouts
    @spriteData  = []
    @sprites     = {}
    @viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z  = 99999
    pbSetMapSprites(map)
    @arrow0 = @sprites["arrow0"] = IconSprite.new(0,0,@viewport)
    @arrow0.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow0.src_rect.set(0,0,16,16)
    @arrow1 = @sprites["arrow1"] = IconSprite.new(0,0,@viewport)
    @arrow1.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow1.src_rect.set(16,0,16,16)
    @arrow2 = @sprites["arrow2"] = IconSprite.new(0,0,@viewport)
    @arrow2.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow2.src_rect.set(32,0,16,16)
    @arrow3 = @sprites["arrow3"] = IconSprite.new(0,0,@viewport)
    @arrow3.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_arrows")
    @arrow3.src_rect.set(48,0,16,16)
    @cursor = @sprites["cursor"] = IconSprite.new(0,0,@viewport)
    @cursor.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_cursor")
    @cursor.src_rect.set(0,0,64,64)
    @sprites["return"] = IconSprite.new(Graphics.width-125,Graphics.height-77,@viewport)
    @sprites["return"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["return"].src_rect.set(135,0,125,77)
    @sprites["options"] = IconSprite.new(Graphics.width-122,Graphics.height-26,@viewport)
    @sprites["options"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["options"].src_rect.set(0,56,135,26)
    @sprites["speedup"] = IconSprite.new(0,Graphics.height-26,@viewport)
    @sprites["speedup"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["speedup"].src_rect.set(0,30,135,26)
    @sprites["speedup"].visible = false
    @sprites["select"] = IconSprite.new(126,Graphics.height-38,@viewport)
    @sprites["select"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["select"].src_rect.set(0,82,260,38)
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = Graphics.width/2-14
    @sprites["uparrow"].y = 0
    @sprites["uparrow"].play
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = Graphics.width/2-14
    @sprites["downarrow"].y = Graphics.height-44
    @sprites["downarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2-14
    @sprites["leftarrow"].play
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width-44
    @sprites["rightarrow"].y = Graphics.height/2-14
    @sprites["rightarrow"].play
    for i in 0...@maxHearts
      @sprites["hpcount#{i}"] = IconSprite.new(4+(i*34),4,@viewport)
      @sprites["hpcount#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_hearts")
      @sprites["hpcount#{i}"].src_rect.set(0,0,34,30)
    end
    @sprites["lairkey"] = IconSprite.new(-2,38,@viewport)
    @sprites["lairkey"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_ui")
    @sprites["lairkey"].src_rect.set(0,0,135,30)
    @sprites["lairkey"].visible  = false
    pbUpdateLairKeys
    pbUpdateLairFloor if @endlessMode
    pbHideUISprites
    pbHideSwitchTargs
    pbAutoMapPosition(@player,2,true)
    pbBGMPlay("Dynamax Adventure")
    pbMapIntro if !($DEBUG && Input.press?(Input::CTRL))
    if    @startTile.x>@player.x; direction = 3 
    elsif @startTile.x<@player.x; direction = 2
    elsif @startTile.y>@player.y; direction = 1
    else; direction = 0
    end
    pbMovePlayerIcon(direction)
    pbChooseRoute
  end

  #-----------------------------------------------------------------------------
  # Draws the Max Lair Map.
  #-----------------------------------------------------------------------------
  def pbSetMapSprites(map)
    pbSetMapTiles(map)
    offset = 4
    @mapSprites  = []
    @pokeSprites = []
    #---------------------------------------------------------------------------
    # Draws the map background.
    #---------------------------------------------------------------------------
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].bitmap = Bitmap.new(sprintf("Graphics/Pictures/Dynamax/LairMaps/map_%02d",map))
    bgheight = @sprites["background"].bitmap.height
    bgwidth  = @sprites["background"].bitmap.width
    @mapSprites.push(@sprites["background"])
    @upperBounds = -offset
    @lowerBounds = (Graphics.height-bgheight)+offset
    @leftBounds  = -offset
    @rightBounds = (Graphics.width-bgwidth)-offset
    #---------------------------------------------------------------------------
    # Draws the lair's start point tile on the map.
    #---------------------------------------------------------------------------
    @startTile = @sprites["startTile"] = IconSprite.new(@mapStart[0],@mapStart[1],@viewport)
    @startTile.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
    @startTile.src_rect.set(0,0,32,32)
    @mapSprites.push(@startTile)
    #---------------------------------------------------------------------------
    # Draws all Selection tiles on the map.
    #---------------------------------------------------------------------------
    selectionTiles = []
    for i in 0...@mapPathsUL.length
      mapPoints = @mapPathsUL[i]
      tile = @sprites["mapPathUL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUR.length
      mapPoints = @mapPathsUR[i]
      tile = @sprites["mapPathUR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDL.length
      mapPoints = @mapPathsDL[i]
      tile = @sprites["mapPathDL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDR.length
      mapPoints = @mapPathsDR[i]
      tile = @sprites["mapPathDR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUD.length
      mapPoints = @mapPathsUD[i]
      tile = @sprites["mapPathUD#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsLR.length
      mapPoints = @mapPathsLR[i]
      tile = @sprites["mapPathLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsULR.length
      mapPoints = @mapPathsULR[i]
      tile = @sprites["mapPathULR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDL.length
      mapPoints = @mapPathsUDL[i]
      tile = @sprites["mapPathUDL#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDR.length
      mapPoints = @mapPathsUDR[i]
      tile = @sprites["mapPathUDR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsDLR.length
      mapPoints = @mapPathsDLR[i]
      tile = @sprites["mapPathDLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for i in 0...@mapPathsUDLR.length
      mapPoints = @mapPathsUDLR[i]
      tile = @sprites["mapPathUDLR#{i}"] = IconSprite.new(mapPoints[0],mapPoints[1],@viewport)
      selectionTiles.push(tile)
    end
    for tile in selectionTiles
      tile.bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      tile.src_rect.set(32,0,32,32)
      @mapSprites.push(tile)
    end
    #---------------------------------------------------------------------------
    # Draws all Random Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnRandom.length
      xpos = @mapTurnRandom[i][0]
      ypos = @mapTurnRandom[i][1]
      @sprites["mapTurnRandom#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnRandom#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnRandom#{i}"].src_rect.set(0,32,32,32)
      @mapSprites.push(@sprites["mapTurnRandom#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Flip Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnFlip.length
      xpos = @mapTurnFlip[i][0]
      ypos = @mapTurnFlip[i][1]
      @sprites["mapTurnFlip#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnFlip#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnFlip#{i}"].src_rect.set(32,32,32,32)
      @mapSprites.push(@sprites["mapTurnFlip#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Up Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnUp.length
      xpos = @mapTurnUp[i][0]
      ypos = @mapTurnUp[i][1]
      @sprites["mapTurnUp#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnUp#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnUp#{i}"].src_rect.set(64,32,32,32)
      @mapSprites.push(@sprites["mapTurnUp#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Down Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnDown.length
      xpos = @mapTurnDown[i][0]
      ypos = @mapTurnDown[i][1]
      @sprites["mapTurnDown#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnDown#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnDown#{i}"].src_rect.set(96,32,32,32)
      @mapSprites.push(@sprites["mapTurnDown#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Left Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnLeft.length
      xpos = @mapTurnLeft[i][0]
      ypos = @mapTurnLeft[i][1]
      @sprites["mapTurnLeft#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnLeft#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnLeft#{i}"].src_rect.set(128,32,32,32)
      @mapSprites.push(@sprites["mapTurnLeft#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Right Turn tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapTurnRight.length
      xpos = @mapTurnRight[i][0]
      ypos = @mapTurnRight[i][1]
      @sprites["mapTurnRight#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapTurnRight#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapTurnRight#{i}"].src_rect.set(160,32,32,32)
      @mapSprites.push(@sprites["mapTurnRight#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Warp Point tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapWarpPoint.length
      xpos = @mapWarpPoint[i][0]
      ypos = @mapWarpPoint[i][1]
      @sprites["mapWarpPoint#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapWarpPoint#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapWarpPoint#{i}"].src_rect.set(192,32,32,32)
      @mapSprites.push(@sprites["mapWarpPoint#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Random Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventRandom.length
      xpos = @mapEventRandom[i][0]
      ypos = @mapEventRandom[i][1]
      @sprites["mapEventRandom#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventRandom#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventRandom#{i}"].src_rect.set(0,64,32,32)
      @mapSprites.push(@sprites["mapEventRandom#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Scientist Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventSwap.length
      xpos = @mapEventSwap[i][0]
      ypos = @mapEventSwap[i][1]
      @sprites["mapEventSwap#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventSwap#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventSwap#{i}"].src_rect.set(32,64,32,32)
      @mapSprites.push(@sprites["mapEventSwap#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Backpacker Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventItems.length
      xpos = @mapEventItems[i][0]
      ypos = @mapEventItems[i][1]
      @sprites["mapEventItems#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventItems#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventItems#{i}"].src_rect.set(64,64,32,32)
      @mapSprites.push(@sprites["mapEventItems#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Blackbelt Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventTrain.length
      xpos = @mapEventTrain[i][0]
      ypos = @mapEventTrain[i][1]
      @sprites["mapEventTrain#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventTrain#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventTrain#{i}"].src_rect.set(96,64,32,32)
      @mapSprites.push(@sprites["mapEventTrain#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Ace Trainer Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventTutor.length
      xpos = @mapEventTutor[i][0]
      ypos = @mapEventTutor[i][1]
      @sprites["mapEventTutor#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventTutor#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventTutor#{i}"].src_rect.set(128,64,32,32)
      @mapSprites.push(@sprites["mapEventTutor#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Channeler Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventWard.length
      xpos = @mapEventWard[i][0]
      ypos = @mapEventWard[i][1]
      @sprites["mapEventWard#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventWard#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventWard#{i}"].src_rect.set(160,64,32,32)
      @mapSprites.push(@sprites["mapEventWard#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Nurse Event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventHeal.length
      xpos = @mapEventHeal[i][0]
      ypos = @mapEventHeal[i][1]
      @sprites["mapEventHeal#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventHeal#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventHeal#{i}"].src_rect.set(192,64,32,32)
      @mapSprites.push(@sprites["mapEventHeal#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Berry tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventBerry.length
      xpos = @mapEventBerry[i][0]
      ypos = @mapEventBerry[i][1]
      @sprites["mapEventBerry#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventBerry#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventBerry#{i}"].src_rect.set(192,0,32,32)
      @mapSprites.push(@sprites["mapEventBerry#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Treasure Chest tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventChest.length
      xpos = @mapEventChest[i][0]
      ypos = @mapEventChest[i][1]
      @sprites["mapEventChest#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventChest#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventChest#{i}"].src_rect.set(0,96,32,32)
      @mapSprites.push(@sprites["mapEventChest#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Lair Key tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapEventKey.length
      xpos = @mapEventKey[i][0]
      ypos = @mapEventKey[i][1]
      @sprites["mapEventKey#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapEventKey#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapEventKey#{i}"].src_rect.set(32,96,32,32)
      @mapSprites.push(@sprites["mapEventKey#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Locked Door tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapLockedDoor.length
      xpos = @mapLockedDoor[i][0]
      ypos = @mapLockedDoor[i][1]
      @sprites["mapLockedDoor#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapLockedDoor#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapLockedDoor#{i}"].src_rect.set(64,96,32,32)
      @mapSprites.push(@sprites["mapLockedDoor#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Roadblock tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapRoadblock.length
      xpos = @mapRoadblock[i][0]
      ypos = @mapRoadblock[i][1]
      rand = rand(12)
      @sprites["mapRoadblock#{i}#{rand}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapRoadblock#{i}#{rand}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapRoadblock#{i}#{rand}"].src_rect.set(160,0,32,32)
      @mapSprites.push(@sprites["mapRoadblock#{i}#{rand}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Switch tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@mapSwitches.length
      xpos = @mapSwitches[i][0]
      ypos = @mapSwitches[i][1]
      @sprites["mapSwitches#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapSwitches#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapSwitches#{i}"].src_rect.set(96,0,32,32)
      @mapSprites.push(@sprites["mapSwitches#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Switch Target tiles on the map. (No visible sprite)
    #---------------------------------------------------------------------------
    for i in 0...@mapSwitchTargs.length
      xpos = @mapSwitchTargs[i][0]
      ypos = @mapSwitchTargs[i][1]
      @sprites["mapSwitchTargs#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapSwitchTargs#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapSwitchTargs#{i}"].src_rect.set(0,0,0,0)
      @sprites["mapSwitchTargs#{i}"].visible = false
      @mapSprites.push(@sprites["mapSwitchTargs#{i}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Hidden Trap tiles on the map. (No visible sprite)
    #---------------------------------------------------------------------------
    for i in 0...@mapHiddenTrap.length
      xpos = @mapHiddenTrap[i][0]
      ypos = @mapHiddenTrap[i][1]
      rand = rand(6)
      @sprites["mapHiddenTrap#{i}#{rand}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapHiddenTrap#{i}#{rand}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapHiddenTrap#{i}#{rand}"].src_rect.set(0,0,0,0)
      @sprites["mapHiddenTrap#{i}#{rand}"].visible = false if rand(10)<4
      @mapSprites.push(@sprites["mapHiddenTrap#{i}#{rand}"])
    end
    #---------------------------------------------------------------------------
    # Draws all Pokemon event tiles on the map.
    #---------------------------------------------------------------------------
    for i in 0...@size
      xpos = @mapPkmnCoords[i][0]
      ypos = @mapPkmnCoords[i][1]
      @sprites["mapPokemon#{i}"] = IconSprite.new(xpos,ypos,@viewport)
      @sprites["mapPokemon#{i}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_tiles")
      @sprites["mapPokemon#{i}"].src_rect.set(64,0,32,32)
      @sprites["mapPokemon#{i}"].visible = false
      @mapSprites.push(@sprites["mapPokemon#{i}"])
      poke      = GameData::Species.get(@lairSpecies[i])
      gmax      = (poke.hasGmax? && rand(10)>5)
      types     = [GameData::Type.get(poke.type1).id_number, 
                   GameData::Type.get(poke.type2).id_number]
      raidtype  = types[rand(types.length)]
      @bosstype = GameData::Type.get(raidtype).name if i==(@size-1)
      if pbGenderedSpeciesIcons?(poke.id)
        odds   = (poke.species==:PYROAR) ? 10 : 2
        gender = (rand(odds)<1) ? 0 : 1
      end
      @spriteData.push([gender,gmax])
      pokemon   = @sprites["pokemon#{i}"] = PokemonSprite.new(@viewport)
      pokemon.setSpeciesBitmap(poke.species, gender, poke.form, false, false, false, false, gmax)
      pokemon.setOffset(PictureOrigin::Center)
      pokemon.zoom_x = 0.5
      pokemon.zoom_y = 0.5
      pokemon.color.alpha = 255
      pokemon.x = @sprites["mapPokemon#{i}"].x+16
      pokemon.y = @sprites["mapPokemon#{i}"].y-16
      poketype  = @sprites["poketype#{i}"] = IconSprite.new(pokemon.x-32,pokemon.y+20,@viewport)
      poketype.bitmap = Bitmap.new("Graphics/Pictures/types")
      poketype.src_rect.set(0,raidtype*28,64,28)
      @pokeSprites.push(pokemon)
      @pokeSprites.push(poketype)
    end
    #---------------------------------------------------------------------------
    # Draws the player's icon.
    #---------------------------------------------------------------------------
    @player = @sprites["player"] = IconSprite.new(@entryPoint[0],@entryPoint[1],@viewport)
    @player.setBitmap(GameData::TrainerType.player_map_icon_filename($Trainer.trainer_type))
    @mapSprites.push(@player)
    #---------------------------------------------------------------------------
    # Centers all map sprites.
    #---------------------------------------------------------------------------
    @sprites["background"].y = Graphics.height-bgheight
    allSprites = @mapSprites+@pokeSprites
    for sprite in allSprites
      sprite.y+=offset*2
      sprite.x+=8+(offset*2)
    end
  end
end

#-------------------------------------------------------------------------------
# Used for accessing the Max Lair Map screen.
#-------------------------------------------------------------------------------
class LairMapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(map)
    @scene.pbStartMapScene(map)
    @scene.pbEndScene
  end
end

def pbMaxLairMap(map)
  scene  = LairMapScene.new
  screen = LairMapScreen.new(scene)
  screen.pbStartScreen(map)
end