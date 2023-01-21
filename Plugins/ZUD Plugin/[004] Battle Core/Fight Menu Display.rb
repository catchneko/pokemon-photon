#===============================================================================
# Adds ZUD buttons to the fight menu.
#===============================================================================
class FightMenuDisplay < BattleMenuBase
  NoButton         =-1 
  MegaButton       = 0
  UltraBurstButton = 1
  ZMoveButton      = 2
  DynamaxButton    = 3

  def initialize(viewport,z)
    super(viewport)
    self.x = 0
    self.y = Graphics.height-96
    @battler   = nil
    @shiftMode = 0
    if USE_GRAPHICS
      @buttonBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @shiftBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
      @battleButtonBitmap = {}
      # Mega Evolution
      @battleButtonBitmap[MegaButton]       = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      # Ultra Burst
      @battleButtonBitmap[UltraBurstButton] = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_ultra"))
      # Z-Moves
      @battleButtonBitmap[ZMoveButton]      = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_zmove"))
      # Dynamax
      @battleButtonBitmap[DynamaxButton]    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_dynamax"))
      # Chosen button:
      @chosen_button = NoButton
      background = IconSprite.new(0,Graphics.height-96,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background",background)
      @buttons = Array.new(Pokemon::MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+4
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+6
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
      @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      pbSetNarrowFont(@overlay.bitmap)
      addSprite("overlay",@overlay)
      @infoOverlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
      @infoOverlay.x = self.x
      @infoOverlay.y = self.y
      pbSetNarrowFont(@infoOverlay.bitmap)
      addSprite("infoOverlay",@infoOverlay)
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x+416
      @typeIcon.y      = self.y+20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon",@typeIcon)
	  @battleButton = SpriteWrapper.new(viewport) # For button graphic
	  addSprite("battleButton",@battleButton)
      @shiftButton = SpriteWrapper.new(viewport)
      @shiftButton.bitmap = @shiftBitmap.bitmap
      @shiftButton.x      = self.x+4
      @shiftButton.y      = self.y-@shiftBitmap.height
      addSprite("shiftButton",@shiftButton)
    else
      @msgBox = Window_AdvancedTextPokemon.newWithSize("",
         self.x+320,self.y,Graphics.width-320,Graphics.height-self.y,viewport)
      @msgBox.baseColor   = TEXT_BASE_COLOR
      @msgBox.shadowColor = TEXT_SHADOW_COLOR
      pbSetNarrowFont(@msgBox.contents)
      addSprite("msgBox",@msgBox)
      @cmdWindow = Window_CommandPokemon.newWithSize([],
         self.x,self.y,320,Graphics.height-self.y,viewport)
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      pbSetNarrowFont(@cmdWindow.contents)
      addSprite("cmdWindow",@cmdWindow)
    end
    self.z = z
  end
  
  def dispose
    super
    @buttonBitmap.dispose  if @buttonBitmap
    @typeBitmap.dispose    if @typeBitmap
	@battleButtonBitmap.each { |k,bmp| bmp.dispose if bmp}
    @shiftBitmap.dispose   if @shiftBitmap
  end
  
  #-----------------------------------------------------------------------------
  # Allows for shortened move names to display.
  #-----------------------------------------------------------------------------
  def refreshButtonNames
    moves = (@battler) ? @battler.moves : []
    if !USE_GRAPHICS
      commands = []
      for i in 0...[4, moves.length].max
        commands.push((moves[i]) ? moves[i].short_name : "-")
      end
      @cmdWindow.commands = commands
      return
    end
    @overlay.bitmap.clear
    textPos = []
    @buttons.each_with_index do |button,i|
      next if !@visibility["button_#{i}"]
      x = button.x-self.x+button.src_rect.width/2
      y = button.y-self.y+2
      moveNameBase = TEXT_BASE_COLOR
      if moves[i].type
        moveNameBase = button.bitmap.get_pixel(10,button.src_rect.y+34)
      end
      textPos.push([moves[i].short_name,x,y,2,moveNameBase,TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(@overlay.bitmap,textPos)
  end  
  
  #-----------------------------------------------------------------------------
  # Displays appropriate button for battle mechanics.
  #-----------------------------------------------------------------------------
  def refreshBattleButton
    return if !USE_GRAPHICS
	if @chosen_button==NoButton
	  @visibility["battleButton"] = false
	  return
	end
    @battleButton.bitmap = @battleButtonBitmap[@chosen_button].bitmap
    @battleButton.x      = self.x+120
    @battleButton.y      = self.y-@battleButtonBitmap[@chosen_button].height/2
    @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height/2
    @battleButton.src_rect.y    = (@mode - 1) * @battleButtonBitmap[@chosen_button].height / 2
    @battleButton.x             = self.x + ((@shiftMode > 0) ? 204 : 120)
    @battleButton.z             = self.z - 1
    @visibility["battleButton"] = (@mode > 0)
  end
  
  def chosen_button=(value)
    oldValue = @chosen_button
    @chosen_button = value
    refresh if @chosen_button!=oldValue
  end
  
  def refresh
    return if !@battler
    refreshSelection
	refreshBattleButton
    refreshShiftButton
    refreshButtonNames
  end
end

def pbPlayZUDButton
  if FileTest.audio_exist?("Audio/SE/GUI sel cancel")
    pbSEPlay("GUI ZUD Button",80)
  else
    pbPlayDecisionSE
  end
end