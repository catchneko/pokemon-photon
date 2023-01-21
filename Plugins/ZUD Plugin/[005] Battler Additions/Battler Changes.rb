#===============================================================================
# Changes elements of a battler.
#===============================================================================
class PokeBattle_Battler
  
  #-----------------------------------------------------------------------------
  # HP reduction is based on the user's non-Dynamax HP.
  #-----------------------------------------------------------------------------
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true,ignoreDynamax=false)
    if ignoreDynamax; amt = amt.round
    else;             amt = (amt/self.dynamaxBoost).round
    end
    amt = @hp if amt>@hp
    amt = 1 if amt<1 && !fainted?
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    @tookDamage = true if amt>0 && registerDamage
    return amt
  end

  #-----------------------------------------------------------------------------
  # HP recovery is based on the user's non-Dynamax HP.
  #-----------------------------------------------------------------------------
  def pbRecoverHP(amt,anim=true,anyAnim=true,ignoreDynamax=false)
    if ignoreDynamax; amt = amt.round
    else;             amt = (amt/self.dynamaxBoost).round
    end
    amt = @totalhp-@hp if amt>@totalhp-@hp
    amt = 1 if amt<1 && @hp<@totalhp
    oldHP = @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    self.damage_done = 0 if GameData::Evolution.exists?(:damage_done)
    return amt
  end
  
  def pbRecoverHPFromDrain(amt,target,msg=nil)
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!",target.pbThis) if !msg || msg==""
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt*1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt,true,true,true) # Drain moves ignore Dynamax.
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Un-Dynamaxes a Pokemon upon fainting. Also makes Max Raid-related checks.
  #-----------------------------------------------------------------------------
  def pbFaint(showMessage=true)
    if @battle.decision==0 && !pbOwnedByPlayer? && @effects[PBEffects::MaxRaidBoss]
      self.hp += 1
      pbCatchRaidPokemon(self)
    else
      if !fainted?
        PBDebug.log("!!!***Can't faint with HP greater than 0")
        return
      end
      return if @fainted
	  self.unmax if dynamax?  # Reverts Dynamax upon fainting.
      @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
      PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
      @battle.scene.pbFaintBattler(self)
      pbInitEffects(false)
      self.status      = :NONE
      self.statusCount = 0
      if @pokemon && @battle.internalBattle
        badLoss = false
        @battle.eachOtherSideBattler(@index) do |b|
          badLoss = true if b.level>=self.level+30
        end
        @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
      end
      @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
      @pokemon.makeUnmega   if mega?
      @pokemon.makeUnprimal if primal?
      @pokemon.makeUnUltra  if ultra?    # Reverts Ultra Burst upon fainting.
      self.damage_done = 0 if GameData::Evolution.exists?(:damage_done)
      @battle.pbClearChoice(@index)
      pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
      pbAbilitiesOnFainting
      @battle.pbEndPrimordialWeather
      # Reduces the KO counter in Max Raid battles if your Pokemon are KO'd. 
      pbRaidKOCounter(self.pbDirectOpposing) if $game_switches[Settings::MAXRAID_SWITCH]
	  @battle.pbSetBattled(self) if Settings::GEN8_COMPAT
    end
  end
  
  #=============================================================================
  # Transform copies relevant Dynamax-related attributes.
  #=============================================================================
  # -Stores base moves of the Transform target as user's new base moves.
  # -Stores the Pokemon data of the Transform target.
  # -Copies the base moves of a Dynamaxed Transform target.
  # -Gets the correct Max Moves if the user is Dynamaxed prior to transforming.
  #-----------------------------------------------------------------------------
  def pbTransform(target)
    oldAbil = @ability_id
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    @effects[PBEffects::TransformPokemon] = target.pokemon
    pbChangeTypes(target)
	self.ability = target.ability
    @attack  = target.attack
    @defense = target.defense
    @spatk   = target.spatk
    @spdef   = target.spdef
    @speed   = target.speed
    GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m,i|
      if target.dynamax?
        basemove  = target.effects[PBEffects::BaseMoves][i].id
        @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(basemove))
      else
        @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
      end
      @moves[i].pp       = 5
      @moves[i].total_pp = 5
    end 
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = 0
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    pbDisplayPowerMoves(2) if @pokemon.dynamax? # Converts new moves to Max Moves if Dynamaxed.
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,target.pbThis(true)))
    pbOnAbilityChanged(oldAbil)
  end
end

#-------------------------------------------------------------------------------
# Ensures Ultra Necrozma reverts from Ultra Burst after battle.
#-------------------------------------------------------------------------------
alias _ZUD_pbAfterBattle pbAfterBattle
def pbAfterBattle(*args)
  $Trainer.party.each do |pkmn|
    pkmn.makeUnUltra
  end
  if $PokemonGlobal.partner
    $Trainer.heal_party
    $PokemonGlobal.partner[3].each do |pkmn|
      pkmn.heal
      pkmn.makeUnmega
      pkmn.makeUnprimal
      pkmn.makeUnUltra
    end
  end
  # Compatibility with Modular Battle Scene
  if Settings::EMBS_COMPAT && $PokemonSystem.activebattle>=1
    $PokemonSystem.activebattle=0
    embEndOfBattleResize
  end
  _ZUD_pbAfterBattle(*args)
end