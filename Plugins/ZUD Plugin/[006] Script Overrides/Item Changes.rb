#===============================================================================
# Berry Juice
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::HPHealItem.add(:BERRYJUICE,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && battler.hp>battler.totalhp/2
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
    battle.pbCommonAnimation("UseItem",battler) if !forced
    battler.pbRecoverHP(20,true,true,true) # Ignores Dynamax
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

#===============================================================================
# Oran Berry
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::HPHealItem.add(:ORANBERRY,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    amt  = 10
	  amt *= 2 if battler.hasActiveAbility?(:RIPEN)
    battler.pbRecoverHP(amt,true,true,true) # Ignores Dynamax
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

#===============================================================================
# Shell Bell
#===============================================================================
# Healing isn't reduced while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::UserItemAfterMoveUse.add(:SHELLBELL,
  proc { |item,user,targets,move,numHits,battle|
    next if !user.canHeal?
    totalDamage = 0
    targets.each { |b| totalDamage += b.damageState.totalHPLost }
    next if totalDamage<=0
    user.pbRecoverHP(totalDamage/8,true,true,true) # Ignores Dynamax
    battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
       user.pbThis,user.itemName))
  }
)

#===============================================================================
# Choice Items
#===============================================================================
# Stat bonuses are not applied to Z-Moves or while Dynamaxed.
#-------------------------------------------------------------------------------
BattleHandlers::DamageCalcUserItem.add(:CHOICEBAND,
  proc { |item,user,target,move,mults,baseDmg,type|
    if move.physicalMove? && !move.powerMove?
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserItem.add(:CHOICESPECS,
  proc { |item,user,target,move,mults,baseDmg,type|
    if move.specialMove? && !move.powerMove?
      mults[:base_damage_multiplier] *= 1.5 
    end
  }
)

BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
  proc { |item,battler,mult|
    next mult*1.5 if !battler.dynamax?
  }
)

#===============================================================================
# Red Card
#===============================================================================
# Item triggers, but its effects fail to activate vs Dynamax targets.
#-------------------------------------------------------------------------------
BattleHandlers::TargetItemAfterMoveUse.add(:REDCARD,
  proc { |item,battler,user,move,switched,battle|
    next if user.fainted? || switched.include?(user.index)
    newPkmn = battle.pbGetReplacementPokemonIndex(user.index,true)
    next if newPkmn<0
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
       battler.pbThis,battler.itemName,user.pbThis(true)))
    battler.pbConsumeItem
    if user.dynamax?
      battle.pbDisplay(_INTL("But it failed!"))
    else
      battle.pbRecallAndReplace(user.index, newPkmn, true)
      battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
      battle.pbClearChoice(user.index)
      switched.push(user.index)
    end
  }
)