#===============================================================================
#  Battle Scene processing start
#===============================================================================
if Settings::EBDX_COMPAT
  class PokeBattle_Scene
    #-----------------------------------------------------------------------------
    #  apply bitmaps for wild battlers
    #-----------------------------------------------------------------------------
    alias _ZUD_loadWildBitmaps loadWildBitmaps
    def loadWildBitmaps
      _ZUD_loadWildBitmaps
      if @battle.wildBattle?
        @battle.pbParty(1).each_with_index do |pkmn, i|
          next if !@sprites["pokemon_#{i*2 + 1}"]
      @sprites["pokemon_#{i*2 + 1}"].dynamax = true if $game_switches[Settings::MAXRAID_SWITCH]
        end
      end
    end
  end  
end