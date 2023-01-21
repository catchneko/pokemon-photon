#===============================================================================
# Various utilities that all Max Raid scripts depend on.
#===============================================================================
# Sets up arrays of eligible Max Raid species as temporary data.
#-------------------------------------------------------------------------------
class PokemonTemp
  attr_accessor :raidRank1
  attr_accessor :raidRank2
  attr_accessor :raidRank3
  attr_accessor :raidRank4
  attr_accessor :raidRank5
  attr_accessor :raidTotal
  attr_accessor :raidBanlist
end

def pbSetRaidRanks
  rank1, rank2, rank3, rank4, rank5 = pbRaidRankLists
  if !$PokemonTemp.raidRank1; $PokemonTemp.raidRank1 = rank1;         end
  if !$PokemonTemp.raidRank2; $PokemonTemp.raidRank2 = rank2 + rank1; end
  if !$PokemonTemp.raidRank3; $PokemonTemp.raidRank3 = rank3 + rank2; end
  if !$PokemonTemp.raidRank4; $PokemonTemp.raidRank4 = rank4 + rank3; end
  if !$PokemonTemp.raidRank5; $PokemonTemp.raidRank5 = rank5;         end
  if !$PokemonTemp.raidTotal
    $PokemonTemp.raidTotal = rank1 + rank2 + rank3 + rank4 + rank5
  end
end

#-------------------------------------------------------------------------------
# Related to the Max Raid banlist.
#-------------------------------------------------------------------------------
def pbRaidBanlist
  #-----------------------------------------------------------------------------
  # Hard-coded banned species list.
  #-----------------------------------------------------------------------------
  raid_banlist = [:SMEARGLE,:SHEDINJA,:PHIONE,:FLOETTE_5,:ZYGARDE_2,:ZYGARDE_3,
                  :TYPENULL,:COSMOG,:COSMOEM,:POIPOLE,:MELTAN,:ZACIAN,:ZAMAZENTA,
                  :KUBFU]
  #-----------------------------------------------------------------------------
  # Allowable multi-form species.
  #-----------------------------------------------------------------------------
  allowed_forms = [:UNOWN,:DEOXYS,:BURMY,:WORMADAM,:SHELLOS,:GASTRODON,:ROTOM,
                   :SHAYMIN,:BASCULIN,:TORNADUS,:THUNDURUS,:LANDORUS,:VIVILLON,
                   :FURFROU,:FLABEBE,:FLOETTE,:FLORGES,:MEOWSTIC,:PUMPKABOO,
                   :GOURGEIST,:ZYGARDE,:HOOPA,:ORICORIO,:ROCKRUFF,:LYCANROC,
                   :SINISTEA,:POLTEAGEIST,:TOXTRICITY,:INDEEDEE,:URSHIFU]
  #-----------------------------------------------------------------------------
  # Regional forms and Minior meteor forms also allowed.
  #-----------------------------------------------------------------------------
  GameData::Species.each do |sp|
    next if sp.form==0
    next if regionalVariant?(sp)
    next if allowed_forms.include?(sp.species)
    next if sp.species==:MINIOR && sp.form < 7
    raid_banlist.push(sp.id)
  end 
  return raid_banlist
end

def pbMaxRaidBanList
  if !$PokemonTemp.raidBanlist
    $PokemonTemp.raidBanlist = pbRaidBanlist
  end
  return $PokemonTemp.raidBanlist
end

