#===============================================================================
# Summary display.
#===============================================================================
class PokemonSummary_Scene
  #-----------------------------------------------------------------------------
  # Displays G-Max Factor & Dynamax meter in the Summary screen.
  # Must be added to def drawPage.
  #-----------------------------------------------------------------------------
  def _ZUD_SummaryImages(textToHide=nil,line=nil)
    if @pokemon.dynamaxAble?
      overlay = @sprites["overlay"].bitmap
      imagepos=[]
      imagepos.push(["Graphics/Pictures/Dynamax/gfactor",88,95,0,0,-1,-1]) if @pokemon.gmaxFactor?
      imagepos.push(["Graphics/Pictures/Dynamax/dynamax_meter",56,308,0,0,-1,-1]) if @page==3
      pbDrawImagePositions(overlay,imagepos)
      if @page==3
	      textToHide[line][0] = "" if textToHide && line
        dlevel = @pokemon.dynamax_lvl
        levels = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/dynamax_levels"))
        overlay.blt(69,325,levels.bitmap,Rect.new(0,0,dlevel*12,21))
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Displays Max Move names and type in the Summary screen.
  # Must be added to def drawPageFourSelecting and def drawSelectedMove.
  #-----------------------------------------------------------------------------
  def _ZUD_DrawMoveSel(move)
    flex_dmg = "???"
    if @pokemon.dynamax? && @pokemon.compat_maxmove?(move)
      id = @pokemon.get_maxmove(move, move.category)
      flex_dmg = pbMaxMoveBaseDamage(move.id, Pokemon::Move.new(id).id)
      move = Pokemon::Move.new(id)
    end
    return [move, flex_dmg]
  end
end


