#===============================================================================
#  EBS DX Battle Core processing
#===============================================================================
if Settings::EBDX_COMPAT  
  class PokeBattle_Battle
    def quadrubattle?; return (pbSideSize(0) > 3 || pbSideSize(1) > 3); end
    def quintebattle?; return (pbSideSize(0) > 4 || pbSideSize(1) > 4); end
	
	def dynamaxactive?
	  ret = false
	  @battlers.each { |b| ret = true if (b && !b.fainted? && b.effects[PBEffects::Dynamax]>0) }
	  return ret
    end
	
    alias ebdx_pbStartBattleSendOut pbStartBattleSendOut
    def pbStartBattleSendOut(sendOuts)
      if wildBattle? && $game_switches[Settings::MAXRAID_SWITCH]
        pbRaidSendOut(sendOuts)
      else
        ebdx_pbStartBattleSendOut(sendOuts)
      end
    end
  end
end