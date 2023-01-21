#===============================================================================
# The "Power Move" class, which handles all Z-Moves & Max Moves.
#===============================================================================
module GameData
  class PowerMove
    attr_reader :id
    attr_reader :id_number
    attr_reader :power_type   # Max Move || G-Max Move || Z-Move || Z-Move Ex || Z-Status Move
    attr_reader :req_criteria # Array of criteria for this Power Move
    attr_reader :status_atk   # [[Moves], Stage]
    attr_reader :status_def   # [[Moves], Stage]
    attr_reader :status_spatk # [[Moves], Stage]
    attr_reader :status_spdef # [[Moves], Stage]
    attr_reader :status_speed # [[Moves], Stage]
    attr_reader :status_acc   # [[Moves], Stage]
    attr_reader :status_eva   # [[Moves], Stage]
    attr_reader :status_omni  # [[Moves], Stage]
    attr_reader :status_heal  # [[Moves], Stage]
    attr_reader :status_crit  # [Moves]
    attr_reader :status_reset # [Moves]
    attr_reader :status_focus # [Moves]
    
    ZMOVE    = 0
    MAXMOVE  = 1
    ZMOVEEX  = 2
    GMAXMOVE = 3
    ZSTATUS  = 4

    DATA = {}
    DATA_FILENAME = "ZUD_PowerMoves.dat"

    SCHEMA = {
      #-------------------------------------------------------------------------
      # Power Moves
      #-------------------------------------------------------------------------
      "MaxMove"         => [0,  "ee",  :Move, :Type],
      "GMaxMove"        => [0, "eee",  :Move, :Type, :Species],
      "ZMove"           => [0, "eee",  :Move, :Item, :Type],
      "ZMoveEx"         => [0, "eeee", :Move, :Item, :Move, :Species],
      #-------------------------------------------------------------------------
      # Status Z-Moves
      #-------------------------------------------------------------------------
      "AtkBoost1"       => [0,  "*e",  :Move],
      "AtkBoost2"       => [0,  "*e",  :Move],
      "AtkBoost3"       => [0,  "*e",  :Move],
      
      "DefBoost1"       => [0,  "*e",  :Move],
      "DefBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
      "DefBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "SpAtkBoost1"     => [0,  "*e",  :Move],
      "SpAtkBoost2"     => [0,  "*e",  :Move],
      "SpAtkBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "SpDefBoost1"     => [0,  "*e",  :Move],
      "SpDefBoost2"     => [0,  "*e",  :Move],
      "SpDefBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "SpeedBoost1"     => [0,  "*e",  :Move],
      "SpeedBoost2"     => [0,  "*e",  :Move],
      "SpeedBoost3"     => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "AccBoost1"       => [0,  "*e",  :Move],
      "AccBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
      "AccBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "EvaBoost1"       => [0,  "*e",  :Move],
      "EvaBoost2"       => [0,  "*e",  :Move], # Not used by any existing moves.
      "EvaBoost3"       => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "OmniBoost1"      => [0,  "*e",  :Move],
      "OmniBoost2"      => [0,  "*e",  :Move], # Not used by any existing moves.
      "OmniBoost3"      => [0,  "*e",  :Move], # Not used by any existing moves.
      
      "HealUser"        => [0,  "*e",  :Move],
      "HealSwitch"      => [0,  "*e",  :Move],
      
      "CritBoost"       => [0,  "*e",  :Move],
      "ResetStats"      => [0,  "*e",  :Move],
      "FocusOnUser"     => [0,  "*e",  :Move],
      #-------------------------------------------------------------------------
      # Other data
      #-------------------------------------------------------------------------
      "DexData"         => [0, "efss", :Species] # Saved in GameData::Species, not here.
    }

    extend ClassMethods
    include InstanceMethods

    def initialize(hash)
      @id             = hash[:id]
      @id_number      = hash[:id_number]
      @power_type     = hash[:compat_type]
      @req_criteria   = hash[:req_criteria]
      @status_atk     = hash[:status_atk]
      @status_def     = hash[:status_def]
      @status_spatk   = hash[:status_spatk]
      @status_spdef   = hash[:status_spdef]
      @status_speed   = hash[:status_speed]
      @status_acc     = hash[:status_acc]
      @status_eva     = hash[:status_eva]
      @status_omni    = hash[:status_omni]
      @status_heal    = hash[:status_heal]
      @status_crit    = hash[:status_crit]
      @status_reset   = hash[:status_reset]
      @status_focus   = hash[:status_focus]
    end
    
    #---------------------------------------------------------------------------
    # Utilities for getting Power Move compatibility data.
    #---------------------------------------------------------------------------
    def zMove?;       return true if @power_type==ZMOVE;    end
    def zMoveEx?;     return true if @power_type==ZMOVEEX;  end
    def zStatus?;     return true if @power_type==ZSTATUS;  end
    def maxMove?;     return true if @power_type==MAXMOVE;  end
    def gmaxMove?;    return true if @power_type==GMAXMOVE; end
    def any_ZMove?;   return true if zMove?   || zMoveEx?;  end
    def any_MaxMove?; return true if maxMove? || gmaxMove?; end
    
    def power_move;   return (!zStatus?) ? @req_criteria[0] : nil; end
    def reqItem;      return @req_criteria[1] if any_ZMove?; end
    def reqMove;      return @req_criteria[2] if zMoveEx?;   end
    
    def reqType
      return @req_criteria[1] if any_MaxMove?
      return @req_criteria[2] if zMove?
    end
    
    def reqSpecies
      return @req_criteria[2] if gmaxMove?
      return @req_criteria[3] if zMoveEx?
    end
    
    #---------------------------------------------------------------------------
    # Returns total number of Power Moves, or number of specific Power Moves.
    #---------------------------------------------------------------------------
    def self.get_count(power_type=0)
      num = 0
      self.each do |m|
        if (power_type==1 && m.any_ZMove?) || # Gets only Z-Move count (excludes Status Z-Moves).
           (power_type==2 && m.any_MaxMove?)  # Gets only Max Move count.
          num += 1
        elsif power_type==0
          num += 1
        end
      end
      return num
    end
    #---------------------------------------------------------------------------
    # Returns a list of all species with an exclusive Z-Move(1) or G-Max(2) form.
    #---------------------------------------------------------------------------
    def self.species_list(mode=0)
      species_list = []
      self.each do |m|
        break if mode==0
        next if mode==1 && !m.zMoveEx?
        next if mode==2 && !m.gmaxMove?
        species_list.push(m.reqSpecies)
      end
      if GameData::Species.exists?(:ETERNATUS) && mode==2
        species_list.push(:ETERNATUS)
      end
      return species_list
    end
    #---------------------------------------------------------------------------
    # Returns a required Z-Crystal based on the inputted Type.
    #---------------------------------------------------------------------------
    def self.item_from(type)
      self.each do |m|
        next if !m.zMove?
        if type==m.reqType; return m.reqItem; end
      end
    end
    #---------------------------------------------------------------------------
    # Returns true when all inputted parameters are compatible.
    #---------------------------------------------------------------------------
    # Z-Moves
    def self.z_compat?(param, item, species)
      return true if self.zmove_from(param, item, species)
      return false
    end
    # Max Moves
    def self.g_compat?(param, species)
      return true if self.maxmove_from(param, species)
      return false
    end
    #---------------------------------------------------------------------------
    # Returns a Z-Move based on the inputted parameters.
    # Parameters can be any of the following (or an array containing the following):
    # PokeBattle_ZMove, PokeBattle_Move, Pokemon::Move, GameData::Move, GameData::Type
    #---------------------------------------------------------------------------
    def self.zmove_from(param, item, species)
      ret = nil
      self.each do |m|
        next if !m.any_ZMove?
        next if m.zMoveEx? && species!=m.reqSpecies
        if item == m.reqItem
          if param.is_a?(Array)
            for i in param
              if i.id == m.reqMove || i.type == m.reqType
                ret = m.power_move
              end
            end
          else
            if param.is_a?(PokeBattle_ZMove)
              ret = m.power_move
            elsif param.is_a?(PokeBattle_Move)
              ret = m.power_move if param.id   == m.reqMove
              ret = m.power_move if param.type == m.reqType
            elsif param.is_a?(Pokemon::Move)
              ret = m.power_move if param.id   == m.reqMove
              ret = m.power_move if param.type == m.reqType
            elsif GameData::Move.exists?(param)
              ret = m.power_move if param == m.reqMove
              ret = m.power_move if GameData::Move.get(param).type == m.reqType
            elsif GameData::Type.exists?(param)
              ret = m.power_move if param == m.reqType
            end
          end
        end
      end
      return ret
    end
    #---------------------------------------------------------------------------
    # Returns a Max Move based on the inputted parameters.
    # Parameters can be any of the following (or an array containing the following):
    # PokeBattle_MaxMove, PokeBattle_Move, Pokemon::Move, GameData::Move, GameData::Type
    #---------------------------------------------------------------------------
    def self.maxmove_from(param, species, gmax=false)
      ret = nil
      self.each do |m|
        next if !m.any_MaxMove?
        next if m.gmaxMove? && (species!=m.reqSpecies || !gmax)
        if param.is_a?(Array)
          for i in param
            ret = m.power_move if i.type == m.reqType
          end
        else
          if param.is_a?(PokeBattle_MaxMove)
            ret = m.power_move
          elsif param.is_a?(PokeBattle_Move)
            ret = m.power_move if param.type == m.reqType
          elsif param.is_a?(Pokemon::Move)
            ret = m.power_move if param.type == m.reqType
          elsif GameData::Move.exists?(param)
            ret = m.power_move if GameData::Move.get(param).type == m.reqType
          elsif GameData::Type.exists?(param)
            ret = m.power_move if param == m.reqType
          end
        end
      end
      return ret
    end
    #---------------------------------------------------------------------------
    # Returns true if inputted move would boost user's stats as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.stat_booster?(move)
      self.each do |z|
        next if !z.zStatus?
        if (z.status_atk[0]   && z.status_atk[0].include?(move))   || 
           (z.status_def[0]   && z.status_def[0].include?(move))   ||
           (z.status_spatk[0] && z.status_spatk[0].include?(move)) || 
           (z.status_spdef[0] && z.status_spdef[0].include?(move)) ||
           (z.status_speed[0] && z.status_speed[0].include?(move)) || 
           (z.status_acc[0]   && z.status_acc[0].include?(move))   ||
           (z.status_eva[0]   && z.status_eva[0].include?(move))   || 
           (z.status_omni[0]  && z.status_omni[0].include?(move))
          return true
        end
      end
      return false
    end
    #---------------------------------------------------------------------------
    # Returns a stat & stage boost of a Z-Move based on the inputted move. (Status)
    #---------------------------------------------------------------------------
    def self.stat_with_stage(move)
      stats = []
      stage = 0
      self.each do |z|
        next if !z.zStatus?
        if    z.status_atk[0]   && z.status_atk[0].include?(move);   stats, stage = [:ATTACK],          z.status_atk[1];
        elsif z.status_def[0]   && z.status_def[0].include?(move);   stats, stage = [:DEFENSE],         z.status_def[1];
        elsif z.status_spatk[0] && z.status_spatk[0].include?(move); stats, stage = [:SPECIAL_ATTACK],  z.status_spatk[1];
        elsif z.status_spdef[0] && z.status_spdef[0].include?(move); stats, stage = [:SPECIAL_DEFENSE], z.status_spdef[1];
        elsif z.status_speed[0] && z.status_speed[0].include?(move); stats, stage = [:SPEED],           z.status_speed[1];
        elsif z.status_acc[0]   && z.status_acc[0].include?(move);   stats, stage = [:ACCURACY],        z.status_acc[1];
        elsif z.status_eva[0]   && z.status_eva[0].include?(move);   stats, stage = [:EVASION],         z.status_eva[1];
        elsif z.status_omni[0]  && z.status_omni[0].include?(move)
          stats, stage  = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED], z.status_omni[1]
        end
      end
      return stats, stage
    end
    #---------------------------------------------------------------------------
    # Returns true if inputted move would heal the user as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.heals_self?(move)
      self.each do |z|
        next if !z.zStatus?
        return true if z.status_heal[0] && z.status_heal[0].include?(move) && z.status_heal[1]==1
      end
      return false
    end
    #---------------------------------------------------------------------------
    # Returns true if inputted move would heal a switch-in as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.heals_switch?(move)
      self.each do |z|
        next if !z.zStatus?
        return true if z.status_heal[0] && z.status_heal[0].include?(move) && z.status_heal[1]==2
      end
      return false
    end    
    #---------------------------------------------------------------------------
    # Returns true if inputted move increases critical hit as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.boosts_crit?(move)
      self.each do |z|
        next if !z.zStatus?
        return true if z.status_crit && z.status_crit.include?(move)
      end
      return false
    end
    #---------------------------------------------------------------------------
    # Returns true if inputted move resets user's stats as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.resets_stats?(move)
      self.each do |z|
        next if !z.zStatus?
        return true if z.status_reset && z.status_reset.include?(move)
      end
      return false
    end
    #---------------------------------------------------------------------------
    # Returns true if inputted move draws in moves as a Z-Move. (Status)
    #---------------------------------------------------------------------------
    def self.focus_user?(move)
      self.each do |z|
        next if !z.zStatus?
        return true if z.status_focus && z.status_focus.include?(move)
      end
      return false
    end
  end
end