#===============================================================================
# Adds Dynamax debug tools to the Level/Stats menu.
#===============================================================================
PokemonDebugMenuCommands.register("dynamax", {
  "parent"      => "levelstats",
  "name"        => _INTL("Dynamax..."),
  "always_show" => defined?(Settings::ZUD_COMPAT),
  "effect"      => proc { |pkmn, pkmnid, heldpoke, settingUpBattle, screen|
    if !pkmn.egg? && !pkmn.shadowPokemon? && (pkmn.dynamaxAble? || pkmn.isSpecies?(:ETERNATUS))
      cmd = 0
      loop do
        dlvl = pkmn.dynamax_lvl
        gmax = (pkmn.gmaxFactor?) ? "Yes" : "No" 
        dmax = (pkmn.dynamax?)    ? "Yes" : "No"
        cmd = screen.pbShowCommands(_INTL("Dynamax Level: {1}\nG-Max Factor: {2}\nDynamaxed: {3}",dlvl,gmax,dmax),[
             _INTL("Set Dynamax Level"),
             _INTL("Set G-Max Factor"),
             _INTL("Set Dynamax"),
             _INTL("Reset All")],cmd)
        break if cmd<0
        case cmd
        when 0   # Set Dynamax Level
          params = ChooseNumberParams.new
          params.setRange(0,10)
          params.setDefaultValue(pkmn.dynamax_lvl)
          params.setCancelValue(pkmn.dynamax_lvl)
          f = pbMessageChooseNumber(
            _INTL("Set {1}'s Dynamax level (max. 10).",pkmn.name),params) { screen.pbUpdate }
          if f!=pkmn.dynamax_lvl
            pkmn.dynamax_lvl = f
            pkmn.calc_stats
            screen.pbRefreshSingle(pkmnid)
          end
        when 1   # Set G-Max Factor
          if pkmn.gmaxFactor?
            pkmn.removeGMaxFactor
			if pkmn.isSpecies?(:ETERNATUS) && pkmn.dynamax?
			  pkmn.makeUndynamax
			  pkmn.calc_stats
              pkmn.pbReversion
			end
            screen.pbDisplay(_INTL("Gigantamax factor was removed from {1}.",pkmn.name))
          else
            if pkmn.hasGmax? || pkmn.isSpecies?(:ETERNATUS)
              pkmn.giveGMaxFactor
              screen.pbDisplay(_INTL("Gigantamax factor was given to {1}.",pkmn.name))
            else
              if pbConfirmMessage(_INTL("{1} doesn't have a Gigantamax form.\nGive it Gigantamax factor anyway?",pkmn.name))
                pkmn.giveGMaxFactor
                screen.pbDisplay(_INTL("Gigantamax factor was given to {1}.",pkmn.name))
              end
            end
          end
          screen.pbRefreshSingle(pkmnid)
        when 2   # Set Dynamax
          if pkmn.dynamax?
            pkmn.makeUndynamax
            pkmn.calc_stats
            pkmn.pbReversion
            screen.pbDisplay(_INTL("{1} is no longer dynamaxed.",pkmn.name))
          elsif pkmn.isSpecies?(:ETERNATUS) && !pkmn.gmaxFactor?
			screen.pbDisplay(_INTL("{1} can only be in Eternamax form, which requires G-Max Factor.",pkmn.name))
		  else
            pkmn.makeDynamax
            pkmn.calc_stats
            pkmn.pbReversion(true)
            screen.pbDisplay(_INTL("{1} is dynamaxed.",pkmn.name))
          end
          screen.pbRefreshSingle(pkmnid)
        when 3   # Reset All
          pkmn.setDynamaxLvl(0)
          pkmn.removeGMaxFactor
          if pkmn.dynamax?
            pkmn.makeUndynamax
            pkmn.calc_stats
            pkmn.pbReversion
          end
          screen.pbDisplay(_INTL("All dynamax settings restored to default."))
          screen.pbRefreshSingle(pkmnid)
        end
      end
    else
      screen.pbDisplay(_INTL("Can't edit Dynamax values on that Pokémon."))
      pkmn.dynamax_lvl = 0
      pkmn.gmaxfactor = false
      if pkmn.dynamax?
        pkmn.makeUndynamax
        pkmn.calc_stats
        pkmn.pbReversion
      end
    end
    next false
  }
})

