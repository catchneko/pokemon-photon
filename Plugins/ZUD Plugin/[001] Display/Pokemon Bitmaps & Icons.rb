#===============================================================================
# Icon sprites.
#===============================================================================
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :gmax

  def initialize(species,viewport=nil)
    super(viewport)
    @species      = species
    @gender       = 0
    @form         = 0
    @shiny        = 0
    @gmax         = 0
    @numFrames    = 0
    @currentFrame = 0
    @counter      = 0
    refresh
  end
  
  # Gigantamax value for icon sprites.
  def gmax=(value)
    @gmax = value
    refresh
  end
  
  # Set Gigantamax icon sprites with true/false parameters.
  def pbSetParams(species,gender,form,shiny=false,gmax=false)
    @species   = species
    @gender    = gender
    @form      = form
    @shiny     = shiny
    @gmax      = gmax
    refresh
  end
  
  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny, false, false, @gmax)
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width  = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width/@animBitmap.height
    @currentFrame = 0 if @currentFrame>=@numFrames
    changeOrigin
  end
end

#-------------------------------------------------------------------------------
# Enlarges & colors Pokemon icon sprites in the party menu when Dynamaxed.
#-------------------------------------------------------------------------------
class PokemonPartyPanel < SpriteWrapper
  def _ZUD_DynamaxSize
    if Settings::DYNAMAX_SIZE
      largeicons = true if @pokemon.gmax? && Settings::GMAX_XL_ICONS
      if @pokemon.dynamax? && !largeicons
        @pkmnsprite.zoom_x = 1.5 
        @pkmnsprite.zoom_y = 1.5
      else
        @pkmnsprite.zoom_x = 1
        @pkmnsprite.zoom_y = 1
      end
    end
  end
  def _ZUD_DynamaxColor
    if Settings::DYNAMAX_COLOR
      if @pokemon.dynamax?
        alpha_div = (1.0 - self.color.alpha.to_f / 255.0)
        r_base = 217
        g_base = 29
        b_base = 71
        if @pokemon.isSpecies?(:CALYREX)
          r_base = 56
          g_base = 160
          b_base = 193
        end 
        r = (r_base.to_f * alpha_div).floor
        g = (g_base.to_f * alpha_div).floor 
        b = (b_base.to_f * alpha_div).floor 
        a = 128 + self.color.alpha / 2
        @pkmnsprite.color = Color.new(r,g,b,a)
      else
        @pkmnsprite.color = self.color
      end
    end
  end
end

#===============================================================================
# Pokémon sprites. (Out of battle)
#===============================================================================
class PokemonSprite < SpriteWrapper
  def setPokemonBitmap(pokemon,back=false,showDynamax=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0,0,0,0)
    changeOrigin
    if pokemon.dynamax? && showDynamax
      if Settings::DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      end
      if Settings::DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if pokemon.isSpecies?(:CALYREX)
      end
    end
  end

  def setPokemonBitmapSpecies(pokemon,species,back=false,showDynamax=false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
    if pokemon.dynamax? && showDynamax
      if Settings::DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      end
      if Settings::DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if pokemon.isSpecies?(:CALYREX)
      end
    end
  end

  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false, gmax =false, dynamax = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg, gmax)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
    if dynamax
      if Settings::DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      end
      if Settings::DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if species==:CALYREX
      end
    end
  end
end


#===============================================================================
# Pokémon sprites. (In battle)
#===============================================================================
class PokemonBattlerSprite < RPG::Sprite
  def setPokemonBitmap(pkmn,back=false,actual_pkmn=nil)
    @pkmn = pkmn
    @_iconBitmap.dispose if @_iconBitmap
    @_iconBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back, nil, actual_pkmn)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites
    #---------------------------------------------------------------------------
    @dynamax = nil
    if actual_pkmn
      if actual_pkmn.dynamax?
        @dynamax = 0 
        @dynamax = 1 if actual_pkmn.gmaxFactor? && @pkmn.gmax?
      end
    else 
      @dynamax = 0 if @pkmn.dynamax?
      @dynamax = 1 if @pkmn.gmax?
    end
    if @dynamax
      if Settings::DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      end
      if Settings::DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      end
    end
    pbSetPosition
  end
  
  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    if (@index%2)==0
      self.z = 50+5*@index/2
    else
      self.z = 50-5*(@index+1)/2
    end
    p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, false, @dynamax)
  end
  
  def update(frameCounter=0)
    return if !@_iconBitmap
    @updating = true
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    @spriteYExtra = 0
    if @selected==1
      case (frameCounter/QUARTER_ANIM_PERIOD).floor
      when 1; @spriteYExtra = 2
      when 3; @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    #---------------------------------------------------------------------------
    # Enlarges and/or colors Dynamax sprites.
    #---------------------------------------------------------------------------
    if @dynamax
      if Settings::DYNAMAX_SIZE
        self.zoom_x = 1.5
        self.zoom_y = 1.5
      end
      if Settings::DYNAMAX_COLOR
        self.color = Color.new(217,29,71,128)
        self.color = Color.new(56,160,193,128) if @pkmn.isSpecies?(:CALYREX)
      end
    end
    #---------------------------------------------------------------------------
    self.visible = @spriteVisible
    if @selected==2 && @spriteVisible
      case (frameCounter/SIXTH_ANIM_PERIOD).floor
      when 2, 5; self.visible = false
      else;      self.visible = true
      end
    end
    @updating = false
  end
