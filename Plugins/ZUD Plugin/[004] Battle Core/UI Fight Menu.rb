#===============================================================================
# Applies the effects of a registered battle mechanic when toggled in the menu.
#===============================================================================
class PokeBattle_Scene
  def pbFightMenu(idxBattler,megaEvoPossible = false,
                             ultraPossible   = false,
                             zMovePossible   = false,
                             dynamaxPossible = false
                             )
                             
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex  = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    mechanicPossible = false
    cw.chosen_button = FightMenuDisplay::NoButton
    cw.chosen_button = FightMenuDisplay::MegaButton       if megaEvoPossible
    cw.chosen_button = FightMenuDisplay::UltraBurstButton if ultraPossible
    cw.chosen_button = FightMenuDisplay::ZMoveButton      if zMovePossible
    cw.chosen_button = FightMenuDisplay::DynamaxButton    if dynamaxPossible
    if megaEvoPossible || ultraPossible || 
       zMovePossible   || dynamaxPossible
      mechanicPossible = true
    end
    cw.setIndexAndMode(moveIndex,(mechanicPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if ultraPossible
          newMode = (@battle.pbRegisteredUltraBurst?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if zMovePossible
          newMode = (@battle.pbRegisteredZMove?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        if dynamaxPossible
          newMode = (@battle.pbRegisteredDynamax?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      pbUpdate(cw)
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
#===============================================================================
# Confirm Selection
#===============================================================================
      if Input.trigger?(Input::USE)
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          if cw.mode==2
            itemname = battler.item.name
            movename = battler.moves[cw.index].name
            if !battler.pbCompatibleZMove?(battler.moves[cw.index])
              @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",movename,itemname))
              if battler.effects[PBEffects::PowerMovesButton]
                battler.effects[PBEffects::PowerMovesButton] = false
                battler.pbDisplayBaseMoves(1)
              end
              break if yield -1
            end
          end
        end
        battler.effects[PBEffects::PowerMovesButton] = false if ultraPossible
        #-----------------------------------------------------------------------
        # Dynamax - Gets Max Move PP usage.
        #-----------------------------------------------------------------------
        if battler.effects[PBEffects::PowerMovesButton]
          pressure = true if @battle.pbCheckOpposingAbility(:PRESSURE,battler)
          ppusage  = (pressure) ? 2 : 1
          battler.effects[PBEffects::MaxMovePP][cw.index] += ppusage
        end
        #-----------------------------------------------------------------------
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
#===============================================================================
# Cancel Selection
#===============================================================================
      elsif Input.trigger?(Input::BACK)
        #-----------------------------------------------------------------------
        # Z-Moves - Reverts to base moves.
        #-----------------------------------------------------------------------
        if zMovePossible
          if battler.effects[PBEffects::PowerMovesButton]
            battler.pbDisplayBaseMoves
          end
        end
        #-----------------------------------------------------------------------
        # Dynamax - Reverts to base moves.
        #-----------------------------------------------------------------------
        if dynamaxPossible
          if battler.effects[PBEffects::PowerMovesButton] && !battler.dynamax?
            battler.pbDisplayBaseMoves
          end
        end
        #-----------------------------------------------------------------------
        battler.effects[PBEffects::PowerMovesButton] = false
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
#===============================================================================
# Toggle Battle Mechanic
#===============================================================================
      elsif Input.trigger?(Input::ACTION)
        #-----------------------------------------------------------------------
        # Mega Evolution
        #-----------------------------------------------------------------------
        if megaEvoPossible
          pbPlayDecisionSE
          break if yield -2
          needRefresh = true
        end
		#-----------------------------------------------------------------------
        # Ultra Burst
        #-----------------------------------------------------------------------
        if ultraPossible
          battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
          if battler.effects[PBEffects::PowerMovesButton]
            pbPlayZUDButton
          else
            pbPlayCancelSE
          end
          break if yield -3
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Z-Moves
        #-----------------------------------------------------------------------
        if zMovePossible
          battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
          if battler.effects[PBEffects::PowerMovesButton]
            battler.pbDisplayPowerMoves(1)
            pbPlayZUDButton
          else
            battler.pbDisplayBaseMoves
            pbPlayCancelSE
          end
          needFullRefresh = true
          break if yield -4
          needRefresh = true
        end
        #-----------------------------------------------------------------------
        # Dynamax
        #-----------------------------------------------------------------------
        if dynamaxPossible
          battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
          if battler.effects[PBEffects::PowerMovesButton]
            battler.pbDisplayPowerMoves(2)
            pbPlayZUDButton
          else
            battler.pbDisplayBaseMoves
            pbPlayCancelSE
          end
          needFullRefresh = true
          break if yield -5
          needRefresh = true
        end
#===============================================================================
# Shift Command
#===============================================================================
      elsif Input.trigger?(Input::SPECIAL)
        if cw.shiftMode>0
          pbPlayDecisionSE
          break if yield -6
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end
end