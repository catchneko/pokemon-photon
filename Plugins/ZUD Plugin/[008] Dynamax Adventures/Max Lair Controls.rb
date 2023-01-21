#===============================================================================
# Max Lair - Map movement.
#===============================================================================
class LairMapScene
  def pbCanMoveUp?;      return true if pbRouteSelections.include?(0); end
  def pbCanMoveDown?;    return true if pbRouteSelections.include?(1); end
  def pbCanMoveLeft?;    return true if pbRouteSelections.include?(2); end
  def pbCanMoveRight?;   return true if pbRouteSelections.include?(3); end
  def pbSelectionTile?;  return true if pbRouteSelections; end
  def pbUpTurnTile?;     return true if pbTurnTiles==0;    end
  def pbDownTurnTile?;   return true if pbTurnTiles==1;    end
  def pbLeftTurnTile?;   return true if pbTurnTiles==2;    end
  def pbRightTurnTile?;  return true if pbTurnTiles==3;    end
  def pbRandTurnTile?;   return true if pbTurnTiles==4;    end
  def pbFlipTurnTile?;   return true if pbTurnTiles==5;    end
  def pbSwapEventTile?;  return true if pbEventTiles==0;   end
  def pbItemsEventTile?; return true if pbEventTiles==1;   end
  def pbTrainEventTile?; return true if pbEventTiles==2;   end
  def pbTutorEventTile?; return true if pbEventTiles==3;   end
  def pbWardEventTile?;  return true if pbEventTiles==4;   end
  def pbHealEventTile?;  return true if pbEventTiles==5;   end
  def pbRandEventTile?;  return true if pbEventTiles==6;   end
  def pbBerryEventTile?; return true if pbEventTiles==7;   end
  def pbKeyEventTile?;   return true if pbEventTiles==8;   end
  def pbChestEventTile?; return true if pbEventTiles==9;   end
  def pbPokemonTile?;    return true if pbPokemonTiles;    end
    
  #-----------------------------------------------------------------------------
  # Checks if the inputted coordinates match the map's Start Tile.
  #-----------------------------------------------------------------------------
  def pbStartTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    start  = [@startTile.x,@startTile.y]
    return true if coords==start
  end
  
  #-----------------------------------------------------------------------------
  # Returns the index of the Pokemon tile the player is on, if any.
  #-----------------------------------------------------------------------------  
  def pbPokemonTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapPkmnCoords.length
      tile    = @sprites["mapPokemon#{i}"]
      tilepos = [tile.x,tile.y]
      next if coords!=tilepos
      ret = i
    end
    return ret
  end
    
  #-----------------------------------------------------------------------------
  # Warp Tile functions.
  #-----------------------------------------------------------------------------
  # Checks if there's a Warp Tile at the inputted coordinates.
  def pbWarpTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapWarpPoint.length
      tile    = @sprites["mapWarpPoint#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = true
    end
    return ret
  end
  
  # Automatically teleports the player to the next available Warp Tile.
  def pbWarpPlayer
    coords = [@player.x,@player.y]
    if pbWarpTile?(coords)
      for i in 0...@mapWarpPoint.length
        warpTile   = @sprites["mapWarpPoint#{i}"]
        warpCoords = [warpTile.x,warpTile.y]
        if coords==warpCoords
          newpos    = i+1
          newpos    = 0 if newpos>@mapWarpPoint.length-1
          pbWait(20)
          pbSEPlay("Player jump")
          @player.visible = false
          @player.x = @sprites["mapWarpPoint#{newpos}"].x
          @player.y = @sprites["mapWarpPoint#{newpos}"].y
          pbAutoMapPosition(@player,8)
          pbSEPlay("Player jump")
          @player.visible = true
          pbWait(20)
        end
      end
    end
  end  
    
  #-----------------------------------------------------------------------------
  # Locked Door Tile functions.
  #-----------------------------------------------------------------------------
  # Checks if there's a Locked Door Tile at the inputted coordinates.
  def pbLockedDoorTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapLockedDoor.length
      tile    = @sprites["mapLockedDoor#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = true
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Roadblock Tile functions.
  #-----------------------------------------------------------------------------
  # Checks if there's a Roadblock Tile at the inputted coordinates.
  def pbRoadblockTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapRoadblock.length
      for j in 0...12
        if @sprites["mapRoadblock#{i}#{j}"]
          tile    = @sprites["mapRoadblock#{i}#{j}"]
          tilepos = [tile.x,tile.y]
          next if !tile.visible
          next if coords!=tilepos
          ret = true
        end
      end
    end
    return ret
  end
  
  # Returns the type of Roadblock that is present at the inputted coordinates.
  def pbRoadblockType(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for event in 0...@mapRoadblock.length
      for type in 0...12
        if @sprites["mapRoadblock#{event}#{type}"]
          tile    = @sprites["mapRoadblock#{event}#{type}"]
          tilepos = [tile.x,tile.y]
          next if coords!=tilepos
          ret = type
        end
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Hidden Trap Tile functions.
  #-----------------------------------------------------------------------------
  # Checks if there's a Hidden Trap Tile at the inputted coordinates.
  def pbHiddenTrapTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapHiddenTrap.length
      for j in 0...6
        if @sprites["mapHiddenTrap#{i}#{j}"]
          tile    = @sprites["mapHiddenTrap#{i}#{j}"]
          tilepos = [tile.x,tile.y]
          next if !tile.visible
          next if coords!=tilepos
          ret = true
        end
      end
    end
    return ret
  end
  
  # Returns the type of Hidden Trap that is present at the inputted coordinates.
  def pbHiddenTrapType(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for event in 0...@mapHiddenTrap.length
      for type in 0...6
        if @sprites["mapHiddenTrap#{event}#{type}"]
          tile    = @sprites["mapHiddenTrap#{event}#{type}"]
          tilepos = [tile.x,tile.y]
          next if coords!=tilepos
          ret = type
        end
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Switch and Switch Target Tile functions.
  #-----------------------------------------------------------------------------
  # Checks if there's a Switch Tile at the inputted coordinates.
  def pbSwitchTile?(coords=nil)
    ret = false
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapSwitches.length
      tile    = @sprites["mapSwitches#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = true
    end
    return ret
  end
  
  # Hides the sprites for all tiles that share the coordinates of a Switch Target Tile.
  def pbHideSwitchTargs
    for i in 0...@mapSwitchTargs.length
      tile    = @sprites["mapSwitchTargs#{i}"]
      tilepos = [tile.x,tile.y]
      for sprite in @mapSprites
        next if sprite==@player
        next if sprite==@startTile
        next if sprite==@sprites["background"]
        next if pbPokemonTiles(tilepos)
        next if pbRoadblockTile?(tilepos)
        next if pbHiddenTrapTile?(tilepos)
        coords = [sprite.x,sprite.y]
        sprite.visible = false if coords==tilepos
      end
    end
  end
  
  # Toggles the sprites for all tiles that share the coordinates of a Switch Target Tile.
  def pbToggleSwitchTargs
    pbWait(10)
    pbSEPlay("Voltorb flip tile")
    for i in 0...@mapSwitchTargs.length
      tile    = @sprites["mapSwitchTargs#{i}"]
      tilepos = [tile.x,tile.y]
      for sprite in @mapSprites
        next if sprite==@player
        next if sprite==@startTile
        next if sprite==@sprites["background"]
        next if pbPokemonTiles(tilepos)
        next if pbRoadblockTile?(tilepos)
        next if pbHiddenTrapTile?(tilepos)
        coords = [sprite.x,sprite.y]
        if coords==tilepos
          sprite.visible = (sprite.visible) ? false : true
          toggle = (sprite.visible) ? 128 : 96
        end
      end
    end
    for i in 0...@mapSwitches.length
      @sprites["mapSwitches#{i}"].src_rect.set(toggle,0,32,32)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Returns the type of Turn tile the player is on. (0-5)
  #-----------------------------------------------------------------------------
  def pbTurnTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapTurnUp.length
      tile    = @sprites["mapTurnUp#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 0
    end
    for i in 0...@mapTurnDown.length
      tile    = @sprites["mapTurnDown#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 1
    end
    for i in 0...@mapTurnLeft.length
      tile    = @sprites["mapTurnLeft#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 2
    end
    for i in 0...@mapTurnRight.length
      tile    = @sprites["mapTurnRight#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 3
    end
    for i in 0...@mapTurnRandom.length
      tile    = @sprites["mapTurnRandom#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 4
    end
    for i in 0...@mapTurnFlip.length
      tile    = @sprites["mapTurnFlip#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 5
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Returns the type of Event tile the player is on. (0-9)
  #-----------------------------------------------------------------------------
  def pbEventTiles(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapEventSwap.length
      tile    = @sprites["mapEventSwap#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 0
    end
    for i in 0...@mapEventItems.length
      tile    = @sprites["mapEventItems#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 1
    end
    for i in 0...@mapEventTrain.length
      tile    = @sprites["mapEventTrain#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 2
    end
    for i in 0...@mapEventTutor.length
      tile    = @sprites["mapEventTutor#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 3
    end
    for i in 0...@mapEventWard.length
      tile    = @sprites["mapEventWard#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 4
    end
    for i in 0...@mapEventHeal.length
      tile    = @sprites["mapEventHeal#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 5
    end
    for i in 0...@mapEventRandom.length
      tile    = @sprites["mapEventRandom#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 6
    end
    for i in 0...@mapEventBerry.length
      tile    = @sprites["mapEventBerry#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 7
    end
    for i in 0...@mapEventKey.length
      tile    = @sprites["mapEventKey#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 8
    end
    for i in 0...@mapEventChest.length
      tile    = @sprites["mapEventChest#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = 9
    end
    return ret
  end
    
  #-----------------------------------------------------------------------------
  # Returns which directions can be chosen on a given Selection tile.
  #-----------------------------------------------------------------------------
  def pbRouteSelections(coords=nil)
    ret = nil
    coords = [@player.x,@player.y] if !coords
    for i in 0...@mapPathsUL.length
      tile    = @sprites["mapPathUL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,2]
    end
    for i in 0...@mapPathsUR.length
      tile    = @sprites["mapPathUR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,3]
    end 
    for i in 0...@mapPathsDL.length
      tile    = @sprites["mapPathDL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,2]
    end
    for i in 0...@mapPathsDR.length
      tile    = @sprites["mapPathDR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,3]
    end
    for i in 0...@mapPathsUD.length
      tile    = @sprites["mapPathUD#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1]
    end 
    for i in 0...@mapPathsLR.length
      tile    = @sprites["mapPathLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [2,3]
    end
    for i in 0...@mapPathsULR.length
      tile    = @sprites["mapPathULR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,2,3]
    end
    for i in 0...@mapPathsUDL.length
      tile    = @sprites["mapPathUDL#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,2]
    end
    for i in 0...@mapPathsUDR.length
      tile    = @sprites["mapPathUDR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,3]
    end
    for i in 0...@mapPathsDLR.length
      tile    = @sprites["mapPathDLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [1,2,3]
    end
    for i in 0...@mapPathsUDLR.length
      tile    = @sprites["mapPathUDLR#{i}"]
      tilepos = [tile.x,tile.y]
      next if !tile.visible
      next if coords!=tilepos
      ret = [0,1,2,3]
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Moves the player's icon around the map.
  #-----------------------------------------------------------------------------
  def pbMovePlayerIcon(index=0)
    pbChangePokeOpacity
    speed     = 2
    moveUp    = true if index==0
    moveDown  = true if index==1
    moveLeft  = true if index==2
    moveRight = true if index==3
    moveStop  = false
    loop do
      boundsReached = (@player.x<32 || @player.y<32 || @player.x>Graphics.width-32 || @player.y>Graphics.height-32)
      instant = (Input.press?(Input::ACTION)) ? true : false
      #-------------------------------------------------------------------------
      # Move player.
      #-------------------------------------------------------------------------
      pbWait(1) if !instant
      if    moveUp;    @player.y -= speed
      elsif moveDown;  @player.y += speed
      elsif moveLeft;  @player.x -= speed
      elsif moveRight; @player.x += speed
      end
      #-------------------------------------------------------------------------
      # Hidden Trap Tile triggers.
      #-------------------------------------------------------------------------
      if pbHiddenTrapTile?
        pbDynAdventureState.pbLairTraps(pbHiddenTrapType) 
        pbClearTile
      end
      #-------------------------------------------------------------------------
      # Roadblock & Locked Door Tile triggers.
      #-------------------------------------------------------------------------
      if pbRoadblockTile? || pbLockedDoorTile?
        if $DEBUG && Input.press?(Input::CTRL)
          pbClearTile
        else
          if    pbLockedDoorTile? && pbDynAdventureState.pbLairDoors; pbUpdateLairKeys;    pbClearTile
          elsif pbRoadblockTile?  && pbDynAdventureState.pbLairObstacles(pbRoadblockType); pbClearTile
          else
            if    moveUp;    moveDown  = true; moveUp    = false
            elsif moveDown;  moveUp    = true; moveDown  = false
            elsif moveLeft;  moveRight = true; moveLeft  = false
            elsif moveRight; moveLeft  = true; moveRight = false
            end
          end
        end
      end
      #-------------------------------------------------------------------------
      # Event Tile triggers.
      #-------------------------------------------------------------------------
      if pbEventTiles
        if    pbItemsEventTile?; pbDynAdventureState.pbLairEventItems
        elsif pbTrainEventTile?; pbDynAdventureState.pbLairEventTrain
        elsif pbTutorEventTile?; pbDynAdventureState.pbLairEventTutor
        elsif pbSwapEventTile?;  pbDynAdventureState.pbLairEventSwap;   pbClearTile
        elsif pbHealEventTile?;  pbDynAdventureState.pbLairEventHeal;   pbClearTile
        elsif pbWardEventTile? || (pbRandEventTile? && rand(6)==5)
          pbDynAdventureState.pbLairEventWardIntro
          @sprites["hpcount#{@maxHearts}"] = IconSprite.new(4+(@maxHearts*34),4,@viewport)
          @sprites["hpcount#{@maxHearts}"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmap_hearts")
          pbDynAdventureState.knockouts += 1
          pbDynAdventureState.knockouts  = 6 if pbDynAdventureState.knockouts > 6
          @knockouts  = pbDynAdventureState.knockouts
          @maxHearts +=1
          @maxHearts  = 6 if @maxHearts > 6
          pbUpdateLairHP
          pbDynAdventureState.pbLairEventWardOutro
          pbClearTile
        elsif pbRandEventTile?;  pbDynAdventureState.pbLairEventRandom(rand(5)); pbClearTile
        elsif pbBerryEventTile?; pbDynAdventureState.pbLairBerries; pbClearTile
        elsif pbKeyEventTile?;   pbDynAdventureState.pbLairKeys; pbUpdateLairKeys; pbClearTile
        elsif pbChestEventTile?; pbDynAdventureState.pbLairChests; pbClearTile
        end
      end
      #-------------------------------------------------------------------------
      # Other Tile triggers.
      #-------------------------------------------------------------------------
      if pbPokemonTile?
        pbBattleLairPokemon(pbPokemonTiles) if !($DEBUG && Input.press?(Input::CTRL) && pbPokemonTiles<@size-1)
      end
      pbToggleSwitchTargs if pbSwitchTile?
      pbWarpPlayer if pbWarpTile?
      #-------------------------------------------------------------------------
      # Turn Tile triggers.
      #-------------------------------------------------------------------------
      if pbTurnTiles
        if pbFlipTurnTile?
          if    moveUp;    moveDown  = true; moveUp    = false
          elsif moveDown;  moveUp    = true; moveDown  = false
          elsif moveLeft;  moveRight = true; moveLeft  = false
          elsif moveRight; moveLeft  = true; moveRight = false
          end
        else
          moveUp = moveDown = moveLeft = moveRight = false
          if    pbUpTurnTile?;    moveUp    = true
          elsif pbDownTurnTile?;  moveDown  = true
          elsif pbLeftTurnTile?;  moveLeft  = true
          elsif pbRightTurnTile?; moveRight = true
          elsif pbRandTurnTile?
            directions = [0,1,2,3]
            directions.delete_at(0) if index==1
            directions.delete_at(1) if index==0
            directions.delete_at(2) if index==3
            directions.delete_at(3) if index==2
            randturn  = directions[rand(directions.length)]
            moveUp    = true if randturn==0
            moveDown  = true if randturn==1
            moveLeft  = true if randturn==2
            moveRight = true if randturn==3
          end
        end
      end
      #-------------------------------------------------------------------------
      # Stop player movement.
      #-------------------------------------------------------------------------
      moveStop = true if pbSelectionTile? || pbStartTile?
      pbAutoMapPosition(@player,speed) if boundsReached
      break if moveStop || pbDynAdventureState.ended?
    end
  end
  
  #-----------------------------------------------------------------------------
  # Automatically scrolls the map to the correct position when needed.
  #-----------------------------------------------------------------------------
  def pbAutoMapPosition(sprite,speed,instant=false)
    xBoundsReached = false
    yBoundsReached = false
    center = [(Graphics.width/2)-16,(Graphics.height/2)-16]
    allSprites = @mapSprites+@pokeSprites
    loop do
      coords = [sprite.x,sprite.y]
      xBoundsReached = true if coords[0]==center[0]
      yBoundsReached = true if coords[1]==center[1]
      #-------------------------------------------------------------------------
      # X axis movement.
      #-------------------------------------------------------------------------
      if !xBoundsReached
        # Target sprite is left of center.
        if coords[0]<center[0]
          if @sprites["background"].x+2*speed>=@leftBounds+2
            xBoundsReached = true
          else
            if (center[0]-coords[0])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.x+=2*speed; end
            else; for i in allSprites; i.x+=1; end
            end
          end
        end
        # Target sprite is right of center.
        if coords[0]>center[0]
          if @sprites["background"].x-2*speed<=@rightBounds+2
            xBoundsReached = true
          else
            if (coords[0]-center[0])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.x-=2*speed; end 
            else; for i in allSprites; i.x-=1; end
            end
          end
        end
      #-------------------------------------------------------------------------
      # Y axis movement.
      #-------------------------------------------------------------------------
      elsif !yBoundsReached
        # Target sprite is above center.
        if coords[1]<center[1]
          if @sprites["background"].y+2*speed>=@upperBounds+2
            yBoundsReached = true
          else
            if (center[1]-coords[1])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.y+=2*speed; end 
            else; for i in allSprites; i.y+=1; end
            end
          end
        end
        # Target sprite is below center.
        if coords[1]>center[1]
          if @sprites["background"].y-2*speed<=@lowerBounds+2
            yBoundsReached = true
          else
            if (coords[1]-center[1])%(2*speed)==0
              pbWait(1) if !instant
              for i in allSprites; i.y-=2*speed; end 
            else; for i in allSprites; i.y-=1; end
            end
          end
        end
      end
      break if xBoundsReached && yBoundsReached
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows for free scrolling of the Max Lair map.
  #-----------------------------------------------------------------------------
  def pbLairMapScroll(index)
    move = 8
    pbHideUISprites
    @cursor.x = @player.x-16
    @cursor.y = @player.y-16
    @cursor.visible = true
    @sprites["return"].visible = true
    allSprites = @mapSprites+@pokeSprites
    for i in 0...@mapPkmnCoords.length
      @sprites["mapPokemon#{i}"].visible = true
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate
      @sprites["uparrow"].visible    = true
      @sprites["downarrow"].visible  = true
      @sprites["leftarrow"].visible  = true
      @sprites["rightarrow"].visible = true
      #-------------------------------------------------------------------------
      # Scroll map and cursor upwards.
      #-------------------------------------------------------------------------
      if Input.press?(Input::UP)
        @cursor.y-=move if @cursor.y>0
        if @sprites["background"].y<=(@upperBounds-move)
          for i in allSprites; i.y += move; end
        else
          @sprites["uparrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor downwards.
      #-------------------------------------------------------------------------
      if Input.press?(Input::DOWN)
        @cursor.y+=move if @cursor.y<=Graphics.height-72
        if @sprites["background"].y>=(@lowerBounds+move)
          for i in allSprites; i.y -= move; end
        else
          @sprites["downarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor to the left.
      #-------------------------------------------------------------------------
      if Input.press?(Input::LEFT)
        @cursor.x-=move if @cursor.x>0
        if @sprites["background"].x<=(@leftBounds-move)
          for i in allSprites; i.x += move; end
        else
          @sprites["leftarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Scroll map and cursor to the right.
      #-------------------------------------------------------------------------
      if Input.press?(Input::RIGHT)
        @cursor.x+=move if @cursor.x<=Graphics.width-72
        if @sprites["background"].x>=(@rightBounds+move)
          for i in allSprites; i.x -= move; end
        else
          @sprites["rightarrow"].visible = false
        end
      end
      #-------------------------------------------------------------------------
      # Toggle Pokemon sprites.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::ACTION)
        pbSEPlay("GUI party switch")
        for i in 0...@mapPkmnCoords.length
          mapPoke = @sprites["pokemon#{i}"]
          mapType = @sprites["poketype#{i}"]
          mapPoke.visible = (mapPoke.visible) ? false: true
          mapType.visible = (mapType.visible) ? false: true
        end
      end
      #-------------------------------------------------------------------------
      # Gets tile information.
      #-------------------------------------------------------------------------
      if pbCursorReact.is_a?(Array)
        @cursor.src_rect.set(64,0,64,64)
        if Input.trigger?(Input::USE)
          @cursor.x = pbCursorReact[0]-16 
          @cursor.y = pbCursorReact[1]-16
          @cursor.src_rect.set(64,0,64,64)
          newcoords = [@cursor.x+16,@cursor.y+16]
          if pbStartTile?(newcoords)
            pbMessage(_INTL("This is the Start Tile.\nThis will always be the first tile you move towards."))
          elsif pbRouteSelections(newcoords)
            pbMessage(_INTL("This is a Selection Tile.\nLanding on this tile will allow you to choose a new path to travel in."))
            pbMessage(_INTL("The number of paths you can choose from varies with each individual Selection Tile."))
          elsif pbPokemonTiles(newcoords)
            pbMessage(_INTL("This is a Raid Tile.\nPassing over this tile will initiate a battle against a Dynamaxed Pokémon."))
            pbMessage(_INTL("Once captured or defeated, this tile is cleared and the Pokémon cannot be challenged again."))
          elsif pbWarpTile?(newcoords)
            pbMessage(_INTL("This is a Warp Tile.\nLanding on this tile will teleport you to another Warp Tile on the map that is linked to this one."))
          elsif pbLockedDoorTile?(newcoords)
            pbMessage(_INTL("This is a Locked Door Tile.\nA locked door prevents movement on this path unless you have acquired a Lair Key to open it."))
            pbMessage(_INTL("Opening the door will clear the tile, and allow you to proceed. However, this will consume one of your Lair Keys."))
          elsif pbRoadblockTile?(newcoords)
            pbMessage(_INTL("This is a Roadblock Tile.\nAn obstacle prevents movement on this path unless you meet certain criteria."))
            pbMessage(_INTL("Once the obstacle's criteria has been met, this tile will become cleared and you will not be required to clear the obstacle again."))
          elsif pbSwitchTile?(newcoords)
            pbMessage(_INTL("This is a Switch Tile.\nLanding on this tile will flip all switches to the ON position, revealing hidden tiles that are normally inactive."))
            pbMessage(_INTL("Landing on a Switch Tile that is already in the ON position will revert all switches to the OFF position, and any revealed tiles will return to their inactive state."))
          elsif pbTurnTiles(newcoords)==4
            pbMessage(_INTL("This is a Random Turn Tile.\nPassing over this tile may force you into changing course in a random direction."))
          elsif pbTurnTiles(newcoords)==5
            pbMessage(_INTL("This is a Flip Turn Tile.\nLanding on this tile will force you to reverse course and travel in the opposite direction."))
          elsif pbTurnTiles(newcoords)
            pbMessage(_INTL("This is a Directional Tile.\nPassing over this tile will force you to move in the direction it's pointing."))
          elsif pbEventTiles(newcoords)==0
            pbMessage(_INTL("There's a Scientist on this tile.\nScientists have additional rental Pokémon you may add to your party by swapping out an existing party member."))
            pbMessage(_INTL("After encountering a Scientist, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==1
            pbMessage(_INTL("There's a Backpacker on this tile.\nBackpackers carry a random assortment of items that may be given to your party Pokémon to hold."))
          elsif pbEventTiles(newcoords)==2
            pbMessage(_INTL("There's a Blackbelt on this tile.\nBlackbelts have secret training techniques that can power up particular stats of your party Pokémon."))
          elsif pbEventTiles(newcoords)==3
            pbMessage(_INTL("There's an Ace Trainer on this tile.\nAce Trainers can tutor your party Pokémon to teach one of them a new move for a strategical advantage."))
          elsif pbEventTiles(newcoords)==4
            pbMessage(_INTL("There's a Channeler on this tile.\nChannelers will raise your spirit, increasing your heart counter by one."))
            pbMessage(_INTL("After encountering a Channeler, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==5
            pbMessage(_INTL("There's a Nurse on this tile.\nNurses will heal your party Pokémon back to full health."))
            pbMessage(_INTL("After encountering a Nurse, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==6
            pbMessage(_INTL("It's a mystery who's on this tile.\nYou'll never know who you'll run into!"))
            pbMessage(_INTL("After encountering this mystery person, they will leave the map and this tile will be cleared."))
          elsif pbEventTiles(newcoords)==7
            pbMessage(_INTL("There's a pile of Berries on this tile.\nIf you land on this tile, you'll feed your party Pokémon the Berries to recover some HP."))
            pbMessage(_INTL("This tile will become cleared after consuming the Berries."))
          elsif pbEventTiles(newcoords)==8
            pbMessage(_INTL("There's a Lair Key on this tile.\nIf you land on this tile, you'll collect the key and increase your total number of Lair Keys by one."))
            pbMessage(_INTL("This tile will become cleared after collecting the Lair Key."))
          elsif pbEventTiles(newcoords)==9
            pbMessage(_INTL("There's a Treasure Chest on this tile.\nIf you land on this tile, you'll open the chest and discover the treasure within."))
            pbMessage(_INTL("This tile will become cleared after the Treasure Chest has been opened."))
          end
        end
      end
      #-------------------------------------------------------------------------
      # Cycles through raid species from first to last.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::JUMPUP)
        coords = [@cursor.x+16,@cursor.y+16]
        pkmn_index = pbPokemonTiles(coords)
        if pkmn_index
          pkmn_index = -1 if pkmn_index==@size-1
          pkmn_index += 1
          sprite = @sprites["mapPokemon#{pkmn_index}"]
        else
          sprite = @sprites["mapPokemon#{0}"]
        end
        pbSEPlay("GUI party switch")
        pbAutoMapPosition(sprite,move,true)
        @cursor.x = sprite.x-16
        @cursor.y = sprite.y-16
      #-------------------------------------------------------------------------
      # Cycles through raid species from last to first.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::JUMPDOWN)
        coords = [@cursor.x+16,@cursor.y+16]
        pkmn_index = pbPokemonTiles(coords)
        if pkmn_index
          pkmn_index = @size if pkmn_index==0
          pkmn_index -= 1
          sprite = @sprites["mapPokemon#{pkmn_index}"]
        else
          pkmn_index = @size-1
          sprite = @sprites["mapPokemon#{pkmn_index}"]
        end
        pbSEPlay("GUI party switch")
        pbAutoMapPosition(sprite,move,true)
        @cursor.x = sprite.x-16
        @cursor.y = sprite.y-16
      end
      #-------------------------------------------------------------------------
      # Returns to route selection.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        pbHideUISprites
        for i in 0...@mapPkmnCoords.length
          @sprites["mapPokemon#{i}"].visible = false
          if @sprites["pokemon#{i}"].color.alpha==255
            @sprites["pokemon#{i}"].visible  = true
            @sprites["poketype#{i}"].visible = true
          else
            @sprites["pokemon#{i}"].visible  = false
            @sprites["poketype#{i}"].visible = false
          end
        end
        pbAutoMapPosition(@player,move)
        @sprites["select"].visible  = true
        @sprites["options"].visible = true
        break
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows the player to select a route to take while on a Selection tile.
  #-----------------------------------------------------------------------------
  def pbChooseRoute
    endgame = false
    highlight  = Color.new(255,0,0,200)
    resetcolor = Color.new(0,0,0,0)
    loop do
      pbResetRaidSettings
      $PokemonTemp.clearBattleRules
      break if pbDynAdventureState.ended?
      pbAutoMapPosition(@player,2)
      pbChangePokeOpacity(false)
      @sprites["speedup"].visible = false
      pbMessage(_INTL("Which path would you like to take?"))
      coords     = [@player.x,@player.y]
      index = 3 if pbCanMoveRight?
      index = 2 if pbCanMoveLeft?
      index = 1 if pbCanMoveDown?
      index = 0 if pbCanMoveUp?
      @arrow0.color = highlight if index==0
      @arrow1.color = highlight if index==1
      @arrow2.color = highlight if index==2
      @arrow3.color = highlight if index==3
      loop do
        Graphics.update
        Input.update
        pbUpdate
        @arrow0.y = @player.y-16
        @arrow1.y = @player.y+32
        @arrow0.x = @arrow1.x = @player.x+8
        @arrow2.x = @player.x-16
        @arrow3.x = @player.x+32
        @arrow2.y = @arrow3.y = @player.y+10
        @arrow0.visible = true if pbCanMoveUp?
        @arrow1.visible = true if pbCanMoveDown?
        @arrow2.visible = true if pbCanMoveLeft?
        @arrow3.visible = true if pbCanMoveRight?
        @sprites["select"].visible  = true
        @sprites["options"].visible = true
        #-----------------------------------------------------------------------
        # Selects between available routes to take.
        #-----------------------------------------------------------------------
        if Input.trigger?(Input::UP) && pbCanMoveUp?
          pbPlayDecisionSE
          index = 0
        elsif Input.trigger?(Input::DOWN) && pbCanMoveDown?
          pbPlayDecisionSE
          index = 1
        elsif Input.trigger?(Input::LEFT) && pbCanMoveLeft?
          pbPlayDecisionSE
          index = 2
        elsif Input.trigger?(Input::RIGHT) && pbCanMoveRight?
          pbPlayDecisionSE
          index = 3
        end
        @arrow0.color = (index==0) ? highlight : resetcolor
        @arrow1.color = (index==1) ? highlight : resetcolor
        @arrow2.color = (index==2) ? highlight : resetcolor
        @arrow3.color = (index==3) ? highlight : resetcolor
        #-----------------------------------------------------------------------
        # Confirms a selected route.
        #-----------------------------------------------------------------------
        if Input.trigger?(Input::USE)
          if pbConfirmMessage(_INTL("Are you sure you want to take this path?"))
            pbHideUISprites
            @sprites["speedup"].visible = true
            pbMovePlayerIcon(index)
            break
          end
        #-----------------------------------------------------------------------
        # Options menu.
        #-----------------------------------------------------------------------
        elsif Input.trigger?(Input::ACTION)
		  options = ["View Map","View Party"]
		  options.push("View Record") if @endlessMode && pbEndlessLairRecord[0] > 1
		  options.push("Leave Lair")
          loop do
            cmd = pbMessage("What would you like to do?",options,-1,nil,0)
			break if cmd==-1
            case options[cmd]
            when "View Map";    pbLairMapScroll(index); break
            when "View Party";  pbSummary($Trainer.party,0,@sprites); break
			when "View Record"; pbMaxLairMenu([7],pbEndlessLairRecord[2].length)
            when "Leave Lair"
              if pbConfirmMessage(_INTL("End your Dynamax Adventure?\nAny captured Pokémon and acquired treasure will be lost."))
                endgame = true
                break
              end
            end
          end
          break if endgame
        end
      end
      break if endgame  
    end
    if @endlessMode && pbDynAdventureState.victory?
      pbMessage(_INTL("The storm seems to have died down a bit..."))
      pbDynAdventureState.bossSpecies = nil
      pbDynAdventureState.bossBattled = false
      pbDynAdventureState.lairfloor  += 1
    else
      pbMessage(_INTL("Your Dynamax Adventure is over!"))
      pbDynAdventureState.abandoned = endgame
    end
  end
end