#===============================================================================
# NPC Trainer editor.
#===============================================================================
module TrainerPokemonProperty
  def self.set(settingname,initsetting)
    initsetting = {:species => nil, :level => 10} if !initsetting
    oldsetting = [
      initsetting[:species],
      initsetting[:level],
      initsetting[:name],
      initsetting[:form],
      initsetting[:gender],
      initsetting[:shininess],
      initsetting[:shadowness]
    ]
    Pokemon::MAX_MOVES.times do |i|
      oldsetting.push((initsetting[:moves]) ? initsetting[:moves][i] : nil)
    end
    oldsetting.concat([
      initsetting[:ability],
      initsetting[:ability_index],
      initsetting[:item],
      initsetting[:nature],
      initsetting[:iv],
      initsetting[:ev],
      initsetting[:happiness],
      initsetting[:poke_ball],
      #-------------------------------------------------------------------------
      # Dynamax values.
      #-------------------------------------------------------------------------
      initsetting[:dynamax_lvl],
      initsetting[:gmaxfactor],
      initsetting[:acepkmn]
    ])
    max_level = GameData::GrowthRate.max_level
    pkmn_properties = [
       [_INTL("Species"),       SpeciesProperty,                         _INTL("Species of the Pokémon.")],
       [_INTL("Level"),         NonzeroLimitProperty.new(max_level),     _INTL("Level of the Pokémon (1-{1}).", max_level)],
       [_INTL("Name"),          StringProperty,                          _INTL("Name of the Pokémon.")],
       [_INTL("Form"),          LimitProperty2.new(999),                 _INTL("Form of the Pokémon.")],
       [_INTL("Gender"),        GenderProperty,                          _INTL("Gender of the Pokémon.")],
       [_INTL("Shiny"),         BooleanProperty2,                        _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Shadow"),        BooleanProperty2,                        _INTL("If set to true, the Pokémon is a Shadow Pokémon.")]
    ]
    Pokemon::MAX_MOVES.times do |i|
      pkmn_properties.push([_INTL("Move {1}", i + 1),
         MovePropertyForSpecies.new(oldsetting), _INTL("A move known by the Pokémon. Leave all moves blank (use Z key to delete) for a wild moveset.")])
    end
    pkmn_properties.concat([
       [_INTL("Ability"),       AbilityProperty,                         _INTL("Ability of the Pokémon. Overrides the ability index.")],
       [_INTL("Ability index"), LimitProperty2.new(99),                  _INTL("Ability index. 0=first ability, 1=second ability, 2+=hidden ability.")],
       [_INTL("Held item"),     ItemProperty,                            _INTL("Item held by the Pokémon.")],
       [_INTL("Nature"),        GameDataProperty.new(:Nature),           _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),           IVsProperty.new(Pokemon::IV_STAT_LIMIT), _INTL("Individual values for each of the Pokémon's stats.")],
       [_INTL("EVs"),           EVsProperty.new(Pokemon::EV_STAT_LIMIT), _INTL("Effort values for each of the Pokémon's stats.")],
       [_INTL("Happiness"),     LimitProperty2.new(255),                 _INTL("Happiness of the Pokémon (0-255).")],
       [_INTL("Poké Ball"),     BallProperty.new(oldsetting),            _INTL("The kind of Poké Ball the Pokémon is kept in.")],
	   #------------------------------------------------------------------------
       # Dynamax values.
       #------------------------------------------------------------------------
       [_INTL("Dynamax Lvl"),  LimitProperty2.new(10),               _INTL("The Dynamax level of the Pokémon (0-10).")],
       [_INTL("G-Max Factor"), BooleanProperty2,                     _INTL("If set to true, the Pokémon has G-Max Factor.")],
       [_INTL("Trainer Ace"),  BooleanProperty2,                     _INTL("If set to true, the trainer will save Dynamax for this Pokémon.")]
    ])
    pbPropertyList(settingname, oldsetting, pkmn_properties, false)
    return nil if !oldsetting[0]   # Species is nil
    ret = {
      :species       => oldsetting[0],
      :level         => oldsetting[1],
      :name          => oldsetting[2],
      :form          => oldsetting[3],
      :gender        => oldsetting[4],
      :shininess     => oldsetting[5],
      :shadowness    => oldsetting[6],
      :ability       => oldsetting[7 + Pokemon::MAX_MOVES],
      :ability_index => oldsetting[8 + Pokemon::MAX_MOVES],
      :item          => oldsetting[9 + Pokemon::MAX_MOVES],
      :nature        => oldsetting[10 + Pokemon::MAX_MOVES],
      :iv            => oldsetting[11 + Pokemon::MAX_MOVES],
      :ev            => oldsetting[12 + Pokemon::MAX_MOVES],
      :happiness     => oldsetting[13 + Pokemon::MAX_MOVES],
      :poke_ball     => oldsetting[14 + Pokemon::MAX_MOVES],
	  #-------------------------------------------------------------------------
      # Dynamax values.
      #-------------------------------------------------------------------------
      :dynamax_lvl   => oldsetting[15 + Pokemon::MAX_MOVES],
      :gmaxfactor    => oldsetting[16 + Pokemon::MAX_MOVES],
      :acepkmn       => oldsetting[17 + Pokemon::MAX_MOVES]
    }
    moves = []
    Pokemon::MAX_MOVES.times do |i|
      moves.push(oldsetting[7 + i])
    end
    moves.uniq!
    moves.compact!
    ret[:moves] = moves
    return ret
  end
