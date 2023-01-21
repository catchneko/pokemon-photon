#===============================================================================
# Max Raid Den.
#===============================================================================
class MaxRaidScene
  BASE   = Color.new(248,248,248)
  SHADOW = Color.new(0,0,0)
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
   
  def pbEndScene
    pbUpdate
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbResetRaidSettings
  end
  
#-------------------------------------------------------------------------------
# Initializes the raid den.
#-------------------------------------------------------------------------------
  def pbStartScene(size, rank, pkmn, loot, field, gmax, hard, storedPkmn)
    pbResetRaidSettings
    @viewport   = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @loot       = (loot) ? loot : nil
    @size       = (size) ? size : Settings::MAXRAID_SIZE
    weather = []
    terrain = []
    environ = []
    GameData::Environment.each   { |e| environ.push(e.id) }
    GameData::BattleTerrain.each { |t| terrain.push(t.id) }
    GameData::BattleWeather.each do |w|
      next if w.id==:HarshSun
      next if w.id==:HeavyRain
      next if w.id==:StrongWinds
      next if w.id==:ShadowSky
      weather.push(w.id)
    end
    @weather    = (field.is_a?(Array)) ? field[0] : :None
    @terrain    = (field.is_a?(Array)) ? field[1] : :None
    @environ    = (field.is_a?(Array)) ? field[2] : field
    @weather    = weather[rand(weather.length)] if @weather==-1
    @terrain    = terrain[rand(terrain.length)] if @terrain==-1
    @environ    = environ[rand(environ.length)] if @environ==-1
    #---------------------------------------------------------------------------
    # Determines Raid Pokemon data of an existing raid species.
    #---------------------------------------------------------------------------
    stored = $game_variables[storedPkmn]
    if stored!=0
      existing = true if stored.is_a?(Pokemon)
      species  = (existing) ? stored.species     : stored[0]
      form     = (existing) ? stored.form        : stored[1]
      gender   = (existing) ? stored.gender      : stored[2]
      level    = (existing) ? stored.level       : stored[3]
      makegmax = (existing) ? stored.gmaxFactor? : stored[4]
      rank     = 1
      rank     = 2 if level>=30
      rank     = 3 if level>=40
      rank     = 4 if level>=50
      rank     = 5 if level>=60
      rank     = 6 if level>=70
    else
      #-------------------------------------------------------------------------
      # Determines Raid Pokemon data of a newly spawned species.
      #-------------------------------------------------------------------------
      stars1 = 15+rand(5) # 1 Star Pokemon raid levels: 15-20
      stars2 = 30+rand(5) # 2 Star Pokemon raid levels: 30-35
      stars3 = 40+rand(5) # 3 Star Pokemon raid levels: 40-45
      stars4 = 50+rand(5) # 4 Star Pokemon raid levels: 50-55
      stars5 = 60+rand(5) # 5 Star Pokemon raid levels: 60-65
      # Gets appropriate raid rank if rank is nil and no specific species ID is entered.
      if pkmn.is_a?(Array) && !rank
        stars = []
        stars.push(stars1) if $Trainer.badge_count <6
        stars.push(stars2) if $Trainer.badge_count <8 && $Trainer.badge_count >0
        stars.push(stars3) if $Trainer.badge_count >=3
        stars.push(stars4) if $Trainer.badge_count >=6
        stars.push(stars5) if $Trainer.badge_count >=8
        level = stars[rand(stars.length)]
        rank  = 1 if level>=15
        rank  = 2 if level>=30
        rank  = 3 if level>=40
        rank  = 4 if level>=50
        rank  = 5 if level>=60
      # Gets appropriate raid rank if specified species ID is not found in the entered rank.
      elsif rank && !pbAllRanksAppearedIn(pkmn).include?(rank)
        rank = pbRankFromSpecies(pkmn)
      end
      env      = (@environ) ? @environ : pbGetEnvironment
      pokemon  = pbGenerateDenSpecies(pkmn, rank, env, false)
      species  = GameData::Species.get(pokemon).species
      form     = GameData::Species.get(pokemon).form
      gender   = nil
      makegmax = false
      rank     = pbRankFromSpecies(pokemon) if !rank
      level    = stars1 if rank<=1
      level    = stars2 if rank==2
      level    = stars3 if rank==3
      level    = stars4 if rank==4
      level    = stars5 if rank==5
      level    = 70     if rank>=6
      if pbGenderedSpeciesIcons?(pokemon)
        odds   = (species==:PYROAR) ? 10 : 2
        gender = (rand(odds)<1) ? 0 : 1
      end
      if GameData::Species.get(pokemon).hasGmax?
        gmaxchance = rand(10)
        makegmax   = true if rank==3 && gmaxchance<2
        makegmax   = true if rank==4 && gmaxchance<3
        makegmax   = true if rank>=5 && gmaxchance<5
        makegmax   = true if gmax
      end
    end
    @bosspoke   = species
    @bossform   = form
    @bossgender = gender
    @bosslevel  = level
    @gmax       = makegmax
    @rank       = rank
    @hardmode   = $game_switches[Settings::HARDMODE_RAID] = true if hard || rank==6
    #---------------------------------------------------------------------------
    # Saves the game and begins Raid Event.
    #---------------------------------------------------------------------------
    @sprites    = {}
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    # Hold CTRL in Debug to skip saving prompt.
    if $game_variables[storedPkmn]!=0 || ($DEBUG && Input.press?(Input::CTRL))
      pbMessage(_INTL("You peered into the raid den before you..."))
      if !$game_variables[storedPkmn].is_a?(Pokemon)
        $game_variables[storedPkmn] = [@bosspoke,@bossform,@bossgender,@bosslevel,@gmax]
      end
      pbMaxRaidEntry(storedPkmn)
    else
      if pbConfirmMessage(_INTL("You must save the game before entering a new raid den. Is this ok?"))
        if safeExists?(RTP.getSaveFileName("Game.rxdata"))
          $game_variables[storedPkmn] = [@bosspoke,@bossform,@bossgender,@bosslevel,@gmax]
          if $PokemonTemp.begunNewGame
            pbMessage(_INTL("WARNING!"))
            pbMessage(_INTL("There is a different game file that is already saved."))
            pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
            if !pbConfirmMessageSerious(
              _INTL("Are you sure you want to save now and overwrite the other save file?"))
              pbSEPlay("GUI save choice")
              $game_variables[storedPkmn] = 0
            else
              Game.save
              pbSEPlay("GUI save choice")
              pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]",$Trainer.name))
              pbMaxRaidEntry(storedPkmn)
            end
          else
            Game.save
            pbSEPlay("GUI save choice")
            pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]",$Trainer.name))
            pbMaxRaidEntry(storedPkmn)
          end
        else
          Game.save
          pbSEPlay("GUI save choice")
          pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]",$Trainer.name))
          pbMaxRaidEntry(storedPkmn)
        end
      end
    end
  end

