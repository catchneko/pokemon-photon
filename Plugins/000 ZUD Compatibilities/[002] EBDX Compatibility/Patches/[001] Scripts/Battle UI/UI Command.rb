#===============================================================================
# Command Window
#===============================================================================
if Settings::EBDX_COMPAT
  class CommandWindowEBDX
    def compileCommands(index)
      cmd = []
      @indexes = []
      poke = @battle.battlers[index]
      # returns indexes and commands for Safari Battles
      if @safaribattle
        @indexes = [0,1,2,3]
        return [_INTL("BALL"), _INTL("BAIT"), _INTL("ROCK"), _INTL("RUN")]
      end
      # looks up cached metrics
      d1 = EliteBattle.get(:nextUI)
      d1 = d1.has_key?(:BATTLE_COMMANDS) ? d1[:BATTLE_COMMANDS] : nil if !d1.nil?
      # looks up globally defined settings
      d1 = EliteBattle.get_data(:BATTLE_COMMANDS, :Metrics, :METRICS) if d1.nil?
      # array containing the default commands
      default = [_INTL("FIGHT"), _INTL("BAG"), _INTL("PARTY"), _INTL("RUN")]
      default.push(_INTL("DEBUG")) if $DEBUG && default.length == 4 && EliteBattle::SHOW_DEBUG_FEATURES
      for i in 0...default.length
        val = default[i]
      val = _INTL("CALL")  if default[i] == _INTL("RUN") && (poke.shadowPokemon? && poke.inHyperMode?)
      val = _INTL("CHEER") if default[i] == _INTL("RUN") && $game_switches[Settings::MAXRAID_SWITCH]
        if !d1.nil?
          if d1.include?(default[i])
            @indexes.push(i); cmd.push(val)
          end
          next
        end
        cmd.push(val); @indexes.push(i)
      end
      return cmd
    end
  end 
end