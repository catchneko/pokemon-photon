#===============================================================================
# Max Raid Databox display.
#===============================================================================
class PokemonDataBox < SpriteWrapper
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide  = ((@battler.index%2)==0)
    player_normal = "Graphics/Pictures/Battle/databox_normal"
    player_thin   = "Graphics/Pictures/Battle/databox_thin"
    enemy_normal  = "Graphics/Pictures/Battle/databox_normal_foe"
    enemy_thin    = "Graphics/Pictures/Battle/databox_thin_foe"
    enemy_raid    = "Graphics/Pictures/Dynamax/databox_maxraid"
    player_data   = (sideSize==1) ? player_normal : player_thin
    enemy_data    = (sideSize==1) ? enemy_normal  : enemy_thin
    enemy_data    = enemy_raid if $game_switches[Settings::MAXRAID_SWITCH]
    bgFilename = [player_data, enemy_data][@battler.index%2]
    @databoxBitmap  = AnimatedBitmap.new(bgFilename)
    if onPlayerSide
      @showHP  = true if sideSize==1
      @showExp = true if sideSize==1
      @spriteX = Graphics.width - 244
      @spriteY = Graphics.height - 192
      @spriteBaseX = 34
    else
      @spriteX = -16
      @spriteY = 36
      @spriteBaseX = 16
    end
    case sideSize
    when 2
      @spriteX += (Settings::EMBS_COMPAT) ? [0,0,0,0][@battler.index] : [-12,12,0,0][@battler.index]
      @spriteY += [-20, -34, 34, 20][@battler.index]
    when 3
      @spriteX += (Settings::EMBS_COMPAT) ? [0,0,0,0,0,0][@battler.index] : [-12,12,-6,6,0,0][@battler.index]
      @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
    when 4
      @spriteX += [  0,  0,  0,  0,  0,   0,  0,  0][@battler.index]
      @spriteY += [-88,-46,-42,  0,  4,  46, 50, 92][@battler.index]
    when 5
      @spriteX += [   0,  0,  0,  0,  0,  0,  0,  0,  0,  0][@battler.index]
      @spriteY += [-134,-46,-88,  0,-42, 46,  4, 92, 50,138][@battler.index]
    end
  end
  
  #-----------------------------------------------------------------------------
  # Sets up graphics for the Raid Databox.
  #-----------------------------------------------------------------------------
  alias _ZUD_initializeOtherGraphics initializeOtherGraphics
  def initializeOtherGraphics(viewport)
    @raidNumbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_num"))
    @raidBarBitmap     = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_bar"))
    @shieldHPBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raidbattle_shield"))
    _ZUD_initializeOtherGraphics(viewport)
  end
  
  def pbDrawRaidNumber(counter,number,btmp,startX,startY)
    color = 0
    if counter==0
      color = 1 if number<=Settings::MAXRAID_TIMER/2
      color = 2 if number<=Settings::MAXRAID_TIMER/4
      color = 3 if number<=Settings::MAXRAID_TIMER/8
    elsif counter==1
      color = 1 if number<=Settings::MAXRAID_KOS/2
      color = 2 if number<=Settings::MAXRAID_KOS/4
      color = 3 if number<=1
    end
    n = (number==-1) ? 10 : number.to_i.digits.reverse
    charWidth  = @raidNumbersBitmap.width/11
    charHeight = @raidNumbersBitmap.height/4
    startX -= charWidth*n.length
    n.each do |i|
      numberRect = Rect.new(i*charWidth, color*14, charWidth, charHeight)
      btmp.blt(startX, startY, @raidNumbersBitmap.bitmap, numberRect)
      startX += charWidth
    end
  end
  
  alias _ZUD_dispose dispose
  def dispose
    @raidBarBitmap.dispose
    @shieldHPBitmap.dispose
    @raidNumbersBitmap.dispose
    _ZUD_dispose
  end
  
  #-----------------------------------------------------------------------------
  # Updates databoxes in battle.
  #-----------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    textPos = []
    imagePos = []
    self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth-116 if nameWidth>116
    if $game_switches[Settings::MAXRAID_SWITCH] && @battler.effects[PBEffects::MaxRaidBoss]
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,Color.new(248,248,248),Color.new(248,32,32)])
      turncount = @battler.effects[PBEffects::Dynamax]-1
      kocount   = @battler.effects[PBEffects::KnockOutCount]
      kocount   = 0 if kocount<0
      pbDrawRaidNumber(0,turncount,self.bitmap,@spriteBaseX+170,20) # Draws turncount
      pbDrawRaidNumber(1,kocount,self.bitmap,@spriteBaseX+199,20)   # Draws KO count
      if @battler.effects[PBEffects::RaidShield]>0
        shieldHP   =   @battler.effects[PBEffects::RaidShield]
        shieldLvl  =   @battler.effects[PBEffects::MaxShieldHP]
        offset     = (121-(2+shieldLvl*30/2))
        self.bitmap.blt(@spriteBaseX+offset,59,@raidBarBitmap.bitmap,Rect.new(0,0,2+shieldLvl*30,12)) 
        self.bitmap.blt(@spriteBaseX+offset,59,@shieldHPBitmap.bitmap,Rect.new(0,0,2+shieldHP*30,12))
      end
    else
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
      case @battler.displayGender
      when 0   # Male
        textPos.push([_INTL("♂"),@spriteBaseX+126,0,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
      when 1   # Female
        textPos.push([_INTL("♀"),@spriteBaseX+126,0,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
      end
      imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
      pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
    end
    pbDrawTextPositions(self.bitmap,textPos)
    if @battler.shiny?
      shinyX = (@battler.opposes?(0)) ? 206 : -6
      imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
    end
	if @battler.is_a?(PokeBattle_FakeBattler)
	  specialX = -28
	else
	  specialX = (@battler.opposes?) ? 208 : -28
	end
    if @battler.mega?
      imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
    elsif @battler.primal?
      if @battler.isSpecies?(:KYOGRE)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+specialX,4])
      elsif @battler.isSpecies?(:GROUDON)
        imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+specialX,4])
      end
    elsif @battler.ultra?
      imagePos.push(["Graphics/Pictures/Battle/icon_ultra",@spriteBaseX+specialX+2,4])
    elsif @battler.dynamax?
      imagePos.push(["Graphics/Pictures/Battle/icon_dynamax",@spriteBaseX+specialX,4])
    end
    if @battler.owned? && @battler.opposes?(0)
      imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
    end
    if @battler.status != :NONE
      s = GameData::Status.get(@battler.status).id_number
      if s == :POISON && @battler.statusCount > 0
        s = GameData::Status::DATA.keys.length / 2
      end
      imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,36,
         0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
    end
    pbDrawImagePositions(self.bitmap,imagePos)
    refreshHP
    refreshExp
  end
end