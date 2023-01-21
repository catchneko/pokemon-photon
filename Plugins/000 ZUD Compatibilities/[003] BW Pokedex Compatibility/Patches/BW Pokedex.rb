#-------------------------------------------------------------------------------
# BW Pokedex compatibility patches.
#-------------------------------------------------------------------------------
if Settings::BW_POKEDEX_COMPAT
  class PokemonPokedexInfo_Scene
    alias bw_pbStartScene pbStartScene
    def pbStartScene(*args)
	  @gmax = false
	  @maxPage = 3
      if Settings::ADV_POKEDEX_COMPAT
	    @maxPage = $game_switches[SWITCH] ? 4 : 3
        @subPage=1
        bw_pbStartScene(*args)
        @sprites["advancedicon"]=PokemonSpeciesIconSprite.new(nil,@viewport)
        @sprites["advancedicon"].setOffset(PictureOrigin::Center)
        @sprites["advancedicon"].x = 82
        @sprites["advancedicon"].y = 328
        @sprites["advancedicon"].visible = false
	  else
	    bw_pbStartScene(*args)
      end
    end
	
	def pbUpdate
	  if @page==2
	    intensity = (Graphics.frame_count%40)*12
	    intensity = 480-intensity if intensity>240
	    @sprites["areahighlight"].opacity = intensity
	  end
	  pbUpdateSpriteHash(@sprites)
	  if Settings::ADV_POKEDEX_COMPAT
	    if Input.trigger?(Input::ACTION)
		  if @page == 4
		    @subPage-=1
		    @subPage=@totalSubPages if @subPage<1
		    displaySubPage
		  end
	    elsif Input.trigger?(Input::USE)
		  if @page == 4 
		    @subPage+=1
		    @subPage=1 if @subPage>@totalSubPages
		    displaySubPage
		  end
	    end
	  end
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
        @sprites["formback"].y = 226
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
  
    def pbGetAvailableForms
      ret = []
      multiple_forms = false
      # Find all genders/forms of @species that have been seen
      GameData::Species.each do |sp|
        next if sp.species != @species
        next if sp.form != 0 && (!sp.real_form_name || sp.real_form_name.empty?)
        next if sp.pokedex_form != sp.form
        multiple_forms = true if sp.form > 0
        case sp.gender_ratio
        when :AlwaysMale, :AlwaysFemale, :Genderless
          real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
          next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          real_gender = 2 if sp.gender_ratio == :Genderless
          ret.push([sp.form_name, real_gender, sp.form])
        else   # Both male and female
          for real_gender in 0...2
            next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
            ret.push([sp.form_name, real_gender, sp.form])
            break if sp.form_name && !sp.form_name.empty?   # Only show 1 entry for each non-0 form
          end
        end
      end
      # Sort all entries
      ret.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
      # Create form names for entries if they don't already exist
      ret.each do |entry|
        if !entry[0] || entry[0].empty?   # Necessarily applies only to form 0
          case entry[1]
          when 0 then entry[0] = _INTL("Male")
          when 1 then entry[0] = _INTL("Female")
          else
            entry[0] = (multiple_forms) ? _INTL("One Form") : _INTL("Genderless")
          end
        end
        entry[1] = 0 if entry[1] == 2   # Genderless entries are treated as male
      end
      #-------------------------------------------------------------------------
      # For G-Max forms.
      #-------------------------------------------------------------------------
      for i in 0...ret.length
        ret[i][3] = false
      end 
      ret2 = []
      species_list = GameData::PowerMove.species_list(2)
      for i in species_list
        sp = GameData::Species.get(i)
        next if sp.id!=@species
        case sp.gender_ratio
        when :AlwaysMale, :AlwaysFemale, :Genderless
          real_gender = (sp.gender_ratio == :AlwaysFemale) ? 1 : 0
          next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
          real_gender = 2 if sp.gender_ratio == :Genderless
          ret2.push([sp.gmax_form_name, real_gender, sp.form, true])
        else
          for real_gender in 0...2
            next if !$Trainer.pokedex.seen_form?(@species, real_gender, sp.form) && !Settings::DEX_SHOWS_ALL_FORMS
            ret2.push([sp.gmax_form_name, real_gender, sp.form, true])
            break if sp.gmax_form_name && !sp.gmax_form_name.empty?
          end
        end
      end
      ret2.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
      ret2.each do |entry|
        entry[1] = 0 if entry[1] == 2
      end
      ret += ret2
      #-------------------------------------------------------------------------
      return ret
    end
	
	alias adv_drawPage drawPage
    def drawPage(page)
      adv_drawPage(page)
	  if Settings::ADV_POKEDEX_COMPAT
		return if @brief
		@sprites["advancedicon"].visible = page==4 if @sprites["advancedicon"]
		if @sprites["advancedicon"] && @sprites["advancedicon"].visible
		  @sprites["advancedicon"].pbSetParams(@species,@gender,@form)
		end
		drawPageAdvanced if page==4
	  end
    end
  
    def drawPageInfo
      @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_info"))
      @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/info_overlay"))
      overlay = @sprites["overlay"].bitmap
      base   = Color.new(82, 82, 90)
      shadow = Color.new(165, 165, 173)
      imagepos = []
      if @brief
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_capture"))
        @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/capture_overlay"))
        @sprites["capturebar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/overlay_info"))
      end
      species_data = GameData::Species.get_species_form(@species, @form)
      indexText = "???"
      if @dexlist[@index][4] > 0
        indexNumber = @dexlist[@index][4]
        indexNumber -= 1 if @dexlist[@index][5]
        indexText = sprintf("%03d", indexNumber)
      end
      if @brief
        textpos = [
           [_INTL("Pokémon Registration Complete"), 82, -2, 0, Color.new(255, 255, 255), Color.new(165, 165, 173)],
           [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
              272, 54, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
           [_INTL("Height"), 288, 170, 0, base, shadow],
           [_INTL("Weight"), 288, 200, 0, base, shadow]
        ]
      else
        textpos = [
           [_INTL("{1}{2} {3}", indexText, " ", species_data.name),
              272, 16, 0, Color.new(82, 82, 90), Color.new(165, 165, 173)],
           [_INTL("Height"), 288, 132, 0, base, shadow],
           [_INTL("Weight"), 288, 162, 0, base, shadow]
        ]
      end
      if $Trainer.owned?(@species)
        if @brief
          textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 90, 2, base, shadow])
        else
          textpos.push([_INTL("{1} Pokémon", species_data.category), 376, 52, 2, base, shadow])
        end
        height = (@gmax) ? species_data.gmax_height : species_data.height
        weight = species_data.weight
        if System.user_language[3..4] == "US"
          inches = (height / 0.254).round
          pounds = (@gmax) ? _INTL("????.? lbs.") : _ISPRINTF("{1:4.1f} lbs.",(weight / 0.45359).round/10.0)
          if @brief
            textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 170, 1, base, shadow])
          else
            textpos.push([_ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12), 490, 132, 1, base, shadow])
          end
          if @brief
            textpos.push([pounds, 490, 200, 1, base, shadow])
          else
            textpos.push([pounds, 490, 162, 1, base, shadow])
          end
        else
          kilograms = (@gmax) ? _INTL("????.? kg") : _ISPRINTF("{1:.1f} kg", weight / 10.0)
          if @brief
            textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 170, 1, base, shadow])
          else
            textpos.push([_ISPRINTF("{1:.1f} m", height / 10.0), 490, 132, 1, base, shadow])
          end
          if @brief
            textpos.push([kilograms, 490, 200, 1, base, shadow])
          else
            textpos.push([kilograms, 490, 162, 1, base, shadow])
          end
        end
        base   = Color.new(255,255,255)
        shadow = Color.new(165,165,173)
		dexentry = (@gmax) ? species_data.gmax_dex_entry : species_data.pokedex_entry
        if @brief
          drawTextEx(overlay, 38, 258, Graphics.width - (40 * 2), 4, dexentry, base, shadow)
        else
          drawTextEx(overlay, 38, 220, Graphics.width - (40 * 2), 4, dexentry, base, shadow)		 
        end
        footprintfile = GameData::Species.footprint_filename(@species, @form, @gmax)
        if footprintfile
          footprint = RPG::Cache.load_bitmap("",footprintfile)
          if @brief
            overlay.blt(224, 150, footprint, footprint.rect)
          else
            overlay.blt(224, 112, footprint, footprint.rect)
          end
          footprint.dispose
        end
        if @brief
          imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 210, 57])
        else
          imagepos.push(["Graphics/Pictures/Pokedex/icon_own", 210, 19])
        end
        type1 = species_data.type1
        type2 = species_data.type2
        type1_number = GameData::Type.get(type1).id_number
        type2_number = GameData::Type.get(type2).id_number
        type1rect = Rect.new(0, type1_number * 32, 96, 32)
        type2rect = Rect.new(0, type2_number * 32, 96, 32)
        if @brief
          overlay.blt(286, 132, @typebitmap.bitmap, type1rect)
          overlay.blt(366, 132, @typebitmap.bitmap, type2rect) if type1 != type2
        else
          overlay.blt(286, 94, @typebitmap.bitmap, type1rect)
          overlay.blt(366, 94, @typebitmap.bitmap, type2rect) if type1 != type2
        end
      else
        textpos.push([_INTL("????? Pokémon"), 274, 50, 0, base, shadow])
        if System.user_language[3..4] == "US"
          textpos.push([_INTL("???'??\""), 490, 136, 1, base, shadow])
          textpos.push([_INTL("????.? lbs."), 488, 170, 1, base, shadow])
        else
          textpos.push([_INTL("????.? m"), 488, 132, 1, base, shadow])
          textpos.push([_INTL("????.? kg"), 488, 162, 1, base, shadow])
        end
      end
      pbDrawTextPositions(overlay, textpos)
      pbDrawImagePositions(overlay, imagepos)
    end
  
  
    def drawPageForms
      @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_forms"))
      @sprites["infoverlay"].setBitmap(_INTL("Graphics/Pictures/Pokedex/forms_overlay"))
      overlay = @sprites["overlay"].bitmap
      base   = Color.new(255,255,255)
      shadow = Color.new(165,165,173)
      formname = ""
      for i in @available
        if i[1]==@gender && i[2]==@form && i[3]==@gmax
          formname = i[0]; break
        end
      end
      textpos = [
         [_INTL("Forms"),58,0,0,Color.new(255,255,255),Color.new(115,115,115)],
         [GameData::Species.get(@species).name,Graphics.width/2,Graphics.height-316,2,base,shadow],
         [formname,Graphics.width/2,Graphics.height-280,2,base,shadow],
      ]
      pbDrawTextPositions(overlay,textpos)
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
          if @page==2   # Area
  #          dorefresh = true
          elsif @page==3   # Forms
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
end