#-------------------------------------------------------------------------------
# Related to Max Raid rank lists.
#-------------------------------------------------------------------------------
def pbRaidRankLists
  rank1    = [] # Contains Pokemon excluding legendaries with >=365 BST
  rank2    = [] # Contains Pokemon excluding legendaries between 365-478 BST
  rank3    = [] # Contains Pokemon excluding legendaries between 480-535 BST
  rank4    = [] # Contains Pokemon excluding legendaries between 535-600 BST
  rank5    = [] # Contains all fully evolved legendaries, Silvally & Ultra Beasts
  GameData::Species.each do |sp|
    next if pbMaxRaidBanList.include?(sp.id)
    bst       = pbBaseStatTotal(sp.id)
    legendary = sp.egg_groups.include?(:Undiscovered)
	exception = Settings::LEGENDARY_EXCEPTIONS.include?(sp.id)
    banRank1  = (sp.id==:WISHIWASHI)
    banRank2  = (sp.id==:ROTOM)
    banRank3  = (sp.id==:ZYGARDE_1 || sp.id==:CALYREX)
    banRank4  = (sp.id==:MANAPHY)
    rank1.push(sp.id) if bst <= 365                 && !banRank1 && !exception
    rank2.push(sp.id) if (bst < 480 && bst > 365)   && !banRank2 && !exception
    rank3.push(sp.id) if (bst <= 535 && bst >= 480) && !banRank3 && !exception
    rank3.push(sp.id) if sp.id==:ROTOM && sp.form==0
    rank4.push(sp.id) if (bst <= 600 && bst > 535)  && !banRank4 && !exception && !legendary
    rank4.push(sp.id) if sp.id==:SLAKING
    rank4.push(sp.id) if sp.id==:WISHIWASHI
    rank5.push(sp.id) if bst >= 570 && legendary
    rank5.push(sp.id) if sp.id==:MANAPHY
    rank5.push(sp.id) if sp.id==:ZYGARDE_1
    rank5.push(sp.id) if sp.id==:NAGANADEL
    rank5.push(sp.id) if sp.species==:URSHIFU
    rank5.push(sp.id) if sp.id==:CALYREX
	rank5.push(sp.id) if exception
  end
  return rank1, rank2, rank3, rank4, rank5
end

def pbRaidRank(rank=nil)
  pbSetRaidRanks if !$PokemonTemp.raidTotal
  return $PokemonTemp.raidTotal if !rank
  ranks = [[:DITTO],
           $PokemonTemp.raidRank1,
           $PokemonTemp.raidRank2,
           $PokemonTemp.raidRank3,
           $PokemonTemp.raidRank4,
           $PokemonTemp.raidRank4,
           $PokemonTemp.raidRank5]
  return ranks[rank]
end

def pbRankFromSpecies(species)
  pbSetRaidRanks if !$PokemonTemp.raidTotal
  rank = 6 if $PokemonTemp.raidRank5.include?(species)
  rank = 4 if $PokemonTemp.raidRank4.include?(species)
  rank = 3 if $PokemonTemp.raidRank3.include?(species)
  rank = 2 if $PokemonTemp.raidRank2.include?(species)
  return rank
end

def pbAllRanksAppearedIn(species)
  ranks = []
  pbSetRaidRanks if !$PokemonTemp.raidTotal
  ranks.push(6)  if $PokemonTemp.raidRank5.include?(species)
  ranks.push(1)  if $PokemonTemp.raidRank1.include?(species)
  ranks.push(2)  if $PokemonTemp.raidRank2.include?(species)
  ranks.push(3)  if $PokemonTemp.raidRank3.include?(species)
  if $PokemonTemp.raidRank4.include?(species)
    ranks.push(4)
    ranks.push(5)
  end
  return ranks
end

