#===============================================================================
#  Additional overrides for boss battle mechanic (immunities)
#===============================================================================
if Settings::EBDX_COMPAT  
  class PokeBattle_Battler
    alias canflinch_ebdx pbFlinch unless self.method_defined?(:canflinch_ebdx)
    def pbFlinch(*args)
      rule = EliteBattle.get_data(:BOSSBATTLES, :Metrics, :IMMUNITIES)
      rule = rule.nil? ? false : rule.include?(:FLINCH)
      return false if (self.immunity && rule) || @effects[PBEffects::Dynamax]>0
      return canflinch_ebdx(*args)
    end
  end
end