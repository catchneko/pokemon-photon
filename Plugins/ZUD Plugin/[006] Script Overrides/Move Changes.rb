#===============================================================================
# Two-Turn Attaks (Fly, Dig, Dive, etc.)
#===============================================================================
# Max Raid Pokemon skip charge turn of moves that make them semi-invulnerable.
#-------------------------------------------------------------------------------
class PokeBattle_TwoTurnMove < PokeBattle_Move
  def pbIsChargingTurn?(user)
    @powerHerb = false
    @chargingTurn = false
    @damagingTurn = true
    if !user.effects[PBEffects::TwoTurnAttack]
      @powerHerb = user.hasActiveItem?(:POWERHERB)
      @chargingTurn = true
      @damagingTurn = @powerHerb
      if user.effects[PBEffects::MaxRaidBoss] &&
         ["0C9","0CA","0CB","0CC","0CD","0CE","14D"].include?(@function)
        @damagingTurn = true
      end
    end
    return !@damagingTurn
  end
end

#===============================================================================
# Defog
#===============================================================================
# Clears away hazard applied with G-Max Steelsurge.
#-------------------------------------------------------------------------------
class PokeBattle_Move_049 < PokeBattle_TargetStatDownMove
  alias _ZUD_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user,target)
    return false if Settings::MECHANICS_GENERATION >= 6 && target.pbOpposingSide.effects[PBEffects::Steelsurge]
    _ZUD_pbFailsAgainstTarget?(user,target)
  end
  
  alias _ZUD_pbEffectAgainstTarget pbEffectAgainstTarget
  def pbEffectAgainstTarget(user,target)
    _ZUD_pbEffectAgainstTarget(user,target)
	  if target.pbOwnSide.effects[PBEffects::Steelsurge] ||
       (Settings::MECHANICS_GENERATION >= 6 && target.pbOpposingSide.effects[PBEffects::Steelsurge])
      target.pbOwnSide.effects[PBEffects::Steelsurge]      = false
      target.pbOpposingSide.effects[PBEffects::Steelsurge] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
  end
end

#===============================================================================
# Pain Split
#===============================================================================
# Changes to HP is based on user/target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    newHP = (user.realhp+target.realhp)/2
    if user.realhp>newHP;    user.pbReduceHP(user.realhp-newHP,false,false,true,true)
    elsif user.realhp<newHP; user.pbRecoverHP(newHP-user.realhp,false,true,true)
    end
    if target.realhp>newHP;    target.pbReduceHP(target.realhp-newHP,false,false,true,true)
    elsif target.realhp<newHP; target.pbRecoverHP(newHP-target.realhp,false,true,true)
    end
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    user.pbItemHPHealCheck
    target.pbItemHPHealCheck
  end
end

#===============================================================================
# Mimic
#===============================================================================
# Move fails when attempting to Mimic a Z-Move/Max Move.
# Records mimicked move as a new base move to revert to after Z-Move/Dynamax.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05C < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
    if !lastMoveData ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData.function_code) ||
       lastMoveData.type == :SHADOW || lastMoveData.powerMove?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  # Records the correct move to revert to after Z-Move/Dynamax.
  def pbEffectAgainstTarget(user,target)
      user.effects[PBEffects::BaseMoves]    = []
	  user.effects[PBEffects::MoveMimicked] = true
      for i in 0...user.pokemon.moves.length
        battlemove = PokeBattle_Move.from_pokemon_move(@battle,user.pokemon.moves[i])
        user.effects[PBEffects::BaseMoves].push(battlemove)
      end
      user.eachMoveWithIndex do |m,i|
      next if m.id!=@id
      newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
      user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,newMove)
	    user.effects[PBEffects::BaseMoves][i] = user.moves[i]
      @battle.pbDisplay(_INTL("{1} learned {2}!",user.pbThis,newMove.name))
      user.pbCheckFormOnMovesetChange
      break
    end
  end
