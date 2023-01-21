#===============================================================================
# The core battle mechanics for utilizing ZUD functions in battle.
#===============================================================================
class PokeBattle_ActiveSide
  #-----------------------------------------------------------------------------
  # Initializes effects for a battler's side.
  #-----------------------------------------------------------------------------
  alias _ZUD_initialize initialize  
  def initialize
    _ZUD_initialize
    @effects[PBEffects::Cannonade]  = 0
    @effects[PBEffects::Steelsurge] = false
    @effects[PBEffects::VineLash]   = 0
    @effects[PBEffects::Volcalith]  = 0
    @effects[PBEffects::Wildfire]   = 0
    @effects[PBEffects::ZHeal]      = false
  end
end

#===============================================================================
# Triggering and using each mechanic during battle.
#===============================================================================
class PokeBattle_Battle
  attr_accessor :zMove, :ultraBurst, :dynamax

  #-----------------------------------------------------------------------------
  # Initializes each battle mechanic.
  #-----------------------------------------------------------------------------
  alias _ZUD_initialize initialize
  def initialize(*args)
    _ZUD_initialize(*args)
    @zMove             = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @ultraBurst        = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @dynamax         = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
  end
  
  #-----------------------------------------------------------------------------
  # Checks for items required to utilize certain battle mechanics.
  #-----------------------------------------------------------------------------
  def pbHasZRing?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)
    Settings::Z_RINGS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
    return false
  end
  
  def pbHasDynamaxBand?(idxBattler)
    return true if !pbOwnedByPlayer?(idxBattler)
    Settings::DMAX_BANDS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Eligibility checks.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbCanMegaEvolve? pbCanMegaEvolve?
  def pbCanMegaEvolve?(idxBattler)
    return false if pbCanZMove?(idxBattler)
	return false if @battlers[idxBattler].dynamax?
    _ZUD_pbCanMegaEvolve?(idxBattler)
  end
  
  def pbCanZMove?(idxBattler)
    battler = @battlers[idxBattler]
    side    = battler.idxOwnSide
    owner   = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[Settings::NO_Z_MOVE]      # No Z-Moves if switch enabled.
    return false if !battler.hasZMove?                       # No Z-Moves if ineligible.
    return false if battler.hasUltra?                        # No Z-Moves if Ultra Burst is available first.
	return false if battler.dynamax?                         # No Z-Moves if the user is Dynamaxed.
    return false if wildBattle? && opposes?(idxBattler)      # No Z-Moves for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Z-Moves with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0   # No Z-Moves if in Sky Drop.
    return false if @zMove[side][owner]!=-1                  # No Z-Moves if used this battle.
    return false if !pbHasZRing?(idxBattler)                 # No Z-Moves if no Z-Ring.
    return @zMove[side][owner]==-1
  end
  
  def pbCanUltraBurst?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[Settings::NO_ULTRA_BURST] # No Ultra Burst if switch enabled.
    return false if !battler.hasUltra?                       # No Ultra Burst if ineligible.
	return false if battler.dynamax?                         # No Ultra Burst if user is Dynamaxed.
    return false if wildBattle? && opposes?(idxBattler)      # No Ultra Burst for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Ultra Burst with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0   # No Ultra Burst if in Sky Drop.
    return false if @ultraBurst[side][owner]!=-1             # No Ultra Burst if used this battle.
    return false if !pbHasZRing?(idxBattler)                 # No Ultra Burst if no Z-Ring.
    return @ultraBurst[side][owner]==-1
  end
  
  def pbCanDynamax?(idxBattler)
    battler = @battlers[idxBattler]
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return false if $game_switches[Settings::NO_DYNAMAX]      # No Dynamax if switch enabled.
    return false if !battler.hasDynamax?                      # No Dynamax if ineligible.
    return false if wildBattle? && opposes?(idxBattler)       # No Dynamax for wild Pokemon.
    return true if $DEBUG && Input.press?(Input::CTRL)        # Allows Dynamax with CTRL in Debug.
    return false if battler.effects[PBEffects::SkyDrop]>=0    # No Dynamax if in Sky Drop.
    return false if @dynamax[side][owner]!=-1                 # No Dynamax if used this battle.
    return false if wildBattle? && !Settings::CAN_DMAX_WILD && 
                   !$game_switches[Settings::MAXRAID_SWITCH]  # No Dynamax in normal wild battles, unless enabled.
    return false if !pbHasDynamaxBand?(idxBattler)            # No Dynamax if no Dynamax Band.
    return @dynamax[side][owner]==-1
  end
  
  # Returns true if any battle mechanic is available to the user.
  def pbCanUseBattleMechanic?(idxBattler)
    return true if pbCanMegaEvolve?(idxBattler) ||
                   pbCanZMove?(idxBattler) ||
                   pbCanUltraBurst?(idxBattler) ||
                   pbCanDynamax?(idxBattler)
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Uses the eligible battle mechanic.
  #-----------------------------------------------------------------------------
  def pbUseZMove(idxBattler,move,crystal)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasZMove?
	@scene.pbTrainerBattleSpeech(playerBattler?(battler) ? "zmove" : "zmoveOpp") if Settings::EBDX_COMPAT
    the_zmove = PokeBattle_ZMove.from_base_move(self,battler,move)
    the_zmove.pbUse(battler, nil, false)
  end
  
  def pbUltraBurst(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasUltra? || battler.ultra?
	@scene.pbTrainerBattleSpeech(playerBattler?(battler) ? "ultra" : "ultraOpp") if Settings::EBDX_COMPAT
	anim = (@scene.pbCommonAnimationExists?("UltraBurst")) ? "UltraBurst" : "MegaEvolution"
    pbDisplay(_INTL("Bright light is about to burst out of {1}!",battler.pbThis(true)))    
    pbCommonAnimation(anim,battler)
    battler.pokemon.makeUltra
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation(anim+"2",battler)
    pbDisplay(_INTL("{1} regained its true power with Ultra Burst!",battler.pbThis))    
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = -2
	pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    battler.pbEffectsOnSwitchIn
  end
  
  def pbDynamax(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasDynamax? || battler.dynamax?
    return if @choices[idxBattler][2]==@struggle
	@scene.pbTrainerBattleSpeech(playerBattler?(battler) ? "dynamax" : "dynamaxOpp") if Settings::EBDX_COMPAT
    trainerName = pbGetOwnerName(idxBattler)
    pbDisplay(_INTL("{1} recalled {2}!",trainerName,battler.pbThis(true)))
    battler.effects[PBEffects::Dynamax]     = Settings::DYNAMAX_TURNS
    battler.effects[PBEffects::NonGMaxForm] = battler.form
    battler.effects[PBEffects::Encore]      = 0
    battler.effects[PBEffects::Disable]     = 0
    battler.effects[PBEffects::Substitute]  = 0
    battler.effects[PBEffects::Torment]     = false
    @scene.pbRecall(idxBattler)
	battler.pokemon.makeDynamax if !Settings::EBDX_COMPAT
    # Alcremie reverts to form 0 only for the duration of Gigantamax.
    battler.pokemon.form = 0 if battler.isSpecies?(:ALCREMIE) && battler.gmaxFactor?
    battler.pokemon.form = 0 if battler.isSpecies?(:CRAMORANT)
    text = "Dynamax"
    text = "Gigantamax" if battler.canGmax?
    text = "Eternamax"  if battler.isSpecies?(:ETERNATUS)
    pbDisplay(_INTL("{1}'s ball surges with {2} energy!",battler.pbThis,text))
    party = pbParty(idxBattler)
    idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
    for i in idxPartyStart...idxPartyEnd
      if party[i] == battler.pokemon
        pbSendOut([[idxBattler,party[i]]])
      end
    end
	back = !opposes?(idxBattler)
	pkmn = battler.effects[PBEffects::TransformPokemon]
	# EBDX Compatibility
	if Settings::EBDX_COMPAT
	  battler.pokemon.makeDynamax
	  @scene.pbChangePokemon(battler,battler.pokemon)
	  if battler.effects[PBEffects::Transform]
	    @scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back,nil,battler)
	  end
	  @scene.sprites["pokemon_#{idxBattler}"].dynamax = true
	  EliteBattle.playCommonAnimation(:ROAR, @scene, battler.index)
	else
	  # Gets appropriate battler sprite if user was transformed prior to Dynamaxing.
      if battler.effects[PBEffects::Transform]
        @scene.sprites["pokemon_#{idxBattler}"].setPokemonBitmap(pkmn,back,battler)
      end
	end
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -2
    oldhp = battler.hp
    battler.pbUpdate(false)
    @scene.pbHPChanged(battler,oldhp)
    battler.pokemon.pbReversion(true)
  end
  
  #-----------------------------------------------------------------------------
  # Registering Z-Moves.
  #-----------------------------------------------------------------------------
  def pbRegisterZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @zMove[side][owner] = idxBattler
  end
  
  def pbUnregisterZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @zMove[side][owner] = -1 if @zMove[side][owner]==idxBattler
  end

  def pbToggleRegisteredZMove(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @zMove[side][owner]==idxBattler
      @zMove[side][owner] = -1
    else
      @zMove[side][owner] = idxBattler
    end
  end
  
  def pbRegisteredZMove?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @zMove[side][owner]==idxBattler
  end
  
  #-----------------------------------------------------------------------------
  # Registering Ultra Burst.
  #-----------------------------------------------------------------------------
  def pbRegisterUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = idxBattler
  end
  
  def pbUnregisterUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @ultraBurst[side][owner] = -1 if @ultraBurst[side][owner]==idxBattler
  end

  def pbToggleRegisteredUltraBurst(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @ultraBurst[side][owner]==idxBattler
      @ultraBurst[side][owner] = -1
    else
      @ultraBurst[side][owner] = idxBattler
    end
  end
  
  def pbRegisteredUltraBurst?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @ultraBurst[side][owner]==idxBattler
  end

  #-----------------------------------------------------------------------------
  # Registering Dynamax
  #-----------------------------------------------------------------------------
  def pbRegisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = idxBattler
  end

  def pbUnregisterDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @dynamax[side][owner] = -1 if @dynamax[side][owner]==idxBattler
  end

  def pbToggleRegisteredDynamax(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    if @dynamax[side][owner]==idxBattler
      @dynamax[side][owner] = -1
    else
      @dynamax[side][owner] = idxBattler
    end
  end

  def pbRegisteredDynamax?(idxBattler)
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @dynamax[side][owner]==idxBattler
  end
  
  #-----------------------------------------------------------------------------
  # Triggers the use of each battle mechanic during the attack phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")
    end
    #---------------------------------------------------------------------------
    # Prepare for Z-Moves.
    #---------------------------------------------------------------------------
    @battlers.each_with_index do |b,i|
      next if !b || b.fainted?
      next if @choices[i][0]!=:UseMove
      side  = (opposes?(i)) ? 1 : 0
      owner = pbGetOwnerIndexFromBattlerIndex(i)
      @choices[i][2].zmove_sel = (@zMove[side][owner]==i)
    end
    #---------------------------------------------------------------------------
    PBDebug.log("")
    pbCalculatePriority(true)
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseUltraBurst
    pbAttackPhaseZMoves
    pbAttackPhaseDynamax
    pbAttackPhaseRaidBoss
    pbAttackPhaseCheer
    pbAttackPhaseMoves
  end
  
  def pbAttackPhaseZMoves
    pbPriority.each do |b|
      idxMove = @choices[b.index]
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @zMove[b.idxOwnSide][owner]!=b.index
      @choices[b.index][2].zmove_sel = true
    end
  end
  
  def pbAttackPhaseUltraBurst
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @ultraBurst[b.idxOwnSide][owner]!= b.index
      pbUltraBurst(b.index)
    end
  end
  
  def pbAttackPhaseDynamax
    pbPriority.each do |b|
      next if wildBattle? && b.opposes?
      next unless @choices[b.index][0]==:UseMove && !b.fainted?
      owner = pbGetOwnerIndexFromBattlerIndex(b.index)
      next if @dynamax[b.idxOwnSide][owner]!= b.index
      pbDynamax(b.index)
    end
  end
  
#===============================================================================
# Reverting the effects of Dynamax.
#===============================================================================
# Counts down Dynamax turns and reverts the user once it expires.
#-------------------------------------------------------------------------------
  alias _ZUD_pbEndOfRoundPhase pbEndOfRoundPhase
  def pbEndOfRoundPhase
    _ZUD_pbEndOfRoundPhase
    eachBattler do |b|
      pbEORMaxRaidEffects(b)
      next if b.effects[PBEffects::Dynamax]<=0
      # Converts any newly-learned moves into Max Moves while Dynamaxed.
      for m in 0...b.moves.length
        next if b.moves[m].id==0 || b.moves[m].id==nil
        next if b.moves[m].maxMove?
		b.effects[PBEffects::MaxMovePP][m] = 0
		b.effects[PBEffects::BaseMoves][m] = b.moves[m]
        b.moves[m] = PokeBattle_MaxMove.from_base_move(self,b,b.moves[m])
		b.moves[m].pp       = b.effects[PBEffects::BaseMoves][m].pp
		b.moves[m].total_pp = b.effects[PBEffects::BaseMoves][m].total_pp
      end
      b.effects[PBEffects::Dynamax]-=1
      b.unmax if b.effects[PBEffects::Dynamax]==0
      pbRaidUpdate(b)
    end
  end

  #-----------------------------------------------------------------------------
  # Reverts Dynamax upon switching.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbRecallAndReplace pbRecallAndReplace
  def pbRecallAndReplace(*args)
    idxBattler = args[0]
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax?
    _ZUD_pbRecallAndReplace(*args)
  end
  
  alias _ZUD_pbSwitchInBetween pbSwitchInBetween
  def pbSwitchInBetween(*args)
    idxBattler = args[0]
    ret = _ZUD_pbSwitchInBetween(*args)
    @battlers[idxBattler].unmax if @battlers[idxBattler].dynamax? && ret > 0
    return ret 
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Dynamax at the end of battle.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    @battlers.each do |b|
      next if !b || !b.dynamax?
      next if b.effects[PBEffects::MaxRaidBoss]
      b.unmax
    end
    _ZUD_pbEndOfBattle
  end
end

#-------------------------------------------------------------------------------
# Reverts Dynamax upon fainting.
#-------------------------------------------------------------------------------
class PokeBattle_Scene
  alias _ZUD_pbFaintBattler pbFaintBattler
  def pbFaintBattler(battler)
    if @battle.battlers[battler.index].dynamax?
      @battle.battlers[battler.index].unmax
    end
    _ZUD_pbFaintBattler(battler)
  end
end

#===============================================================================
# Battler AI for ZUD mechanics.
#===============================================================================
class PokeBattle_AI
  def pbDefaultChooseEnemyCommand(idxBattler)
    return if pbEnemyShouldUseItem?(idxBattler)
    return if pbEnemyShouldWithdraw?(idxBattler)
    return if @battle.pbAutoFightMenu(idxBattler)
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?(idxBattler)
    @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?(idxBattler)
    @battle.pbRegisterDynamax(idxBattler) if pbEnemyShouldDynamax?(idxBattler)
    pbChooseEnemyZMove(idxBattler) if pbEnemyShouldZMove?(idxBattler)
    pbChooseMoves(idxBattler) if !@battle.pbRegisteredZMove?(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Z-Moves - The AI will use Z-Moves if opponent's HP isn't below half.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldZMove?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanZMove?(idxBattler)
      battler.eachOpposing { |opp|
        if opp.hp>(opp.totalhp/2).round
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use a Z-Move")
          return true
          break
        end
      }
    end
    return false 
  end

  def pbChooseEnemyZMove(idxBattler) #Put specific cases for trainers using status Z-Moves
    chosenmove  = nil
    chosenindex = -1
    useZMove    = false
    attacker    = @battle.battlers[idxBattler]
    # Choose the move
    for i in 0...attacker.moves.length
      move = attacker.moves[i]
      next if !move 
      if attacker.pbCompatibleZMove?(move)
        if !chosenmove
          chosenindex = i
          chosenmove  = move
        else
          if move.baseDamage>chosenmove.baseDamage
            chosenindex = i
            chosenmove  = move
          end          
        end
      end
    end   
    target_i   = nil
    target_eff = 0 
    # Choose the target
    attacker.eachOpposing { |opp|
      temp_eff = chosenmove.pbCalcTypeMod(chosenmove.type,attacker,opp)        
      if temp_eff > target_eff
        target_i   = opp.index
        target_eff = target_eff
        useZMove   = true
      end 
    }
    if useZMove
      @battle.pbRegisterZMove(idxBattler)
      @battle.pbRegisterMove(idxBattler,chosenindex,false)
      @battle.pbRegisterTarget(idxBattler,target_i)
	  for i in attacker.moves; attacker.effects[PBEffects::BaseMoves].push(i); end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Ultra Burst - The AI will immediately use Ultra Burst, if possible.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldUltraBurst?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanUltraBurst?(idxBattler)
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Ultra Burst")
      return true
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Dynamax - The AI will only use Dynamax on their Trainer Ace Pokemon.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldDynamax?(idxBattler)
    battler = @battle.battlers[idxBattler]
    if @battle.pbCanDynamax?(idxBattler) && battler.pokemon.trainerAce?
      battler.pbDisplayPowerMoves(2) if !@battle.pbOwnedByPlayer?(idxBattler)
      PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will Dynamax")
      return true
    end
    return false
  end
end