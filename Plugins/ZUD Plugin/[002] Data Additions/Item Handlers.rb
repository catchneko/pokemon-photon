#===============================================================================
# Item handlers.
#===============================================================================
# Z-Crystal properties.
module GameData
  class Item
    def is_z_crystal?; return @type == 14; end
      
    def is_important?
      return true if is_key_item? || is_HM? || is_TM? || is_z_crystal?
      return false
    end
	
    alias _ZUD_unlosable? unlosable?
    def unlosable?(*args)
      return true if is_z_crystal?
      _ZUD_unlosable?(*args)
    end
  end
end

# Prevents Z-Crystals from duplicating in the bag.
class PokemonBag
  alias _ZUD_pbStoreItem pbStoreItem
  def pbStoreItem(*args)
    if pbHasItem?(args[0]) && GameData::Item.get(args[0]).is_z_crystal?
      args[1] = 0 
    end
    _ZUD_pbStoreItem(*args)
  end
end

#-------------------------------------------------------------------------------
# Z-Crystals - Equips a holdable crystal upon use.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:NORMALIUMZ,proc { |item,pkmn,scene|
  crystalname = GameData::Item.get(item).name
  zcomp       = pkmn.compat_zmove?(pkmn.moves, item)
  next false if pkmn.egg? && scene.pbDisplay(_INTL("Eggs can't hold items."))
  next false if pkmn.shadowPokemon? && scene.pbDisplay(_INTL("Shadow Pokémon can't use Z-Moves."))
  next false if pkmn.item==item && scene.pbDisplay(_INTL("{1} is already holding {2}.",pkmn.name,crystalname))
  next false if !zcomp && !scene.pbConfirm(_INTL("This Pokémon currently can't use this crystal's Z-Power. Is that OK?"))
  scene.pbDisplay(_INTL("The {1} will be given to the Pokémon so that the Pokémon can use its Z-Power!",crystalname))
  if pkmn.item
    itemname = GameData::Item.get(pkmn.item).name
    scene.pbDisplay(_INTL("{1} is already holding a {2}.\1",pkmn.name,itemname))
    if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
      if !$PokemonBag.pbCanStore?(pkmn.item)
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        next false
      else
        $PokemonBag.pbStoreItem(pkmn.item)
        scene.pbDisplay(_INTL("You took the Pokémon's {1} and gave it the {2}.",itemname,crystalname))
      end
    else
      next false
    end
  end
  pkmn.item = item
  pbSEPlay("Pkmn move learnt")
  scene.pbDisplay(_INTL("Your Pokémon is now holding {1}!",crystalname))
  next true
})

ItemHandlers::UseOnPokemon.copy(:NORMALIUMZ, :FIRIUMZ,    :WATERIUMZ,  :ELECTRIUMZ,  :GRASSIUMZ,
			                    :ICIUMZ,     :FIGHTINIUMZ,:POISONIUMZ, :GROUNDIUMZ,  :FLYINIUMZ,  
			                    :PSYCHIUMZ,  :BUGINIUMZ,  :ROCKIUMZ,   :GHOSTIUMZ,   :DRAGONIUMZ,
			                    :DARKINIUMZ, :STEELIUMZ,  :FAIRIUMZ,   :ALORAICHIUMZ,:DECIDIUMZ,
			                    :INCINIUMZ,  :PRIMARIUMZ, :EEVIUMZ,    :PIKANIUMZ,   :SNORLIUMZ, 
			                    :MEWNIUMZ,   :TAPUNIUMZ,  :MARSHADIUMZ,:PIKASHUNIUMZ,:KOMMONIUMZ,
			                    :LYCANIUMZ,  :MIMIKIUMZ,  :LUNALIUMZ,  :SOLGANIUMZ,  :ULTRANECROZIUMZ)

#-------------------------------------------------------------------------------
# Dynamax Candy/XL - Increases the Dynamax Level of a Pokemon.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:DYNAMAXCANDY,proc { |item,pkmn,scene|
  if pkmn.dynamax_lvl<10 && pkmn.dynamaxAble?
    pbSEPlay("Pkmn move learnt")
    if item == :DYNAMAXCANDYXL
      scene.pbDisplay(_INTL("{1}'s Dynamax level was increased to 10!",pkmn.name))
      pkmn.setDynamaxLvl(10)
    else
      scene.pbDisplay(_INTL("{1}'s Dynamax level was increased by 1!",pkmn.name))
      pkmn.addDynamaxLvl
    end
    scene.pbHardRefresh
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.copy(:DYNAMAXCANDY,:DYNAMAXCANDYXL)

#-------------------------------------------------------------------------------
# Max Soup - Toggles Gigantamax Factor.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSOUP,proc { |item,pkmn,scene|
  if pkmn.hasGmax?
    if pkmn.gmaxFactor?
      pkmn.removeGMaxFactor
      scene.pbDisplay(_INTL("{1} lost its Gigantamax energy.",pkmn.name))
    else
      pkmn.giveGMaxFactor
      pbSEPlay("Pkmn move learnt")
      scene.pbDisplay(_INTL("{1} is now bursting with Gigantamax energy!",pkmn.name))
    end
    scene.pbHardRefresh
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