#===============================================================================
# Max Raid Species
#-------------------------------------------------------------------------------
# Narrows down a list of eligible species for a particular Max Raid.
#-------------------------------------------------------------------------------
def pbMaxRaidSpecies(params,rank,env=nil,database=false)
  #-----------------------------------------------------------------------------
  # Gets data for specific cases.
  #-----------------------------------------------------------------------------
  environ  = [:BURMY,:WORMADAM]
  seasonal = [:DEERLING,:SAWSBUCK]
  timeday  = [:SHAYMIN,:ROCKRUFF,:LYCANROC]
  dataform = [:PIKACHU,:UNOWN,:FLABEBE,:FLOETTE,:FLORGES,:FURFROU,:PUMPKABOO,
              :GOURGEIST,:ROCKRUFF,:MINIOR,:SINISTEA,:POLTEAGEIST]
  enviform =  (env==:Cave || env==:Rock || env==:Sand) ? 1 : 0
  enviform = 2 if env==:None
  timeform = (PBDayNight.isNight?) ? 1 : 0
  timeform = 2 if PBDayNight.isEvening?
  region   = pbGetCurrentRegion
  database_filter = true if database
  #-----------------------------------------------------------------------------
  # Filters by Type/Habitat/Region when params is an array.
  #-----------------------------------------------------------------------------
  if params.is_a?(Array)
    type_filter    = true if params[0]
    habitat_filter = true if params[1]
    region_filter  = true if params[2]
  #-----------------------------------------------------------------------------
  # Filters by specific species/form when params is a species ID.
  #-----------------------------------------------------------------------------
  elsif params
    params  = :DITTO if !GameData::Species.exists?(params)
    pokemon = GameData::Species.get(params)
    if params.is_a?(Numeric); pokemon_filter = true;
    elsif pokemon.form>0;     pokemon_filter = true;
    else;                     species_filter = true;
    end
    params  = pokemon.species if pbMaxRaidBanList.include?(pokemon.id)
    params  = :DITTO          if pbMaxRaidBanList.include?(pokemon.species)
    rank    = pbRankFromSpecies(params) if !rank
  #-----------------------------------------------------------------------------
  # Filters by random species found on the current map when params is nil.
  #-----------------------------------------------------------------------------
  else
    species_filter = true
    enctype = $PokemonEncounters.encounter_type
    if enctype && $PokemonEncounters.encounter_possible_here?
      encounter = $PokemonEncounters.choose_wild_pokemon(enctype)
      params = encounter[0]
    end
    if params
      pokemon = GameData::Species.get(params)
      params  = pokemon.species if pbMaxRaidBanList.include?(pokemon.id)
      params  = :DITTO          if pbMaxRaidBanList.include?(pokemon.species)
    else
      params  = :DITTO
    end
  end
  #-----------------------------------------------------------------------------
  # Builds an array of eligible species based on applied filters.
  #-----------------------------------------------------------------------------
  raidRank    = pbRaidRank(rank)
  raidSpecies = []
  for i in raidRank
    sp = GameData::Species.get(i)
    next if seasonal.include?(sp.species) && sp.form!=pbGetSeason
    #---------------------------------------------------------------------------
    # No specific filters apply when searching for a particular species_form.
    #---------------------------------------------------------------------------
    if pokemon_filter
      next if sp.id!=params
    #---------------------------------------------------------------------------
    # Filters that apply when searching for a species.
    #---------------------------------------------------------------------------
    elsif species_filter
      next if sp.species!=params
      next if regionalVariant?(sp)         && !encounterRegional?(sp,region)
      next if environ.include?(sp.species) && sp.form!=enviform
      next if timeday.include?(sp.species) && sp.form!=timeform
      next if sp.species==:VIVILLON && sp.form!=$Trainer.secret_ID%18
      next if sp.species==:FURFROU  && sp.form > 0
      next if i==:ZYGARDE_1
    #---------------------------------------------------------------------------
    # Filters that apply when generating species for the Max Raid Database.
    #---------------------------------------------------------------------------
    elsif database_filter
      next if type_filter    && (sp.type1!=params[0] && sp.type2!=params[0])
      next if habitat_filter && sp.habitat!=params[1]
      next if region_filter  && sp.generation!=params[2]
      next if dataform.include?(sp.species) && sp.form > 0
      next if sp.species==:VIVILLON && sp.form!=$Trainer.secret_ID%18
    #---------------------------------------------------------------------------
    # Filters that apply when generally searching for random species.
    #---------------------------------------------------------------------------
    else
      next if type_filter    && (sp.type1!=params[0] && sp.type2!=params[0])
      next if habitat_filter && sp.habitat!=params[1]
      next if region_filter  && sp.generation!=params[2]
      next if regionalVariant?(sp)         && !encounterRegional?(sp,region)
      next if environ.include?(sp.species) && sp.form!=enviform
      next if timeday.include?(sp.species) && sp.form!=timeform
      next if sp.species==:VIVILLON && sp.form!=$Trainer.secret_ID%18
      next if sp.species==:FURFROU  && sp.form > 0
      next if sp.species==:ETERNATUS
      next if sp.species==:UNOWN
      next if i==:ZYGARDE_1
    end
    raidSpecies.push(i)
  end
  return raidSpecies
end

def pbGenerateDenSpecies(*args)
  species = pbMaxRaidSpecies(*args)
  species = species[rand(species.length)]
  species = :DITTO if !species
  return species
end


