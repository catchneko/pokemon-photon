#===============================================================================
# New battler properties.
#===============================================================================
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  # Initializes new battler effects.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbInitEffects pbInitEffects  
  def pbInitEffects(batonPass)
    _ZUD_pbInitEffects(batonPass)
    @lastMoveUsedIsZMove                  = false
    @effects[PBEffects::BaseMoves]        = []
    @effects[PBEffects::CriticalBoost]    = 0
    @effects[PBEffects::Dynamax]          = 0
    @effects[PBEffects::MaxGuard]         = false
    @effects[PBEffects::MaxMovePP]        = [0,0,0,0]
    @effects[PBEffects::MoveMimicked]     = false
    @effects[PBEffects::EncoreRestore]    = nil
    @effects[PBEffects::NonGMaxForm]      = nil
    @effects[PBEffects::PowerMovesButton] = false
    @effects[PBEffects::TransformPokemon] = nil
    @effects[PBEffects::UsedZMoveIndex]   = -1
    @effects[PBEffects::MaxRaidBoss]      = false
    @effects[PBEffects::RaidShield]       = -1
    @effects[PBEffects::MaxShieldHP]      = -1
    @effects[PBEffects::ShieldCounter]    = -1
    @effects[PBEffects::KnockOutCount]    = -1
    pbInitRaidBoss if $game_switches[Settings::MAXRAID_SWITCH]
  end
    
  #-----------------------------------------------------------------------------
  # Checks if the battler is in one of these modes.
  #-----------------------------------------------------------------------------
  def ultra?;       return @pokemon && @pokemon.ultra?;       end
  def dynamax?;     return @pokemon && @pokemon.dynamax?;     end
  def gmax?;        return @pokemon && @pokemon.gmax?;        end
    
  #-----------------------------------------------------------------------------
  # Checks various Dynamax conditions.
  #-----------------------------------------------------------------------------
  def dynamaxAble?; return @pokemon && @pokemon.dynamaxAble?; end
  def dynamaxBoost; return @pokemon && @pokemon.dynamaxBoost; end
  def gmaxFactor?;  return @pokemon && @pokemon.gmaxFactor?;  end
    
  #-----------------------------------------------------------------------------
  # Gets the non-Dynamax HP of a Pokemon.
  #-----------------------------------------------------------------------------
  def realhp;       return @pokemon && @pokemon.realhp;       end
  def realtotalhp;  return @pokemon && @pokemon.realtotalhp;  end
    
  #-----------------------------------------------------------------------------
  # Checks if the battler is capable of using any of the following mechanics.
  #-----------------------------------------------------------------------------
  def pbCompatibleZMove?(move=nil)
    transform = @effects[PBEffects::Transform]
    newpoke   = @effects[PBEffects::TransformPokemon]
    species   = (transform) ? newpoke.species_data.id : nil
    return false if transform && hasActiveItem?(:ULTRANECROZIUMZ)
    return @pokemon.compat_zmove?(move, nil, species)
  end
  
  def hasZMove?
    return false if shadowPokemon?
    return false if primal? || hasPrimal?
    return pbCompatibleZMove?(@moves)
  end
  
  def hasUltra?
    return false if @effects[PBEffects::Transform]
    return false if shadowPokemon?
    return false if mega?   || hasMega?
    return false if primal? || hasPrimal?
    return false if ultra?
    return @pokemon && pokemon.hasUltra?
  end
  
  def hasDynamax?
    transform  = @effects[PBEffects::Transform] || @effects[PBEffects::Illusion]
    newpoke    = @effects[PBEffects::TransformPokemon] if @effects[PBEffects::Transform]
    newpoke    = @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]
    pokemon    = transform ? newpoke : @pokemon
    powerspot  = $game_map && Settings::POWERSPOTS.include?($game_map.map_id)
    eternaspot = $game_map && Settings::ETERNASPOT.include?($game_map.map_id)
	return false if hasActiveItem?(:BLUEORB) || hasActiveItem?(:REDORB)
	return false if self.item && GameData::Item.get(self.item).is_mega_stone?
	return false if self.item && GameData::Item.get(self.item).is_z_crystal?
    return true if isSpecies?(:ETERNATUS) && gmaxFactor? && eternaspot && !transform
    return false if !pokemon.dynamaxAble?
    return false if !powerspot && !Settings::DMAX_ANYMAP
    return false if shadowPokemon?
    return false if hasZMove?
    return false if pokemon.mega?   || hasMega?
    return false if pokemon.primal? || hasPrimal?
    return false if pokemon.ultra?  || hasUltra?
    return true
  end
  
  def hasGmax?
    return false if !hasDynamax?
    return @pokemon && @pokemon.hasGmax?
  end
  
  def canGmax?
    return true if hasGmax? && gmaxFactor?
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Reverts the effects of Dynamax.
  #-----------------------------------------------------------------------------
  def pbUndynamax
    @pokemon.makeUndynamax
    pbUpdate(false)
    @pokemon.pbReversion
    if !@effects[PBEffects::MaxRaidBoss]
      pbDisplayBaseMoves(2)
      @effects[PBEffects::Dynamax]          = 0
      @effects[PBEffects::MaxMovePP]        = [0,0,0,0]
      @effects[PBEffects::PowerMovesButton] = false
	  @battle.pbCommonAnimation("UnDynamax",self) if Settings::GEN8_COMPAT && @battle.scene.pbCommonAnimationExists?("UnDynamax")
      self.form = @effects[PBEffects::NonGMaxForm] if isSpecies?(:ALCREMIE)
      @battle.scene.pbChangePokemon(self,@pokemon)
	  if @effects[PBEffects::Transform]
	    back = !opposes?(self.index)
	    pkmn = @effects[PBEffects::TransformPokemon]
	    @battle.scene.sprites["pokemon_#{self.index}"].setPokemonBitmap(pkmn,back,nil,self)
	  end
      @battle.scene.pbHPChanged(self,totalhp) if !fainted?
	  text = "Dynamax"
      text = "Gigantamax" if gmax?
      text = "Eternamax"  if isSpecies?(:ETERNATUS)
      @battle.pbDisplay(_INTL("{1}'s {2} energy left its body!",pbThis,text))
      @battle.scene.pbRefresh
    end
  end
  alias unmax pbUndynamax
end

#===============================================================================
# Safari Zone compatibility
#===============================================================================
class PokeBattle_FakeBattler
  def ultra?;       return false; end
  def dynamax?;     return false; end
  def gmax?;        return false; end
  def dynamaxAble?; return false; end
  def gmaxFactor?;  return @pokemon.gmaxFactor?;  end
  def dynamaxBoost; return @pokemon.dynamaxBoost; end
end