end

#===============================================================================
# Sketch
#===============================================================================
# Move fails when attempting to Sketch a Z-Move/Max Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_05D < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
    if !lastMoveData ||
       user.pbHasMove?(target.lastRegularMoveUsed) ||
       @moveBlacklist.include?(lastMoveData.function_code) ||
       lastMoveData.type = :SHADOW || lastMoveData.powerMove?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Transform
#===============================================================================
# Move fails if the user is Dynamaxed and attempts to Transform into a species
# that is unable to have a Dynamax form.
#-------------------------------------------------------------------------------
class PokeBattle_Move_069 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Transform] ||
       target.effects[PBEffects::Illusion]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if user.dynamax? && !target.dynamaxAble?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Super Fang
#===============================================================================
# Damage dealt is based on the target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return (target.realhp/2.0).round
  end
end

#===============================================================================
# Endeavor
#===============================================================================
# Damage dealt is based on the user/target's non-Dynamax HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_06E < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return target.realhp-user.realhp
  end
end

#===============================================================================
# Copycat
#===============================================================================
# Move fails when the last used move was a Z-Move.
# If last move used was a Max Move, copies the base move of that Max Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0AF < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !@copied_move || GameData::Move.get(@copied_move).zMove? ||
       @moveBlacklist.include?(GameData::Move.get(@copied_move).function_code)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def pbChangeUsageCounters(user,specialUsage)
    super
    @copied_move = @battle.lastMoveUsed
    @copy_target = @battle.lastMoveUser
  end
  
  def pbEffectGeneral(user)
    if @copied_move && GameData::Move.get(@copied_move).maxMove?
      @battle.eachBattler do |b|
        next if b.index!=@copy_target
        idxMove = @battle.choices[b.index][1]
        @copied_move = b.effects[PBEffects::BaseMoves][idxMove].id
      end
    end
    user.pbUseMoveSimple(@copied_move)
  end
end

#===============================================================================
# Me First
#===============================================================================
# Move fails when attempting to copy a target's Z-Move/Max Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B0 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return true if pbMoveFailedTargetAlreadyMoved?(target)
    oppMove = @battle.choices[target.index][2]
    if !oppMove || oppMove.statusMove? || @moveBlacklist.include?(oppMove.function) || oppMove.powerMove?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Sleep Talk
#===============================================================================
# Z-Sleep Talk will use the Z-Powered version of the random move selected.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbEffectGeneral(user)
    choice = @sleepTalkMoves[@battle.pbRandom(@sleepTalkMoves.length)]
    user.pbUseMoveSimple(user.moves[choice].id,user.pbDirectOpposing.index, choice)
  end
end

#===============================================================================
# Assist
#===============================================================================
# Ignores Z-Moves/Max Moves when calling a move in the party.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @assistMoves = []
    @battle.pbParty(user.index).each_with_index do |pkmn,i|
      next if !pkmn || i==user.pokemonIndex
      next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
      pkmn.moves.each do |move|
	    next if move.powerMove?
        next if @moveBlacklist.include?(move.function_code)
        next if move.type == :SHADOW
        @assistMoves.push(move.id)
      end
    end
    if @assistMoves.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Metronome
#===============================================================================
# Ignores Z-Moves/Max Moves when calling a random move.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    @metronomeMove = nil
    move_keys = GameData::Move::DATA.keys
    1000.times do
      move_id = move_keys[@battle.pbRandom(move_keys.length)]
      move_data = GameData::Move.get(move_id)
	  next if move_data.powerMove?
      next if @moveBlacklist.include?(move_data.function_code)
      next if @moveBlacklistSignatures.include?(move_data.id)
      next if move_data.type == :SHADOW
      @metronomeMove = move_data.id
      break
    end
    if !@metronomeMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Encore
