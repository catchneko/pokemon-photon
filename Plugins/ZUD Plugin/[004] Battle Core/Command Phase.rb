#===============================================================================
# Command Phase
#===============================================================================
class PokeBattle_Battle
  
  #-----------------------------------------------------------------------------
  # Pokemon with an eligible battle mechanic may always access its fight menu,
  # even if the effects of Encore would otherwise lock them out.
  #-----------------------------------------------------------------------------
  def pbCanShowFightMenu?(idxBattler)
    battler = @battlers[idxBattler]
    # Restores the user's Encore status after a Z-Move was used.
    if battler.effects[PBEffects::EncoreRestore]
      battler.effects[PBEffects::Encore]        = battler.effects[PBEffects::EncoreRestore][0]
      battler.effects[PBEffects::EncoreMove]    = battler.effects[PBEffects::EncoreRestore][1]
      battler.effects[PBEffects::EncoreRestore] = nil
    end
    return false if battler.effects[PBEffects::Encore]>0 && !pbCanUseBattleMechanic?(idxBattler)
    usable = false
    battler.eachMoveWithIndex do |_m,i|
      next if !pbCanChooseMove?(idxBattler,i,false)
      usable = true
      break
    end
    return usable
  end
  
  #-----------------------------------------------------------------------------
  # Message display when an Encored move is selected in the fight menu.
  #-----------------------------------------------------------------------------
  def pbCanChooseMove?(idxBattler,idxMove,showMessages,sleepTalk=false)
    battler = @battlers[idxBattler]
    move = battler.moves[idxMove]
    return false unless move
    if move.pp==0 && move.total_pp>0 && !sleepTalk
      pbDisplayPaused(_INTL("There's no PP left for this move!")) if showMessages
      return false
    end
    if battler.effects[PBEffects::Encore]>0
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove>=0 && idxMove!=idxEncoredMove && !move.powerMove?
        pbDisplayPaused(_INTL("Encore prevents using this move!")) if showMessages
        return false 
      end 
    end
    return battler.pbCanChooseMove?(move,true,showMessages,sleepTalk)
  end
  
  #-----------------------------------------------------------------------------
  # Unregisters mechanics and returns to base moves when a choice is cancelled.
  #-----------------------------------------------------------------------------
  def pbCancelChoice(idxBattler)
    if @choices[idxBattler][0]==:UseItem
      item = @choices[idxBattler][1]
      pbReturnUnusedItemToBag(item,idxBattler) if item
    end
    pbUnregisterMegaEvolution(idxBattler)
    pbUnregisterUltraBurst(idxBattler)
    if pbRegisteredZMove?(idxBattler)
      pbUnregisterZMove(idxBattler)
      @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
      @battlers[idxBattler].pbDisplayBaseMoves
    end
    if pbRegisteredDynamax?(idxBattler)
      pbUnregisterDynamax(idxBattler)
      @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
      @battlers[idxBattler].pbDisplayBaseMoves
    end
    pbClearChoice(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Battle mechanics during the command phase.
  #-----------------------------------------------------------------------------
  def pbCommandPhase
    @scene.pbBeginCommandPhase
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Mega Evolution
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    # Ultra Burst
    for side in 0...2
      @ultraBurst[side].each_with_index do |uBurst,i|
        @ultraBurst[side][i] = -1 if uBurst>=0
      end
    end
    # Z-Moves
    for side in 0...2
      @zMove[side].each_with_index do |zMove,i|
        @zMove[side][i] = -1 if zMove>=0
      end
    end
    # Dynamax
    for side in 0...2
      @dynamax[side].each_with_index do |dmax,i|
        @dynamax[side][i] = -1 if dmax>=0
      end
    end
    pbCommandPhaseLoop(true)
    return if @decision!=0
    pbCommandPhaseLoop(false)
  end
  
  #-----------------------------------------------------------------------------
  # Registers battle mechanics when triggered in the fight menu.
  #-----------------------------------------------------------------------------
  def pbFightMenu(idxBattler)
    return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
    return true if pbAutoFightMenu(idxBattler)
    ret = false
    @scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler),
                                  pbCanUltraBurst?(idxBattler),
                                  pbCanZMove?(idxBattler),
                                  pbCanDynamax?(idxBattler)
                                  ) { |cmd|
      case cmd
      when -1   # Cancel
      when -2   # Mega Evolution
        pbToggleRegisteredMegaEvolution(idxBattler)
        next false
      when -3   # Ultra Burst
        pbToggleRegisteredUltraBurst(idxBattler)
        next false
      when -4   # Z-Moves
        pbToggleRegisteredZMove(idxBattler)
        next false
      when -5   # Dynamax
        pbToggleRegisteredDynamax(idxBattler)
        next false
      when -6   # Shift
        pbUnregisterMegaEvolution(idxBattler)
        pbUnregisterUltraBurst(idxBattler)
        pbUnregisterZMove(idxBattler)
        pbUnregisterDynamax(idxBattler)
        @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
        @battlers[idxBattler].pbDisplayBaseMoves
        pbRegisterShift(idxBattler)
        ret = true
      else
        next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
                               !@battlers[idxBattler].moves[cmd].id
        next false if !pbRegisterMove(idxBattler,cmd)
        next false if !singleBattle? &&
           !pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
        ret = true
      end
      next true
    }
    return ret
  end
end