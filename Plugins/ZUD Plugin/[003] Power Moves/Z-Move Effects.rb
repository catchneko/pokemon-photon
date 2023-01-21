#===============================================================================
# Move Effects for Z-Moves.
#===============================================================================

#===============================================================================
# Generic Z-Move classes.
#===============================================================================
# Raises all of the user's stats.
#-------------------------------------------------------------------------------
class PokeBattle_ZMove_AllStatsUp < PokeBattle_ZMove
  def initialize(battle,move,newMove)
    super
    @statUp = []
  end
  
  def pbMoveFailed?(user,targets)
    return false if damagingMove?
    failed = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    return if damagingMove?
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end

  def pbAdditionalEffect(user,target)
    showAnim = true
    for i in 0...@statUp.length/2
      next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
      if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
        showAnim = false
      end
    end
  end
end

#===============================================================================
# Generic Z-Moves
#===============================================================================
# No effect.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z000 < PokeBattle_ZMove
end

#===============================================================================
# Stoked Sparksurfer
#===============================================================================
# Inflicts paralysis.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z001 < PokeBattle_ZMove
  def initialize(battle,move,newMove)
    super
  end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    return !target.pbCanParalyze?(user,true,self)
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.pbParalyze(user)
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
  end
end 

#===============================================================================
# Malicious Moonsault
#===============================================================================
# Doubles damage on minimized Pokémon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z002 < PokeBattle_ZMove
  def tramplesMinimize?(param=1)
    # Perfect accuracy and double damage if minimized
    return MECHANICS_GENERATION >= 7
  end
end 

#===============================================================================
# Extreme Evoboost, Clangorus Soulblaze
#===============================================================================
# Raises all stats by 2 stages.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z003 < PokeBattle_ZMove_AllStatsUp
  def initialize(battle,move,newMove)
    super
    @statUp = [:ATTACK,2,:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2] if @id == :EXTREMEEVOBOOST
    @statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1] if @id == :CLANGOROUSSOULBLAZE
  end
end 

#===============================================================================
# Genesis Supernova
#===============================================================================
# Sets Psychic Terrain.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z004 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    @battle.pbStartTerrain(user, :Psychic) if @battle.field.terrain!= :Psychic
  end
end 

#===============================================================================
# Guardian of Alola
#===============================================================================
# Inflicts 75% of the target's current HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z005 < PokeBattle_ZMove
  def pbFixedDamage(user,target)
    return (target.hp*0.75).round
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end
end

#===============================================================================
# Menacing Moonraze Maelstrom, Searing Sunraze Smash
#===============================================================================
# Ignores ability.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z006 < PokeBattle_ZMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end 

#===============================================================================
# Splintered Stormshards
#===============================================================================
# Removes terrains.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z007 < PokeBattle_ZMove
  def pbAdditionalEffect(user,target)
    case @battle.field.terrain
    when :Electric
      @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
    when :Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
    when :Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
    when :Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
    end
    @battle.field.terrain = :None
  end
end 

#===============================================================================
# Light That Burns the Sky
#===============================================================================
# Ignores ability + is physical or special depending on what's best. 
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z008 < PokeBattle_Move_Z007
  def initialize(battle,move,newMove)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType=nil); return (@calcCategory==0); end
  def specialMove?(thisType=nil);  return (@calcCategory==1); end
    
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end

  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    atk        = user.attack
    atkStage   = user.stages[:ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end