#===============================================================================
# Max Raid Movesets
#-------------------------------------------------------------------------------
# Obtains arrays of eligible moves a species has to be used in a Max Raid.
#-------------------------------------------------------------------------------
def pbMaxRaidMovelists(pkmn,rental=false)
  stab_moves     = []
  coverage_moves = []
  spread_moves   = []
  status_moves   = []
  #-----------------------------------------------------------------------------
  # Moves that are ignored when compiling movelists.
  #-----------------------------------------------------------------------------
  blacklist  = ["0CE","0DE", # Sky Drop, Dream Eater
                "115","090", # Focus Punch, Hidden Power
                "012","174", # Fake Out, First Impression
                "0C2","0E0", # Recharge moves, Self-KO moves
                "0EC","125", # Circle Throw/Dragon Tail, Last Resort
                "195","196", # Steel Roller, Misty Explosion
                "192","03F"] # Poltergeist, Stat Down moves (Overheat, Draco Meteor, etc.)
  #-----------------------------------------------------------------------------
  # Eligible support moves.
  #-----------------------------------------------------------------------------
  whitelist  = ["0D6","0D7", # Roost, Wish
                "160","16D", # Strength Sap, Shore Up
                "0D5","0D8", # Heal moves, Weather heal moves
                "0DA","0DB", # Aqua Ring, Ingrain
                "02F","033", # +2 Defense moves, +2 Sp.Def moves
                "02A","034", # Cosmic Power, Minimize
                "0A2","0A3", # Reflect, Light Screen
                "01A","019", # Safeguard, Heal Bell
                "049","05B", # Defog, Tailwind
                "0DC","0BA", # Leech Seed, Taunt
                "148","186", # Powder, Tar Shot
                "061","197", # Soak, Magic Powder
                "141","051", # Topsy-Turvy, Haze
                "0AC","149", # Wide Guard, Mat Block
                "14B","14C", # King's Shield, Spiky Shield
                "168","14E", # Baneful Bunker, Geomancy
                "038","189", # Cotton Guard, Jungle Healing
                "181","180", # Octolock, Obstruct
                "17F","17E"] # No Retreat, Life Dew
  #-----------------------------------------------------------------------------
  # Additional moves considered only for Rental Pokemon in a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  if rental
    blacklist += ["0C9","0CA", # Fly, Dig
                  "0CB","158", # Dive, Belch
                  "199"]       # Behemoth Blade/Behemoth Bash
    whitelist += ["117","16A", # Follow Me, Spotlight
                  "0AF","16B", # Copycat, Instruct
                  "09C","0AA", # Helping Hand, Protect
                  "068","064", # Gastro Acid, Worry Seed
                  "065","0DF", # Role Play, Heal Pulse
                  "17B","18E"] # Decorate, Coaching
  end
  #-----------------------------------------------------------------------------
  # Creates arrays of eligible moves for this species.
  #-----------------------------------------------------------------------------
  pokemon    = GameData::Species.get(pkmn)
  species    = pokemon.species
  type1      = pokemon.type1
  type2      = pokemon.type2
  legalMoves = pbGetFamilyLegalMoves(pkmn)
  GameData::Move.each do |m|
    next if m.powerMove?
    next if !legalMoves.include?(m.id)
    next if blacklist.include?(m.function_code)
    next if m.accuracy>0 && m.accuracy<70
    stab = (m.type==type1 || m.type==type2)
    mult = (m.target==:AllNearFoes || m.target==:AllNearOthers)
    if whitelist.include?(m.function_code)
      status_moves.push(m.id)
    elsif m.base_damage>=55 && mult && !rental
      spread_moves.push(m.id)
    elsif stab && !mult && (m.base_damage>=75 || m.function_code=="086")
      stab_moves.push(m.id)
    elsif m.type!=:NORMAL && !mult && !stab && (m.base_damage>=75 || m.function_code=="086")
      coverage_moves.push(m.id)
    end 
    # Rental Pokemon in a Dynamax Adventure don't get spread moves.
    if rental && !mult
      spread_moves.push(m.id) if whitelist.include?(m.function_code) || m.base_damage>=75
    end
  end
  #-----------------------------------------------------------------------------
  # Forces certain moves onto specific species' movelists.
  #-----------------------------------------------------------------------------
  if    species==:SNORLAX;    status_moves.push(:REST);
  elsif species==:SHUCKLE;    status_moves.push(:POWERTRICK);
  elsif species==:SLAKING;    stab_moves.push(:GIGAIMPACT);
  elsif species==:CASTFORM;   stab_moves.push(:WEATHERBALL);
  elsif pokemon==:ROTOM_1;    stab_moves.push(:OVERHEAT);
  elsif pokemon==:ROTOM_2;    stab_moves.push(:HYDROPUMP);
  elsif pokemon==:ROTOM_3;    stab_moves.push(:BLIZZARD);
  elsif pokemon==:ROTOM_4;    stab_moves.push(:AIRSLASH);
  elsif pokemon==:ROTOM_5;    stab_moves.push(:LEAFSTORM);
  elsif species==:DARKRAI;    status_moves.push(:DARKVOID);
  elsif species==:GENESECT;   coverage_moves.push(:TECHNOBLAST);  
  elsif species==:ORICORIO;   stab_moves.push(:REVELATIONDANCE);
  elsif species==:MELMETAL;   stab_moves.push(:DOUBLEIRONBASH);
  elsif species==:SIRFETCHD;  stab_moves.push(:METEORASSAULT);
  elsif species==:DRAGAPULT;  spread_moves.push(:DRAGONDARTS);
  elsif pokemon==:URSHIFU_1;  stab_moves.push(:SURGINGSTRIKES);
  end
  return [stab_moves, coverage_moves, spread_moves, status_moves]