end

#===============================================================================
# Sprite Position editor.
#===============================================================================
class SpritePositioner
  alias _ZUD_pbOpen pbOpen
  def pbOpen
    @gmax    = false
    @dynamax = (Input.press?(Input::CTRL)) ? true : false
    @metrics = []
    _ZUD_pbOpen
  end
  
  def pbSaveMetrics
    GameData::Species.save
    if @dynamax
      Compiler.write_ZUD_Metrics
    else
      Compiler.write_pokemon
      Compiler.write_pokemon_forms
    end
  end
  
  def pbGetMetricsFromSpecies(species)
    if @dynamax
      ret = (@gmax) ? species.gmax_metrics : species.dmax_metrics
    else
      ret = [species.back_sprite_x, species.back_sprite_y, species.front_sprite_x, species.front_sprite_y,
             species.front_sprite_altitude, species.shadow_x, species.shadow_size]
    end
    return ret
  end
  
  def pbApplyMetricsToSpecies(species)
    if @dynamax
      species.gmax_metrics = @metrics if @gmax
      species.dmax_metrics = @metrics if !@gmax
    else
      species.back_sprite_x         = @metrics[0]
      species.back_sprite_y         = @metrics[1]
      species.front_sprite_x        = @metrics[2]
      species.front_sprite_y        = @metrics[3]
      species.front_sprite_altitude = @metrics[4]
      species.shadow_x              = @metrics[5]
      species.shadow_size           = @metrics[6]
    end
  end
              
  def refresh
    if !@species
      @sprites["pokemon_0"].visible = false
      @sprites["pokemon_1"].visible = false
      @sprites["shadow_1"].visible = false
      return
    end
    species_data = GameData::Species.get(@species)
    mode = nil
    mode = 0 if @dynamax
    mode = 1 if @gmax
    pbApplyMetricsToSpecies(species_data)
    for i in 0...2
      pos = PokeBattle_SceneConstants.pbBattlerPosition(i, 1)
      @sprites["pokemon_#{i}"].x = pos[0]
      @sprites["pokemon_#{i}"].y = pos[1]
      species_data.apply_metrics_to_sprite(@sprites["pokemon_#{i}"], i, false, mode)
      @sprites["pokemon_#{i}"].visible = true
      if i == 1
        @sprites["shadow_1"].x = pos[0]
        @sprites["shadow_1"].y = pos[1]
        if @sprites["shadow_1"].bitmap
          @sprites["shadow_1"].x -= @sprites["shadow_1"].bitmap.width / 2
          @sprites["shadow_1"].y -= @sprites["shadow_1"].bitmap.height / 2
        end
        species_data.apply_metrics_to_sprite(@sprites["shadow_1"], i, true, mode)
        @sprites["shadow_1"].visible = true
      end
    end
  end

  def pbAutoPosition
    species_data = GameData::Species.get(@species)
    old_back_y         = @metrics[1]
    old_front_y        = @metrics[3]
    old_front_altitude = @metrics[4]
    bitmap1 = @sprites["pokemon_0"].bitmap
    bitmap2 = @sprites["pokemon_1"].bitmap
    if defined?(EBDXBitmapWrapper) && !defined?(EliteBattle)
      bottom = findBottom(bitmap1)
      top = findTop(bitmap1)
      actual_height = bottom - top
      value = actual_height < (bitmap1.height/2) ? 5 : 3
      new_back_y = (bitmap1.height - bottom + (bottom/value) + 1)/2
    else
      new_back_y  = (bitmap1.height - (findBottom(bitmap1) + 1)) / 2
    end
    new_front_y = (bitmap2.height - (findBottom(bitmap2) + 1)) / 2
    new_front_y += 4
    if new_back_y != old_back_y || new_front_y != old_front_y || old_front_altitude != 0
      @metrics[1] = new_back_y
      @metrics[3] = new_front_y
      @metrics[4] = 0
      @metricsChanged = true
      refresh
    end
  end

  def pbChangeSpecies(species, gmax)
    @species = species
    @gmax    = gmax
    species_data = GameData::Species.try_get(@species)
    return if !species_data
    @metrics = pbGetMetricsFromSpecies(species_data)
    spe = species_data.species
    frm = species_data.form
    @sprites["pokemon_0"].setSpeciesBitmap(spe, 0, frm, false, false, true, false, @gmax, @dynamax)
    @sprites["pokemon_1"].setSpeciesBitmap(spe, 0, frm, false, false, false, false, @gmax, @dynamax)
    @sprites["shadow_1"].setBitmap(GameData::Species.shadow_filename(spe, frm, @dynamax))
  end

  def pbShadowSize
    pbChangeSpecies(@species, @gmax)
    refresh
    species_data = GameData::Species.get(@species)
    if @dynamax
      pbMessage("Dynamax Pokémon have their own shadow sprite. The shadow size metric cannot be edited.")
      return false
    elsif pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s_%d", species_data.species, species_data.form)) ||
          pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s", species_data.species))
      pbMessage("This species has its own shadow sprite in Graphics/Pokemon/Shadow/. The shadow size metric cannot be edited.")
      return false
    end
    oldval = @metrics[6]
    cmdvals = [0]
    commands = [_INTL("None")]
    defindex = 0
    i = 0
    loop do
      i += 1
      fn = sprintf("Graphics/Pokemon/Shadow/%d", i)
      break if !pbResolveBitmap(fn)
      cmdvals.push(i)
      commands.push(i.to_s)
      defindex = cmdvals.length - 1 if oldval == i
    end
    cw = Window_CommandPokemon.new(commands)
    cw.index    = defindex
    cw.viewport = @viewport
    ret = false
    oldindex = cw.index
    loop do
      Graphics.update
      Input.update
      cw.update
      self.update
      if cw.index != oldindex
        oldindex = cw.index
        @metrics[6] = cmdvals[cw.index]
        pbApplyMetricsToSpecies(species_data)
        pbChangeSpecies(@species, @gmax)
        refresh
      end
      if Input.trigger?(Input::ACTION)   # Cycle to next option
        pbPlayDecisionSE
        @metricsChanged = true if @metrics[6] != oldval
        ret = true
        break
      elsif Input.trigger?(Input::BACK)
        @metrics[6] = oldval
        pbApplyMetricsToSpecies(species_data)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    cw.dispose
    return ret
  end
  
  def pbSetParameter(param)
    return if !@species
    return pbShadowSize if param == 2
    if param == 4
      pbAutoPosition
      return false
    end
    species_data = GameData::Species.get(@species)
    case param
    when 0
      sprite = @sprites["pokemon_0"]
      xpos = @metrics[0]
      ypos = @metrics[1]
    when 1
      sprite = @sprites["pokemon_1"]
      xpos = @metrics[2]
      ypos = @metrics[3]
    when 3
      sprite = @sprites["shadow_1"]
      xpos = @metrics[5]
      ypos = 0
    end
    oldxpos = xpos
    oldypos = ypos
    @sprites["info"].visible = true
    ret = false
    loop do
      sprite.visible = (Graphics.frame_count % 16) < 12   # Flash the selected sprite
      Graphics.update
      Input.update
      self.update
      case param
      when 0 then @sprites["info"].setTextToFit("Ally Position = #{xpos},#{ypos}")
      when 1 then @sprites["info"].setTextToFit("Enemy Position = #{xpos},#{ypos}")
      when 3 then @sprites["info"].setTextToFit("Shadow Position = #{xpos}")
      end
      if (Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)) && param != 3
        ypos += (Input.repeat?(Input::DOWN)) ? 1 : -1
        case param
        when 0 then @metrics[1] = ypos
        when 1 then @metrics[3] = ypos
        end
        refresh
      end
      if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
        xpos += (Input.repeat?(Input::RIGHT)) ? 1 : -1
        case param
        when 0 then @metrics[0] = xpos
        when 1 then @metrics[2] = xpos
        when 3 then @metrics[5] = xpos
        end
        refresh
      end
      if Input.repeat?(Input::ACTION) && param != 3   # Cycle to next option
        @metricsChanged = true if xpos != oldxpos || ypos != oldypos
        ret = true
        pbPlayDecisionSE
        break
      elsif Input.repeat?(Input::BACK)
        case param
        when 0
          @metrics[0] = oldxpos
          @metrics[1] = oldypos
        when 1
          @metrics[2] = oldxpos
          @metrics[3] = oldypos
        when 3
          @metrics[5] = oldxpos
        end
        pbPlayCancelSE
        refresh
        break
      elsif Input.repeat?(Input::USE)
        @metricsChanged = true if xpos != oldxpos || (param != 3 && ypos != oldypos)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["info"].visible = false
    sprite.visible = true
    return ret
  end

  def pbMenu(species, gmax)
    pbChangeSpecies(species, gmax)
    refresh
    cw = Window_CommandPokemon.new([
       _INTL("Set Ally Position"),
       _INTL("Set Enemy Position"),
       _INTL("Set Shadow Size"),
       _INTL("Set Shadow Position"),
       _INTL("Auto-Position Sprites")
    ])
    cw.x        = Graphics.width - cw.width
    cw.y        = Graphics.height - cw.height
    cw.viewport = @viewport
    ret = -1
    loop do
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cw.index
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        break
      end
    end
    cw.dispose
    return ret
  end

  def pbChooseSpecies
    if @starting
      pbFadeInAndShow(@sprites) { update }
      @starting = false
    end
    cw = Window_CommandPokemonEx.newEmpty(0, 0, 260, 32 + 24 * 6, @viewport)
    cw.rowHeight = 24
    pbSetSmallFont(cw.contents)
    cw.x = Graphics.width - cw.width
    cw.y = Graphics.height - cw.height
    allspecies = []
    GameData::Species.each do |sp|
      name = (sp.form == 0) ? sp.name : _INTL("{1} (form {2})", sp.real_name, sp.form)
      allspecies.push([sp.id, sp.species, name]) if name && !name.empty?
      if @dynamax && sp.hasGmax? && !(sp.id==:ALCREMIE && sp.form>0)
        name = _INTL("{1} (G-Max)", sp.real_name)
        allspecies.push([sp.id, sp.species, name]) if name && !name.empty?
      end
    end
    allspecies.sort! { |a, b| a[2] <=> b[2] }
    commands = []
    allspecies.each { |sp| commands.push(sp[2]) }
    cw.commands = commands
    cw.index    = @oldSpeciesIndex
    ret = nil
    oldindex = -1
    gmax = false
    loop do
      Graphics.update
      Input.update
      cw.update
      if cw.index != oldindex
        oldindex = cw.index
        gmax = allspecies[cw.index][2].include?("(G-Max)") ? true : false
        pbChangeSpecies(allspecies[cw.index][0], gmax)
        refresh
      end
      self.update
      if Input.trigger?(Input::BACK)
        pbChangeSpecies(nil, gmax)
        refresh
        break
      elsif Input.trigger?(Input::USE)
        pbChangeSpecies(allspecies[cw.index][0], gmax)
        ret = [allspecies[cw.index][0], gmax]
        break
      end
    end
    @oldSpeciesIndex = cw.index
    cw.dispose
    return ret
  end
