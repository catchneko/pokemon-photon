#===============================================================================
# Selecting and converting moves when using Z-Moves or Max Moves.
#===============================================================================
class PokeBattle_Battler
  
  #-----------------------------------------------------------------------------
  # Converts base moves into Z-Moves/Max Moves.
  #-----------------------------------------------------------------------------
  def pbDisplayPowerMoves(mode=0)
    # Set "mode" to 1 to convert to Z-Moves.
    # Set "mode" to 2 to convert to Max Moves.
    species = (@effects[PBEffects::Transform]) ? @effects[PBEffects::TransformPokemon].species_data.id : nil
    for i in 0...@moves.length
	  next if !@moves[i]
	  @effects[PBEffects::BaseMoves].push(@moves[i])
      # Z-Moves
      if mode==1
        next if !@pokemon.compat_zmove?(@moves[i], nil, species)
        @moves[i]          = PokeBattle_ZMove.from_base_move(@battle, self, @moves[i])
        @moves[i].pp       = 1
        @moves[i].total_pp = 1
      # Max Moves
      elsif mode==2
        currentPP          = @moves[i].pp
        totalPP            = @moves[i].total_pp
        @moves[i]          = PokeBattle_MaxMove.from_base_move(@battle, self, @moves[i])
        @moves[i].pp       = currentPP     
        @moves[i].total_pp = totalPP
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Reverts Z-Moves/Max Moves into base moves.
  #-----------------------------------------------------------------------------
  def pbDisplayBaseMoves(mode=0)
    # Set "mode" to 1 to reduce PP of base move of converted Z-Move.
    # Set "mode" to 2 to reduce PP of base moves converted into Max Moves.
    # "Mode" can be omitted if there is no need to reduce PP.
    oldmoves    = []
    basemoves   = @pokemon.moves
    storedmoves = @effects[PBEffects::BaseMoves]
    # Determines base move set to revert to (considers Mimic/Transform).
    if @effects[PBEffects::MoveMimicked]
      for i in 0...@moves.length
        next if !@moves[i]
        if basemoves[i]==storedmoves[i]
          oldmoves.push(basemoves[i])
        else
          oldmoves.push(storedmoves[i])
        end
      end
    elsif @effects[PBEffects::Transform]
	  copiedmoves = @effects[PBEffects::TransformPokemon].moves
	  for i in 0...@moves.length
	    copiedmoves[i].pp = @moves[i].pp
		oldmoves.push(copiedmoves[i])
	  end
    else
      oldmoves = basemoves
    end
    for i in 0...@moves.length
      next if !@moves[i]
      if oldmoves[i].is_a?(PokeBattle_Move)
        @moves[i] = oldmoves[i]
      else
        @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,oldmoves[i])
      end
      @moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1 && @moves[i].category!=2
      @moves[i].pp -= @effects[PBEffects::MaxMovePP][i] if mode==2
      @moves[i].pp = 0 if @moves[i].pp<0
      if !@effects[PBEffects::Transform]
        @pokemon.moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1 && @moves[i].category!=2
        @pokemon.moves[i].pp -= @effects[PBEffects::MaxMovePP][i] if mode==2
        @pokemon.moves[i].pp = 0 if @pokemon.moves[i].pp<0
      end
    end
    @effects[PBEffects::BaseMoves].clear
  end
  
  #-----------------------------------------------------------------------------
  # Effects that may change a Z-Move/Max Move into one of a different type.
  #-----------------------------------------------------------------------------
  def pbChangePowerMove(choice)
    thismove = choice[2]
    if thismove.powerMove?
      basemove = @effects[PBEffects::BaseMoves][choice[1]]
      newtype  = :ELECTRIC if @effects[PBEffects::Electrify]
      newtype  = :ELECTRIC if @battle.field.effects[PBEffects::IonDeluge] && thismove.type==:NORMAL
      if thismove.type==:NORMAL && thismove.damagingMove?
        #-------------------------------------------------------------------------
        # Abilities that change move type (only applies to Max Moves).
        #-------------------------------------------------------------------------
        if thismove.maxMove?
          newtype = :ICE      if hasActiveAbility?(:REFRIGERATE)
          newtype = :FAIRY    if hasActiveAbility?(:PIXILATE)
          newtype = :FLYING   if hasActiveAbility?(:AERILATE)
          newtype = :ELECTRIC if hasActiveAbility?(:GALVANIZE)
        end
        #-------------------------------------------------------------------------
        # Weather is in play and base move is Weather Ball.
        #-------------------------------------------------------------------------
        if basemove.id==:WEATHERBALL
          case @battle.pbWeather
          when :Sun, :HarshSun;   newtype = :FIRE
          when :Rain, :HeavyRain; newtype = :WATER
          when :Sandstorm;        newtype = :ROCK
          when :Hail;             newtype = :ICE
          end
        #-------------------------------------------------------------------------
        # Terrain is in play and base move is Terrain Pulse.
        #-------------------------------------------------------------------------
        elsif basemove.id==:TERRAINPULSE
          case @battle.field.terrain
          when :Electric;         newtype = :ELECTRIC
          when :Grassy;           newtype = :GRASS
          when :Misty;            newtype = :FAIRY
          when :Psychic;          newtype = :PSYCHIC
          end
        #-------------------------------------------------------------------------
        # Base move is Revelation Dance.
        #-------------------------------------------------------------------------
        elsif basemove.id==:REVELATIONDANCE
          userTypes = pbTypes(true)
          newtype   = userTypes[0]
        #-------------------------------------------------------------------------
        # Base move is Techno Blast and a drive is held by Genesect.
        #-------------------------------------------------------------------------
        elsif basemove.id==:TECHNOBLAST && isSpecies?(:GENESECT)
          itemtype  = true
          itemTypes = {
             :SHOCKDRIVE => :ELECTRIC,
             :BURNDRIVE  => :FIRE,
             :CHILLDRIVE => :ICE,
             :DOUSEDRIVE => :WATER
          }
        #-------------------------------------------------------------------------
        # Base move is Judgment and user has Multitype and held plate.
        #-------------------------------------------------------------------------
        elsif basemove.id==:JUDGMENT && hasActiveAbility?(:MULTITYPE)
          itemtype  = true
          itemTypes = {
             :FISTPLATE   => :FIGHTING,
             :SKYPLATE    => :FLYING,
             :TOXICPLATE  => :POISON,
             :EARTHPLATE  => :GROUND,
             :STONEPLATE  => :ROCK,
             :INSECTPLATE => :BUG,
             :SPOOKYPLATE => :GHOST,
             :IRONPLATE   => :STEEL,
             :FLAMEPLATE  => :FIRE,
             :SPLASHPLATE => :WATER,
             :MEADOWPLATE => :GRASS,
             :ZAPPLATE    => :ELECTRIC,
             :MINDPLATE   => :PSYCHIC,
             :ICICLEPLATE => :ICE,
             :DRACOPLATE  => :DRAGON,
             :DREADPLATE  => :DARK,
             :PIXIEPLATE  => :FAIRY
          }
        #-------------------------------------------------------------------------
        # Base move is Multi-Attack and user has RKS System and held memory.
        #-------------------------------------------------------------------------
        elsif basemove.id==:MULTIATTACK && hasActiveAbility?(:RKSSYSTEM)
          itemtype  = true
          itemTypes = {
             :FIGHTINGMEMORY => :FIGHTING,
             :FLYINGMEMORY   => :FLYING,
             :POISONMEMORY   => :POISON,
             :GROUNDMEMORY   => :GROUND,
             :ROCKMEMORY     => :ROCK,
             :BUGMEMORY      => :BUG,
             :GHOSTMEMORY    => :GHOST,
             :STEELMEMORY    => :STEEL,
             :FIREMEMORY     => :FIRE,
             :WATERMEMORY    => :WATER,
             :GRASSMEMORY    => :GRASS,
             :ELECTRICMEMORY => :ELECTRIC,
             :PSYCHICMEMORY  => :PSYCHIC,
             :ICEMEMORY      => :ICE,
             :DRAGONMEMORY   => :DRAGON,
             :DARKMEMORY     => :DARK,
             :FAIRYMEMORY    => :FAIRY
          }
        end
        if itemActive? && itemtype
          itemTypes.each do |item, itemType|
            next if !hasActiveItem?(item)
            newtype = itemType
            break
          end
        end
      end
      if newtype && GameData::Type.exists?(newtype)
        #-------------------------------------------------------------------------
        # Z-Moves - Converts to a new Z-Move of a given type.
        #-------------------------------------------------------------------------
        if thismove.zMove?
          zMove        = @pokemon.get_zmove(newtype)
          newMove      = Pokemon::Move.new(zMove)
          moveFunction = newMove.function_code || "Z000"
          className    = sprintf("PokeBattle_Move_%s",moveFunction)
          if Object.const_defined?(className)
            return Object.const_get(className).new(battle, basemove, newMove)
          end
          return PokeBattle_ZMove.new(battle, basemove, newMove)
        end
        #-------------------------------------------------------------------------
        # Max Moves - Converts to a new Max Move of a given type.
        #-------------------------------------------------------------------------
        if thismove.maxMove?
          maxMove      = @pokemon.get_maxmove(newtype)
          newMove      = Pokemon::Move.new(maxMove)
          moveFunction = newMove.function_code || "D000"
          className    = sprintf("PokeBattle_Move_%s",moveFunction)
          if Object.const_defined?(className)
            return Object.const_get(className).new(battle, basemove, newMove)
          end
          return PokeBattle_MaxMove.new(@battle, basemove, newMove)
        end
      end
    end
    return thismove
  end
  
  #-----------------------------------------------------------------------------
  # Handles the actual use of Z-Moves, and converts to base moves when done.
  #-----------------------------------------------------------------------------
  def pbProcessTurn(choice,tryFlee=true)
    return false if fainted?
    if tryFlee && @battle.wildBattle? && opposes? &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
      pbBeginTurn(choice)
      pbSEPlay("Battle flee")
      @battle.pbDisplay(_INTL("{1} fled from battle!",pbThis))
      @battle.decision = 3
      pbEndTurn(choice)
      return true
    end
    if choice[0]==:Shift
      idxOther = -1
      case @battle.pbSideSize(@index)
      when 2
        idxOther = (@index+2)%4
      when 3
        if @index!=2 && @index!=3
          idxOther = ((@index%2)==0) ? 2 : 3
        end
      end
      if idxOther>=0
        @battle.pbSwapBattlers(@index,idxOther)
        case @battle.pbSideSize(@index)
        when 2
          @battle.pbDisplay(_INTL("{1} moved across!",pbThis))
        when 3
          @battle.pbDisplay(_INTL("{1} moved to the center!",pbThis))
        end
      end
      pbBeginTurn(choice)
      pbCancelMoves
      @lastRoundMoved = @battle.turnCount
      return true
    end
    if choice[0]!=:UseMove
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return false
    end
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit] = false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge
      return false
    end
    # Z-Moves
    if choice[2].zmove_sel
      choice[2].zmove_sel = false
      @battle.pbUseZMove(self.index,choice[2],self.item)
    else
      PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
      PBDebug.logonerr{pbUseMove(choice,choice[2]==@battle.struggle)}
    end
    pbRaidBossUseMove(choice) # Allows a Raid Pokemon to use additional moves.
    @battle.pbJudge
    @battle.pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
    return true
  end
  
  def pbUseMoveSimple(moveID,target=-1,idxMove=-1,specialUsage=true)
    choice = []
    choice[0] = :UseMove
    choice[1] = idxMove
    if idxMove>=0
      choice[2] = @moves[idxMove]
    else
      choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
      choice[2].pp = -1
    end
    choice[3] = target
    PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
    # Z-Moves
    side  = (@battle.opposes?(self.index)) ? 1 : 0
    owner = @battle.pbGetOwnerIndexFromBattlerIndex(self.index)
    if @battle.zMove[side][owner]==self.index
      z_move  = PokeBattle_ZMove.from_base_move(@battle,self,choice[2])
      z_move.pbUse(self,choice,specialUsage)
    else
      pbUseMove(choice,specialUsage)
    end
  end
  
  alias _ZUD_pbUseMove pbUseMove
  def pbUseMove(choice,specialUsage=false)
    @lastMoveUsedIsZMove = false
    @effects[PBEffects::UsedZMoveIndex] = choice[1] if choice[2].zMove?
    choice[2] = pbChangePowerMove(choice)
    _ZUD_pbUseMove(choice,specialUsage)
  end
end