end

def pbCustomRaidSets(pokemon,form)
  if pokemon.isSpecies?(:ROTOM)        
    pokemon.learn_move(:OVERHEAT)  if form==1         # Required for Rotom Heat
    pokemon.learn_move(:HYDROPUMP) if form==2         # Required for Rotom Wash
    pokemon.learn_move(:BLIZZARD)  if form==3         # Required for Rotom Frost
    pokemon.learn_move(:AIRSLASH)  if form==4         # Required for Rotom Fan
    pokemon.learn_move(:LEAFSTORM) if form==5         # Required for Rotom Mow
  elsif pokemon.isSpecies?(:ZYGARDE)
    for i in pokemon.getAbilityList
      next if i[0]!=:POWERCONSTRUCT
      pokemon.ability_index = i[1]                    # Ensures Power Construct
    end
  elsif pokemon.isSpecies?(:ORICORIO)  
    pokemon.learn_move(:REVELATIONDANCE)              # Ensures Revelation Dance
  elsif pokemon.isSpecies?(:CRAMORANT) 
    pokemon.learn_move(:DIVE)                         # Ensures Dive
  elsif pokemon.isSpecies?(:MORPEKO)   
    pokemon.learn_move(:AURAWHEEL)                    # Ensures Aura Wheel
  end
end

#===============================================================================
# Max Raid Forms
#-------------------------------------------------------------------------------
# Gets the relevant display name of forms in the Max Raid Database.
#-------------------------------------------------------------------------------
def pbRaidFormName(species,dataPage=false)
  poke = GameData::Species.get(species)
  if dataPage
    hide_base_name = [:CASTFORM,:ROTOM,:GIRATINA,:ARCEUS,:KYUREM,:KELDEO,
	                  :MELOETTA,:GENESECT,:FURFROU,:AEGISLASH,:XERNEAS,:ZYGARDE,
					  :WISHIWASHI,:SILVALLY,:MIMIKYU,:CRAMORANT,:EISCUE,:MORPEKO]
    form_name = poke.form_name
    form_name = "Own Tempo" if poke.species==:ROCKRUFF && poke.form!=0
    form_name = form_name[0..12] + "..." if form_name.length > 15
    return form_name if poke.form>0 || (!hide_base_name.include?(poke.id))
    return ""
  else
    show_base_name = [:BURMY,:WORMADAM,:SHELLOS,:GASTRODON,:BASCULIN,:DEERLING,
                      :SAWSBUCK,:MEOWSTIC,:ORICORIO,:LYCANROC,:INDEEDEE,:TOXTRICITY,:URSHIFU]
    if show_base_name.include?(poke.id) || poke.form>0
      form_name = poke.form_name
      form_name = form_name[0..12] + "..." if form_name.length > 15
      return _INTL("{1} ({2})",poke.name,form_name) if form_name
    end
    return _INTL("{1}",poke.name)
  end
end

#-------------------------------------------------------------------------------
# Determines if a species is a regional form, and if it may be encountered.
#-------------------------------------------------------------------------------
def regionalVariant?(species)
  regional = false
  for i in Settings::REGIONAL_FORMS
    break if species.form_name.include?("Zen Mode")
    if species.form_name.include?(i[0])
	  regional = true
	  break
	end
  end
  return regional
