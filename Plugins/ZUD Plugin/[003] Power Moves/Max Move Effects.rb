#===============================================================================
# Move effects for all Max Moves. 
#===============================================================================

#===============================================================================
# Generic Max Move classes. 
#===============================================================================
# Raise stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_StatUp < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if !b.pbCanRaiseStatStage?(@statUp[0],b,self)
      b.pbRaiseStatStage(@statUp[0],@statUp[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Lower stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_TargetStatDown < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      next if !b.pbCanLowerStatStage?(@statDown[0],b,self)
      b.pbLowerStatStage(@statDown[0],@statDown[1],b)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up weather on use.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Weather < PokeBattle_MaxMove
  def initialize(battle,move,newMove)
    super
    @weatherType = :None
  end
  
  def pbEffectGeneral(user)
	if ![:HarshSun, :HeavyRain, :StrongWinds, @weatherType].include?(@battle.field.weather)
      @battle.pbStartWeather(user,@weatherType,true,false)
    end
  end
end

#-------------------------------------------------------------------------------
# Sets up battle terrain on use.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Terrain < PokeBattle_MaxMove
  def initialize(battle,move,newMove)
    super
    @terrainType = :None
  end

  def pbEffectGeneral(user)
    if @battle.field.terrain!=@terrainType
      @battle.pbStartTerrain(user,@terrainType)
    end
  end
end

#-------------------------------------------------------------------------------
# Applies one of multiple statuses on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Status < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      randstatus = @statuses[@battle.pbRandom(@statuses.length)]
      if !b.pbHasAnyStatus? && b.pbCanInflictStatus?(randstatus,b,false)
        b.pbInflictStatus(randstatus)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_MaxMove_Confusion < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbConfuse if b.pbCanConfuse?(user,false)
    end
  end
end

#===============================================================================
# G-Max One Blow, G-Max Rapid Flow.
#===============================================================================
# No effect. (Protection bypass handled elsewhere)
#-------------------------------------------------------------------------------
class PokeBattle_Move_D000 < PokeBattle_MaxMove
end

#===============================================================================
# Max Guard.
#===============================================================================
# Guards the user from all attacks, including Z-Moves/Max Moves.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D001 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::MaxGuard
  end
end

#===============================================================================
# Max Knuckle, Max Steelspike, Max Ooze, Max Quake, Max Airstream.
#===============================================================================
# Increases a stat of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D002 < PokeBattle_MaxMove_StatUp
  def initialize(battle,move,newMove)
    super
    @statUp = [:ATTACK,1]          if @id == :MAXKNUCKLE
    @statUp = [:DEFENSE,1]         if @id == :MAXSTEELSPIKE
    @statUp = [:SPECIAL_ATTACK,1]  if @id == :MAXOOZE
    @statUp = [:SPECIAL_DEFENSE,1] if @id == :MAXQUAKE
    @statUp = [:SPEED,1]           if @id == :MAXAIRSTREAM
  end
end


#===============================================================================
# Max Wyrmwind, Max Phantasm, Max Flutterby, Max Darkness, Max Strike.
# G-Max Foamburst, G-Max Tartness.
#===============================================================================
# Decreases a stat of all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D003 < PokeBattle_MaxMove_TargetStatDown
  def initialize(battle,move,newMove)
    super
    @statDown = [:ATTACK,1]          if @id == :MAXWYRMWIND
    @statDown = [:DEFENSE,1]         if @id == :MAXPHANTASM
    @statDown = [:SPECIAL_ATTACK,1]  if @id == :MAXFLUTTERBY
    @statDown = [:SPECIAL_DEFENSE,1] if @id == :MAXDARKNESS
    @statDown = [:SPEED,1]           if @id == :MAXSTRIKE
    @statDown = [:SPEED,2]           if @id == :GMAXFOAMBURST
    @statDown = [:EVASION,1]         if @id == :GMAXTARTNESS
  end
end

#===============================================================================
# Max Flare, Max Gyser, Max Hailstorm, Max Rockfall.
#===============================================================================
# Sets up weather effect on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D004 < PokeBattle_MaxMove_Weather
  def initialize(battle,move,newMove)
    super
    @weatherType = :Sun       if @id == :MAXFLARE
    @weatherType = :Rain      if @id == :MAXGEYSER
    @weatherType = :Hail      if @id == :MAXHAILSTORM
    @weatherType = :Sandstorm if @id == :MAXROCKFALL
  end
end

#===============================================================================
# Max Overgrowth, Max Lightning, Max Starfall, Max Mindstorm.
#===============================================================================
# Sets up battle terrain on the field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D005 < PokeBattle_MaxMove_Terrain
  def initialize(battle,move,newMove)
    super
    @terrainType = :Electric if @id == :MAXLIGHTNING
    @terrainType = :Grassy   if @id == :MAXOVERGROWTH
    @terrainType = :Misty    if @id == :MAXSTARFALL
    @terrainType = :Psychic  if @id == :MAXMINDSTORM
  end
end

#===============================================================================
# G-Max Vine Lash, G-Max Wildfire, G-Max Cannonade, G-Max Volcalith.
#===============================================================================
# Damages all Pokemon on the opposing field for 4 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D006 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @id == :GMAXVINELASH && user.pbOpposingSide.effects[PBEffects::VineLash]==0
      user.pbOpposingSide.effects[PBEffects::VineLash]=4
      @battle.pbDisplay(_INTL("{1} got trapped with vines!",user.pbOpposingTeam))
    end
    if @id == :GMAXWILDFIRE && user.pbOpposingSide.effects[PBEffects::Wildfire]==0
      user.pbOpposingSide.effects[PBEffects::Wildfire]=4
      @battle.pbDisplay(_INTL("{1} were surrounded by fire!",user.pbOpposingTeam))
    end
    if @id == :GMAXCANNONADE && user.pbOpposingSide.effects[PBEffects::Cannonade]==0
      user.pbOpposingSide.effects[PBEffects::Cannonade]=4
      @battle.pbDisplay(_INTL("{1} got caught in a vortex of water!",user.pbOpposingTeam))
    end
    if @id == :GMAXVOLCALITH && user.pbOpposingSide.effects[PBEffects::Volcalith]==0
      user.pbOpposingSide.effects[PBEffects::Volcalith]=4
      @battle.pbDisplay(_INTL("{1} became surrounded by rocks!",user.pbOpposingTeam))
    end
  end
end

#===============================================================================
# G-Max Drum Solo, G-Max Fireball, G-Max Hydrosnipe.
#===============================================================================
# Bypasses target's abilities that would reduce or ignore damage.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D007 < PokeBattle_MaxMove
  def pbChangeUsageCounters(user,specialUsage)
    super
    @battle.moldBreaker = true if !specialUsage
  end
end

#===============================================================================
# G-Max Malador, G-Max Volt Crash, G-Max Stun Shock, G-Max Befuddle.
#===============================================================================
# Applies status effects on all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D008 < PokeBattle_MaxMove_Status
  def initialize(battle,move,newMove)
    super
    if @id == :GMAXMALODOR
      @statuses = [:POISON]
    end
    if @id == :GMAXVOLTCRASH
      @statuses = [:PARALYSIS]
    end
    if @id == :GMAXSTUNSHOCK
      @statuses = [:POISON,:PARALYSIS]
    end
    if @id == :GMAXBEFUDDLE
      @statuses = [:POISON,:PARALYSIS,:SLEEP]
    end
  end
end

#===============================================================================
# G-Max Smite, G-Max Gold Rush.
#===============================================================================
# Confuses all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D009 < PokeBattle_MaxMove_Confusion
  def pbEffectGeneral(user)
    if @id == :GMAXGOLDRUSH
      @battle.field.effects[PBEffects::PayDay] += 100*user.level
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end
end

#===============================================================================
# G-Max Stonesurge, G-Max Steelsurge.
#===============================================================================
# Sets up entry hazard on the opposing side's field.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D010 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @id == :GMAXSTONESURGE && !user.pbOpposingSide.effects[PBEffects::StealthRock]
      user.pbOpposingSide.effects[PBEffects::StealthRock] = true
      @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
         user.pbOpposingTeam(true)))
    end
    if @id == :GMAXSTEELSURGE && !user.pbOpposingSide.effects[PBEffects::Steelsurge]
      user.pbOpposingSide.effects[PBEffects::Steelsurge] = true
      @battle.pbDisplay(_INTL("Sharp-pointed pieces of steel started floating around {1}!",
         user.pbOpposingTeam(true)))
    end   
  end