#===============================================================================
# Pokedex display.
#===============================================================================
class PokemonPokedexInfo_Scene
  alias _ZUD_pbStartScene pbStartScene
  def pbStartScene(*args)
    @gmax = false
	@maxPage = 3
    if Settings::ADV_POKEDEX_COMPAT
	  @maxPage = $game_switches[SWITCH] ? 4 : 3
      @subPage=1
      _ZUD_pbStartScene(*args)
      @sprites["advancedicon"]=PokemonSpeciesIconSprite.new(nil,@viewport)
      @sprites["advancedicon"].setOffset(PictureOrigin::Center)
      @sprites["advancedicon"].x = 82
      @sprites["advancedicon"].y = 328
      @sprites["advancedicon"].visible = false
	else
	  _ZUD_pbStartScene(*args)
    end
  end 
  
  #-----------------------------------------------------------------------------
  # Sets up G-Max forms to appear in the Pokedex.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbGetAvailableForms pbGetAvailableForms
  def pbGetAvailableForms
    available = _ZUD_pbGetAvailableForms
    for i in 0...available.length
      available[i][3] = false
    end 
    ret = []
    species_list = GameData::PowerMove.species_list(2)
    for i in species_list
      sp = GameData::Species.get(i)
      next if sp.id!=@species
      case sp.gender_ratio
      when :AlwaysMale, :AlwaysFemale, :Genderless
        real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
        next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
        real_gender = 2 if sp.gender_ratio == :Genderless
        ret.push([sp.gmax_form_name, real_gender, sp.form, true])
      else
        for real_gender in 0...2
          next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          ret.push([sp.gmax_form_name, real_gender, sp.form, true])
          break if sp.gmax_form_name && !sp.gmax_form_name.empty?
        end
      end
    end
    ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
    ret.each do |entry|
      entry[1] = 0 if entry[1] == 2
    end
    available += ret
    return available
  end
  
  def pbChooseForm
    index = 0
    for i in 0...@available.length
      if @available[i][1]==@gender && @available[i][2]==@form
        index = i
        break
      end
    end
    oldindex = -1
    loop do
      if oldindex!=index
        $Trainer.pokedex.set_last_form_seen(@species, @available[index][1], @available[index][2], @available[index][3])
        pbUpdateDummyPokemon
        drawPage(@page)
        @sprites["uparrow"].visible   = (index>0)
        @sprites["downarrow"].visible = (index<@available.length-1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index+@available.length-1)%@available.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index+1)%@available.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
  end
  
  def pbUpdateDummyPokemon
    @species = @dexlist[@index][0]
    @gender, @form, @gmax = $Trainer.pokedex.last_form_seen(@species)
    species_data = GameData::Species.get_species_form(@species, @form)
    @sprites["infosprite"].setSpeciesBitmap(@species, @gender, @form, false, false, false, false, @gmax)
    if @sprites["formfront"]
      @sprites["formfront"].setSpeciesBitmap(@species, @gender, @form, false, false, false, false, @gmax)
    end
    if @sprites["formback"]
      @sprites["formback"].setSpeciesBitmap(@species, @gender, @form, false, false, true, false, @gmax)
      @sprites["formback"].y = 256
      @sprites["formback"].y += species_data.back_sprite_y * 2
    end
    if @sprites["formicon"]
      @sprites["formicon"].pbSetParams(@species, @gender, @form, false, @gmax)
    end
	# Compatibility with the Gen 8 Project
    if Settings::GEN8_COMPAT && !defined?(EliteBattle)
      @sprites["infosprite"].constrict(208)
      @sprites["formfront"].constrict(200) if @sprites["formfront"]
      if @sprites["formback"]
        @sprites["formback"].constrict(400)
        @sprites["formback"].setOffset(PictureOrigin::Center)
        @sprites["formback"].y = @sprites["formfront"].y if @sprites["formfront"]
        if Settings::BACK_BATTLER_SPRITE_SCALE > Settings::FRONT_BATTLER_SPRITE_SCALE
          @sprites["formback"].zoom_x = ((Settings::FRONT_BATTLER_SPRITE_SCALE * 1.0)/Settings::BACK_BATTLER_SPRITE_SCALE)
          @sprites["formback"].zoom_y = ((Settings::FRONT_BATTLER_SPRITE_SCALE * 1.0)/Settings::BACK_BATTLER_SPRITE_SCALE)
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws G-Max info in the Pokedex.
  #-----------------------------------------------------------------------------
  def drawPageForms
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    formname = ""
    for i in @available
      if i[1]==@gender && i[2]==@form && i[3]==@gmax
        formname = i[0]; break
      end
    end
    textpos = [
       [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-94,2,base,shadow],
       [formname,Graphics.width/2,Graphics.height-62,2,base,shadow],
    ]
    pbDrawTextPositions(overlay,textpos)
  end

  def drawPageInfo
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    imagepos = []
    if @brief
      imagepos.push([_INTL("Graphics/Pictures/Pokedex/overlay_info"), 0, 0])
    end
    species_data = GameData::Species.get_species_form(@species, @form)
    indexText = "???"
    if @dexlist[@index][4] > 0
      indexNumber = @dexlist[@index][4]
      indexNumber -= 1 if @dexlist[@index][5]
      indexText = sprintf("%03d", indexNumber)
    end
    textpos = [
       [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
          246, 36, 0, Color.new(248, 248, 248), Color.new(0, 0, 0)],
       [_INTL("Height"), 314, 152, 0, base, shadow],
       [_INTL("Weight"), 314, 184, 0, base, shadow]
    ]
    if $Trainer.owned?(@species)
      textpos.push([_INTL("{1} Pokémon", species_data.category), 246, 68, 0, base, shadow])
      height = (@gmax) ? species_data.gmax_height : species_data.height
      weight = species_data.weight
      if System.user_language[3..4] == "US"
        inches = (height / 0.254).round
        pounds = (@gmax) ? _INTL("????.? lbs.") : _ISPRINTF("{1:4.1f} lbs.",(weight / 0.45359).round/10.0)
        textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 460, 152, 1, base, shadow])
        textpos.push([pounds, 494, 184, 1, base, shadow])
      else
        kilograms = (@gmax) ? _INTL("????.? kg") : _ISPRINTF("{1:.1f} kg", weight / 10.0)
        textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 470, 152, 1, base, shadow])
        textpos.push([kilograms, 482, 184, 1, base, shadow])
      end
      dexentry = (@gmax) ? species_data.gmax_dex_entry : species_data.pokedex_entry
      drawTextEx(overlay, 40, 244, Graphics.width - (40 * 2), 4, dexentry, base, shadow)
      footprintfile = GameData::Species.footprint_filename(@species, @form, @gmax)
      if footprintfile
        footprint = RPG::Cache.load_bitmap("",footprintfile)
        overlay.blt(226, 138, footprint, footprint.rect)
        footprint.dispose
      end
      imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 212, 44])
      type1 = species_data.type1
      type2 = species_data.type2
      type1_number = GameData::Type.get(type1).id_number
      type2_number = GameData::Type.get(type2).id_number
      type1rect = Rect.new(0, type1_number * 32, 96, 32)
      type2rect = Rect.new(0, type2_number * 32, 96, 32)
      overlay.blt(296, 120, @typebitmap.bitmap, type1rect)
      overlay.blt(396, 120, @typebitmap.bitmap, type2rect) if type1 != type2
    else
      textpos.push([_INTL("????? Pokémon"), 246, 68, 0, base, shadow])
      if System.user_language[3..4] == "US"
        textpos.push([_INTL("???'??\""), 460, 152, 1, base, shadow])
        textpos.push([_INTL("????.? lbs."), 494, 184, 1, base, shadow])
      else
        textpos.push([_INTL("????.? m"), 470, 152, 1, base, shadow])
        textpos.push([_INTL("????.? kg"), 482, 184, 1, base, shadow])
      end
    end
    pbDrawTextPositions(overlay, textpos)
    pbDrawImagePositions(overlay, imagepos)
  end

  #-----------------------------------------------------------------------------
  # Plays Dynamax cries of species while viewing info pages.
  #-----------------------------------------------------------------------------
  def pbScene
    volume, pitch = 90, 100
    volume, pitch = 100, 60 if @gmax
    Pokemon.play_cry(@species, @form, volume, pitch)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        volume, pitch = 90, 100
        volume, pitch = 100, 60 if @gmax
        Pokemon.play_cry(@species, @form, volume, pitch) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page==2
        elsif @page==3
          if @available.length>1
            pbPlayDecisionSE
            pbChooseForm
            dorefresh = true
          end
        end
      elsif Input.trigger?(Input::UP)
        oldindex = @index
        pbGoToPrevious
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          volume, pitch = 90, 100
          volume, pitch = 100, 60 if @gmax
          (@page==1) ? Pokemon.play_cry(@species, @form, volume, pitch) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN)
        oldindex = @index
        pbGoToNext
        if @index!=oldindex
          pbUpdateDummyPokemon
          @available = pbGetAvailableForms
          pbSEStop
          volume, pitch = 90, 100
          volume, pitch = 100, 60 if @gmax
          (@page==1) ? Pokemon.play_cry(@species, @form, volume, pitch) : pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT)
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = @maxPage if @page>@maxPage
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT)
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = @maxPage if @page>@maxPage
        if @page!=oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @index
  end
  
  def pbSceneBrief
    volume, pitch = 90, 100
    volume, pitch = 100, 60 if @gmax
    Pokemon.play_cry(@species, @form, volume, pitch)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form, volume, pitch)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
  end
end