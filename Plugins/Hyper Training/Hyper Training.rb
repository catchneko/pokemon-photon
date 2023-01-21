#===============================================================================
#  Hyper Training Script
#  Credit to Jonas930
#  Modified by catchneko
#===============================================================================
#  How to Use:
#     pbMrHyper(ITEM1,ITEM2)
#         ITEM1 => the item that you want player use with boosting ONE IV to 31
#         ITEM2 => the item that you want player use with boosting ALL IVs to 31
#         ITEM3 => the item that you want player use with boosting ONE IV to 30
#  Example: pbMrHyper(:STARDUST,:STARPIECE)
#===============================================================================

def pbMrHyper(item1,item2,item3)
  @nameitem1=GameData::Item.get(item1).name
  @nameitem2=GameData::Item.get(item2).name
  @nameitem3=GameData::Item.get(item3).name
  @hasitem1=$PokemonBag.pbHasItem?(item1)
  @hasitem2=$PokemonBag.pbHasItem?(item2)
  @hasitem3=$PokemonBag.pbHasItem?(item3)
  Kernel.pbMessage(_INTL("The name's Mr. Hyper!\nI can help Pokemon do Hyper Training!"))
  if Kernel.pbConfirmMessage(_INTL("Want to try some of my Hyper Training to boost your Pokemon's stats?"))
    if @hasitem1 || @hasitem2 || @hasitem3
      item = 0 if @hasitem1 && !@hasitem2 && !@hasitem3
	  itemuse = @nameitem1 if @hasitem1 && !@hasitem2 && !@hasitem3
	  chooseitem = 0 if @hasitem1 && !@hasitem2 && !@hasitem3
      item = 1 if !@hasitem1 && @hasitem2 && !@hasitem3
	  itemuse = @nameitem2 if !@hasitem1 && @hasitem2 && !@hasitem3
	  chooseitem = 1 if !@hasitem1 && @hasitem2 && !@hasitem3
	  item = 2 if !@hasitem1 && !@hasitem2 && @hasitem3
	  itemuse = @nameitem3 if !@hasitem1 && !@hasitem2 && @hasitem3
	  chooseitem = 2 if !@hasitem1 && !@hasitem2 && @hasitem3
	  if @hasitem1 && @hasitem2 && !@hasitem3
		item = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),[@nameitem1,@nameitem2])
		itemuse = (item == 0 ? @nameitem1 : @nameitem2)
		chooseitem = (item == 0 ? 0 : 1)
	  elsif  @hasitem1 && !@hasitem2 && @hasitem3
		item = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),[@nameitem1,@nameitem3])
		itemuse = (item == 0 ? @nameitem1 : @nameitem3)
		chooseitem = (item == 0 ? 0 : 2)
	  elsif !@hasitem1 && @hasitem2 && @hasitem3
		item = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),[@nameitem2,@nameitem3])
		itemuse = (item == 0 ? @nameitem2 : @nameitem3)
		chooseitem = (item == 0 ? 1 : 2)
	  elsif @hasitem1 && @hasitem2 && @hasitem3
		item = Kernel.pbMessage(_INTL("Which item would you want to use on Hyper Training?"),[@nameitem1,@nameitem2,@nameitem3])
		itemuse = (item == 0 ? @nameitem1 : (item == 1 ? @nameitem2 : @nameitem3))
		chooseitem = (item == 0 ? 0 : (item == 1 ? 1 : 2))
	  end
      if Kernel.pbConfirmMessage(_INTL("Are you gonna use one \\c[1]{1}\\c[0] for Hyper Training?",itemuse))
        Kernel.pbMessage(_INTL("Which one of your Pokemon do you want to do some Hyper Training on?"))
        pbChoosePokemon(1,2)
        pokemon = $Trainer.pokemonParty[pbGet(1)]
        if pbGet(1) < 0
        elsif $Trainer.party[pbGet(1)].egg?
          Kernel.pbMessage(_INTL("An Egg?!\nI understand why you're hyped to have one,\nbut I can't train that thing yet!"))
        else
          if chooseitem==0
            stat = Kernel.pbMessage(_INTL("Which one of {1}'s stats do you want to do some Hyper Training on?",pokemon.name),
            [_INTL("HP"),_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Sp. Atk"),_INTL("Sp. Def")])
			stat2 = :HP if stat == 0
			stat2 = :ATTACK if stat == 1
			stat2 = :DEFENSE if stat == 2
			stat2 = :SPEED if stat == 3
			stat2 = :SPECIAL_ATTACK if stat == 4
			stat2 = :SPECIAL_DEFENSE if stat == 5
            if pokemon.iv[stat2]==31
              Kernel.pbMessage(_INTL("But that Pokemon is already so awesome that it doesn't need any training!"))
            else
              pokemon.iv[stat2]=31
			  pokemon.calc_stats
              $PokemonBag.pbDeleteItem(item1)
              Kernel.pbMessage(_INTL("Then get hype!"))
              Kernel.pbMessage(_INTL("Because I'm about to do some real Hyper Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("All right!\n{1} got even stronger thanks to my Hyper Training!",pokemon.name))
            end
          elsif chooseitem==1
            if (pokemon.iv[:HP]==31 && pokemon.iv[:ATTACK]==31 && pokemon.iv[:DEFENSE]==31 && 
                pokemon.iv[:SPEED]==31 && pokemon.iv[:SPECIAL_ATTACK]==31 && pokemon.iv[:SPECIAL_DEFENSE]==31)
              Kernel.pbMessage(_INTL("But that Pokemon is already so awesome that it doesn't need any training!"))
            else
              pokemon.iv[:HP] = 31
			  pokemon.iv[:ATTACK] = 31
			  pokemon.iv[:DEFENSE] = 31
			  pokemon.iv[:SPECIAL_ATTACK] = 31
			  pokemon.iv[:SPECIAL_DEFENSE] = 31
			  pokemon.iv[:SPEED] = 31
			  pokemon.calc_stats
              $PokemonBag.pbDeleteItem(item2)
              Kernel.pbMessage(_INTL("Then get hype!"))
              Kernel.pbMessage(_INTL("Because I'm about to do some real Hyper Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("All right!\n{1} got even stronger thanks to my Hyper Training!",pokemon.name))
            end
          elsif chooseitem==2
            stat = Kernel.pbMessage(_INTL("Which one of {1}'s stats do you want to do some Hyper Training on?",pokemon.name),
            [_INTL("HP"),_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Sp. Atk"),_INTL("Sp. Def")])
			stat2 = :HP if stat == 0
			stat2 = :ATTACK if stat == 1
			stat2 = :DEFENSE if stat == 2
			stat2 = :SPEED if stat == 3
			stat2 = :SPECIAL_ATTACK if stat == 4
			stat2 = :SPECIAL_DEFENSE if stat == 5
            if pokemon.iv[stat2]==30
              Kernel.pbMessage(_INTL("But that Pokemon is already so awesome that it doesn't need any training!"))
            else
              pokemon.iv[stat2]=30
			  pokemon.calc_stats
              $PokemonBag.pbDeleteItem(item3)
              Kernel.pbMessage(_INTL("Then get hype!"))
              Kernel.pbMessage(_INTL("Because I'm about to do some real Hyper Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("All right!\n{1} got even stronger thanks to my Hyper Training!",pokemon.name))
            end
		  end
        end
      end
    else
      Kernel.pbMessage(_INTL("Oh no...\nNo, no, no!"))
      Kernel.pbMessage(_INTL("You don't have any {1} or {2}!\nNot even one!",@nameitem1,@nameitem2))
    end
  end
  Kernel.pbMessage(_INTL("Then come back anytime!\nMr. Hyper will always be hyped up to see you!"))
end

def pbEvilHyper(item1)
  @nameitem1=GameData::Item.get(item1).name
  @hasitem1=$PokemonBag.pbHasItem?(item1)
  Kernel.pbMessage(_INTL("The name's EVIL Mr. Hyper!\nI can help Pokemon do Hyper UN-Training!"))
  if Kernel.pbConfirmMessage(_INTL("Want to try some of my Hyper UN-Training to LOWER your Pokemon's stats?"))
    if @hasitem1
      itemuse = @nameitem1
      if Kernel.pbConfirmMessage(_INTL("Are you gonna use one \\c[1]{1}\\c[0] for Hyper UN-Training?",itemuse))
        Kernel.pbMessage(_INTL("Which one of your Pokemon do you want to do some Hyper UN-Training on?"))
        pbChoosePokemon(1,2)
        pokemon = $Trainer.pokemonParty[pbGet(1)]
        if pbGet(1) < 0
        elsif $Trainer.party[pbGet(1)].egg?
          Kernel.pbMessage(_INTL("An Egg?!\nIt hasn't even been trained to begin with!\nHow could I possibly UN-train that?!"))
        else
            stat = Kernel.pbMessage(_INTL("Which one of {1}'s stats do you want to do some Hyper UN-Training on?",pokemon.name),
            [_INTL("HP"),_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Sp. Atk"),_INTL("Sp. Def")])
			stat2 = :HP if stat == 0
			stat2 = :ATTACK if stat == 1
			stat2 = :DEFENSE if stat == 2
			stat2 = :SPEED if stat == 3
			stat2 = :SPECIAL_ATTACK if stat == 4
			stat2 = :SPECIAL_DEFENSE if stat == 5
            if pokemon.iv[stat2]==0
              Kernel.pbMessage(_INTL("But that Pokemon's stat already is the lowest it can be!"))
            else
              pokemon.iv[stat2]=0
			  pokemon.calc_stats
              $PokemonBag.pbDeleteItem(item1)
              Kernel.pbMessage(_INTL("Then DON'T get hype!"))
              Kernel.pbMessage(_INTL("Because I'm about to do some real Hyper UN-Training on {1} here!",pokemon.name))
              Kernel.pbMessage(_INTL("Mwahahaha!\n{1} got LESS strong thanks to my Hyper UN-Training!",pokemon.name))
            end
        end
      end
    else
      Kernel.pbMessage(_INTL("Oh no...\nNo, no, no!"))
      Kernel.pbMessage(_INTL("You don't have any {1}!\nNot even one!",@nameitem1,@nameitem2))
    end
  end
  Kernel.pbMessage(_INTL("Then come back anytime!\nEVIL Mr. Hyper will NEVER be hyped up to see you!"))
end