end

class SpritePositionerScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStart
    @scene.pbOpen
    loop do
      species = @scene.pbChooseSpecies
      break if !species
      loop do
        command = @scene.pbMenu(species[0],species[1])
        break if command < 0
        loop do
          par = @scene.pbSetParameter(command)
          break if !par
          command = (command + 1) % 3
        end
      end
    end
    @scene.pbClose
  end
end

#-------------------------------------------------------------------------------
# Automatically positions G-Max sprites.
#-------------------------------------------------------------------------------
def pbAutoPositionDynamax
  species_list = GameData::PowerMove.species_list(2)
  for i in species_list
    next if !GameData::Species.try_get(i)
    sp = GameData::Species.get(i)
    Graphics.update if sp.id_number % 50 == 0
    bitmap1 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, true, false, true)
    bitmap2 = GameData::Species.sprite_bitmap(sp.species, sp.form, nil, nil, nil, false, false, true)
    if bitmap1 && bitmap1.bitmap
      sp.gmax_metrics[0] = 0
      sp.gmax_metrics[1] = (bitmap1.height - (findBottom(bitmap1.bitmap) + 1)) / 2
      sp.gmax_metrics[1] += 45
    end
    if bitmap2 && bitmap2.bitmap
      sp.gmax_metrics[2] = 0
      sp.gmax_metrics[3] = (bitmap2.height - (findBottom(bitmap2.bitmap) + 1)) / 2
      sp.gmax_metrics[3] += 4
    end
    sp.gmax_metrics[4]   = 0
    sp.gmax_metrics[5]   = 0
    sp.gmax_metrics[6]   = 3
    bitmap1.dispose if bitmap1
    bitmap2.dispose if bitmap2
  end
  GameData::Species.each do |sp|
    sp.dmax_metrics = [sp.back_sprite_x, sp.back_sprite_y,
                       sp.front_sprite_x, sp.front_sprite_y+8,
                       sp.front_sprite_altitude, sp.shadow_x, 3]
  end
  GameData::Species.save
  Compiler.write_ZUD_Metrics
end