end

#===============================================================================
# G-Max Centiferno, G-Max Sand Blast.
#===============================================================================
# Traps all opposing Pokemon in a vortex for multiple turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D011 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    moveid = :FIRESPIN if @id == :GMAXCENTIFERNO
    moveid = :SANDTOMB if @id == :GMAXSANDBLAST
    user.eachOpposing do |b|    
      next if b.fainted? || b.damageState.substitute
      next if b.effects[PBEffects::Trapping]>0
      if user.hasActiveItem?(:GRIPCLAW)
        b.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
      else
        b.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
      end
      b.effects[PBEffects::TrappingMove] = moveid
      b.effects[PBEffects::TrappingUser] = user.index
      msg = _INTL("{1} was trapped in the vortex!",b.pbThis)
	  case @id
      when :GMAXCENTIFERNO
        msg = _INTL("{1} was trapped in the fiery vortex!",b.pbThis)
      when :GMAXSANDBLAST
        msg = _INTL("{1} became trapped by Sand Tomb!",b.pbThis)
      end
      @battle.pbDisplay(msg)
    end
  end
end

#===============================================================================
# G-Max Wind Rage.
#===============================================================================
# Blows away hazards, terrain, and effects on the opponent's side.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D012 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist]>0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard]>0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
	if target.pbOwnSide.effects[PBEffects::Steelsurge] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Steelsurge])
      target.pbOwnSide.effects[PBEffects::Steelsurge]      = false
      target.pbOpposingSide.effects[PBEffects::Steelsurge] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away the pointed steel!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
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
end