end

def encounterRegional?(species,region)
  encounter = false
  for i in Settings::REGIONAL_FORMS
    if species.form_name.include?(i[0]) && region==i[1]
      encounter = true
      break
    end
  end
  return encounter
end

#-------------------------------------------------------------------------------
# Returns an array of ID's for all eligible forms of a species.
#-------------------------------------------------------------------------------
def pbGetAvailableRaidForms(pkmn)
  ret = []
  GameData::Species.each do |sp|
    next if sp.species != pkmn
    next if pbMaxRaidBanList.include?(sp.id)
    ret.push(sp.id)
  end
  return ret
end

#-------------------------------------------------------------------------------
# Returns true if the inputted species has cosmetic gender differences.
#-------------------------------------------------------------------------------
def pbGenderedSpeciesIcons?(species)
  return true if pbResolveBitmap(sprintf("Graphics/Pokemon/Icons/%s_female",species))
end

#===============================================================================
# Creates a Max Raid battler.
#===============================================================================  
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::MAXRAID_SWITCH]
    #---------------------------------------------------------------------------
    # Gets raid boss attributes depending on the type of event.
    #---------------------------------------------------------------------------
    hardmode   = $game_switches[Settings::HARDMODE_RAID]
    thisMap    = $game_map.map_id
    thisEvent  = pbMapInterpreter.get_character(0)
    thisEvent  = (thisEvent) ? thisEvent.id : 0
    mapOffset  = (thisEvent>0) ? thisMap*100 : 0
    storedPkmn =  mapOffset + thisEvent + Settings::MAXRAID_PKMN
    stored     = $game_variables[storedPkmn]
    # Max Raid Database
    if $game_variables[Settings::MAXRAID_PKMN].is_a?(Array)
      raidtype   = 0
      bosspoke   = $game_variables[Settings::MAXRAID_PKMN][0]
      bossform   = $game_variables[Settings::MAXRAID_PKMN][1]
      bossgender = $game_variables[Settings::MAXRAID_PKMN][2]
      bosslevel  = $game_variables[Settings::MAXRAID_PKMN][3]
      gmax       = $game_variables[Settings::MAXRAID_PKMN][4]
    # Max Raid Den
    else
      existing   = true if stored.is_a?(Pokemon)
      raidtype   = (existing) ? 2 : 1
      bosspoke   = (existing) ? stored.species     : stored[0]
      bossform   = (existing) ? stored.form        : stored[1]
      bossgender = (existing) ? stored.gender      : stored[2]
      bosslevel  = (existing) ? stored.level       : stored[3]
      gmax       = (existing) ? stored.gmaxFactor? : stored[4]
      if raidtype==2
        pokemon.moves         = stored.moves
        pokemon.nature        = stored.nature
        pokemon.ability_index = stored.ability_index
        pokemon.shiny = true  if stored.shiny?
        pokemon.makeShadow    if stored.shadowPokemon?
        GameData::Stat.each_main do |s|
          pokemon.iv[s.id] = stored.iv[s.id]
        end
      end
    end
    #---------------------------------------------------------------------------
    # Gets the raid rank and Dynamax Level based on raid Pokemon's level.
    #---------------------------------------------------------------------------
    rank = 1
    rank = 2  if bosslevel>=30
    rank = 3  if bosslevel>=40
    rank = 4  if bosslevel>=50
    rank = 5  if bosslevel>=60
    rank = 6  if bosslevel>=70
    dlvl = 5
    dlvl = 10 if rank==2
    dlvl = 20 if rank==3
    dlvl = 30 if rank==4
    dlvl = 40 if rank==5
    dlvl = 50 if rank==6
    dlvl+= rank*2 if hardmode
    #---------------------------------------------------------------------------
    # Sets the raid attributes for a newly generated wild species.
    #---------------------------------------------------------------------------
    species_id      = GameData::Species.get_species_form(bosspoke, bossform)
    pokemon.species = species_id
    if raidtype < 2
      raidmoves = pbMaxRaidMovelists(species_id)
      move1     = raidmoves[0][rand(raidmoves[0].length)]
      move2     = raidmoves[1][rand(raidmoves[1].length)]
      move3     = raidmoves[2][rand(raidmoves[2].length)]
      move4     = raidmoves[3][rand(raidmoves[3].length)]
      pokemon.learn_move(move1) if raidmoves[0].length>0
      pokemon.learn_move(move2) if raidmoves[1].length>0
      pokemon.learn_move(move3) if raidmoves[2].length>0
      pokemon.learn_move(move4) if raidmoves[3].length>0
      pokemon.ability_index = 2 if rank==4  && rand(10)<2
      pokemon.ability_index = 2 if rank==5  && rand(10)<5
      pokemon.ability_index = 2 if hardmode && rand(10)<8
      # Scales randomized IV's to match the raid level.
      maxIV = 1
      stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
      pokemon.iv[stats[rand(stats.length)]] = 31
      for stat in stats.shuffle
        next if pokemon.iv[stat]==31
        maxIV += 1
        pokemon.iv[stat] = 31
        break if maxIV>=rank
      end
    end
    gmax = true if bosspoke==:ETERNATUS
    pbCustomRaidSets(pokemon,bossform) if raidtype < 2
    pokemon.gender = bossgender
    pokemon.item   = 0
    pokemon.setDynamaxLvl(dlvl)
    pokemon.giveGMaxFactor if pokemon.hasGmax? && gmax
    pokemon.obtain_text = _INTL("Max Raid Den.") if raidtype > 0
    pokemon.obtain_text = _INTL("Max Lair.") if pbInDynAdventure?
    pokemon.shiny = false if pbInDynAdventure? 
    pokemon.makeDynamax
    pokemon.calc_stats
    pokemon.hp = pokemon.totalhp
    pokemon.pbReversion(true)
    $game_variables[storedPkmn] = pokemon if raidtype > 0
  end
}

