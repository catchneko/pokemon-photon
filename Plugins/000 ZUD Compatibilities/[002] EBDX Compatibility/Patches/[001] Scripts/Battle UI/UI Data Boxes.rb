#===============================================================================
#  Pokemon data battle boxes (Next Generation)
#  UI overhaul
#===============================================================================
if Settings::EBDX_COMPAT
  class DataBoxEBDX  <  SpriteWrapper
    def applyMetrics
      # default variable states
      @showhp = @playerpoke && !@doublebattle
      @expBarWidth = 100
      @hpBarWidth = 168
      @baseBitmap = "dataBox"
      @colors = "barColors"
      @containerBmp = "containers"
      @expandDouble = false
      @hpBarX = 4
      @hpBarY = 2
      @expBarX = 4
      @expBarY = 16
      # calc width in advance
      tbmp = pbBitmap(@path + @baseBitmap)
      # set XY positions
      @defX = @playerpoke ? @viewport.width - tbmp.width : 0
      @defY = @playerpoke ? @viewport.height - 130 : 52
      tbmp.dispose
      # compiles default positioning data for databox
      @data = {
        "status" => {:x => @playerpoke ? -26 : 202, :y => 16, :z => 1},
        "mega" => {:x => @playerpoke ? -10 : 206, :y => -18, :z => 1},
        "ultra" => {:x => @playerpoke ? -10 : 206, :y => -18, :z => 1},
        "dynamax" => {:x => @playerpoke ? -10 : 206, :y => -18, :z => 1},
        "container" => {:x => @playerpoke ? 20 : 24, :y => 6, :z => 1},
        "name" => {:x => @playerpoke ? 22 : 26, :y => -24, :z => 9},
        "hp" => {:x => @playerpoke ? 22 : 20, :y => 9, :z => 9}
      }
      # determines which constant to search for
      const = @playerpoke ? :PLAYERDATABOX : :ENEMYDATABOX
      const = :RAIDDATABOX if $game_switches[Settings::MAXRAID_SWITCH] && !@playerpoke
      # looks up next cached metrics first
      d1 = EliteBattle.get(:nextUI)
      d2 = d1[const] if !d1.nil? && d1.has_key?(const)
      d3 = d1[:ALLDATABOX] if !d1.nil? && d1.has_key?(:ALLDATABOX)
      # looks up globally defined settings
      d4 = EliteBattle.get_data(const, :Metrics, :METRICS)
      d7 = EliteBattle.get_map_data(:DATABOX_METRICS)
      # look up trainer specific metrics
      d6 = @battle.opponent ? EliteBattle.get_trainer_data(@trainer.trainer_type, :DATABOX_METRICS, @trainer) : nil
      # looks up species specific metrics
      d5 = EliteBattle.get_data(@battler.species, :Species, :DATABOX_METRICS, (@battler.form rescue 0))
      # proceeds with parameter definition if available
      for data in [d4, d2, d3, d7, d6, d5, d1]
        if !data.nil?
          # applies a set of predefined keys
          @defX = data[:X] if data.has_key?(:X) && data[:X].is_a?(Numeric)
          @defY = data[:Y] if data.has_key?(:Y) && data[:Y].is_a?(Numeric)
          @showhp = data[:SHOWHP] if (!@doublebattle || (@doublebattle && !@playerpoke && @battle.pbParty(1).length < 2)) && data.has_key?(:SHOWHP)
          @expBarWidth = data[:EXPBARWIDTH] if data.has_key?(:EXPBARWIDTH) && data[:EXPBARWIDTH].is_a?(Numeric)
          @expBarX = data[:EXPBARX] if data.has_key?(:EXPBARX) && data[:EXPBARX].is_a?(Numeric)
          @expBarY = data[:EXPBARY] if data.has_key?(:EXPBARY) && data[:EXPBARY].is_a?(Numeric)
          @hpBarWidth = data[:HPBARWIDTH] if data.has_key?(:HPBARWIDTH) && data[:HPBARWIDTH].is_a?(Numeric)
          @hpBarX = data[:HPBARX] if data.has_key?(:HPBARX) && data[:HPBARX].is_a?(Numeric)
          @hpBarY = data[:HPBARY] if data.has_key?(:HPBARY) && data[:HPBARY].is_a?(Numeric)
          @baseBitmap = data[:BITMAP] if data.has_key?(:BITMAP) && data[:BITMAP].is_a?(String)
          @colors = data[:HPCOLORS] if data.has_key?(:HPCOLORS) && data[:HPCOLORS].is_a?(String)
          @containerBmp = data[:CONTAINER] if data.has_key?(:CONTAINER) && data[:CONTAINER].is_a?(String)
          if $game_switches[Settings::MAXRAID_SWITCH] && !@playerpoke
            @defY = 22
            @hpBarY = @data["container"][:y]-4
          end
          # expand databox even in doubles
          @expandDouble = data[:EXPANDINDOUBLES] == true ? true : false if data.has_key?(:EXPANDINDOUBLES)
          @showexp = true if @expandDouble && @playerpoke && @battler.pbOwnedByPlayer?
          @showhp = true if @expandDouble && @playerpoke
          # applies a set of possible modifier keys
          for key in data.keys
            next if !key.is_a?(String) || !@data.has_key?(key) || !data[key].is_a?(Hash)
            for m in data[key].keys
              next if !@data[key].has_key?(m)
              @data[key][m] = data[key][m]
            end
          end
        end
      end
    end
    
    alias _ZUD_setUp setUp
    def setUp
      _ZUD_setUp
    
      @sprites["shieldbar"] = Sprite.new(@viewport)
      @sprites["shieldbar"].bitmap = pbBitmap(@path + "raidshieldbar")
      @sprites["shieldbar"].z = self.getMetric("container", :z)
      @sprites["shieldbar"].src_rect.width = 0
      @sprites["shieldbar"].ex = self.getMetric("container", :x)-8
      @sprites["shieldbar"].ey = self.getMetric("container", :y)+14
    
      @sprites["shieldhp"] = Sprite.new(@viewport)
      @sprites["shieldhp"].bitmap = pbBitmap(@path + "raidshieldhp")
      @sprites["shieldhp"].z = self.getMetric("container", :z)
      @sprites["shieldhp"].src_rect.width = 0
      @sprites["shieldhp"].ex = self.getMetric("container", :x)-8
      @sprites["shieldhp"].ey = self.getMetric("container", :y)+14
    
      @sprites["timercount"] = Sprite.new(@viewport)
      @sprites["timercount"].bitmap = Bitmap.new(@sprites["container"].bitmap.width + 32, @sprites["base"].bitmap.height)
      @sprites["timercount"].z = self.getMetric("name", :z)
      @sprites["timercount"].ex = self.getMetric("name", :x)
      @sprites["timercount"].ey = self.getMetric("name", :y)
      pbSetSmallFont(@sprites["timercount"].bitmap)
    
      @sprites["kocount"] = Sprite.new(@viewport)
      @sprites["kocount"].bitmap = Bitmap.new(@sprites["container"].bitmap.width + 32, @sprites["base"].bitmap.height)
      @sprites["kocount"].z = self.getMetric("name", :z)
      @sprites["kocount"].ex = self.getMetric("name", :x)
      @sprites["kocount"].ey = self.getMetric("name", :y)
      pbSetSmallFont(@sprites["kocount"].bitmap)
      
      @sprites["ultra"] = Sprite.new(@viewport)
      @sprites["ultra"].z = self.getMetric("ultra", :z)
      @sprites["ultra"].mirror = @playerpoke
      @sprites["ultra"].ex = self.getMetric("ultra", :x)
      @sprites["ultra"].ey = self.getMetric("ultra", :y)
      
      @sprites["dynamax"] = Sprite.new(@viewport)
      @sprites["dynamax"].z = self.getMetric("dynamax", :z)
      @sprites["dynamax"].mirror = @playerpoke
      @sprites["dynamax"].ex = self.getMetric("dynamax", :x)
      @sprites["dynamax"].ey = self.getMetric("dynamax", :y)
      
      @ultraBmp   = pbBitmap(@path + "symUltra")
      @dynamaxBmp = pbBitmap(@path + "symDynamax")
    end
    
    def refresh
      return if self.disposed?
      # refreshes data
      @pokemon = @battler.displayPokemon
      # failsafe
      return if @pokemon.nil?
      @hidden = EliteBattle.get_data(@pokemon.species, :Species, :HIDENAME, (@pokemon.form rescue 0)) && !$Trainer.owned?(@pokemon.species)
      # exits the refresh if the databox isn't fully set up yet
      return if !@loaded
      # update for HP/EXP bars
      self.updateHpBar
      # clears the current bitmap containing text and adjusts its font
      @sprites["textName"].bitmap.clear
      # used to calculate the potential offset of elements should they exceed the
      # width of the HP bar
      str = ""
      str = _INTL("♂") if @pokemon.gender == 0 && !@hidden
      str = _INTL("♀") if @pokemon.gender == 1 && !@hidden
      w = @sprites["textName"].bitmap.text_size("#{@battler.name.force_encoding("UTF-8")}#{str.force_encoding("UTF-8")}Lv.#{@pokemon.level}").width
      o = (w > @hpBarWidth + 4) ? (w-(@hpBarWidth + 4))/2.0 : 0; o = o.ceil
      # writes the Pokemon's name
      str = @battler.name.nil? ? "" : @battler.name
      str += " "
      color = @pokemon.shiny? ? Color.new(222,197,95) : Color.white
	  if !@battler.is_a?(PokeBattle_FakeBattler) && @battler.effects[PBEffects::MaxRaidBoss]
        color  = Color.white
        shadow = Color.new(248,32,32)
	  else
	    shadow = Color.new(0,0,0,125)
	  end
      pbDrawOutlineText(@sprites["textName"].bitmap,18-o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,color,shadow,0)
      if $game_switches[Settings::MAXRAID_SWITCH] && !@battler.is_a?(PokeBattle_FakeBattler) && @battler.effects[PBEffects::MaxRaidBoss]
        @sprites["timercount"].bitmap.clear
        @sprites["kocount"].bitmap.clear
        turncount   = @battler.effects[PBEffects::Dynamax]-1
        kocount     = @battler.effects[PBEffects::KnockOutCount]
        kocount     = 0 if kocount<0
        # Text colors
        turncolor   = 0
        turncolor   = 1 if turncount<=Settings::MAXRAID_TIMER/2
        turncolor   = 2 if turncount<=Settings::MAXRAID_TIMER/4
        turncolor   = 3 if turncount<=Settings::MAXRAID_TIMER/8
        kocolor     = 0
        kocolor     = 1 if kocount<=Settings::MAXRAID_KOS/2
        kocolor     = 2 if kocount<=Settings::MAXRAID_KOS/4
        kocolor     = 3 if kocount<=1
        shadow      = Color.new(0,0,0,125)
        base        = [Color.white,
                       Color.new(248,192,0),  # Yellow
                       Color.new(248,136,32), # Orange
                       Color.new(248,72,72)]  # Red
        pbDrawOutlineText(@sprites["timercount"].bitmap,-8,7,@sprites["timercount"].bitmap.width-40,@sprites["timercount"].bitmap.height,"#{turncount}",base[turncolor],shadow,2)
        pbDrawOutlineText(@sprites["kocount"].bitmap,19,7,@sprites["kocount"].bitmap.width-40,@sprites["kocount"].bitmap.height,"#{kocount}",base[kocolor],shadow,2)
        if @battler.effects[PBEffects::RaidShield]>0
          shieldHP  = @battler.effects[PBEffects::RaidShield]
          shieldLvl = @battler.effects[PBEffects::MaxShieldHP]
          @sprites["shieldbar"].src_rect.width = 2+shieldLvl*22
          @sprites["shieldhp"].src_rect.width  = 2+shieldHP*22
        else
          @sprites["shieldbar"].src_rect.width = 0
          @sprites["shieldhp"].src_rect.width  = 0
        end
      else
        # writes the Pokemon's gender
        x = @sprites["textName"].bitmap.text_size(str).width + 18
        str = ""
        str = _INTL("♂") if @pokemon.gender == 0 && !@hidden
        str = _INTL("♀") if @pokemon.gender == 1 && !@hidden
        color = (@pokemon.gender == 0) ? Color.new(53,107,208) : Color.new(180,37,77)
        pbDrawOutlineText(@sprites["textName"].bitmap,x-o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,color,Color.new(0,0,0,125),0)
        # writes the Pokemon's level
        str = "Lv.#{@battler.level}"
        pbDrawOutlineText(@sprites["textName"].bitmap,18+o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,Color.white,Color.new(0,0,0,125),2)
      end
      # changes the Mega symbol graphics (depending on Mega or Primal)
      if @battler.mega?
        @sprites["mega"].bitmap = @megaBmp.clone
      elsif @battler.primal?
        @sprites["mega"].bitmap = @prKyogre.clone if @battler.isSpecies?(:KYOGRE)
        @sprites["mega"].bitmap = @prGroudon.clone if @battler.isSpecies?(:GROUDON)
      elsif @sprites["mega"].bitmap
        @sprites["mega"].bitmap.clear
        @sprites["mega"].bitmap = nil
      end
      if @battler.ultra?
        @sprites["ultra"].bitmap = @ultraBmp.clone
      elsif @sprites["ultra"].bitmap
        @sprites["ultra"].bitmap.clear
        @sprites["ultra"].bitmap = nil
      end
      if @battler.dynamax?
        @sprites["dynamax"].bitmap = @dynamaxBmp.clone
      elsif @sprites["dynamax"].bitmap
        @sprites["dynamax"].bitmap.clear
        @sprites["dynamax"].bitmap = nil
      end
      self.updateHpBar
      self.updateExpBar
    end
  end 
end