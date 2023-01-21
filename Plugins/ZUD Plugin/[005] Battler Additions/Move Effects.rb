#===============================================================================
# Checks for the success or failure of certain effects.
#===============================================================================
class PokeBattle_Battler
  attr_accessor :lastMoveUsedIsZMove
  
  #=============================================================================
  # Z-Move selection
  #=============================================================================
  # Bypasses effects that would normally lock the user out of move selection.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbCanChooseMove? pbCanChooseMove?
  def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
    if move.powerMove?
      # Gravity still affects Power Moves.
      if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
        if showMessages
          msg = _INTL("{1} can't use {2} because of gravity!",pbThis,move.name)
          (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
        end
        return false
      end
      # Taunt still affects Max Guard.
      if @effects[PBEffects::Taunt]>0 && move.id==:MAXGUARD && dynamax?
        if showMessages
          msg = _INTL("{1} can't use {2} after the taunt!",pbThis,move.name)
          (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
        end
        return false
      end
      return true
    else
      return _ZUD_pbCanChooseMove?(move,commandPhase,showMessages,specialUsage)
    end
  end
  
  #=============================================================================
  # Z-Move completion check
  #=============================================================================
  # Completes the Z-Move process at the end of the turn if one was used.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbTryUseMove pbTryUseMove 
  def pbTryUseMove(*args)
    ret = _ZUD_pbTryUseMove(*args)
    @lastMoveUsedIsZMove = ret if args[1].zMove?
    return ret 
  end
  
  alias _ZUD_pbEndTurn pbEndTurn
  def pbEndTurn(_choice)
    if _choice[0] == :UseMove && _choice[2].zMove?
      if @lastMoveUsedIsZMove
        side  = self.idxOwnSide
        owner = @battle.pbGetOwnerIndexFromBattlerIndex(self.index)
        @battle.zMove[side][owner] = -2
      else 
        @battle.pbUnregisterZMove(self.index)
      end
      pbDisplayBaseMoves(1)
      @effects[PBEffects::PowerMovesButton] = false
    end
    _ZUD_pbEndTurn(_choice)
  end
  
  #=============================================================================
  # Encore
  #=============================================================================
  # Index of encored move is reset during the turn a Z-Move is used.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbEncoredMoveIndex pbEncoredMoveIndex
  def pbEncoredMoveIndex
    if @battle.choices[self.index][0]==:UseMove && 
       @battle.choices[self.index][2].zMove?
      turns = @effects[PBEffects::Encore]
      move  = @effects[PBEffects::EncoreMove]
      @effects[PBEffects::EncoreRestore] = [turns,move]
      return -1
    end
    _ZUD_pbEncoredMoveIndex
  end
  
  #=============================================================================
  # Flinch
  #=============================================================================
  # Dynamax Pokemon are immune to flinching effects.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbFlinch pbFlinch
  def pbFlinch(_user=nil)
    return if @effects[PBEffects::Dynamax]>0
    _ZUD_pbFlinch(_user)
  end
  
  #=============================================================================
  # Imprison
  #=============================================================================
  # Prevents Z-Moves/Max Moves from becoming unselectable due to Imprison.
  # Must be added to def pbCanChooseMove?
  #-----------------------------------------------------------------------------
  def _ZUD_Imprison(move,commandPhase)
    @battle.eachOtherSideBattler(@index) do |b|
      next if move.powerMove?
      basemove = false
      b.eachMoveWithIndex do |m,i|
        break if b.effects[PBEffects::BaseMoves].empty?
        basemove = true if b.effects[PBEffects::BaseMoves][i].id==move.id
      end
      hasmove = (b.dynamax?) ? basemove : b.pbHasMove?(move.id)
      next if !b.effects[PBEffects::Imprison] || !hasmove
      if showMessages
        msg = _INTL("{1} can't use its sealed {2}!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
  end
   
  #=============================================================================
  # Grudge, Destiny Bond
  #=============================================================================
  # Grudge: Lowers PP of base move if Max Move was used. Fails on Z-Moves.
  # Destiny Bond: Effect fails to apply on a Dynamax Pokemon.
  # Must be added to def pbEffectsOnMakingHit.
  #=============================================================================
  def _ZUD_EffectsOnKO(move,user,target)
    # Grudge
    if target.effects[PBEffects::Grudge] && target.fainted? && !move.zMove?
      move.pp  = 0
      basemove = nil
      user.eachMoveWithIndex do |m,i|
        next if m!=move && m.pp>0
        if move.maxMove? && user.dynamax?
          basemove = user.effects[PBEffects::BaseMoves][i]
          user.effects[PBEffects::MaxMovePP][i] += basemove.total_pp
        end
      end
      movename = (basemove) ? basemove.name : move.name  
      @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
        user.pbThis,movename))
    end
    # Destiny Bond (recording that it should apply)
    if target.effects[PBEffects::DestinyBond] && target.fainted? && !user.dynamax?
      if user.effects[PBEffects::DestinyBondTarget]<0
        user.effects[PBEffects::DestinyBondTarget] = target.index
      end
    end
  end
  
  #=============================================================================
  # Dynamax Immunities
  #=============================================================================
  # Prevents Dynamax targets from being affected by various moves.
  # Must be added to def pbSuccessCheckAgainstTarget.
  #-----------------------------------------------------------------------------
  def _ZUD_SuccessCheck(move,user,target)
    ret = true
    # Max Guard blocks all moves except specified moves.
    if target.effects[PBEffects::Dynamax]>0
      if move.function=="066" || # Entrainment
         move.function=="067" || # Skill Swap
         move.function=="070" || # OHKO moves
         move.function=="09A" || # Weight-based moves
		 move.function=="09B" || # Heat Crash / Heavy Slam												  
         move.function=="0B7" || # Torment
         move.function=="0B9" || # Disable
         move.function=="0BC" || # Encore
         move.function=="0E7" || # Destiny Bond
         move.function=="0EB" || # Roar/Whirlwind
         move.function=="16B"    # Instruct
        @battle.pbDisplay(_INTL("But it failed!"))
        return false
      end
    end
    ret = pbSuccessCheckMaxRaid(move,user,target)
    if target.effects[PBEffects::MaxGuard]
      bypass = [:MEANLOOK,:ROLEPLAY,:PERISHSONG,:DECORATE,:FEINT,:GMAXONEBLOW,:GMAXRAPIDFLOW]
      if !bypass.include?(move.id)
        @battle.pbCommonAnimation("Protect",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        pbRaidShieldBreak(move,target)
        return false
      end
    end
    return ret
  end
  
  alias _ZUD_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
  def pbSuccessCheckAgainstTarget(*args)
    return true if _ZUD_SuccessCheck(*args) && _ZUD_pbSuccessCheckAgainstTarget(*args)
    return false
  end
end

#===============================================================================
# Checks for the effects of certain Z-Move/Max Moves.
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  # Switch-in effect of certain Z-Moves/Max Moves.
  # Must be added to def pbOnActiveOne.
  #-----------------------------------------------------------------------------
  def _ZUD_OnActiveEffects(battler)
    # Z-Parting Shot/Z-Memento
    if @positions[battler.index].effects[PBEffects::ZHeal]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The Z-Power healed {1}!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      @positions[battler.index].effects[PBEffects::ZHeal] = false
    end
    # G-Max Steelsurge
    if battler.pbOwnSide.effects[PBEffects::Steelsurge] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:STEEL) && battler.takesEntryHazardDamage?
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:STEEL, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("The sharp steel bit into {1}!",battler.pbThis(true)))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)
          return pbOnActiveOne(battler) 
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # End of round effects of certain Max Moves.
  # Must be added to def pbEndOfRoundPhase.
  #-----------------------------------------------------------------------------
  def _ZUD_EndOfRoundEffects(priority)
    priority.each do |b|
      b.effects[PBEffects::MaxGuard] = false
    end
    for side in 0...2
      #-------------------------------------------------------------------------
      # G-Max Vine Lash
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::VineLash]>0
	    if Settings::GEN8_COMPAT
      	  pbCommonAnimation("VineLash")    if @scene.pbCommonAnimationExists?("VineLash")    && side==0
      	  pbCommonAnimation("VineLashOpp") if @scene.pbCommonAnimationExists?("VineLashOpp") && side==1
		end
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:GRASS)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/6,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Vine Lash's ferocious beating!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      #-------------------------------------------------------------------------
      # G-Max Wildfire
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Wildfire]>0
	    if Settings::GEN8_COMPAT
      	  pbCommonAnimation("Wildfire")    if @scene.pbCommonAnimationExists?("Wildfire")    && side==0
      	  pbCommonAnimation("WildfireOpp") if @scene.pbCommonAnimationExists?("WildfireOpp") && side==1
		end
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/6,false)
          pbDisplay(_INTL("{1} is burning up within G-Max Wildfire's flames!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      #-------------------------------------------------------------------------
      # G-Max Cannonade
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Cannonade]>0
	    if Settings::GEN8_COMPAT
      	  pbCommonAnimation("Cannonade")    if @scene.pbCommonAnimationExists?("Cannonade")    && side==0
      	  pbCommonAnimation("CannonadeOpp") if @scene.pbCommonAnimationExists?("CannonadeOpp") && side==1
		end
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:WATER)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/6,false)
          pbDisplay(_INTL("{1} is hurt by G-Max Cannonade's vortex!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
      #-------------------------------------------------------------------------
      # G-Max Volcalith
      #-------------------------------------------------------------------------
      if sides[side].effects[PBEffects::Volcalith]>0
	    if Settings::GEN8_COMPAT
      	  pbCommonAnimation("Volcalith")    if @scene.pbCommonAnimationExists?("Volcalith")    && side==0
      	  pbCommonAnimation("VolcalithOpp") if @scene.pbCommonAnimationExists?("VolcalithOpp") && side==1
		end
      	priority.each do |b|
          next if b.opposes?(side)
          next if !b.takesIndirectDamage? || b.pbHasType?(:ROCK)
          oldHP = b.hp
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(b.totalhp/6,false)
          pbDisplay(_INTL("{1} is hurt by the rocks thrown out by G-Max Volcalith!",b.pbThis))
          b.pbItemHPHealCheck
          b.pbAbilitiesOnDamageTaken(oldHP)
          b.pbFaint if b.fainted?
        end
      end
	  #-------------------------------------------------------------------------
      # Counts down the turns until the effect ends.
      #-------------------------------------------------------------------------
      # Vinelash
      pbEORCountDownSideEffect(side,PBEffects::VineLash,
            _INTL("{1} was released from G-Max Vinelash's beating!",@battlers[side].pbTeam))
      # Wildfire
      pbEORCountDownSideEffect(side,PBEffects::Wildfire,
            _INTL("{1} was released from G-Max Wildfire's flames!",@battlers[side].pbTeam))
      # Cannonade
      pbEORCountDownSideEffect(side,PBEffects::Cannonade,
            _INTL("{1} was released from G-Max Cannonade's vortex!",@battlers[side].pbTeam))
      # Volcalith
      pbEORCountDownSideEffect(side,PBEffects::Volcalith,
            _INTL("Rocks stopped being thrown out by G-Max Volcalith on {1}!",@battlers[side].pbTeam(true)))
    end
  end
end
