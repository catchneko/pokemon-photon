#===============================================================================
#  Additions to the Pokemon class for additional functionality
#===============================================================================
if Settings::EBDX_COMPAT  
  class Pokemon
    def calc_stats(basestat = nil, boss = false)
      oldhpDiff  = @totalhp - @hp
      base_stats = basestat.is_a?(Array) ? basestat.clone : self.baseStats
      this_level = self.level
      this_IV    = self.calcIV
      nature_mod = {}
      GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
      this_nature = self.nature_for_stats
      if this_nature
        this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
      end
      stats = {}; i = 0
      GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = (calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id]) * (boss ? boss[s.id] : 1)).round
      else
        stats[s.id] = (calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id]) * (boss ? boss[s.id] : 1)).round
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
  end
end