#-------------------------------------------------------------------------------
# Max Scales - Allows a Pokemon to recall a past move.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXSCALES,proc { |item,pkmn,scene|
  moves = []
  pkmn.getMoveList.each do |m|
    next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
    moves.push(m[1]) if !moves.include?(m[1])
  end
  tmoves = []
  if pkmn.first_moves
    for i in pkmn.first_moves
      tmoves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)
    end
  end
  moves = tmoves + moves
  if moves.length>0 && !pkmn.egg? && !pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("What move should {1} recall?",pkmn.name))
    m = pkmn.moves
    oldmoves = [m[0],m[1],m[2],m[3]]
    pbRelearnMoveScreen(pkmn)
    newmoves = pkmn.moves
    next false if newmoves==oldmoves
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

#-------------------------------------------------------------------------------
# Max Plumage - Increases each IV of a Pokemon by 1 point.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:MAXPLUMAGE,proc { |item,pkmn,scene|
  used = false
  GameData::Stat.each_main do |s|
    next if pkmn.iv[s.id]==Pokemon::IV_STAT_LIMIT
    pkmn.iv[s.id] += 1
    used = true
  end
  if used
    pbSEPlay("Pkmn move learnt")
    scene.pbDisplay(_INTL("{1}'s base stats each increased by 1!",pkmn.name))
	  pkmn.calc_stats
	  scene.pbHardRefresh
	  next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

#-------------------------------------------------------------------------------
# Max Eggs - Increases the party's Exp. by a large amount relative to badge count.
#-------------------------------------------------------------------------------
ItemHandlers::UseInField.add(:MAXEGGS,proc { |item|
  gainers     = false
  experience  = 2500
  experience *= $Trainer.badge_count if $Trainer.badge_count>1
  experience  = 20000 if experience>20000
  pbFadeOutIn {
    scene  = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene((_INTL("Consuming the {1}...",GameData::Item.get(item).name)),false)
    for i in $Trainer.pokemon_party
      next if i.level>=GameData::GrowthRate.max_level || i.shadowPokemon? || i.egg?
      gainers    = true
      maxexp     = i.growth_rate.maximum_exp
      newexp     = i.growth_rate.add_exp(i.exp,experience)
      newlevel   = i.growth_rate.level_from_exp(newexp)
      curlevel   = i.level
      leveldif   = newlevel - curlevel
      experience = (maxexp-i.exp) if maxexp < (i.exp + experience)
      screen.pbDisplay(_INTL("{1} gained {2} Exp. Points!",i.name,experience.to_s_formatted))
      leveldif.times do
        pbSEPlay("Pkmn move learnt")
        pbChangeLevel(i,i.level+1,screen)
        screen.pbRefreshSingle(i)
      end
      i.exp = newexp
      screen.pbRefreshSingle(i)
    end
    pbMessage(_INTL("It won't have any effect.")) if !gainers
    screen.pbEndScene
    next (gainers) ? 3 : 0
  }
})

#-------------------------------------------------------------------------------
# Max Crystal - Restores your ability to Dynamax if already used in battle.
#-------------------------------------------------------------------------------
ItemHandlers::CanUseInBattle.add(:MAXCRYSTAL,proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
  side        = battler.idxOwnSide
  owner       = battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
  dmaxInUse   = false
  battle.eachSameSideBattler(battler) { |b| dmaxInUse = true if b.dynamax? }
  if !battle.pbHasDynamaxBand?(battler.index)
    scene.pbDisplay(_INTL("You don't have a Dynamax Band to charge!"))
    next false
  elsif !firstAction
    scene.pbDisplay(_INTL("You can't use this item while issuing orders at the same time!"))
    next false
  elsif dmaxInUse || battle.dynamax[side][owner]==-1
    if showMessages
      scene.pbDisplay(_INTL("Your Dynamax Band doesn't currently need to be recharged!"))
    end
    next false
  end
  next true
})

ItemHandlers::UseInBattle.add(:MAXCRYSTAL,proc { |item,battler,battle|
  side        = battler.idxOwnSide
  owner       = battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
  trainerName = battle.pbGetOwnerName(battler.index)
  battle.dynamax[side][owner] = -1
  pbSEPlay(sprintf("Anim/Lucky Chant"))
  battle.pbDisplayPaused(_INTL("{1}'s Dynamax Band was fully recharged!\nDynamax is now usable again!",trainerName))
})

# Using a Max Crystal uses up the player's entire turn.
class PokeBattle_Battle
  alias _ZUD_pbItemUsesAllActions? pbItemUsesAllActions?
  def pbItemUsesAllActions?(item)
    return true if item==:MAXCRYSTAL
    return _ZUD_pbItemUsesAllActions?(item)
  end
end