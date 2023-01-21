#===============================================================================
# Forewarn
#===============================================================================
# Checks the target's base moves, not Max Moves.
#-------------------------------------------------------------------------------
BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMoveWithIndex do |m,i|
        m = (b.dynamax?) ? b.effects[PBEffects::BaseMoves][i] : m
        power = m.baseDamage
        power = 160 if ["070"].include?(m.function)    # OHKO
        power = 150 if ["08B"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(m.function)
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis, forewarnMoveName))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis, forewarnMoveName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

#===============================================================================
# Imposter
#===============================================================================
# Ability fails to trigger if the user is Dynamaxed, and the transform target
# is a species that is unable to have a Dynamax form.
#-------------------------------------------------------------------------------
BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if battler.dynamax? && !choice.dynamaxAble?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(:TRANSFORM,battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

#===============================================================================
# Cursed Body
#===============================================================================
# Ability fails to trigger if the attacker is a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted? || user.dynamax?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.total_pp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# Emergency Exit/Wimp Out
#===============================================================================
# Ability fails to trigger if the user is a Max Raid Boss.
#-------------------------------------------------------------------------------
BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability,battler,battle|
    next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
    next false if battler.effects[PBEffects::MaxRaidBoss]
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      pbSEPlay("Battle flee")
      battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis))
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis,battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn<0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    next true
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)

#===============================================================================
# Gorilla Tactics
#===============================================================================
# No Attack multiplier applied when using Z-Moves/Max Moves.
#-------------------------------------------------------------------------------
BattleHandlers::DamageCalcUserAbility.add(:GORILLATACTICS,
  proc { |ability,user,target,move,mults,baseDmg,type|
  if move.physicalMove? && !move.powerMove?
    mults[:base_damage_multiplier] *= 1.5 
  end
  }
)

#===============================================================================
# Wandering Spirit
#===============================================================================
# Ability fails to trigger if the attacker is a Dynamaxed Pokemon.
#-------------------------------------------------------------------------------
BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted? || user.dynamax?
	next if user.ungainableAbility? 
    next if [:WANDERINGSPIRIT,:WONDERGUARD,:RECEIVER,:GULPMISSILE,:ICEFACE].include?(user.ability)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      # Replaces target's ability
      battle.pbShowAbilitySplash(target,true,false)
      target.ability = user.ability
      battle.pbReplaceAbilitySplash(target)
      # Replaces user's ability
      if user.opposes?(target)
        battle.pbShowAbilitySplash(user,true,false)
        user.ability = ability
        battle.pbReplaceAbilitySplash(user)
      else
        user.ability = ability
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} swapped abilities with {2}!",target.pbThis,user.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1} acquired {2}'s {3}!",target.pbThis,user.pbThis(true),target.ability.name))
        battle.pbDisplay(_INTL("{1} acquired {2}'s {3}!",user.pbThis,target.pbThis(true),user.ability.name))
      end
      battle.pbHideAbilitySplash(user)
      battle.pbHideAbilitySplash(target)
      user.pbOnAbilityChanged(target.ability)
      target.pbOnAbilityChanged(ability)
      user.pbEffectsOnSwitchIn
      target.pbEffectsOnSwitchIn
	end
  }
)