#===============================================================================
# Other Utilities.
#-------------------------------------------------------------------------------
# General reset function for Max Raid battle settings.
#-------------------------------------------------------------------------------
def pbResetRaidSettings
  $game_switches[Settings::MAXRAID_SWITCH]  = false
  $game_switches[Settings::HARDMODE_RAID]   = false
  $game_variables[Settings::MAXRAID_PKMN]   = nil
  $game_variables[Settings::REWARD_BONUSES] = [Settings::MAXRAID_TIMER,true,true] # Timer, Perfect, Fairness
end

#-------------------------------------------------------------------------------
# Gets TR raid rewards from a Pokemon's type.
#-------------------------------------------------------------------------------
def pbTechnicalRecordByType(pokemon)
  trList = []
  if pokemon.is_a?(Pokemon)
    type1 = pokemon.type1
    type2 = pokemon.type2
  else
    type1 = GameData::Species.get(pokemon).type1
    type2 = GameData::Species.get(pokemon).type2
  end
  GameData::Item.each do |i|
    next if !i.is_TR?
    movetype = GameData::Move.get(i.move).type
    next if ![type1,type2].include?(movetype)
    trList.push(i.id)
  end
  return trList
end

#-------------------------------------------------------------------------------
# Gets every eligible move in an entire family's learn set.
#-------------------------------------------------------------------------------
def pbGetFamilyLegalMoves(species)
  spec_dat  = GameData::Species.get(species)
  spec_form = GameData::Species.get_form(species)
  moves = []
  return moves if !spec_dat
  prevspecies = spec_dat.get_previous_species
  babyspecies = spec_dat.get_baby_species
  prev_id     = GameData::Species.get_species_form(prevspecies, spec_form) || prevspecies  
  baby_id     = GameData::Species.get_species_form(babyspecies, spec_form) || babyspecies
  spec_dat.moves.each { |m| moves.push(m[1]) }
  spec_dat.tutor_moves.each { |m| moves.push(m) }
  GameData::Species.get(prev_id).moves.each { |m| moves.push(m[1]) } if prev_id!=species
  GameData::Species.get(baby_id).moves.each { |m| moves.push(m[1]) } if baby_id!=species
  GameData::Species.get(baby_id).egg_moves.each { |m| moves.push(m) }
  moves |= []
  return moves
end

#-------------------------------------------------------------------------------
# Fix to get a species' base stat total.
#-------------------------------------------------------------------------------
def pbBaseStatTotal(species)
  baseStats = GameData::Species.get(species).base_stats
  ret = 0
  baseStats.each { |s| ret += s[1] }
  return ret
end