#===============================================================================
# G-Max Gravitas.
#===============================================================================
# Increases gravity on the field for 5 rounds.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D013 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @battle.field.effects[PBEffects::Gravity]==0
      @battle.field.effects[PBEffects::Gravity] = 5
      @battle.pbDisplay(_INTL("Gravity intensified!"))
      @battle.eachBattler do |b|
        showMessage = false
        if b.inTwoTurnAttack?("0C9","0CC","0CE")
          b.effects[PBEffects::TwoTurnAttack] = 0
          @battle.pbClearChoice(b.index) if !b.movedThisRound?
          showMessage = true
        end
        if b.effects[PBEffects::MagnetRise]>0 ||
           b.effects[PBEffects::Telekinesis]>0 ||
           b.effects[PBEffects::SkyDrop]>=0
          b.effects[PBEffects::MagnetRise]  = 0
          b.effects[PBEffects::Telekinesis] = 0
          b.effects[PBEffects::SkyDrop]     = -1
          showMessage = true
        end
        @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!",
           b.pbThis)) if showMessage
      end
    end
  end
end

#===============================================================================
# G-Max Finale.
#===============================================================================
# Heals all ally Pokemon by 1/6th their max HP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D014 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.hp == b.totalhp
      next if b.effects[PBEffects::HealBlock]>0
      hpGain = (b.totalhp/6.0).round
      b.pbRecoverHP(hpGain)
    end
  end
end

#===============================================================================
# G-Max Sweetness.
#===============================================================================
# Cures any status conditions of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D015 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      t = b.status
      b.pbCureStatus(false)
      case t
      when :BURN
        @battle.pbDisplay(_INTL("{1} was healed of its burn!",b.pbThis))  
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poison!",b.pbThis))  
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis!",b.pbThis))
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",b.pbThis)) 
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",b.pbThis)) 
      end
    end
  end