end

class PokeBattle_Scene
  def pbAnimationCore(animation,user,target,oppMove=false)
    return if !animation
    @briefMessage = false
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    #---------------------------------------------------------------------------
    # Used for Enlarged Dynamax sprites.
    #---------------------------------------------------------------------------
    if Settings::DYNAMAX_SIZE
      oldUserZoomX = (userSprite) ? userSprite.zoom_x : 1
      oldUserZoomY = (userSprite) ? userSprite.zoom_y : 1
      oldTargetZoomX = (targetSprite) ? targetSprite.zoom_x : 1
      oldTargetZoomY = (targetSprite) ? targetSprite.zoom_y : 1
    end
    if Settings::DYNAMAX_COLOR
      newcolor  = Color.new(217,29,71,128)
      newcolor2 = Color.new(56,160,193,128) # Calyrex
      oldcolor  = Color.new(0,0,0,0)
      # Colors user's sprite.
      if userSprite && user.dynamax?
        oldUserColor = user.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldUserColor = oldcolor
      end
      # Colors target's sprite.
      if targetSprite && target.dynamax?
        oldTargetColor = target.isSpecies?(:CALYREX) ? newcolor2 : newcolor
      else
        oldTargetColor = oldcolor
      end
    end
    #---------------------------------------------------------------------------
    animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove)
    userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
       PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
       PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
       oldUserX,oldUserY-userHeight/2,
       oldTargetX,oldTargetY-targetHeight/2)
    animPlayer.start
    loop do
      animPlayer.update
      #-------------------------------------------------------------------------
      # Used for Enlarged Dynamax sprites.
      #-------------------------------------------------------------------------
      if Settings::DYNAMAX_SIZE
        userSprite.zoom_x = oldUserZoomX if userSprite
        userSprite.zoom_y = oldUserZoomY if userSprite
        targetSprite.zoom_x = oldTargetZoomX if targetSprite
        targetSprite.zoom_y = oldTargetZoomY if targetSprite
      end
      if Settings::DYNAMAX_COLOR
        userSprite.color = oldUserColor if userSprite
        targetSprite.color = oldTargetColor if targetSprite
      end
      #-------------------------------------------------------------------------
      pbUpdate
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
  end

#-------------------------------------------------------------------------------
# Changes a battler's sprite.
#-------------------------------------------------------------------------------
  def pbChangePokemon(idxBattler,pkmn)
    idxBattler   = idxBattler.index if idxBattler.respond_to?("index")
    battler      = @battle.battlers[idxBattler]
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back         = !@battle.opposes?(idxBattler)
    if !battler.is_a?(PokeBattle_FakeBattler) && battler.effects[PBEffects::Transform]
      pkmn = battler.effects[PBEffects::TransformPokemon]
    end
	if Settings::EBDX_COMPAT
	  pkmnSprite.setPokemonBitmap(pkmn,back,nil,battler)
	  shadowSprite.setPokemonBitmap(pkmn)
      shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
	else
      pkmnSprite.setPokemonBitmap(pkmn,back,battler)
	  shadowSprite.setPokemonBitmap(pkmn)
      shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
	  if !battler.dynamax? && !pbInSafari?
        if Settings::DYNAMAX_SIZE
          pkmnSprite.zoom_x   = 1
          pkmnSprite.zoom_y   = 1
        end
        if Settings::DYNAMAX_COLOR
          pkmnSprite.color = Color.new(0,0,0,0)
        end
      end
	end
  end
  
#-------------------------------------------------------------------------------
# Shrunk text bug fix.
#-------------------------------------------------------------------------------
  alias _ZUD_pbWaitMessage pbWaitMessage
  def pbWaitMessage(*args)
    _ZUD_pbWaitMessage(*args)
    pbSetSystemFont(@sprites["messageWindow"].contents)
  end
end