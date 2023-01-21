#===============================================================================
# New Pokemon properties.
#===============================================================================
class Pokemon
  attr_accessor :dynamax, :reverted, :dynamax_lvl, :gmaxfactor, :acepkmn
  #-----------------------------------------------------------------------------
  # Trainer Ace
  #-----------------------------------------------------------------------------
  def trainerAce?;      return @acepkmn;          end
  def makeAcePkmn;      @acepkmn = true;          end
  def notAcePkmn;       @acepkmn = false;         end
    
  #-----------------------------------------------------------------------------
  # Dynamax values
  #-----------------------------------------------------------------------------
  def dynamax_lvl;      return @dynamax_lvl || 0; end
  def giveGMaxFactor;   @gmaxfactor = true;       end
  def removeGMaxFactor; @gmaxfactor = false;      end
    
  #-----------------------------------------------------------------------------
  # Dynamax states
  #-----------------------------------------------------------------------------
  def dynamax?;         return @dynamax;          end
  def reverted?;        return @reverted;         end
  def gmaxFactor?;      return @gmaxfactor;       end
    
  def dynamaxAble?
    return false if egg? || shadowPokemon? || species_data.no_dynamax
    return true
  end
  
  def hasGmax?
    return false if !dynamaxAble?
    return true if isSpecies?(:ALCREMIE)
    species_list = GameData::PowerMove.species_list(2)
    for i in species_list
      return true if i==species_data.id
    end
    return false
  end
  
  def canGmax?
    return true if isSpecies?(:ETERNATUS) && gmaxFactor?
    return true if hasGmax? && gmaxFactor?
    return false
  end
  
  def eternamax?
    return (isSpecies?(:ETERNATUS) && gmaxFactor? && dynamax?)
  end
    
  def gmax?
    return true if eternamax? || (dynamax? && gmaxFactor? && hasGmax?)
  end
  
  #-----------------------------------------------------------------------------
  # Change Dynamax states
  #-----------------------------------------------------------------------------
  def makeDynamax
    @dynamax  = true
    @reverted = false
  end
  
  def makeUndynamax
    @dynamax  = false
    @reverted = true
  end

  def pbReversion(revert=false)
    @reverted = revert
  end
  
  #-----------------------------------------------------------------------------
  # Change Dynamax Levels
  #-----------------------------------------------------------------------------
  def addDynamaxLvl
    if dynamaxAble?
      self.dynamax_lvl += 1
      self.dynamax_lvl  = 10 if self.dynamax_lvl>10
    end
  end
  
  def removeDynamaxLvl
    self.dynamax_lvl -= 1
    self.dynamax_lvl  = 0 if self.dynamax_lvl<0
  end
  
  def setDynamaxLvl(value)
    if dynamaxAble? ; self.dynamax_lvl = value; end
  end
    
  #-----------------------------------------------------------------------------
  # Power Move compatibility checks.
  #-----------------------------------------------------------------------------  
  def compat_zmove?(param, equipping=nil, transform=nil)
    return false if egg? || shadowPokemon?
    item    = (equipping) ? equipping : self.item
	species = (transform) ? transform : self.species_data.id
    return GameData::PowerMove.z_compat?(param, item, species)
  end
  
  def compat_maxmove?(param)
    return false if egg? || shadowPokemon?
    return GameData::PowerMove.g_compat?(param, self.species_data.id)
  end
  
  #-----------------------------------------------------------------------------
  # Returns the ID of a Power Move compatible with the inputted parameters.
  #-----------------------------------------------------------------------------
  def get_zmove(param)
    return nil if !compat_zmove?(param) 
    return GameData::PowerMove.zmove_from(param, self.item, species_data.id)
  end  
    
  def get_maxmove(param, category=nil)
    return nil if !compat_maxmove?(param)
    return GameData::Move.get(:MAXGUARD).id if category==2
    return GameData::PowerMove.maxmove_from(param, species_data.id, canGmax?)
  end
  
  #-----------------------------------------------------------------------------
  # Ultra Burst
  #-----------------------------------------------------------------------------
  def hasUltra?
    v = MultipleForms.call("getUltraForm", self)
    return !v.nil?
  end  

  def ultra?
    v = MultipleForms.call("getUltraForm", self)
    return !v.nil? && v == @form
  end

  def makeUltra
    v = MultipleForms.call("getUltraForm", self)
    self.form = v if !v.nil?
  end

  def makeUnUltra
    v = MultipleForms.call("getUnUltraForm", self)
    if !v.nil?;   self.form = v;
    elsif ultra?; self.form = 0;
    end
  end
  
  def ultraName
    v=MultipleForms.call("getUltraName", self)
    return (v.nil?) ? "" : v
  end
  
  #-----------------------------------------------------------------------------
  # Stat Calculations
  #-----------------------------------------------------------------------------
  def realhp;       return @hp/dynamaxBoost;             end
  def realtotalhp;  return @totalhp/dynamaxBoost;        end
  def dynamaxCalc;  return (1.5+(dynamax_lvl*0.05));     end
  def dynamaxBoost; return (dynamax?) ? dynamaxCalc : 1; end
  
  def calcHP(base, level, iv, ev)
    return 1 if base == 1  # For Shedinja
    return ((((base *2 + iv + (ev / 4)) * level / 100).floor + level + 10) * dynamaxBoost).ceil
  end
  
  def calc_stats
    oldhpDiff  = @totalhp - @hp
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    nature_mod = {}
    GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
    this_nature = self.nature_for_stats
    if this_nature
      this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
    end
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id])
      else
        stats[s.id] = calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id])
      end
    end
    # Dynamax HP Calcs
    if dynamax? && !reverted? && @totalhp>1
      @totalhp = stats[:HP]
      @hp      = (@hp * dynamaxCalc).ceil
      @hp      = @totalhp - oldhpDiff if isSpecies?(:ETERNATUS) && gmaxFactor?
    elsif reverted? && !dynamax? && @totalhp>1
      @totalhp = stats[:HP]
      @hp      = (@hp / dynamaxCalc).round
      @hp      = @totalhp - oldhpDiff if isSpecies?(:ETERNATUS) && gmaxFactor?
      @hp     += 1 if !fainted? && @hp<=0
    else
      hpDiff   = @totalhp - @hp
      @totalhp = stats[:HP]
      @hp      = @totalhp - hpDiff
    end
    @hp      = 0 if @hp < 0
    @hp      = @totalhp if @hp > @totalhp
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end
  
  alias _ZUD_baseStats baseStats
  def baseStats
    v = MultipleForms.call("baseStats", self)
    return (v.nil?) ? _ZUD_baseStats : v
  end
  
  alias _ZUD_initialize initialize  
  def initialize(*args)
    _ZUD_initialize(*args)
    @dynamax_lvl = 0
    @dynamax     = false
    @reverted    = false
    @gmaxfactor  = false
    @acepkmn     = false
  end