end

#===============================================================================
# G-Max Replenish.
#===============================================================================
# User has a 50% chance to recover ally Pokemon's consumed berries.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D016 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if @battle.pbRandom(10)<5
      @battle.eachBattler do |b|
        next if b.opposes?(user)
		next if !b.recycleItem
        next if !GameData::Item.get(b.recycleItem).is_berry?
        item = b.recycleItem
        b.item = item
        b.setInitialItem(item) if @battle.wildBattle? && b.initialItem==0
        b.setRecycleItem(0)
        b.effects[PBEffects::PickupItem] = 0
        b.effects[PBEffects::PickupUse]  = 0
        itemName = PBItems.getName(item)
        if itemName.starts_with_vowel?
          @battle.pbDisplay(_INTL("{1} found an {2}!",b.pbThis,itemName))
        else
          @battle.pbDisplay(_INTL("{1} found a {2}!",b.pbThis,itemName))
        end
        user.pbHeldItemTriggerCheck
      end
    end
  end
end

#===============================================================================
# G-Max Depletion.
#===============================================================================
# The target's last used move loses 2 PP.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D017 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.eachMoveWithIndex do |m,i|
        next if m.id!=b.lastRegularMoveUsed || m.pp==0 || m.total_pp<=0
        reduction = [2,m.pp].min
        b.pbSetPP(m,m.pp-reduction)
        b.effects[PBEffects::MaxMovePP][i] +=2 if b.dynamax?
        @battle.pbDisplay(_INTL("{1}'s PP was reduced!",b.pbThis))
        break
      end
    end
  end
end

#===============================================================================
# G-Max Resonance.
#===============================================================================
# Sets up Aurora Veil for the party for 5 turns.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D018 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    if user.pbOwnSide.effects[PBEffects::AuroraVeil]==0
      user.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
      user.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if user.hasActiveItem?(:LIGHTCLAY)
      @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
         @name,user.pbTeam(true)))
    end
  end
end

#===============================================================================
# G-Max Chi Strike.
#===============================================================================
# Increases the critical hit rate of all ally Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D019 < PokeBattle_MaxMove
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.effects[PBEffects::CriticalBoost] += 1
      @battle.pbDisplay(_INTL("{1} is getting pumped!",b.pbThis))
    end
  end
end

#===============================================================================
# G-Max Terror.
#===============================================================================
# Prevents all opposing Pokemon from switching.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D020 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      next if b.effects[PBEffects::MeanLook] = user.index
      @battle.pbDisplay(_INTL("{1} can no longer escape!",b.pbThis))
      b.effects[PBEffects::MeanLook] = user.index
    end
  end
end

#===============================================================================
# G-Max Snooze.
#===============================================================================
# Has a 50% chance of making the target drowsy.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D021 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::Yawn]==0 && @battle.pbRandom(10)<5
      target.effects[PBEffects::Yawn] = 2
      @battle.pbDisplay(_INTL("{1} made {2} drowsy!",user.pbThis,target.pbThis(true)))
    end
  end
end

#===============================================================================
# G-Max Cuddle.
#===============================================================================
# Infatuates all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D022 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      b.pbAttract(user) if b.pbCanAttract?(user)
    end
  end
end

#===============================================================================
# G-Max Meltdown.
#===============================================================================
# Torments all opposing Pokemon.
#-------------------------------------------------------------------------------
class PokeBattle_Move_D023 < PokeBattle_MaxMove
  def pbEffectAgainstTarget(user,target)
    user.eachOpposing do |b|
      next if b.dynamax?
      next if b.effects[PBEffects::Torment]
      b.effects[PBEffects::Torment] = true
      @battle.pbDisplay(_INTL("{1} was subjected to torment!",b.pbThis))
      b.pbItemStatusCureCheck
    end
  end
end