#-------------------------------------------------------------------------------
# Draws the Max Raid entry screen.
#-------------------------------------------------------------------------------
  def pbMaxRaidEntry(storedPkmn)
    @sprites["raidentry"] = IconSprite.new(0,0)
    @sprites["raidentry"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_entry")
    @sprites["pokeicon"]  = PokemonSpeciesIconSprite.new(@bosspoke,@viewport)
    @sprites["pokeicon"].pbSetParams(@bosspoke,@bossgender,@bossform,false,@gmax)
    @sprites["pokeicon"].x = 95
    @sprites["pokeicon"].y = 132
    if @gmax && Settings::GMAX_XL_ICONS
      @sprites["pokeicon"].x -= 12
      @sprites["pokeicon"].y -= 12
    else
      @sprites["pokeicon"].zoom_x = 1.5
      @sprites["pokeicon"].zoom_y = 1.5
    end
    @sprites["pokeicon"].color.alpha = 255
    for i in 1..5
      @sprites["raidstar#{i}"] = IconSprite.new(10,64)
      @sprites["raidstar#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    end
    @sprites["raidstar2"].x = 50  if @rank>=2
    @sprites["raidstar3"].x = 90  if @rank>=3
    @sprites["raidstar4"].x = 130 if @rank>=4
    @sprites["raidstar5"].x = 170 if @rank>=5
    @sprites["usebutton"] = IconSprite.new(346,214)
    @sprites["usebutton"].setBitmap("Graphics/Pictures/Controls help/help_usekey")
    @sprites["usebutton"].zoom_x = 0.5
    @sprites["usebutton"].zoom_y = 0.5
    @sprites["backbutton"] = IconSprite.new(346,151)
    @sprites["backbutton"].setBitmap("Graphics/Pictures/Controls help/help_backkey")
    @sprites["backbutton"].zoom_x = 0.5
    @sprites["backbutton"].zoom_y = 0.5
    @sprites["actionbutton"] = IconSprite.new(54,292)
    @sprites["actionbutton"].setBitmap("Graphics/Pictures/Controls help/help_actionkey")
    @sprites["actionbutton"].zoom_x = 0.5
    @sprites["actionbutton"].zoom_y = 0.5
    @overlay = @sprites["overlay"].bitmap
    pbSetSmallFont(@overlay)
    textPos = [
      [_INTL("MAX RAID DEN"),25,21,0,BASE,SHADOW],
      [_INTL("Leave Den"),403,143,0,BASE,SHADOW],
      [_INTL("Enter Den"),403,206,0,BASE,SHADOW],
      [_INTL("Set Party"),111,284,0,BASE,SHADOW]
    ]
    #---------------------------------------------------------------------------
    # Party display.
    #---------------------------------------------------------------------------
    party = 0
    icons = 0
    for i in $Trainer.able_party; party += 1; end
    @size = 4 if party<5 && @size>=5
    @size = 3 if party<4 && @size>=4
    @size = 3 if @size>3 && !Settings::EMBS_COMPAT
    @size = 2 if party<3 && @size>=3
    @size = 1 if party<2 && @size>=2
    for i in 0...party
      @sprites["partybg#{i}"] = IconSprite.new(-100,252)
      @sprites["partybg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
    end
    for i in 0...$Trainer.party.length
      next if $Trainer.party[i].egg? || $Trainer.party[i].fainted?
      species = $Trainer.party[i].species
      gender  = $Trainer.party[i].gender
      form    = $Trainer.party[i].form
      @sprites["pkmnsprite#{icons}"] = PokemonSpeciesIconSprite.new(species,@viewport)
      @sprites["pkmnsprite#{icons}"].pbSetParams(species,gender,form)
      @sprites["pkmnsprite#{icons}"].y       = 251
      @sprites["pkmnsprite#{icons}"].zoom_x  = 0.5
      @sprites["pkmnsprite#{icons}"].zoom_y  = 0.5
      @sprites["pkmnsprite#{icons}"].visible = false
      icons += 1
      break if icons==@size
    end
    partyX = 127-(19*@size)
    for i in 0...@size
      @sprites["partybg#{i}"].x          = partyX+(37*i)
      @sprites["pkmnsprite#{i}"].x       = @sprites["partybg#{i}"].x+2
      @sprites["pkmnsprite#{i}"].visible = true
    end
    #---------------------------------------------------------------------------
    # Battlefield display.
    #---------------------------------------------------------------------------
    field_1 = field_2 = field_3 = 0
    case @weather
    when :Sun;                      field_1 = 1
    when :Rain;                     field_1 = 2
    when :Sandstorm;                field_1 = 3
    when :Hail;                     field_1 = 4
    when :ShadowSky;                field_1 = 5
    when :Fog;                      field_1 = 6
    when :HarshSun;                 field_1 = 7
    when :HeavyRain;                field_1 = 8
    when :StrongWinds;              field_1 = 9
    end
    case @terrain              
    when :Electric;                 field_2 = 1
    when :Grassy;                   field_2 = 2
    when :Misty;                    field_2 = 3
    when :Psychic;                  field_2 = 4
    end
    case @environ                                 # Raid Tags:
    when :None;                     field_3 = 1   # Urban      
    when :Grass, :TallGrass;        field_3 = 2   # Fields
    when :MovingWater, :StillWater; field_3 = 3   # Aquatic
    when :Puddle;                   field_3 = 4   # Wetlands
    when :Underwater;               field_3 = 5   # Underwater    
    when :Cave;                     field_3 = 6   # Cavern
    when :Rock;                     field_3 = 7   # Rocky
    when :Sand;                     field_3 = 8   # Sandy
    when :Forest, :ForestGrass;     field_3 = 9   # Forest
    when :Snow, :Ice;               field_3 = 10  # Frosty
    when :Volcano;                  field_3 = 11  # Volcanic
    when :Graveyard;                field_3 = 12  # Spiritual
    when :Sky;                      field_3 = 13  # Sky
    when :Space;                    field_3 = 14  # Space
    when :UltraSpace;               field_3 = 15  # Ultra Space
    end
    @sprites["fieldbg"] = IconSprite.new(295,16)
    @sprites["fieldbg"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_header")
    @sprites["fieldbg"].mirror  = true
    @sprites["fieldbg"].visible = false
    fieldbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raid_field"))
    if (field_1 + field_2 + field_3) >0
      xpos = -1
      @sprites["fieldbg"].visible = true
      textPos.push([_INTL("FIELD"),450,8,0,BASE,SHADOW])
      conds = [field_1, field_2, field_3]
      for i in 0...conds.length
        next if conds[i]==0
        xpos += 1
        @overlay.blt(444-(xpos*58),38,fieldbitmap.bitmap,Rect.new(conds[i]*58,i*32,58,32))
      end
    end
    #---------------------------------------------------------------------------
    # Extra raid conditions display.
    #---------------------------------------------------------------------------
    extras = []
    @sprites["gmax"] = IconSprite.new(-100,94)
    @sprites["gmax"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
    @sprites["hard"] = IconSprite.new(-100,80)
    @sprites["hard"].setBitmap("Graphics/Pictures/Dynamax/raid_hard")
    @sprites["loot"] = IconSprite.new(-100,80)
    @sprites["loot"].setBitmap("Graphics/Pictures/Dynamax/raid_loot")
    extras.push(@sprites["gmax"]) if @gmax
    extras.push(@sprites["hard"]) if @hardmode
    extras.push(@sprites["loot"]) if @loot
    for i in 0...extras.length
      extras[i].x = 460-(i*54)
    end
    #---------------------------------------------------------------------------
    # Raid Pokemon type display.
    #---------------------------------------------------------------------------
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    species_id = GameData::Species.get_species_form(@bosspoke, @bossform)
    pokemon    = GameData::Species.get(species_id)
    type1      = GameData::Type.get(pokemon.type1).id_number
    type2      = GameData::Type.get(pokemon.type2).id_number
    type1rect  = Rect.new(0,type1*32,96,32)
    type2rect  = Rect.new(0,type2*32,96,32)
    @overlay.blt(10,106,typebitmap.bitmap,type1rect)
    @overlay.blt(110,106,typebitmap.bitmap,type2rect) if type1!=type2
    #---------------------------------------------------------------------------
    # Text displays.
    #---------------------------------------------------------------------------
    timerbonus = ((@bosslevel+5)/10).floor+1 if @size==1
    timerbonus = ((@bosslevel+5)/20).ceil+1  if @size==2
    turns      = Settings::MAXRAID_TIMER
    turns     += timerbonus if @bosslevel>20 && @size<3
    turns      = 5 if turns<5
    turns      = 25 if turns>25
    kocount    = Settings::MAXRAID_KOS
    kocount   -=1 if @bosslevel>55
    battletext  = _INTL("Battle ends in {1} turns, or after {2} knock outs.",turns,kocount)
    pbDrawTextPositions(@overlay,textPos)
    drawTextEx(@overlay,287,274,220,2,battletext,BASE,SHADOW)
    #---------------------------------------------------------------------------
    # Selection loop.
    #---------------------------------------------------------------------------
    full_party = []
    for i in $Trainer.party
      full_party.push(i)
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate
      #-------------------------------------------------------------------------
      # Accesses Party screen and updates party display.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::ACTION)
        pbPlayCancelSE
        Input.update
        pbPokemonScreen
        full_party.clear
        for i in $Trainer.party
          full_party.push(i)
        end
        icons = 0
        for i in 0...$Trainer.party.length
          next if $Trainer.party[i].egg? || $Trainer.party[i].fainted?
          species = $Trainer.party[i].species
          gender  = $Trainer.party[i].gender
          form    = $Trainer.party[i].form
          @sprites["pkmnsprite#{icons}"].pbSetParams(species,gender,form)
          icons += 1
          break if icons==@size
        end
      #-------------------------------------------------------------------------
      # Sets up and accesses the Raid battle.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::USE)
        if pbConfirmMessage(_INTL("Enter the raid den with the displayed party?"))
          pbFadeOutIn {
            pbSEPlay("Door enter")
            Input.update
            pbDisposeSpriteHash(@sprites)
            @viewport.dispose
            for i in @size...$Trainer.party.length
              $Trainer.party[i] = nil
            end
            $Trainer.party.compact!
            #-------------------------------------------------------------------
            # Gets the environmental properties of the battle.
            #-------------------------------------------------------------------
            @environ = :Cave if !@environ
			ebdx  = :DARKCAVE if Settings::EBDX_COMPAT
            case @environ
            when :None;                     bg = base = "city";            ebdx = :CITY        
            when :Grass, :TallGrass;        bg = "field"; base = "grass";  ebdx = :OUTDOOR
            when :MovingWater, :StillWater; bg = base = "water";           ebdx = :WATER  
            when :Puddle;                   bg = "water"; base = "puddle"; ebdx = :MOUNTAINLAKE
            when :Underwater;               bg = base = "underwater";      ebdx = :UNDERWATER        
            when :Cave;                     bg = base = "cave3";           ebdx = :DARKCAVE            
            when :Rock;                     bg = base = "rocky";           ebdx = :MOUNTAIN
            when :Volcano;                  bg = base = "rocky";           ebdx = :MAGMA			
            when :Sand;                     bg = "rocky"; base = "sand";   ebdx = :SAND   
            when :Forest;                   bg = base = "forest";          ebdx = :FOREST            
            when :ForestGrass;              bg = "forest"; base = "grass"; ebdx = :FOREST  
            when :Snow;                     bg = base = "snow";            ebdx = :SNOW              
            when :Ice;                      bg = "snow"; base = "ice";     ebdx = :ICE     
            when :Graveyard;                bg = base = "distortion";      ebdx = :DARKNESS        
            when :Sky;                      bg = base = "sky";             ebdx = :SKY               
            when :Space;                    bg = base = "space";           ebdx = :SPACE  
            when :UltraSpace;               bg = base = "ultraspace";      ebdx = :DIMENSION  
            end
            #-------------------------------------------------------------------
            # Finalizes battle rules and begins the raid battle.
            #-------------------------------------------------------------------
            setBattleRule("terrain",:Electric)
			setBattleRule("canlose")
            setBattleRule("cannotrun")
            setBattleRule("noexp")
            setBattleRule("nomoney")
            setBattleRule("nopartner")
            setBattleRule(sprintf("%dv%d",@size,1))
            setBattleRule("weather",@weather)
            setBattleRule("terrain",@terrain)
            if @environ
              setBattleRule("environ",@environ)
              setBattleRule("base",base)
              setBattleRule("backdrop",bg)
			  EliteBattle.set(:nextBattleBack, ebdx) if Settings::EBDX_COMPAT
            end
            $PokemonGlobal.nextBattleBGM = (@rank==6) ? "Battle! Legendary Raid" : "Battle! Max Raid"
            $PokemonGlobal.nextBattleBGM = "Battle! Eternatus - Phase 2" if @bosspoke==:ETERNATUS
            pbMessage(_INTL("\\me[Max Raid Intro]You ventured into the den...\\wt[34] ...\\wt[34] ...\\wt[60]!\\wtnp[8]")) #if !$DEBUG
            $game_switches[Settings::MAXRAID_SWITCH] = true
            if Settings::EMBS_COMPAT # Compatibility for Modular Battle Scene
			  max = [0,0,0,3,2,1]
              $PokemonSystem.activebattle=max[@size]
            end
            pbWildBattleCore(@bosspoke,@bosslevel)
            pbWait(20)
            pbSEPlay("Door exit")
          }
          $Trainer.party = full_party
          #---------------------------------------------------------------------
          # Displays Raid results screen and resets variable if necessary.
          #---------------------------------------------------------------------
          pbRaidRewardsScreen($game_variables[storedPkmn])
          if $game_variables[1]==1 || $game_variables[1]==4
            $game_variables[storedPkmn] = 1
            for i in $Trainer.party; i.heal; end
          end
          break
        end
      end
      #-------------------------------------------------------------------------
      # Exits the Raid event and saves the Raid Pokemon to a variable.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::BACK)
        if pbConfirmMessage(_INTL("Would you like to leave the raid den?"))
          $game_variables[storedPkmn]  = [@bosspoke,@bossform,@bossgender,@bosslevel,@gmax]
          $game_variables[storedPkmn]  = 0 if ($DEBUG && Input.press?(Input::CTRL)) 
          Input.update
          pbEndScene
          break
        end
      end
    end
  end
  
#-------------------------------------------------------------------------------
# Max Raid rewards list.
#-------------------------------------------------------------------------------
  def pbMaxRaidRewards(pkmn)
    rewards   = []
    qty       = @size+((@rank*(@bonuses.length+1))*1.1).round
    qty80     = qty/1.25.floor+1
    qty50     = qty/2.floor+1
    qty25     = qty/4.floor+1
    #---------------------------------------------------------------------------
    # Reward lists.
    #---------------------------------------------------------------------------
    expcandy  = [:EXPCANDYXS,:EXPCANDYS,:EXPCANDYM,:EXPCANDYL,:EXPCANDYXL]
    berries   = [:POMEGBERRY,:KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY]
    vitamins  = [:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS]
    training  = [:PPMAX,:ABILITYCAPSULE,:ABILITYPATCH,:BOTTLECAP,:GOLDBOTTLECAP]
    treasure1 = [:TINYMUSHROOM,:NUGGET,:PEARL,:RELICCOPPER,:RELICVASE]
    treasure2 = [:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:RELICSILVER,:RELICBAND]
    treasure3 = [:BALMMUSHROOM,:PEARLSTRING,:RELICGOLD,:RELICSTATUE,:RELICCROWN]
    bonusitem = [:DYNAMAXCANDYXL,:MAXSOUP]
    #---------------------------------------------------------------------------
    # Adds Exp. Candy rewards.
    #---------------------------------------------------------------------------
    if @rank<=1
      rewards.push([expcandy[0],qty+rand(3)])
      rewards.push([expcandy[1],qty25+rand(3)])
    elsif @rank==2
      rewards.push([expcandy[0],qty+rand(3)])
      rewards.push([expcandy[1],qty50+rand(3)])
    elsif @rank==3
      rewards.push([expcandy[0],qty80+rand(3)])
      rewards.push([expcandy[1],qty+rand(3)])
      rewards.push([expcandy[2],qty25+rand(3)])
    elsif @rank==4
      rewards.push([expcandy[0],qty80+rand(3)])
      rewards.push([expcandy[1],qty+rand(3)])
      rewards.push([expcandy[2],qty50+rand(3)])
      rewards.push([expcandy[3],qty25+rand(3)]) if rand(10)<2
    elsif @rank==5
      rewards.push([expcandy[0],qty50+rand(3)]) if rand(10)<6
      rewards.push([expcandy[1],qty80+rand(3)])
      rewards.push([expcandy[2],qty+rand(3)])
      rewards.push([expcandy[3],qty50+rand(3)])
      rewards.push([expcandy[4],qty25+rand(3)])
    elsif @rank>=6
      rewards.push([expcandy[0],qty25+rand(2)]) if rand(10)<2
      rewards.push([expcandy[1],qty50+rand(3)]) if rand(10)<6
      rewards.push([expcandy[2],qty80+rand(3)])
      rewards.push([expcandy[3],qty+rand(3)])
      rewards.push([expcandy[4],qty50+rand(3)])
    end
    rewards.push([:RARECANDY,qty25+rand(3)]) if @rank>2
    rewards.push([:DYNAMAXCANDY,qty25+rand(3)]) if @rank>2
    rewards.push([bonusitem[rand(bonusitem.length)],1]) if @bonuses.length==5 && @rank>2
    #---------------------------------------------------------------------------
    # Adds species-specific rewards.
    #---------------------------------------------------------------------------
    if @bonuses.length>2
      rewards.push([:MAXEGGS,1])   if pkmn.isSpecies?(:BLISSEY)
      rewards.push([:MAXSCALES,1]) if pkmn.isSpecies?(:LUVDISC)
      rewards.push([:MAXHONEY,1])  if pkmn.isSpecies?(:VESPIQUEN)
      if pkmn.isSpecies?(:PARASECT) ||
         pkmn.isSpecies?(:BRELOOM) ||
         pkmn.isSpecies?(:AMOONGUS) ||
         pkmn.isSpecies?(:SHIINOTIC)
        rewards.push([:MAXMUSHROOMS,1])
      end
      if pkmn.isSpecies?(:FEAROW) ||
         pkmn.isSpecies?(:NOCTOWL) ||
         pkmn.isSpecies?(:STARAPTOR) ||
         pkmn.isSpecies?(:BRAVIARY) ||
         pkmn.isSpecies?(:MANDIBUZZ) ||
         pkmn.isSpecies?(:TALONFLAME)
        rewards.push([:MAXPLUMAGE,1])
      end
    end
    #---------------------------------------------------------------------------
    # Adds Technical Record rewards.
    #---------------------------------------------------------------------------
    trList = pbTechnicalRecordByType(pkmn)
    rewards.push([trList[rand(trList.length)],1]) if trList && @rank>2
    #---------------------------------------------------------------------------
    # Adds general rewards.
    #---------------------------------------------------------------------------
    rewards.push([berries[rand(berries.length)],qty50+rand(3)])
    rewards.push([vitamins[rand(vitamins.length)],qty25+rand(3)]) if @rank>=3
    rewards.push([:PPUP,1+rand(3)]) if @rank>=4 && rand(10)<2
    rewards.push([training[rand(training.length)],1])   if @rank>=5 && rand(10)<1
    rewards.push([treasure1[rand(treasure1.length)],1]) if @rank==3 && rand(10)<1
    rewards.push([treasure2[rand(treasure2.length)],1]) if @rank==4 && rand(10)<1
    rewards.push([treasure3[rand(treasure3.length)],1]) if @rank>=5 && rand(10)<1
    #---------------------------------------------------------------------------
    # Adds rewards based on field settings of the raid.
    #---------------------------------------------------------------------------
    if rand(10)<1
      case @weather
      when :Sun, :HarshSun;           rewards.push([:HEATROCK,1])
      when :Rain, :HeavyRain;         rewards.push([:DAMPROCK,1])
      when :Sandstorm;                rewards.push([:SMOOTHROCK,1])
      when :Hail;                     rewards.push([:ICYROCK,1])
      when :ShadowSky;                rewards.push([:LIFEORB,1])
      when :Fog;                      rewards.push([:SMOKEBALL,1])
      end
    end
    if rand(10)<1
      case @terrain              
      when :Electric;                 rewards.push([:ELECTRICSEED,1])
      when :Grassy;                   rewards.push([:GRASSYSEED,1])
      when :Misty;                    rewards.push([:MISTYSEED,1])
      when :Psychic;                  rewards.push([:PSYCHICSEED,1])
      end
    end
    if rand(10)<1
      case @environ
      when :None;                     rewards.push([:CELLBATTERY,1])    
      when :Grass,                    rewards.push([:MIRACLESEED,1])
      when :TallGrass;                rewards.push([:ABSORBBULB,1])
      when :MovingWater;              rewards.push([:MYSTICWATER,1])
      when :StillWater;               rewards.push([:FRESHWATER,qty25])
      when :Puddle;                   rewards.push([:LIGHTCLAY,1])
      when :Underwater;               rewards.push([:SHOALSHELL,qty25])    
      when :Cave;                     rewards.push([:LUMINOUSMOSS,1])
      when :Rock;                     rewards.push([:HARDSTONE,1])
      when :Sand;                     rewards.push([:SOFTSAND,1])
      when :Forest;                   rewards.push([:SHEDSHELL,1])
      when :ForestGrass;              rewards.push([:SILVERPOWDER,1])
      when :Snow;                     rewards.push([:SNOWBALL,1])
      when :Ice;                      rewards.push([:NEVERMELTICE,1])
      when :Volcano;                  rewards.push([:CHARCOAL,1])
      when :Graveyard;                rewards.push([:RAREBONE,1])
      when :Sky;                      rewards.push([:PRETTYFEATHER,qty25])
      when :Space;                    rewards.push([:STARDUST,qty25])
      when :UltraSpace;               rewards.push([:COMETSHARD,1])
      end
    end
    #---------------------------------------------------------------------------
    # Adds manually entered custom rewards.
    #---------------------------------------------------------------------------
    if @loot!=nil
      if @loot.is_a?(Array)
        rewards.push([@loot[0],@loot[1]]) 
      else
        rewards.push([@loot,1])
      end
    end
    return rewards
  end
  
#-------------------------------------------------------------------------------
# Max Raid rewards screen.
#-------------------------------------------------------------------------------
  def pbRaidRewardsScreen(pkmn)
    @sprites    = {}
    @viewport   = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["rewardscreen"] = IconSprite.new(0,0)
    @sprites["rewardscreen"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_rewards")
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(pkmn)
    for i in 1..5
      @sprites["raidstar#{i}"] = IconSprite.new(-100,64)
      @sprites["raidstar#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_star")
    end
    if @rank<=1
      @sprites["raidstar1"].x = 365
    elsif @rank==2
      @sprites["raidstar1"].x = 345
      @sprites["raidstar2"].x = 385
    elsif @rank==3
      @sprites["raidstar1"].x = 325
      @sprites["raidstar2"].x = 365
      @sprites["raidstar3"].x = 405
    elsif @rank==4
      @sprites["raidstar1"].x = 305
      @sprites["raidstar2"].x = 345
      @sprites["raidstar3"].x = 385
      @sprites["raidstar4"].x = 425
    elsif @rank>=5
      @sprites["raidstar1"].x = 285
      @sprites["raidstar2"].x = 325
      @sprites["raidstar3"].x = 365
      @sprites["raidstar4"].x = 405
      @sprites["raidstar5"].x = 445
    end
    @sprites["gmax"] = IconSprite.new(140,82)
    @sprites["gmax"].setBitmap("Graphics/Pictures/Dynamax/gfactor") if pkmn.gmaxFactor?
    @sprites["backbutton"] = IconSprite.new(335,292)
    @sprites["backbutton"].setBitmap("Graphics/Pictures/Controls help/help_backkey")
    @sprites["backbutton"].zoom_x = 0.5
    @sprites["backbutton"].zoom_y = 0.5
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    pbSetSmallFont(@overlay)
    #---------------------------------------------------------------------------
    # Text displays.
    #---------------------------------------------------------------------------
    textPos = []
    condition     = $game_variables[1]
    result        = "lost to"
    lvldisplay    = "???"
    abildisplay   = "???"
    if condition==1
      result      = "defeated"
    elsif condition==4
      result      = "caught"
      lvldisplay  = pkmn.level
      abildisplay = GameData::Ability.get(pkmn.ability).name
      if pkmn.male?
        gendermark = "♂"
        textPos.push([gendermark,20,76,0,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pkmn.female?
        gendermark = "♀"
        textPos.push([gendermark,20,76,0,Color.new(248,56,32),Color.new(224,152,144)])
      end
    end
    result = _INTL("You {1} {2}!",result,pkmn.name)
    textPos.push([_INTL("No Rewards Earned."),296,168,0,BASE,SHADOW]) if condition==2 || condition==3
    textPos.push(
      [result,270,20,0,BASE,SHADOW],
      [_INTL("Exit"),393,284,0,BASE,SHADOW],
      [_INTL("Lvl. {1}",lvldisplay),38,77,0,BASE,SHADOW],
      [_INTL("Ability: {1}",abildisplay),20,283,0,BASE,SHADOW]
    )
    #---------------------------------------------------------------------------
    # Rewards display for captured/defeated Raid Pokemon.
    #---------------------------------------------------------------------------
    @bonuses = []
    if condition==1 || condition==4
      bonuses       = $game_variables[Settings::REWARD_BONUSES]
      bonusTIMER    = true if bonuses[0]>Settings::MAXRAID_TIMER/2.floor
      bonusPERFECT  = true if bonuses[1]==true
      bonusFAIRNESS = true if bonuses[2]==true
      bonusCAPTURE  = true if condition==4
      bonusHARDMODE = true if $game_switches[Settings::HARDMODE_RAID]
      bonusRewards  = true if (bonusTIMER || bonusPERFECT || bonusFAIRNESS || bonusCAPTURE || bonusHARDMODE)
      if bonusRewards
        @sprites["bonusbg"] = IconSprite.new(0,16)
        @sprites["bonusbg"].setBitmap("Graphics/Pictures/Dynamax/raid_bg_header")
        @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
        textPos.push([_INTL("BONUS"),8,8,0,BASE,SHADOW])
        bonusbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/raid_bonus"))
        hardmode = 0
        perfect  = 1
        timer    = 2
        fairness = 3
        capture  = 4
        @bonuses.push(hardmode) if bonusHARDMODE
        @bonuses.push(perfect)  if bonusPERFECT
        @bonuses.push(timer)    if bonusTIMER
        @bonuses.push(fairness) if bonusFAIRNESS
        @bonuses.push(capture)  if bonusCAPTURE
        for i in 0...@bonuses.length
          @overlay.blt(i*41,38,bonusbitmap.bitmap,Rect.new(@bonuses[i]*41,0,41,33))
        end
      end
      rewards = pbMaxRaidRewards(pkmn)
      items   = []
      for i in 0...rewards.length
        item, qty = rewards[i][0], rewards[i][1]
        next if !GameData::Item.exists?(item)
        item     = GameData::Item.get(item)
        itemname = (item.is_TR?) ? _INTL("{1} {2}",item.name,GameData::Move.get(item.move).name) : item.name
        items.push(_INTL("{1}  x{2}",itemname,qty))
        $PokemonBag.pbStoreItem(item.id,qty)
      end
      @sprites["itemwindow"] = Window_CommandPokemon.newWithSize(items,260,92,258,196,@viewport)
      @sprites["itemwindow"].index = 0
      @sprites["itemwindow"].baseColor   = BASE
      @sprites["itemwindow"].shadowColor = SHADOW
      @sprites["itemwindow"].windowskin  = nil
    end
    pbDrawTextPositions(@overlay,textPos)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE
        Input.update
        break
      end
    end
    pbEndScene
  end
end

#===============================================================================
# Used to call a Max Raid Den in an event script.
#===============================================================================
def pbMaxRaid(size=nil, rank=nil, pkmn=nil, loot=nil, field=nil, gmax=false, hard=false)
  thisMap    = $game_map.map_id
  thisEvent  = pbMapInterpreter.get_character(0)
  thisEvent  = (thisEvent) ? thisEvent.id : 0
  mapOffset  = (thisEvent>0) ? thisMap*100 : 0
  storedPkmn =  mapOffset + thisEvent + Settings::MAXRAID_PKMN
  if storedPkmn != Settings::MAXRAID_PKMN
    if Settings::DMAX_ANYMAP || ($game_map && Settings::POWERSPOTS.include?(thisMap))
      pbSetEventTime
      # Forces a manual Raid Reset while holding CTRL in Debug.
      if ($DEBUG && Input.press?(Input::CTRL))
        $game_variables[storedPkmn] = 0
        pbSetSelfSwitch(thisEvent,"B",false) 
      end
      # Resets a Max Raid Den via Wishing Pieces.
      if $game_self_switches[[thisMap,thisEvent,"B"]]
        if $game_variables[storedPkmn]==1
          pbMessage(_INTL("There doesn't seem to be anything in the den..."))
          if pbConfirmMessage(_INTL("Want to throw in a Wishing Piece?"))
            if $PokemonBag.pbHasItem?(:WISHINGPIECE)
              $game_variables[storedPkmn] = 0
              $PokemonBag.pbDeleteItem(:WISHINGPIECE)
              pbMessage(_INTL("You threw a Wishing Piece into the den!"))
              pbSetSelfSwitch(thisEvent,"B",false)
            else
              pbMessage(_INTL("But you don't have any Wishing Pieces..."))
            end
          end
        end
      end
      # Begins Max Raid Den event.
      if !$game_self_switches[[thisMap,thisEvent,"B"]]
        scene  = MaxRaidScene.new
        screen = MaxRaidScreen.new(scene)
        screen.pbStartScreen(size,rank,pkmn,loot,field,gmax,hard,storedPkmn)
        if $game_variables[storedPkmn]==1
          pbSetSelfSwitch(thisEvent,"B",true)
        end
      end
    else
      pbMessage(_INTL("There appears to be a raid den here, but no Dynamax energy is present."))
    end
  end
end

class MaxRaidScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(*args)
    @scene.pbStartScene(*args)
    @scene.pbEndScene
  end
end

#-------------------------------------------------------------------------------
# Initiates a simplified raid battle versus a Pokemon.
#-------------------------------------------------------------------------------
def pbMaxRaidSimple(species, level, gmax = false, raidrules = true)
  pbResetRaidSettings
  species = pbGenerateDenSpecies(species, nil, nil, false)
  if raidrules
    base_form = GameData::Species.get(species).form
    base_spec = GameData::Species.get(species).species
    $game_switches[Settings::MAXRAID_SWITCH] = true
    $game_variables[Settings::MAXRAID_PKMN]  = [base_spec, base_form, nil, level, gmax]
    pbWildBattleCore(species, level)
  else
    pkmn = Pokemon.new(species, level)
    pkmn.setDynamaxLvl(pkmn.level)
    pkmn.giveGMaxFactor if pkmn.hasGmax? && gmax
    pkmn.makeDynamax
    pkmn.calc_stats
    pkmn.hp = pkmn.totalhp
    pkmn.pbReversion(true)
    pbWildBattleCore(pkmn)
  end
  pbResetRaidSettings
end

#-------------------------------------------------------------------------------
# Naturally resets after an alotted amount of time has passed.
#-------------------------------------------------------------------------------
def pbMaxRaidTime
  thisMap    = $game_map.map_id
  thisEvent  = pbMapInterpreter.get_character(0)
  thisEvent  = (thisEvent) ? thisEvent.id : 0
  mapOffset  = (thisEvent>0) ? thisMap*100 : 0
  storedPkmn =  mapOffset + thisEvent + Settings::MAXRAID_PKMN
  $game_variables[storedPkmn] = 0
  pbSetSelfSwitch(thisEvent,"A",false)
  pbSetSelfSwitch(thisEvent,"B",false)
end

#-------------------------------------------------------------------------------
# Forces a raid to reset, bypassing the need to wait or use a Wishing Piece.
#-------------------------------------------------------------------------------
# When afterLoss=false, forces the raid to reset only once its been cleared.
# When afterLoss=true, forces the raid to reset every time, even after a loss.
def pbForcedRaidReset(afterLoss=false)
  thisMap    = $game_map.map_id
  thisEvent  = pbMapInterpreter.get_character(0)
  thisEvent  = (thisEvent) ? thisEvent.id : 0
  mapOffset  = (thisEvent>0) ? thisMap*100 : 0
  storedPkmn =  mapOffset + thisEvent + Settings::MAXRAID_PKMN
  if afterLoss
    $game_variables[storedPkmn] = 0
    pbSetSelfSwitch(thisEvent,"B",false)
  else
    if $game_self_switches[[thisMap,thisEvent,"B"]]
      $game_variables[storedPkmn] = 0
      pbSetSelfSwitch(thisEvent,"B",false)
    end
  end
end