#===============================================================================
# Move fails if the target's last used move was a Z-Move.
# No effect on Max Moves because Dynamax Pokemon are already immune to Encore.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0BC < PokeBattle_Move
  alias _ZUD_pbFailsAgainstTarget? pbFailsAgainstTarget?
  def pbFailsAgainstTarget?(user,target)
    if target.lastMoveUsedIsZMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return _ZUD_pbFailsAgainstTarget?(user, target)
  end
end

#===============================================================================
# Self-KO Moves (Self-Destruct, Explosion)
#===============================================================================
# Move fails when used by a Max Raid Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E0 < PokeBattle_Move
  alias _ZUD_pbMoveFailed? pbMoveFailed?
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::MaxRaidBoss]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    _ZUD_pbMoveFailed?(user,targets)
  end
end

#===============================================================================
# Perish Song
#===============================================================================
# Move fails when used by any Pokemon in a Max Raid battle.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if b.effects[PBEffects::PerishSong]>0
      failed = false
      break
    end
    failed = $game_switches[Settings::MAXRAID_SWITCH]
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Destiny Bond
#===============================================================================
# Move fails when used by a Max Raid Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0E7 < PokeBattle_Move
  alias _ZUD_pbMoveFailed? pbMoveFailed?
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::MaxRaidBoss]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    _ZUD_pbMoveFailed?(user,targets)
  end
end

#===============================================================================
# Teleport
#===============================================================================
# Move fails when used by any Pokemon in a Max Raid battle.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !@battle.pbCanRun?(user.index) || $game_switches[Settings::MAXRAID_SWITCH]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Dragon Tail/Circle Throw
#===============================================================================
# Forced switch fails to trigger if target is Dynamaxed, or user is Raid Boss.
#-------------------------------------------------------------------------------
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if @battle.wildBattle? && target.level<=user.level && @battle.canRun &&
	     !target.dynamax? && !user.effects[PBEffects::MaxRaidBoss] &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      @battle.decision = 3
    end
  end
  
  def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    return if @battle.wildBattle?
    return if user.fainted? || numHits==0
    return if user.effects[PBEffects::MaxRaidBoss]
    roarSwitched = []
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute || b.dynamax?
      next if switchedBattlers.include?(b.index)
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
      next if newPkmn<0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched.length>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end

#===============================================================================
# Spite
#===============================================================================
# Reduced PP of Max Moves is properly applied to the base move as well.
#-------------------------------------------------------------------------------
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.eachMoveWithIndex do |m,i|
      next if m.id!=target.lastRegularMoveUsed
      reduction = [4,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      target.effects[PBEffects::MaxMovePP][i] += reduction if target.dynamax?
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end

#===============================================================================
# Rapid Spin
#===============================================================================
# Also clears away hazard applied with G-Max Steelsurge.
#-------------------------------------------------------------------------------
class PokeBattle_Move_110 < PokeBattle_Move
  alias _ZUD_pbEffectAfterAllHits pbEffectAfterAllHits
  def pbEffectAfterAllHits(user,target)
    _ZUD_pbEffectAfterAllHits(user,target)
    if user.pbOwnSide.effects[PBEffects::Steelsurge]
      user.pbOwnSide.effects[PBEffects::Steelsurge] = false
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
  end
end

#===============================================================================
# Strength Sap
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    # Calculate target's effective attack value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk      = target.attack
    atkStage = target.stages[:ATTACK]+6
    healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK,user,self)
      target.pbLowerStatStage(:ATTACK,1,user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt,true,true,true,true) # Ignores Dynamax
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt*1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt,true,true,true) # Ignores Dynamax
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
end

#===============================================================================
# Behemoth Blade, Behemoth Bash, Dynamax Cannon
#===============================================================================
# Deals double damage vs Dynamax targets, except for Eternamax Eternatus.
#-------------------------------------------------------------------------------
class PokeBattle_Move_19A < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.dynamax? && !target.isSpecies?(:ETERNATUS)
      baseDmg *= 2
    end
    return baseDmg
  end
end