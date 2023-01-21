#===============================================================================
#  Fight Menu functionality part
#===============================================================================
if Settings::EBDX_COMPAT
  class PokeBattle_Scene
    #-----------------------------------------------------------------------------
    #  main fight menu override
    #-----------------------------------------------------------------------------
    def pbFightMenu(idxBattler,megaEvoPossible = false,
                               ultraPossible   = false,
                               zMovePossible   = false,
                               dynamaxPossible = false
                               )
      # refresh current UI
      battler = @battle.battlers[idxBattler]
      self.clearMessageWindow
      @fightWindow.battler = battler
      @fightWindow.megaButton  if megaEvoPossible && @battle.pbCanMegaEvolve?(idxBattler)
      @fightWindow.ultraButton if ultraPossible   && @battle.pbCanUltraBurst?(idxBattler)
      @fightWindow.zMoveButton if zMovePossible   && @battle.pbCanZMove?(idxBattler)
      @fightWindow.dynaButton  if dynamaxPossible && @battle.pbCanDynamax?(idxBattler)
      # last chosen move
      moveIndex = 0
      if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
        moveIndex = @lastMove[idxBattler]
      end
      @fightWindow.index = (battler.moves[moveIndex].id != 0) ? moveIndex : 0
      # setup button bitmaps
      @fightWindow.generateButtons
      # play UI animation
      @sprites["dataBox_#{idxBattler}"].selected = true
      pbSEPlay("EBDX/SE_Zoom4", 50)
      @fightWindow.showPlay
      loop do
        oldIndex = @fightWindow.index
        # General update
        self.updateWindow(@fightWindow)
        # Update selected command
        if (Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT))
          @fightWindow.index = [0, 1, 2, 3][[1, 0, 3, 2].index(@fightWindow.index)]
          @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index < 0
          @fightWindow.index = 0 if @fightWindow.index > (@fightWindow.nummoves - 1)
        elsif (Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN))
          @fightWindow.index = [0, 1, 2, 3][[2, 3, 0, 1].index(@fightWindow.index)]
          @fightWindow.index = 0 if @fightWindow.index < 0
          @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index > (@fightWindow.nummoves - 1)
        elsif Input.trigger?(Input::LEFT) && @fightWindow.index < 4
          if @fightWindow.index > 0
            @fightWindow.index -= 1
          else
            @fightWindow.index = @fightWindow.nummoves - 1
            @fightWindow.refreshpos = true
          end
        elsif Input.trigger?(Input::RIGHT) && @fightWindow.index < 4
          if @fightWindow.index < (@fightWindow.nummoves - 1)
            @fightWindow.index += 1
          else
            @fightWindow.index = 0
          end
        end
        # play SE
        pbSEPlay("EBDX/SE_Select1") if @fightWindow.index != oldIndex
        # Actions
  #===============================================================================
  # Confirm Selection
  #===============================================================================
        if Input.trigger?(Input::USE) # Confirm choice
          #-----------------------------------------------------------------------
          # Z-Moves
          #-----------------------------------------------------------------------
          if zMovePossible && @fightWindow.zMoveSel
            if @fightWindow.zMoveButton
              itemname = battler.item.name
              movename = battler.moves[@fightWindow.index].name
              if !battler.pbCompatibleZMove?(battler.moves[@fightWindow.index])
                @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",movename,itemname))
                if battler.effects[PBEffects::PowerMovesButton]
                  battler.effects[PBEffects::PowerMovesButton] = false
                  battler.pbDisplayBaseMoves(1)
                  @fightWindow.zMoveToggle
                end
                break if yield -1
              end
              @fightWindow.zMoveToggle
            end
          end
          battler.effects[PBEffects::PowerMovesButton] = false if ultraPossible
          #-----------------------------------------------------------------------
          # Dynamax - Gets Max Move PP usage.
          #-----------------------------------------------------------------------
          if battler.effects[PBEffects::PowerMovesButton]
            pressure = true if @battle.pbCheckOpposingAbility(:PRESSURE,battler)
            ppusage  = (pressure) ? 2 : 1
            battler.effects[PBEffects::MaxMovePP][@fightWindow.index] += ppusage
          end
          #-----------------------------------------------------------------------
          pbSEPlay("EBDX/SE_Select2")
          break if yield @fightWindow.index
  #===============================================================================
  # Cancel Selection
  #===============================================================================
        elsif Input.trigger?(Input::BACK) # Cancel fight menu
          #-----------------------------------------------------------------------
          # Z-Moves - Reverts to base moves.
          #-----------------------------------------------------------------------
          if zMovePossible
            if battler.effects[PBEffects::PowerMovesButton]
              battler.pbDisplayBaseMoves
              @fightWindow.zMoveToggle
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
  #===============================================================================
  # Toggle Battle Mechanic
  #===============================================================================
        elsif Input.trigger?(Input::ACTION) # Toggle Mega Evolution
          #-----------------------------------------------------------------------
          # Mega Evolution
          #-----------------------------------------------------------------------
          if megaEvoPossible
            @fightWindow.megaButtonTrigger
            pbSEPlay("EBDX/SE_Select3")
            break if yield -2
          end
          #-----------------------------------------------------------------------
          # Ultra Burst
          #-----------------------------------------------------------------------
          if ultraPossible
            @fightWindow.ultraButtonTrigger
            battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
            if battler.effects[PBEffects::PowerMovesButton]; pbPlayZUDButton
            else; pbPlayCancelSE
            end
            break if yield -3
          end
          #-----------------------------------------------------------------------
          # Z-Moves
          #-----------------------------------------------------------------------
          if zMovePossible
            battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
            if battler.effects[PBEffects::PowerMovesButton]
              battler.pbDisplayPowerMoves(1)
              @fightWindow.zMoveToggle
              @fightWindow.generateButtons
              @fightWindow.showPlay
              @fightWindow.zMoveButtonTrigger
              pbPlayZUDButton
            else
              battler.pbDisplayBaseMoves
              @fightWindow.zMoveToggle
              @fightWindow.generateButtons
              @fightWindow.showPlay
              pbPlayCancelSE
            end
            break if yield -4
          end
          #-----------------------------------------------------------------------
          # Dynamax
          #-----------------------------------------------------------------------
          if dynamaxPossible
            battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
            if battler.effects[PBEffects::PowerMovesButton]
              battler.pbDisplayPowerMoves(2)
              @fightWindow.generateButtons
              @fightWindow.showPlay
              @fightWindow.dynaButtonTrigger
              pbPlayZUDButton
            else
              battler.pbDisplayBaseMoves
              @fightWindow.generateButtons
              @fightWindow.showPlay
              pbPlayCancelSE
            end
            break if yield -5
          end
        end
      end
      #---------------------------------------------------------------------------
      # reset parameters
      self.pbResetParams if @ret > -1
      # hide window
      @fightWindow.hidePlay
      # unselect databoxes
      self.pbDeselectAll
      # set last used move
      @lastMove[idxBattler] = @fightWindow.index
    end
  end
  #===============================================================================
  #  Fight Menu (Next Generation)
  #  UI ovarhaul
  #===============================================================================
  class FightWindowEBDX
    attr_accessor :zMoveSel
    
    alias _ZUD_initialize initialize
    def initialize(*args)
      _ZUD_initialize(*args)
      @zMoveButton = Sprite.new(@viewport)
      @zMoveButton.bitmap = pbBitmap(@path + @zMoveImg)
      @zMoveButton.z = 101
      @zMoveButton.src_rect.width /= 2
      @zMoveButton.center!
      @zMoveButton.x = 30
      @zMoveButton.y = @viewport.height - @background.bitmap.height/2 + 100
      @showZMove = false
      @zMoveSel  = false
  
      @ultraButton = Sprite.new(@viewport)
      @ultraButton.bitmap = pbBitmap(@path + @ultraImg)
      @ultraButton.z = 101
      @ultraButton.src_rect.width /= 2
      @ultraButton.center!
      @ultraButton.x = 30
      @ultraButton.y = @viewport.height - @background.bitmap.height/2 + 100
      @showUltra = false
  
      @dynaButton = Sprite.new(@viewport)
      @dynaButton.bitmap = pbBitmap(@path + @dynaImg)
      @dynaButton.z = 101
      @dynaButton.src_rect.width /= 2
      @dynaButton.center!
      @dynaButton.x = 30
      @dynaButton.y = @viewport.height - @background.bitmap.height/2 + 100
      @showDynamax = false
    end
    
    def applyMetrics
      # sets default values
      @cmdImg   = "moveSelButtons"
      @selImg   = "cmdSel"
      @typImg   = "types"
      @catImg   = "category"
      @megaImg  = "megaButton"
      @zMoveImg = "zMoveButton"
      @ultraImg = "ultraButton"
      @dynaImg  = "dynaButton"
      @barImg   = nil
      @showTypeAdvantage = false
      # looks up next cached metrics first
      d1 = EliteBattle.get(:nextUI)
      d1 = d1[:FIGHTMENU] if !d1.nil? && d1.has_key?(:FIGHTMENU)
      # looks up globally defined settings
      d2 = EliteBattle.get_data(:FIGHTMENU, :Metrics, :METRICS)
      # looks up globally defined settings
      d7 = EliteBattle.get_map_data(:FIGHTMENU_METRICS)
      # look up trainer specific metrics
      d6 = @battle.opponent ? EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :FIGHTMENU_METRICS, @battle.opponent[0]) : nil
      # looks up species specific metrics
      d5 = !@battle.opponent ? EliteBattle.get_data(@battle.battlers[1].species, :Species, :FIGHTMENU_METRICS, (@battle.battlers[1].form rescue 0)) : nil
      # proceeds with parameter definition if available
      for data in [d2, d7, d6, d5, d1]
        if !data.nil?
          # applies a set of predefined keys
          @megaImg = data[:MEGABUTTONGRAPHIC] if data.has_key?(:MEGABUTTONGRAPHIC) && data[:MEGABUTTONGRAPHIC].is_a?(String)
          @zMoveImg = data[:ZMOVEBUTTONGRAPHIC] if data.has_key?(:ZMOVEBUTTONGRAPHIC) && data[:ZMOVEBUTTONGRAPHIC].is_a?(String)
          @ultraImg = data[:ULTRABUTTONGRAPHIC] if data.has_key?(:ULTRABUTTONGRAPHIC) && data[:ULTRABUTTONGRAPHIC].is_a?(String)
          @dynaImg = data[:DYNABUTTONGRAPHIC] if data.has_key?(:DYNABUTTONGRAPHIC) && data[:DYNABUTTONGRAPHIC].is_a?(String)
          @cmdImg = data[:BUTTONGRAPHIC] if data.has_key?(:BUTTONGRAPHIC) && data[:BUTTONGRAPHIC].is_a?(String)
          @selImg = data[:SELECTORGRAPHIC] if data.has_key?(:SELECTORGRAPHIC) && data[:SELECTORGRAPHIC].is_a?(String)
          @barImg = data[:BARGRAPHIC] if data.has_key?(:BARGRAPHIC) && data[:BARGRAPHIC].is_a?(String)
          @typImg = data[:TYPEGRAPHIC] if data.has_key?(:TYPEGRAPHIC) && data[:TYPEGRAPHIC].is_a?(String)
          @catImg = data[:CATEGORYGRAPHIC] if data.has_key?(:CATEGORYGRAPHIC) && data[:CATEGORYGRAPHIC].is_a?(String)
          @showTypeAdvantage = data[:SHOWTYPEADVANTAGE] if data.has_key?(:SHOWTYPEADVANTAGE)
        end
      end
    end
    
    def generateButtons
      @moves = @battler.moves
      @nummoves = 0
      @oldindex = -1
      @x = []; @y = []
      for i in 0...4
        @button["#{i}"].dispose if @button["#{i}"]
        @nummoves += 1 if @moves[i] && @moves[i].id
        @x.push(@viewport.width/2 + (i%2==0 ? -1 : 1)*(@viewport.width/2 + 99))
        @y.push(@viewport.height - 90 + (i/2)*44)
      end
      for i in 0...4
        @y[i] += 22 if @nummoves < 3
      end
      @button = {}
      for i in 0...@nummoves
        # get numeric values of required variables
        movedata = GameData::Move.get(@moves[i].id)
        category = movedata.physical? ? 0 : (movedata.special? ? 1 : 2)
        category = (movedata.powerMove?) ? GameData::Move.get(@battler.effects[PBEffects::BaseMoves][i].id).category : category
        type = GameData::Type.get(movedata.type).id_number
        status_zmove = (@zMoveSel && category==2 && !movedata.powerMove? && @battler.pbCompatibleZMove?(@moves[i]))
        short_name = (movedata.real_name.length > 15 && Settings::SHORTEN_MOVES) ? movedata.real_name[0..12] + "..." : movedata.real_name
        short_name = "Z-"+short_name if status_zmove
        # create sprite
        @button["#{i}"] = Sprite.new(@viewport)
        @button["#{i}"].param = category
        @button["#{i}"].z = 102
        @button["#{i}"].bitmap = Bitmap.new(198*2, 74)
        @button["#{i}"].bitmap.blt(0, 0, @buttonBitmap, Rect.new(0, type*74, 198, 74))
        @button["#{i}"].bitmap.blt(198, 0, @buttonBitmap, Rect.new(198, type*74, 198, 74))
        @button["#{i}"].bitmap.blt(65, 46, @catBitmap, Rect.new(0, category*22, 38, 22))
        @button["#{i}"].bitmap.blt(3, 46, @typeBitmap, Rect.new(0, type*22, 72, 22))
        baseColor = @buttonBitmap.get_pixel(5, 32 + (type*74)).darken(0.4)
        pbSetSmallFont(@button["#{i}"].bitmap)
        pbDrawOutlineText(@button["#{i}"].bitmap, 198, 10, 196, 42,"#{short_name}", Color.white, baseColor, 1)
        if movedata.zMove?
          actualpp = 1
          totalpp  = 1
        elsif movedata.maxMove?
          actualpp = @moves[i].pp
          totalpp  = GameData::Move.get(@battler.effects[PBEffects::BaseMoves][i].id).total_pp
        totalpp  = 5 if @battler.effects[PBEffects::Transform]
        else
          actualpp = @moves[i].pp
          totalpp  = (status_zmove) ? 1 : (@battler.effects[PBEffects::Transform]) ? 5 : movedata.total_pp
        end 
        pp = "#{actualpp}/#{totalpp}"
        pbDrawOutlineText(@button["#{i}"].bitmap, 0, 48, 191, 26, pp, Color.white, baseColor, 2)
        pbSetSystemFont(@button["#{i}"].bitmap)
        text = [[short_name, 99, 4, 2, baseColor, Color.new(0, 0, 0, 24)]]
        pbDrawTextPositions(@button["#{i}"].bitmap, text)
        @button["#{i}"].src_rect.set(198, 0, 198, 74)
        @button["#{i}"].ox = @button["#{i}"].src_rect.width/2
        @button["#{i}"].x = @x[i]
        @button["#{i}"].y = @y[i]
      end
    end
    
    def showPlay
      @megaButton.src_rect.x  = 0
      @zMoveButton.src_rect.x = 0
      @ultraButton.src_rect.x = 0
      @dynaButton.src_rect.x  = 0
      @background.y = @viewport.height
      8.times do
        self.show; @scene.wait(1, true)
      end
    end
    
    def hide
      @sel.visible = false
      @typeInd.visible = false
      @background.y  += (@background.bitmap.height/8)
      @megaButton.y  += 12
      @zMoveButton.y += 12
      @ultraButton.y += 12
      @dynaButton.y  += 12
      for i in 0...@nummoves
        @button["#{i}"].x -= ((i%2 == 0 ? 1 : -1)*@viewport.width/16)
      end
      @showMega = @showZMove = @showUltra = @showDynamax = false
      @megaButton.src_rect.x  = 0
      @zMoveButton.src_rect.x = 0
      @ultraButton.src_rect.x = 0
      @dynaButton.src_rect.x  = 0
    end
    
    def hidePlay
      8.times do
        self.hide; @scene.wait(1, true)
      end
      @megaButton.y  = @viewport.height - @background.bitmap.height/2 + 100
      @zMoveButton.y = @viewport.height - @background.bitmap.height/2 + 100
      @ultraButton.y = @viewport.height - @background.bitmap.height/2 + 100
      @dynaButton.y  = @viewport.height - @background.bitmap.height/2 + 100
    end
    
    def zMoveButton; @showZMove   = true; end
    def ultraButton; @showUltra   = true; end
    def dynaButton;  @showDynamax = true; end
    
    def zMoveButtonTrigger
      @zMoveButton.src_rect.x += @zMoveButton.src_rect.width
      @zMoveButton.src_rect.x = 0 if @zMoveButton.src_rect.x > @zMoveButton.src_rect.width
      @zMoveButton.src_rect.y = -4
    end
    
    def zMoveToggle
      @zMoveSel = !@zMoveSel
      return @zMoveSel
    end
    
    def ultraButtonTrigger
      @ultraButton.src_rect.x += @ultraButton.src_rect.width
      @ultraButton.src_rect.x = 0 if @ultraButton.src_rect.x > @ultraButton.src_rect.width
      @ultraButton.src_rect.y = -4
    end
    
    def dynaButtonTrigger
      @dynaButton.src_rect.x += @dynaButton.src_rect.width
      @dynaButton.src_rect.x = 0 if @dynaButton.src_rect.x > @dynaButton.src_rect.width
      @dynaButton.src_rect.y = -4
    end
    
    def update
      @sel.visible = true
      if @showMega
        @megaButton.y -= 10 if @megaButton.y > @viewport.height - @background.bitmap.height/2
        @megaButton.src_rect.y += 1 if @megaButton.src_rect.y < 0
      end
      if @showZMove
        @zMoveButton.y -= 10 if @zMoveButton.y > @viewport.height - @background.bitmap.height/2
        @zMoveButton.src_rect.y += 1 if @zMoveButton.src_rect.y < 0
      end
      if @showUltra
        @ultraButton.y -= 10 if @ultraButton.y > @viewport.height - @background.bitmap.height/2
        @ultraButton.src_rect.y += 1 if @ultraButton.src_rect.y < 0
      end
      if @showDynamax
        @dynaButton.y -= 10 if @dynaButton.y > @viewport.height - @background.bitmap.height/2
        @dynaButton.src_rect.y += 1 if @dynaButton.src_rect.y < 0
      end
      if @oldindex != @index
        @button["#{@index}"].src_rect.y = -4
        if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
          move = @battler.moves[@index]
          @modifier = move.pbCalcTypeMod(move.type, @player, @opponent)
        end
        @oldindex = @index
      end
      for i in 0...@nummoves
        @button["#{i}"].src_rect.x = 198*(@index == i ? 0 : 1)
        @button["#{i}"].y = @y[i]
        @button["#{i}"].src_rect.y += 1 if @button["#{i}"].src_rect.y < 0
        next if i != @index
        if [0,1].include?(i)
          @button["#{i}"].y = @y[i] - ((@nummoves < 3) ? 14 : 30)
        elsif [2,3].include?(i)
          @button["#{i}"].y = @y[i] - 30
          @button["#{i-2}"].y = @y[i-2] - 30
        end
      end
      @sel.x = @button["#{@index}"].x
      @sel.y = @button["#{@index}"].y + @button["#{@index}"].src_rect.height/2 - 1
      @sel.update
      if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
        @typeInd.visible = true
        @typeInd.y = @button["#{@index}"].y
        @typeInd.x = @button["#{@index}"].x
        eff = 0
        if @button["#{@index}"].param == 2 # status move
          eff = 4
        elsif @modifier == 0 # No effect
          eff = 3
        elsif @modifier < 8
          eff = 1   # "Not very effective"
        elsif @modifier > 8
          eff = 2   # "Super effective"
        end
        @typeInd.src_rect.y = 24 * eff
      end
    end
    
    def dispose
      @buttonBitmap.dispose
      @catBitmap.dispose
      @typeBitmap.dispose
      @background.dispose
      @megaButton.dispose
      @zMoveButton.dispose
      @ultraButton.dispose
      @dynaButton.dispose
      @typeInd.dispose
      pbDisposeSpriteHash(@button)
    end
  end 
end