end

#===============================================================================
# Form handlers for Ultra Necrozma & Eternamax Eternatus.
#===============================================================================
# Ultra Necrozma
MultipleForms.register(:NECROZMA,{
  "getUltraForm" => proc { |pkmn|
     next 3 if pkmn.hasItem?(:ULTRANECROZIUMZ) && pkmn.form > 0
     next
  },
  "getUltraName" => proc { |pkmn|
     next _INTL("Ultra Necrozma") if pkmn.form > 2
     next
  },
  "getUnUltraForm" => proc { |pkmn|
     next 1 if pkmn.hasMove?(:SUNSTEELSTRIKE)
     next 2 if pkmn.hasMove?(:MOONGEISTBEAM)
     next
  },
  "onSetForm" => proc { |pkmn, form, oldForm|
    next if form > 2 || oldForm > 2
    form_moves = [
       :SUNSTEELSTRIKE,
       :MOONGEISTBEAM
    ]
    if form == 0
      move_index = -1
      pkmn.moves.each_with_index do |move, i|
        next if !form_moves.any? { |m| m == move.id }
        move_index = i
        break
      end
      if move_index >= 0
        move_name = pkmn.moves[move_index].name
        pkmn.forget_move_at_index(move_index)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, move_name))
        pbLearnMove(:CONFUSION) if pkmn.numMoves == 0
      end
    else
      new_move_id = form_moves[form - 1]
      pbLearnMove(pkmn, new_move_id, true)
    end
  }
})

# Eternamax Eternatus
MultipleForms.register(:ETERNATUS,{
  "baseStats" => proc { |pkmn|
    next if !(pkmn.isSpecies?(:ETERNATUS) && pkmn.dynamax? && pkmn.gmaxFactor?)
	base_stats = {}
    base_stats[:HP]              = 255
    base_stats[:ATTACK]          = 115
    base_stats[:DEFENSE]         = 250
    base_stats[:SPEED]           = 130
    base_stats[:SPECIAL_ATTACK]  = 125
    base_stats[:SPECIAL_DEFENSE] = 250
	next base_stats
  }
})
