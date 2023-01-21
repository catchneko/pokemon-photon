#===============================================================================
# Legacy animation player core
#===============================================================================
if Settings::EBDX_COMPAT
  class PokeBattle_Scene
    def pbAnimationCore(animation, user, target, oppMove = false)
      return if !animation
      @briefMessage = false
      # store databox visibility
      pbHideAllDataboxes
      # get the battler sprites
      userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
      targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
      # Remember the original positions of Pokémon sprites
      oldUserX = (userSprite) ? userSprite.x : 0
      oldUserY = (userSprite) ? userSprite.y : 0
      oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
      oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
      #---------------------------------------------------------------------------
      # Used for Enlarged Dynamax sprites.
      #---------------------------------------------------------------------------
      if Settings::DYNAMAX_SIZE
        oldUserZoomX = (userSprite) ? userSprite.zoom_x : 1
        oldUserZoomY = (userSprite) ? userSprite.zoom_y : 1
        oldTargetZoomX = (targetSprite) ? targetSprite.zoom_x : 1
        oldTargetZoomY = (targetSprite) ? targetSprite.zoom_y : 1
      end
      if Settings::DYNAMAX_COLOR
        newcolor  = Color.new(217,29,71,128)
        newcolor2 = Color.new(56,160,193,128) # Calyrex
        oldcolor  = Color.new(0,0,0,0)
        # Colors user's sprite.
        if userSprite && user.dynamax?
          oldUserColor = user.isSpecies?(:CALYREX) ? newcolor2 : newcolor
        else
          oldUserColor = oldcolor
        end
        # Colors target's sprite.
        if targetSprite && target.dynamax?
          oldTargetColor = target.isSpecies?(:CALYREX) ? newcolor2 : newcolor
        else
          oldTargetColor = oldcolor
        end
      end
      #---------------------------------------------------------------------------
      userSprite.legacy_anim = true if userSprite
      targetSprite.legacy_anim = true if targetSprite
      # Create the animation player
      animPlayer = PBAnimationPlayerX.new(animation, user, target, self, oppMove)
      # Apply a transformation to the animation based on where the user and target
      # actually are. Get the centres of each sprite.
      userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
      if targetSprite
        targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
      else
        targetHeight = userHeight
      end
      animPlayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X, PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X, PokeBattle_SceneConstants::FOCUSTARGET_Y,
         oldUserX, oldUserY - userHeight/2,
         oldTargetX, oldTargetY - targetHeight/2)
      # Play the animation
      @sprites["battlebg"].defocus
      animPlayer.start; i = 0
      loop do
        # update necessary components
        animPlayer.update
        #-------------------------------------------------------------------------
        # Used for Enlarged Dynamax sprites.
        #-------------------------------------------------------------------------
        if Settings::DYNAMAX_SIZE
          userSprite.zoom_x = oldUserZoomX if userSprite
          userSprite.zoom_y = oldUserZoomY if userSprite
          targetSprite.zoom_x = oldTargetZoomX if targetSprite
          targetSprite.zoom_y = oldTargetZoomY if targetSprite
        end
        if Settings::DYNAMAX_COLOR
          userSprite.color = oldUserColor if userSprite
          targetSprite.color = oldTargetColor if targetSprite
        end
        #-------------------------------------------------------------------------
        pbGraphicsUpdate
        pbInputUpdate
        animateScene
        i += 1
        clearMessageWindow if i == 16
        # finish with the animation player
        break if animPlayer.animDone?
      end
      animPlayer.dispose
      @sprites["battlebg"].focus
      # Return Pokémon sprites to their original positions
      if userSprite
        userSprite.x = oldUserX
        userSprite.y = oldUserY
        userSprite.pbSetOrigin
        userSprite.legacy_anim = false
      end
      if targetSprite
        targetSprite.x = oldTargetX
        targetSprite.y = oldTargetY
        targetSprite.pbSetOrigin
        targetSprite.legacy_anim = false
      end
      # reset databox visibility
      pbShowAllDataboxes
      clearMessageWindow
    end
  
    def pbAnimation(moveid, user, targets, hitnum = 0)
      # for hitnum, 1 is the charging animation, 0 is the damage animation
      return if !moveid
      # move information
      species = @battle.battlers[user.index].species
      movedata = GameData::Move.get(moveid)
    #------------------------------------------------------------------------------------------
    battler = @battle.battlers[user.index]
    sel = @battle.choices[user.index][1]
    if movedata.zMove?
      move = PokeBattle_ZMove.from_base_move(@battle, battler, battler.effects[PBEffects::BaseMoves][sel])
    elsif movedata.maxMove?
      move = PokeBattle_MaxMove.from_base_move(@battle, battler, battler.effects[PBEffects::BaseMoves][sel])
    else
      move = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveid))
    end
    #------------------------------------------------------------------------------------------
      numhits = user.thisMoveHits
      multihit = !numhits.nil? ? (numhits > @animationCount) : false
      @animationCount += 1
      if numhits.nil?
        @animationCount = 1
      elsif @animationCount > numhits
        @animationCount = 1
      end
      multitarget = false
      multitarget = move.target if [:AllFoes, :AllNearFoes].include?(move.target)
      target = (targets && targets.is_a?(Array)) ? targets[0] : targets
      target = user if !target
      # clears the current UI
      pbHideAllDataboxes
      # Substitute animation
      if @sprites["pokemon_#{user.index}"] && @battle.battlescene
        subbed = @sprites["pokemon_#{user.index}"].isSub
        self.setSubstitute(user.index, false) if subbed
      end
      # gets move animation def name
      handled = false
      if @battle.battlescene
        @sprites["battlebg"].defocus
        # checks if def for specific move exists, and then plays it
        handled = EliteBattle.playMoveAnimation(moveid, self, user.index, target.index, hitnum, multihit, species) if !handled
        # in case people want to use the old animation player
        if EliteBattle::CUSTOM_MOVE_ANIM && !handled
          animid = pbFindMoveAnimation(moveid, user.index, hitnum)
          if !animid
            pbShowAllDataboxes
            clearMessageWindow
            return
          end
          anim = animid[0]
          animations = EliteBattle.get(:moveAnimations)
          name = GameData::Move.get(moveid).real_name
          pbSaveShadows {
             if animid[1] # On opposing side and using OppMove animation
               pbAnimationCore(animations[anim], target, user, true)
             else         # On player's side, and/or using Move animation
               pbAnimationCore(animations[anim], user, target, false)
             end
          }
          handled = true
        end
        # decides which global move animation to play, if any
        if !handled
          handled = EliteBattle.mapMoveGlobal(self, move.type, user.index, target.index, hitnum, multihit, multitarget, movedata.category)
        end
        # if all above failed, plays the move animation for Tackle
        if !handled
          EliteBattle.playMoveAnimation(:TACKLE, self, user.index, target.index, 0, multihit)
        end
        @sprites["battlebg"].focus
      end
      # Change form to transformed version
      if move.function == 0x69 && user && target # Transform
        pbChangePokemon(user, target.pokemon)
      end
      # restores cleared UI
      pbShowAllDataboxes
      clearMessageWindow
      self.afterAnim = true
    end
  end  
end