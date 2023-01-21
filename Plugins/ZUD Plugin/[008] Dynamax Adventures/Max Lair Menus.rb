#===============================================================================
# Max Lair Menus.
#===============================================================================
class MaxLairEventScene
  BASE   = Color.new(248,248,248)
  SHADOW = Color.new(0,0,0)
  
  def pbUpdate
    for i in @sprites
      sprite = i[1]
      if sprite
        sprite.update if !pbDisposed?(sprite)
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def pbShowCommands(commands,index=0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
       cmdwindow.z = @viewport.z+1
       cmdwindow.index = index
       pbBottomRight(cmdwindow)
       loop do
         Graphics.update
         Input.update
         cmdwindow.update
         pbUpdate
         if Input.trigger?(Input::BACK)
           pbPlayCancelSE
           ret = -1
           break
         elsif Input.trigger?(Input::USE)
           pbPlayDecisionSE
           ret = cmdwindow.index
           break
         end
       end
    }
    return ret
  end
  
  def pbClearAll
    @rentals.clear
    @textPos.clear
    @imagePos.clear
    @changetext.clear
    @changesprites.clear
  end
  
  #-----------------------------------------------------------------------------
  # Begins the screen.
  #-----------------------------------------------------------------------------
  def pbStartScene(size,level)
    @rentals     = []
    @rentalparty = []
    @textPos     = []
    @imagePos    = []
    @size        = size
    @level       = level
    @trainer     = NPCTrainer.new("RENTAL",0)
    @viewport    = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z  = 99999
    @sprites     = {}
    @sprites["selectbg"] = IconSprite.new(0,0,@viewport)
    @sprites["selectbg"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_bg")
    @sprites["prizebg"]  = IconSprite.new(0,0,@viewport)
    @sprites["prizebg"].setBitmap("Graphics/Pictures/Dynamax/lairmenu")
    @sprites["prizebg"].src_rect.set(0,0,197,384)
    @sprites["prizebg"].visible = false
    @sprites["prizesel"] = IconSprite.new(197,0,@viewport)
    @sprites["prizesel"].setBitmap("Graphics/Pictures/Dynamax/lairmenu")
    @sprites["prizesel"].src_rect.set(197,0,315,384)
    @sprites["prizesel"].visible = false
    @xpos = Graphics.width-330
    @ypos = 39
    for i in 0...3
      @sprites["pokeslot#{i}"] = IconSprite.new(@xpos,@ypos+(i*114),@viewport)
      @sprites["pokeslot#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["pokeslot#{i}"].src_rect.set(0,109,330,115)
      @sprites["pokeslot#{i}"].visible = false
    end
    @sprites["slotsel"] = IconSprite.new(@xpos,@ypos,@viewport)
    @sprites["slotsel"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
    @sprites["slotsel"].src_rect.set(0,0,165,109)
    @sprites["slotsel"].visible = false
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = @xpos-30
    @sprites["rightarrow"].play
    @sprites["rightarrow"].visible = false
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = @xpos-42
    @sprites["leftarrow"].play
    @sprites["leftarrow"].visible = false
    @sprites["actionbutton"] = IconSprite.new(6,350,@viewport)
    @sprites["actionbutton"].setBitmap("Graphics/Pictures/Controls help/help_actionkey")
    @sprites["actionbutton"].zoom_x = 0.5
    @sprites["actionbutton"].zoom_y = 0.5
    @sprites["actionbutton"].visible = false
    for i in 0...@size
      @sprites["partybg#{i}"] = IconSprite.new(4,90+(i*40),@viewport)
      @sprites["partybg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["partyname#{i}"] = IconSprite.new(41,99+(i*40),@viewport)
      @sprites["partyname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["partyname#{i}"].src_rect.set(197,20,150,19)
    end
    @sprites["menudisplay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["menudisplay"].z += 1
    @menudisplay = @sprites["menudisplay"].bitmap
    @sprites["changesprites"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["changesprites"].z += 1
    @changesprites = @sprites["changesprites"].bitmap
    @sprites["statictext"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["statictext"].z += 1
    @statictext = @sprites["statictext"].bitmap
    pbSetSmallFont(@statictext)
    @sprites["changetext"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["changetext"].z += 1
    @changetext = @sprites["changetext"].bitmap
    pbSetSmallFont(@changetext)
    drawTextEx(@statictext,4,6,164,0,_INTL("DYNAMAX ADVENTURE"),BASE,SHADOW)
    @typebitmap     = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @categorybitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/category"))
    @statbitmap     = AnimatedBitmap.new(_INTL("Graphics/Pictures/Dynamax/lairmenu_stats"))
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
  end
  
  #-----------------------------------------------------------------------------
  # Draws the player's rental party.
  #-----------------------------------------------------------------------------
  def pbDrawParty(party,showname=true)
    for i in 0...party.length
      @sprites["partysprite#{i}"] = PokemonIconSprite.new(party[i],@viewport)
      spritex = @sprites["partysprite#{i}"].x = @sprites["partybg#{i}"].x+2
      spritey = @sprites["partysprite#{i}"].y = @sprites["partybg#{i}"].y-2
      @sprites["partysprite#{i}"].zoom_x = 0.5
      @sprites["partysprite#{i}"].zoom_y = 0.5
      if showname
        @textPos.push([_INTL("{1}",party[i].name),spritex+40,spritey+2,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws the type icons for Pokemon and Moves.
  #-----------------------------------------------------------------------------
  def pbDrawTypeIcons(poke,ypos)
    type1 = GameData::Type.get(poke.type1).id_number
    type2 = GameData::Type.get(poke.type2).id_number
    type1rect = Rect.new(0,type1*28,64,28)
    type2rect = Rect.new(0,type2*28,64,28)
    @changesprites.blt(@xpos+86,ypos,@typebitmap.bitmap,type1rect)
    @changesprites.blt(@xpos+86,ypos+32,@typebitmap.bitmap,type2rect) if type1!=type2
  end
  
  #-----------------------------------------------------------------------------
  # Draws the icons used to display a Pokemon's stat training.
  #-----------------------------------------------------------------------------
  def pbDrawStatIcons(poke,ypos,showOnParty=true)
    stat = 0
    GameData::Stat.each_main do |s|
      next if s.id==:HP
      stat = s.id_number if poke.ev[s.id]==252
      stat = 6 if poke.ev[s.id]==50
    end
    for i in 0...$Trainer.party.length
      xpos = @sprites["partysprite#{i}"].x+55 if poke==$Trainer.party[i] && showOnParty
    end
    xpos = Graphics.width-34 if !xpos 
    @changesprites.blt(xpos,ypos,@statbitmap.bitmap,Rect.new((stat-1)*32,0,32,32)) if stat > 0
  end
  
  #-----------------------------------------------------------------------------
  # Draws the Summary screen for inputted Pokemon.
  #-----------------------------------------------------------------------------
  def pbSummary(pokemon,pkmnid,hidesprites)
    oldsprites = pbFadeOutAndHide(hidesprites) { pbUpdate }
    scene  = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,true)
    screen.pbStartScreen(pokemon,pkmnid)
    yield if block_given?
    pbFadeInAndShow(hidesprites,oldsprites) { pbUpdate }
  end
  
#===============================================================================
# Max Lair - Rental Screen
#===============================================================================
  def pbRentalSelect
    pbGenerateRentals
    index    = -1
    maxindex = @rentals.length-1
    drawTextEx(@statictext,4,52,164,0,_INTL("Rental Party:"),BASE,SHADOW)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @rentalparty.length>0
        @sprites["actionbutton"].visible = true
        drawTextEx(@statictext,62,352,120,0,_INTL("Summary"),BASE,SHADOW)
      end
      # Scrolls up/down through rental options.
      if Input.trigger?(Input::DOWN)
        pbPlayDecisionSE
        index += 1
        index  = 0 if index>maxindex
        @sprites["slotsel"].y  = @sprites["pokeslot#{index}"].y
        @sprites["rightarrow"].y = 80+(index*114)
        @sprites["slotsel"].visible = true
        @sprites["rightarrow"].visible = true
      elsif Input.trigger?(Input::UP)
        pbPlayDecisionSE
        index -= 1
        index  = maxindex if index<0
        @sprites["slotsel"].y  = @sprites["pokeslot#{index}"].y
        @sprites["rightarrow"].y = 80+(index*114)
        @sprites["slotsel"].visible = true
        @sprites["rightarrow"].visible = true
      # View the Summary of the current rental party.
      elsif Input.trigger?(Input::ACTION) && @rentalparty.length>0
        pbSummary(@rentalparty,0,@sprites)
      # Select a rental Pokemon.
      elsif Input.trigger?(Input::USE) && index>-1
        cmd = pbShowCommands(["Select","Summary","Back"],0)
        # Adds the selected rental Pokemon to your rental team.
        if cmd==0
          poke = @rentals[index]
          if pbConfirmMessage(_INTL("Add {1} to your rental team?",poke.name))
            GameData::Species.play_cry_from_pokemon(poke)
            @rentalparty.push(poke)
            pbWait(25)
            index = -1
            for i in 0...@rentals.length
              @sprites["pkmnsprite#{i}"].dispose
              @sprites["gmaxsprite#{i}"].dispose
              @sprites["helditem#{i}"].dispose
            end
            pbClearAll
            @sprites["slotsel"].visible    = false
            @sprites["rightarrow"].visible = false
            pbGenerateRentals
            if @rentalparty.length >= @size
              pbWait(20)
              $Trainer.party = @rentalparty
              break
            end
          end
        # View the Summary of the selected rental Pokemon.
        elsif cmd==1
          pbSummary(@rentals,index,@sprites)
        end
      elsif Input.trigger?(Input::BACK)
        break if pbConfirmMessage(_INTL("Exit the Max Lair?"))
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Rental Pokemon creation.
  #-----------------------------------------------------------------------------
  def pbGenerateRentals
    pbDrawParty(@rentalparty)
    remainder = @size-@rentalparty.length
    if remainder > 0
      @textPos.push([_INTL("Select {1} more rental Pokémon.",remainder),230,-6,0,BASE,SHADOW])
      for i in 0...3
        @rentals.push(pbGetMaxLairRental(3,@level,@trainer))
        @sprites["pokeslot#{i}"].visible = true
        @sprites["gmaxsprite#{i}"] = IconSprite.new(0,0,@viewport)
        @sprites["gmaxsprite#{i}"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
        @sprites["pkmnsprite#{i}"] = PokemonIconSprite.new(@rentals[i],@viewport)
        spritex = @sprites["pkmnsprite#{i}"].x = @xpos+12
        spritey = @sprites["pkmnsprite#{i}"].y = @ypos+(i*114)
        @sprites["gmaxsprite#{i}"].x = spritex-4
        @sprites["gmaxsprite#{i}"].y = spritey+4
        @sprites["gmaxsprite#{i}"].visible = false if !@rentals[i].gmaxFactor?
        @sprites["helditem#{i}"] = HeldItemIconSprite.new(spritex-8,spritey+40,@rentals[i],@viewport)
        offset = (@rentals[i].genderless?) ? -4 : 12
        name   = @rentals[i].name
        abil   = GameData::Ability.get(@rentals[i].ability).name
        mark, base, shadow = "♂", Color.new(24,112,216), Color.new(136,168,208) if @rentals[i].male?
        mark, base, shadow = "♀", Color.new(248,56,32),  Color.new(224,152,144) if @rentals[i].female?
        @textPos.push([mark,spritex-4,spritey+57,0,base,shadow]) if !@rentals[i].genderless?
        @textPos.push([_INTL("{1}",name),spritex+offset,spritey+58,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",abil),spritex-4,spritey+78,0,BASE,SHADOW])
        for m in 0...@rentals[i].moves.length
          move = GameData::Move.get(@rentals[i].moves[m].id).name
          xpos = spritex+160
          ypos = (spritey+12)+(m*22)
          @textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
        end
        pbDrawStatIcons(@rentals[i],@sprites["pokeslot#{i}"].y-2)
        pbDrawTypeIcons(@rentals[i],spritey+2)
      end
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Swap Screen
#===============================================================================
  def pbSwapSelect(pokemon)
    pbDrawSwapScreen(pokemon)
    @sprites["slotsel"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,220,6,400,0,_INTL("Select a party member to swap."),BASE,SHADOW)
    if pbConfirmMessage(_INTL("Would you like to swap Pokémon?"))
      pbMessage(_INTL("Select a party member to exchange."))
      index    = 0
      maxindex = $Trainer.party.length-1
      @sprites["leftarrow"].y = 95
      @sprites["leftarrow"].visible = true
      loop do
        Graphics.update
        Input.update
        pbUpdate
        # Scrolls up/down through your rental party.
        if Input.trigger?(Input::DOWN)
          pbPlayDecisionSE
          index += 1
          index  = 0 if index>maxindex
          @sprites["leftarrow"].y = 95+(index*40)
        elsif Input.trigger?(Input::UP)
          pbPlayDecisionSE
          index -= 1
          index  = maxindex if index<0
          @sprites["leftarrow"].y = 95+(index*40)
        # View the Summary of the rental Pokemon.
        elsif Input.trigger?(Input::ACTION)
          pbSummary([pokemon],0,@sprites)
        # Select a party member.
        elsif Input.trigger?(Input::USE)
          cmd = pbShowCommands(["Select","Summary","Back"],0)
          # Exchanges the selected party member for the caught Pokemon.
          if cmd==0
            oldpoke = $Trainer.party[index]
            olditem = $Trainer.party[index].item
            if pbConfirmMessage(_INTL("Exchange {1} for the new Pokémon?",oldpoke.name))
              GameData::Species.play_cry_from_pokemon(pokemon)
              pbWait(25)
              @sprites["partysprite#{index}"].dispose
              @sprites["pkmnsprite"].dispose
              @sprites["gmaxsprite"].dispose
              @sprites["helditem"].dispose
              @sprites["slotsel"].visible = false
              @sprites["leftarrow"].visible = false
              $Trainer.party[index] = pokemon
              $Trainer.party[index].item = olditem
              pbClearAll
              pbDrawSwapScreen
              pbMessage(_INTL("\\se[]{1} was added to the party!\\se[Pkmn move learnt]",pokemon.name))
              pbMessage(_INTL("{1}'s {2} was given to {3}.",oldpoke.name,GameData::Item.get(olditem).name,pokemon.name)) if olditem!=nil
              break
            end
          # View the Summary of the selected party member.
          elsif cmd==1
            pbSummary($Trainer.party,index,@sprites)
          end
        elsif Input.trigger?(Input::BACK)
          break if pbConfirmMessage(_INTL("Move on without swapping?"))
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws all the Pokemon data for a swap screen.
  #-----------------------------------------------------------------------------
  def pbDrawSwapScreen(pokemon=nil)
    pbDrawParty($Trainer.party)
    if pokemon
      slot = 1
      @sprites["pokeslot#{slot}"].visible = true
      @sprites["gmaxsprite"] = IconSprite.new(0,0,@viewport)
      @sprites["gmaxsprite"].setBitmap("Graphics/Pictures/Dynamax/gfactor")
      @sprites["pkmnsprite"] = PokemonIconSprite.new(pokemon,@viewport)
      spritex = @sprites["pkmnsprite"].x = @xpos+12
      spritey = @sprites["pkmnsprite"].y = @ypos+(slot*114)
      @sprites["slotsel"].y  = @sprites["pokeslot#{slot}"].y
      @sprites["gmaxsprite"].x = spritex-4
      @sprites["gmaxsprite"].y = spritey+4
      @sprites["gmaxsprite"].visible = false if !pokemon.gmaxFactor?
      @sprites["helditem"] = HeldItemIconSprite.new(spritex-8,spritey+40,pokemon,@viewport)
      newtag = [["Graphics/Pictures/Dynamax/lairmenu_slot",@xpos+10,spritey-15,165,0,60,20]]
      pbDrawImagePositions(@changesprites,newtag)
      name   = pokemon.name
      abil   = GameData::Ability.get(pokemon.ability).name
      offset = (pokemon.genderless?) ? -4 : 12
      mark, base, shadow = "♂", Color.new(24,112,216), Color.new(136,168,208) if pokemon.male?
      mark, base, shadow = "♀", Color.new(248,56,32),  Color.new(224,152,144) if pokemon.female?
      @textPos.push([mark,spritex-4,spritey+57,0,base,shadow]) if !pokemon.genderless?
      @textPos.push([_INTL("{1}",name),spritex+offset,spritey+58,0,BASE,SHADOW])
      @textPos.push([_INTL("{1}",abil),spritex-4,spritey+78,0,BASE,SHADOW])
      for m in 0...pokemon.moves.length
        move = GameData::Move.get(pokemon.moves[m].id).name
        xpos = spritex+160
        ypos = (spritey+12)+(m*22)
        @textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
      end
      pbDrawStatIcons(pokemon,@sprites["pokeslot#{slot}"].y-2)
      pbDrawTypeIcons(pokemon,spritey+2)
      @sprites["actionbutton"].visible = true
      @textPos.push([_INTL("Summary"),62,342,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Item Screen
#===============================================================================
  def pbItemSelect
    items    = []
    itempool = [:FOCUSSASH,:WIDELENS,:SCOPELENS,:QUICKCLAW,
                :ROCKYHELMET,:PROTECTIVEPADS,:SAFETYGOGGLES,
                :CHOICESCARF,:CHOICESPECS,:CHOICEBAND,
                :LIFEORB,:MUSCLEBAND,:WISEGLASSES,:EXPERTBELT,
                :EVIOLITE,:ASSAULTVEST,:BRIGHTPOWDER,
                :WHITEHERB,:WEAKNESSPOLICY,
                :LEFTOVERS,:SHELLBELL,
                :SITRUSBERRY,:LUMBERRY,:LEPPABERRY,
                :ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED]
    for i in 0...6
      randitem = rand(itempool.length)
      items.push(itempool[randitem])
      itempool.delete_at(randitem)
    end
    pbDrawItemScreen(items)
    ended = false
    @sprites["prizesel"].visible = true
    @sprites["actionbutton"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,62,352,120,0,_INTL("Summary"),BASE,SHADOW)
    pbDrawParty($Trainer.party,false)
    for i in 0...$Trainer.party.length
      spritex = @sprites["partysprite#{i}"].x
      spritey = @sprites["partysprite#{i}"].y
      @sprites["partyitem#{i}"] = ItemIconSprite.new(spritex+73,spritey+20,$Trainer.party[i].item,@viewport)
      @sprites["partyitem#{i}"].zoom_x  = 0.5
      @sprites["partyitem#{i}"].zoom_y  = 0.5
      @sprites["partyitem#{i}"].visible = false if !$Trainer.party[i].item
    end
    if pbConfirmMessage(_INTL("Would you like to give items to your Pokémon?"))
      for i in 0...$Trainer.party.length
        index    = 0
        maxindex = items.length-1
        poke     = $Trainer.party[i]
        pbMessage(_INTL("Select an item to give to {1}.",poke.name))
        if poke.item
          olditem = GameData::Item.get(poke.item).name
          text = _INTL("{1} is already holding a {2}.",poke.name,olditem)
          text = _INTL("{1} is already holding an {2}.",poke.name,olditem)   if olditem.starts_with_vowel?
          text = _INTL("{1} is already holding some {2}.",poke.name,olditem) if poke.hasItem?(:LEFTOVERS)
          if [:WISEGLASSES,:CHOICESPECS,:SAFETYGOGGLES,:PROTECTIVEPADS].include?(poke.item)
            text = _INTL("{1} is already holding a pair of {2}.",poke.name,olditem)
          end
          next if !pbConfirmMessage(_INTL("{1}\nReplace this item?",text))
        end
        @textPos.push([_INTL("Select {1}'s item.",poke.name),250,-6,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",poke.name),46,(85+(i*40))+5,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
        @sprites["rightarrow"].x = @xpos+44
        @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
        @sprites["rightarrow"].visible    = true
        @sprites["partyitem#{i}"].visible = false
        loop do
          Graphics.update
          Input.update
          pbUpdate
          # Scrolls up/down through the item options.
          if Input.trigger?(Input::DOWN)
            pbPlayDecisionSE
            index += 1
            index  = 0 if index>maxindex
            @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
          elsif Input.trigger?(Input::UP)
            pbPlayDecisionSE
            index -= 1
            index  = maxindex if index<0
            @sprites["rightarrow"].y = @sprites["itembg#{index}"].y+5
          # View the Summary of the party.
          elsif Input.trigger?(Input::ACTION)
            pbSummary($Trainer.party,i,@sprites)
          # Select an item.
          elsif Input.trigger?(Input::USE)
            cmd = pbShowCommands(["Give","Details","No Item","Back"],0)
            # Equips the selected hold item.
            if cmd==0
              if poke.item==items[index]
                pbMessage(_INTL("{1}",text))
              else
                newitem = GameData::Item.get(items[index]).name
                if pbConfirmMessage(_INTL("Give the {1} to {2}?",newitem,poke.name))
                  GameData::Species.play_cry_from_pokemon(poke)
                  pbWait(25)
                  pbMessage(_INTL("{1} was given the {2}.",poke.name,newitem))
                  @sprites["partyitem#{i}"].item    = items[index]
                  @sprites["partyitem#{i}"].visible = true
                  @sprites["rightarrow"].visible    = false
                  poke.item = items[index]
                  for item in 0...items.length
                    @sprites["itembg#{item}"].dispose
                    @sprites["itemname#{item}"].dispose
                    @sprites["itemsprite#{item}"].dispose
                  end
                  items.delete_at(index)
                  pbClearAll
                  pbDrawItemScreen(items)
                  break
                end
              end
            # Checks the decription of the selected item.
            elsif cmd==1
              item_id = GameData::Item.get(items[index]).id_number
              pbMessage(_INTL("{1}",pbGetMessage(MessageTypes::ItemDescriptions,item_id)))
            # Skips to the next Pokemon.
            elsif cmd==2
              if pbConfirmMessage(_INTL("Skip {1} without giving it an item?",poke.name))
                @sprites["partyitem#{i}"].visible = true if poke.item
                @sprites["rightarrow"].visible    = false
                for item in 0...items.length
                  @sprites["itembg#{item}"].dispose
                  @sprites["itemname#{item}"].dispose
                  @sprites["itemsprite#{item}"].dispose
                end
                pbClearAll
                pbDrawItemScreen(items)
                break
              end
            end
          elsif Input.trigger?(Input::BACK)
            if pbConfirmMessage(_INTL("Move on without equipping any more items?"))
              ended = true
              break
            end
          end
        end
        break if ended
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Draws the item equip screen.
  #-----------------------------------------------------------------------------
  def pbDrawItemScreen(items)
    for i in 0...items.length
      spritex = @xpos+80
      spritey = 56+(i*40)
      @sprites["itembg#{i}"] = IconSprite.new(spritex,spritey,@viewport)
      @sprites["itembg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["itemname#{i}"] = IconSprite.new(spritex+37,spritey+9,@viewport)
      @sprites["itemname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["itemname#{i}"].src_rect.set(197,20,150,19)
      @sprites["itemsprite#{i}"] = ItemIconSprite.new(spritex+19,spritey+18,items[i],@viewport)
      @sprites["itemsprite#{i}"].zoom_x = 0.5
      @sprites["itemsprite#{i}"].zoom_y = 0.5
      @textPos.push([_INTL("{1}",GameData::Item.get(items[i]).name),spritex+40,spritey,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Training Screen
#===============================================================================
  def pbTrainingSelect
    stats = [["Attack Training",  GameData::Stat.get(:ATTACK).id_number],
             ["Defense Training", GameData::Stat.get(:DEFENSE).id_number],
             ["Sp. Atk Training", GameData::Stat.get(:SPECIAL_ATTACK).id_number],
             ["Sp. Def Training", GameData::Stat.get(:SPECIAL_DEFENSE).id_number],
             ["Speed Training",   GameData::Stat.get(:SPEED).id_number],
             ["Balanced Training",6]]
    ended = false
    @sprites["prizesel"].visible = true
    @sprites["actionbutton"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,62,352,120,0,_INTL("Summary"),BASE,SHADOW)
    pbDrawParty($Trainer.party,false)
    pbDrawStatScreen(stats)
    if pbConfirmMessage(_INTL("Would you like to train your Pokémon?\nDoing so may undo thier current training."))
      for i in 0...$Trainer.party.length
        index    = 0
        maxindex = stats.length-1
        poke     = $Trainer.party[i]
        pbMessage(_INTL("Select the type of training {1} should undergo.",poke.name))
        totalev  = 0
        oldstat  = 0
        ypos     = @sprites["partysprite#{i}"].y+3
        GameData::Stat.each_main do |s|
          next if s.id==:HP
          totalev += poke.ev[s.id]
          oldstat = s.id_number if poke.ev[s.id]==252
        end
        oldstat = 6 if totalev==250
        oldevs  = {}
        GameData::Stat.each_main do |s| 
          oldevs[s.id]  = poke.ev[s.id]
          poke.ev[s.id] = 0
        end
        @changesprites.clear
        for p in 0...$Trainer.party.length
          next if poke==$Trainer.party[p]
          ypos = @sprites["partysprite#{p}"].y+5
          pbDrawStatIcons($Trainer.party[p],ypos)
        end
        @textPos.push([_INTL("Select {1}'s training.",poke.name),230,-6,0,BASE,SHADOW])
        @textPos.push([_INTL("{1}",poke.name),46,(85+(i*40))+5,0,BASE,SHADOW])
        pbDrawTextPositions(@changetext,@textPos)
        @sprites["rightarrow"].x = @xpos+44
        @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
        @sprites["rightarrow"].visible = true
        loop do
          Graphics.update
          Input.update
          pbUpdate
          # Scrolls up/down through the stat options.
          if Input.trigger?(Input::DOWN)
            pbPlayDecisionSE
            index += 1
            index  = 0 if index>maxindex
            @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
          elsif Input.trigger?(Input::UP)
            pbPlayDecisionSE
            index -= 1
            index  = maxindex if index<0
            @sprites["rightarrow"].y = @sprites["statbg#{index}"].y+5
          # View the Summary of the party.
          elsif Input.trigger?(Input::ACTION)
            pbSummary($Trainer.party,i,@sprites)
          # Select a training course.
          elsif Input.trigger?(Input::USE)
            cmd = pbShowCommands(["Train","Details","Don't Train","Back"],0)
            # Trains up the selected stat for the Pokemon.
            if cmd==0
              statsel  = stats[index][1]
              statname = (statsel==6) ? "balanced" : GameData::Stat.get(statsel).name
              if statsel==oldstat
                pbMessage(_INTL("{1} already has {2} training.",poke.name,statname))
              else
                if pbConfirmMessage(_INTL("Give {1} some {2} training?",poke.name,statname))
                  GameData::Species.play_cry_from_pokemon(poke)
                  oldstats = [0,poke.attack,poke.defense,poke.spatk,poke.spdef,poke.speed]
                  if statsel==6; GameData::Stat.each_main { |s| poke.ev[s.id] = 50 }
                  else; poke.ev[GameData::Stat.get(statsel).id] = 252
                  end
                  poke.ev[:HP] = 252
                  poke.calc_stats
                  newstats = [0,poke.attack,poke.defense,poke.spatk,poke.spdef,poke.speed]
                  pbWait(25)
                  pbMessage(_INTL("{1} unlearned its previous training.\\nAnd...\1",poke.name)) if oldstat>0
                  pbSEPlay("Pkmn move learnt")
                  if statsel==6
                    for s in 1...newstats.length
                      next if s==oldstat
                      statdiff = newstats[s]-oldstats[s]
                      pbMessage(_INTL("{1}'s training increased its {2} by {3} point(s)!",poke.name,GameData::Stat.get(s).name,statdiff))
                    end
                  else
                    statdiff = newstats[statsel]-oldstats[statsel]
                    pbMessage(_INTL("{1}'s training increased its {2} by {3} point(s)!",poke.name,statname,statdiff))
                  end
                  @sprites["rightarrow"].visible = false
                  for s in 0...stats.length
                    @sprites["statbg#{s}"].dispose
                    @sprites["statname#{s}"].dispose
                  end
                  stats.delete_at(index)
                  pbClearAll
                  @menudisplay.clear
                  pbDrawStatScreen(stats)
                  break
                end
              end
            elsif cmd==1
              if oldstat==6; pbMessage(_INTL("{1} is currently slightly trained across all stats.",poke.name))
              elsif oldstat>0; pbMessage(_INTL("{1} is currently fully trained in the {2} stat.",poke.name,GameData::Stat.get(oldstat).name))
              else; pbMessage(_INTL("{1} doesn't currently have any training.",poke.name))
              end
            # Skips to the next Pokemon.
            elsif cmd==2
              if pbConfirmMessage(_INTL("Skip {1} without giving it any training?",poke.name))
                @sprites["rightarrow"].visible = false
                for s in 0...stats.length
                  @sprites["statbg#{s}"].dispose
                  @sprites["statname#{s}"].dispose
                end
                pbClearAll
                @menudisplay.clear
                GameData::Stat.each_main { |s| poke.ev[s.id] = oldevs[s.id] }
                poke.calc_stats
                pbDrawStatScreen(stats)
                break
              end
            end
          elsif Input.trigger?(Input::BACK)
            if pbConfirmMessage(_INTL("Move on without any further training?"))
              GameData::Stat.each_main { |s| poke.ev[s.id] = oldevs[s.id] }
              poke.calc_stats
              ended = true
              break
            end
          end
        end
        break if ended
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws the training screen and stat icons.
  #-----------------------------------------------------------------------------
  def pbDrawStatScreen(stats)
    for i in 0...$Trainer.party.length
      ypos = @sprites["partysprite#{i}"].y+5
      pbDrawStatIcons($Trainer.party[i],ypos)
    end
    for i in 0...stats.length
      name    = stats[i][0]
      icon    = stats[i][1]-1
      spritex = @xpos+80
      spritey = 56+(i*40)
      @sprites["statbg#{i}"] = IconSprite.new(spritex,spritey,@viewport)
      @sprites["statbg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["statname#{i}"] = IconSprite.new(spritex+37,spritey+9,@viewport)
      @sprites["statname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["statname#{i}"].src_rect.set(197,20,150,19)
      @menudisplay.blt(spritex+3,spritey+3,@statbitmap.bitmap,Rect.new(icon*32,0,32,32))
      @textPos.push([_INTL("{1}",name),spritex+40,spritey,0,BASE,SHADOW])
    end
    pbDrawTextPositions(@changetext,@textPos)
  end
  
#===============================================================================
# Max Lair - Tutor Screen
#===============================================================================
  def pbTutorSelect
    @sprites["pokeslot#{1}"].visible = true
    @sprites["actionbutton"].visible = true
    drawTextEx(@statictext,4,52,164,0,_INTL("Current Party:"),BASE,SHADOW)
    drawTextEx(@statictext,62,352,120,0,_INTL("Summary"),BASE,SHADOW)
    drawTextEx(@statictext,220,6,400,0,_INTL("Select a party member to tutor."),BASE,SHADOW)
    pbDrawParty($Trainer.party)
    if pbConfirmMessage(_INTL("Would you like to tutor a Pokémon?"))
      pbMessage(_INTL("Select a party member to tutor."))
      newmoves = []
      for i in 0...$Trainer.party.length
        poke = $Trainer.party[i]
        pokemoves  = []
        tutormoves = []
        for m in poke.moves; pokemoves.push(m.id); end
        species_id = GameData::Species.get_species_form(poke.species, poke.form)
        movelist   = pbMaxRaidMovelists(species_id,true)
        raidmoves  = movelist[0]+movelist[1]+movelist[3]
        for m in 0...raidmoves.length
          category = GameData::Move.get(raidmoves[m]).category
          next if pokemoves.include?(raidmoves[m])
          next if category!=0 && poke.ev[:ATTACK]==252
          next if category!=1 && poke.ev[:SPECIAL_ATTACK]==252
          next if category!=2 && poke.ev[:DEFENSE]==252
          next if category!=2 && poke.ev[:SPECIAL_DEFENSE]==252
          tutormoves.push(raidmoves[m])
        end
        move = (tutormoves.length>0) ? tutormoves[rand(tutormoves.length)] : nil
        newmoves.push(move)
      end
      index    = 0
      maxindex = $Trainer.party.length-1
      @sprites["leftarrow"].y = 95
      @sprites["leftarrow"].visible = true
      pbDrawTutorScreen($Trainer.party[index],newmoves[index])
      loop do
        Graphics.update
        Input.update
        pbUpdate
        # Scrolls up/down through your rental party.
        if Input.trigger?(Input::DOWN)
          pbPlayDecisionSE
          index += 1
          index  = 0 if index>maxindex
          @sprites["leftarrow"].y = 95+(index*40)
          pbDrawTutorScreen($Trainer.party[index],newmoves[index])
        elsif Input.trigger?(Input::UP)
          pbPlayDecisionSE
          index -= 1
          index  = maxindex if index<0
          @sprites["leftarrow"].y = 95+(index*40)
          pbDrawTutorScreen($Trainer.party[index],newmoves[index])
        # View the Summary of the current rental party.
        elsif Input.trigger?(Input::ACTION)
          pbSummary($Trainer.party,index,@sprites)
        # Select a party member.
        elsif Input.trigger?(Input::USE)
          poke = $Trainer.party[index]
          if newmoves[index]
            cmd = pbShowCommands(["Teach","Details","Summary","Back"],0)
            # Select a move to replace.
            if cmd==0
              movename = GameData::Move.get(newmoves[index]).name
              if pbConfirmMessage(_INTL("Teach {1} the move {2}?",poke.name,movename))
                GameData::Species.play_cry_from_pokemon(poke)
                pbWait(25)
                if poke.numMoves<4
                  pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",poke.name,movename))
                  poke.learn_move(newmoves[index])
                  break
                else
                  forgetMove = @scene.pbForgetMove(poke,newmoves[index])
                  if forgetMove>=0
                    oldMoveName = GameData::Move.get(poke.moves[forgetMove].id).name
                    pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
                    pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1",poke.name,oldMoveName))
                    pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]",poke.name,movename))
                    poke.moves[forgetMove] = Pokemon::Move.new(newmoves[index])
                    break
                  end
                end
              end
            # Display the description of the new move.
            elsif cmd==1
              move_id = GameData::Move.get(newmoves[index]).id_number
              pbMessage(_INTL("{1}",pbGetMessage(MessageTypes::MoveDescriptions,move_id)))
            # View the Summary of the selected party member.
            elsif cmd==2
              pbSummary($Trainer.party,index,@sprites)
            end
          else
            pbMessage(_INTL("{1} can't be taught any other moves.",poke.name))
          end
        elsif Input.trigger?(Input::BACK)
          break if pbConfirmMessage(_INTL("Move on without tutoring any Pokémon?"))
        end
      end
    end
  end  
  
  #-----------------------------------------------------------------------------
  # Draws all the Pokemon data for a tutor screen.
  #-----------------------------------------------------------------------------
  def pbDrawTutorScreen(pokemon,newmove)
    slot = 1
    textPos = []
    spritex = @xpos+12
    spritey = @ypos+(slot*114)
    @menudisplay.clear
    @changesprites.clear
    if newmove
      @sprites["slotsel"].y = @sprites["pokeslot#{slot}"].y
      @sprites["slotsel"].visible = true
      newtag = [["Graphics/Pictures/Dynamax/lairmenu_slot",@xpos+10,spritey-15,165,0,60,20]]
      pbDrawImagePositions(@changesprites,newtag)
      movedata = GameData::Move.get(newmove)
      name     = movedata.name
      type     = movedata.type
      category = movedata.category
      totalpp  = movedata.total_pp
      damage   = movedata.base_damage
      damage   = (damage>0) ? damage : "---"
      accuracy = movedata.accuracy
      accuracy = (accuracy>0) ? accuracy : "---"
      typerect = Rect.new(0,GameData::Type.get(type).id_number*28,64,28)
      catrect  = Rect.new(0,category*28,64,28)
      @changesprites.blt(spritex-4,spritey+42,@typebitmap.bitmap,typerect)
      @changesprites.blt(spritex-4,spritey+74,@categorybitmap.bitmap,catrect)
      textPos.push([_INTL("{1}",name),spritex-4,spritey+8,0,BASE,SHADOW])
      textPos.push([_INTL("BP: {1}",damage),spritex+72,spritey+36,0,BASE,SHADOW])
      textPos.push([_INTL("AC: {1}",accuracy),spritex+72,spritey+56,0,BASE,SHADOW])
      textPos.push([_INTL("PP: {1}",totalpp),spritex+72,spritey+76,0,BASE,SHADOW])
      pbDrawStatIcons(pokemon,@sprites["pokeslot#{slot}"].y-2,false)
      for m in 0...pokemon.moves.length
        move = GameData::Move.get(pokemon.moves[m].id).name
        xpos = spritex+160
        ypos = (spritey+12)+(m*22)
        textPos.push([_INTL("{1}",move),xpos,ypos,0,SHADOW,BASE])
      end
    else
      @sprites["slotsel"].visible = false
      textPos.push([_INTL("No moves to learn."),spritex+80,spritey+40,0,SHADOW,BASE])
    end
    pbSetSmallFont(@menudisplay)
    pbDrawTextPositions(@menudisplay,textPos)
  end
  
#===============================================================================
# Max Lair - Prize Screen
#===============================================================================
  def pbPrizeSelect(prizes)
    @sprites["prizesel"].visible = true
    for i in 0...prizes.length
      @sprites["partybg#{i}"].x   = @xpos+100
      @sprites["partybg#{i}"].y  -= 30
      @sprites["partyname#{i}"].x = @sprites["partybg#{i}"].x+37
      @sprites["partyname#{i}"].y = @sprites["partybg#{i}"].y+9
    end
    pbDrawParty(prizes)
    pbMessage(_INTL("You may select one of the captured Pokémon to keep."))
    index    = 0
    maxindex = prizes.length-1
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 190
    @sprites["pokemon"].setPokemonBitmap(prizes[index])
    @sprites["rightarrow"].x = @xpos+60
    @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
    @sprites["rightarrow"].visible   = true
    @sprites["prizebg"].visible      = true
    @sprites["actionbutton"].visible = true
    drawTextEx(@statictext,250,6,400,0,_INTL("Select one Pokémon to keep."),BASE,SHADOW)
    drawTextEx(@statictext,62,352,120,0,_INTL("Summary"),BASE,SHADOW) if index>-1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      # Scrolls up/down through the prize options.
      if Input.trigger?(Input::DOWN)
        pbPlayDecisionSE
        index += 1
        index  = 0 if index>maxindex
        @sprites["pokemon"].setPokemonBitmap(prizes[index])
        @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
      elsif Input.trigger?(Input::UP)
        pbPlayDecisionSE
        index -= 1
        index  = maxindex if index<0
        @sprites["pokemon"].setPokemonBitmap(prizes[index])
        @sprites["rightarrow"].y = @sprites["partysprite#{index}"].y+5
      # View the Summary of a prize Pokemon.
      elsif Input.trigger?(Input::ACTION) && index>-1
        pbSummary(prizes,index,@sprites)
      end
      # Select a prize Pokemon.
      if Input.trigger?(Input::USE)
        cmd = pbShowCommands(["Select","Summary","Back"],0)
        # Acquires the selected prize Pokemon.
        if cmd==0
          poke = prizes[index]
          if pbConfirmMessage(_INTL("So, you'd like to take {1} with you?",poke.name))
            GameData::Species.play_cry_from_pokemon(poke)
            pbWait(25)
            pbMessage(_INTL("You returned any remaining captured Pokémon and your rental party."))
            pbNicknameAndStore(poke)
            break
          end
        # View the Summary of the selected Pokemon.
        elsif cmd==1
          pbSummary(prizes,index,@sprites)
        end
      elsif Input.trigger?(Input::BACK)
        break if pbConfirmMessage(_INTL("Leave without taking any captured Pokémon with you?"))
      end
    end
  end
  
#===============================================================================
# Max Lair - Treasure Chest contents screen
#===============================================================================
  def pbTreasureScreen(contents)
    @statictext.clear
    xpos, ypos = Graphics.width/2, Graphics.height/2
    @sprites["header"] = IconSprite.new(xpos-100,ypos-144,@viewport)
    @sprites["header"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmenu_header")
    @sprites["selectbg"].visible = false
    @sprites["prizesel"].visible = true
    @sprites["prizesel"].x = xpos-150
    textPos = [[_INTL("Treasure Chest"),xpos,ypos-132,2,BASE,SHADOW]]
    for i in 0...contents.length
      spritex = xpos-80
      spritey = (ypos-75)+(i*40)
      @sprites["itembg#{i}"] = IconSprite.new(spritex,spritey,@viewport)
      @sprites["itembg#{i}"].setBitmap("Graphics/Pictures/Dynamax/raid_party_bg")
      @sprites["itemname#{i}"] = IconSprite.new(spritex+37,spritey+9,@viewport)
      @sprites["itemname#{i}"].setBitmap("Graphics/Pictures/Dynamax/lairmenu_slot")
      @sprites["itemname#{i}"].src_rect.set(197,20,150,19)
      @sprites["itemsprite#{i}"] = ItemIconSprite.new(spritex+19,spritey+18,contents[i],@viewport)
      @sprites["itemsprite#{i}"].zoom_x = 0.5
      @sprites["itemsprite#{i}"].zoom_y = 0.5
      if GameData::Item.get(contents[i]).is_TR?
        move     = GameData::Item.get(contents[i]).move
        movename = GameData::Move.get(move).name
        textPos.push([_INTL("{1} {2}",GameData::Item.get(contents[i]).name,movename),spritex+40,spritey,0,BASE,SHADOW])
      else
        textPos.push([_INTL("{1}",GameData::Item.get(contents[i]).name),spritex+40,spritey,0,BASE,SHADOW])
      end
    end
    pbDrawTextPositions(@changetext,textPos)
    pbWait(30)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      break if Input.trigger?(Input::BACK)
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
#===============================================================================
# Max Lair - Endless Adventure records screen
#===============================================================================
  def pbEndlessRecordScreen
    @statictext.clear
    xpos, ypos = Graphics.width/2, Graphics.height/2
    @sprites["header"] = IconSprite.new(xpos-100,ypos-144,@viewport)
    @sprites["header"].bitmap = Bitmap.new("Graphics/Pictures/Dynamax/lairmenu_header")
    floor   = pbEndlessLairRecord[0]
    battles = pbEndlessLairRecord[1]
    party   = pbEndlessLairRecord[2]
    @sprites["selectbg"].visible = false
    @sprites["prizesel"].visible = true
    @sprites["prizesel"].x = xpos-150
    textPos = [
      [_INTL("Adventure Record"),xpos,ypos-132,2,BASE,SHADOW],
      [_INTL("Floor Reached:"),xpos-95,ypos+58,0,BASE,SHADOW],
      [_INTL("Pokémon Battled:"),xpos-95,ypos+87,0,BASE,SHADOW],
      [_INTL("B#{floor}F"),xpos+65,ypos+58,0,BASE,SHADOW],
      [_INTL("#{battles}"),xpos+65,ypos+87,0,BASE,SHADOW]
    ]
    offset = 25*@size
    for i in 0...@size
      @sprites["partybg#{i}"].x   = xpos-80
      @sprites["partybg#{i}"].y   = (ypos-offset)+(i*40)
      @sprites["partybg#{i}"].visible = false if i >= party.length
      @sprites["partyname#{i}"].x = @sprites["partybg#{i}"].x+37
      @sprites["partyname#{i}"].y = @sprites["partybg#{i}"].y+9
      @sprites["partyname#{i}"].visible = false if i >= party.length
    end
    pbDrawParty(party)
    pbDrawTextPositions(@changetext,textPos)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      break if Input.trigger?(Input::BACK)
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Used for accessing various Max Lair menu screens.
#===============================================================================
# When params[0]==0; opens rental screen.
# When params[0]==1; opens exchange screen.
# When params[0]==2; opens prize screen.
# When params[0]==3; opens item screen.
# When params[0]==4; opens training screen.
# When params[0]==5; opens tutor screen.
# When params[0]==6; opens treasure screen.
# When params[0]==7; opens record screen.
def pbMaxLairMenu(params, partysize = nil)
  scene  = MaxLairEventScene.new
  screen = MaxLairScreen.new(scene)
  partysize = $Trainer.party.length if !partysize
  if params[0]==6
    screen.pbStartTreasureScreen(params[1])
  elsif params[0]==7
    screen.pbStartRecordsScreen(partysize)
  else
    pbFadeOutIn {
      case params[0]
      when 0; screen.pbStartRentalScreen(params[1],params[2])
      when 1; screen.pbStartSwapScreen(partysize,params[1])
      when 2; screen.pbStartPrizeScreen(params[1])
      when 3; screen.pbStartItemScreen(partysize)
      when 4; screen.pbStartTrainingScreen(partysize)
      when 5; screen.pbStartTutorScreen(partysize)
      end
    }
  end
end

class MaxLairScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartRentalScreen(size,level)
    @scene.pbStartScene(size,level)
    @scene.pbRentalSelect
    @scene.pbEndScene
  end
  
  def pbStartSwapScreen(size,pokemon)
    @scene.pbStartScene(size,nil)
    @scene.pbSwapSelect(pokemon)
    @scene.pbEndScene
  end
  
  def pbStartPrizeScreen(prizes)
    @scene.pbStartScene(prizes.length,nil)
    @scene.pbPrizeSelect(prizes)
    @scene.pbEndScene
  end
  
  def pbStartItemScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbItemSelect
    @scene.pbEndScene
  end
  
  def pbStartTrainingScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbTrainingSelect
    @scene.pbEndScene
  end
  
  def pbStartTutorScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbTutorSelect
    @scene.pbEndScene
  end
  
  def pbStartTreasureScreen(contents)
    @scene.pbStartScene(0,nil)
    @scene.pbTreasureScreen(contents)
  end
  
  def pbStartRecordsScreen(size)
    @scene.pbStartScene(size,nil)
    @scene.pbEndlessRecordScreen
  end
end