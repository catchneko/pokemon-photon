#===============================================================================
# Max Lair Event Tiles.
#===============================================================================
class DynAdventureState
  #-----------------------------------------------------------------------------
  # Scientist NPC
  # Allows the player to exchange a party member for a new rental Pokemon.
  #-----------------------------------------------------------------------------
  def pbLairEventSwap
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Scientist!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("How have the results of your adventure been so far?"))
    pbMessage(_INTL("I have a rental Pokémon here that I could swap with you, if you'd like."))
    trainer = NPCTrainer.new("RENTAL",0)
    pokemon = pbGetMaxLairRental(5,$Trainer.party[0].level,trainer)
    pokemon.item = nil
    pbMaxLairMenu([1,pokemon])
    pbMessage(_INTL("I'll head back to study the new data I've gathered."))
    pbMessage(_INTL("Please report any new findings you may discover on your adventure!"))
  end
  
  #-----------------------------------------------------------------------------
  # Backpacker NPC
  # Allows the player to equip items to party members out of a randomized list.
  #-----------------------------------------------------------------------------
  def pbLairEventItems
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Backpacker!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I was worried I'd run into trouble in here, so I stocked up on more than I can carry..."))
    pbMessage(_INTL("I can share my supplies with you if you're in need. What items would you like?"))
    pbMaxLairMenu([3])
    pbMessage(_INTL("Remember, preparation is the key to victory!"))
  end
  
  #-----------------------------------------------------------------------------
  # Blackbelt NPC
  # Allows the player to reallocate EV points of party members.
  #-----------------------------------------------------------------------------
  def pbLairEventTrain
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Blackbelt!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I've been training deep in this cave so that I can grow strong like a Dynamax Pokémon!"))
    pbMessage(_INTL("Do you want to become strong, too? Let me share my secret training techniques with you!"))
    pbMaxLairMenu([4])
    pbMessage(_INTL("Keep pushing yourself until you've reached your limits!"))
  end
  
  #-----------------------------------------------------------------------------
  # Ace Trainer NPC
  # Allows the player to tutor a party member to learn a randomized move.
  #-----------------------------------------------------------------------------
  def pbLairEventTutor
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered an Ace Trainer!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("I've been studying the most effective tactics to use in Dynamax battles."))
    pbMessage(_INTL("If you'd like, I can teach one of your Pokémon a new move to help it excel in battle!"))
    pbMaxLairMenu([5])
    pbMessage(_INTL("A good strategy will help you overcome any obstacle!"))
  end
  
  #-----------------------------------------------------------------------------
  # Channeller NPC
  # Increases the player's current and total heart counter by 1.
  #-----------------------------------------------------------------------------
  def pbLairEventWardIntro
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Channeler!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("Ahh! Your spirit beckons me to cleanse it of its weariness!"))
    pbMessage(_INTL("Let me exorcise the demons that plague your body and soul!"))
    pbMessage(_INTL("...\\wt[10] ...\\wt[10] ...\\wt[20]Begone!"))
  end
  
  def pbLairEventWardOutro
    return if ended?
    return if !inProgress?
    pbSEPlay(sprintf("Anim/Natural Gift"))
    pbMessage(_INTL("Your total number of hearts increased!\\wt[34]"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("What am I even doing here, you ask?\nHaha! Foolish child."))
    randtext = rand(5)
    case randtext
    when 0
      pbMessage(_INTL("I was once an adventurer like you who got lost in these caves.\nMany...\\wt[10]many years ago.\\wt[10]"))
      pbMessage(_INTL("Huh? The Channeler suddenly vanished!"),nil,0,WINDOWSKIN)
    when 1
      pbMessage(_INTL("I go where the spirits say I'm needed! Nothing more!"))
      pbMessage(_INTL("I must go now, young one. There are many other souls that need saving!"))
    when 2
      pbMessage(_INTL("What makes you think I was ever really here at all?\nOooooo....\\wt[10]"))
      pbWait(20)
      pbMessage(_INTL("The Channeler tripped over a rock during their dramatic exit."),nil,0,WINDOWSKIN)
    when 3
      pbMessage(_INTL("I was summoned here by the wailing of souls crying out from this cave!"))
      pbMessage(_INTL("..but now that I'm here, I think it was just the wind."))
      pbMessage(_INTL("Perhaps it was fate that drew me here to meet you?\nAlas, it is now time for us to part ways."))
      pbMessage(_INTL("Farewell, child. Good luck on your journeys."))
    when 4
      pbMessage(_INTL("If you must know, I...\\wt[10]just got lost."))
      pbMessage(_INTL("The exit is back there, you say?\nThank you, child."))
      pbMessage(_INTL("May the spirits guide you better than they have me!"))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Nurse NPC
  # Fully restores the player's party.
  #-----------------------------------------------------------------------------
  def pbLairEventHeal
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You encountered a Nurse!"),nil,0,WINDOWSKIN)
    pbMessage(_INTL("Are your Pokémon feeling a bit worn out from your adventure?"))
    pbMessage(_INTL("\\me[Pkmn healing]Please, let me heal them back to full health.\\wtnp[30]"))
    for i in $Trainer.party; i.heal; end
    pbMessage(_INTL("I'll be going now.\nGood luck with the rest of your adventure!"))
  end
  
  #-----------------------------------------------------------------------------
  # Random NPC
  # The effect of a random NPC Tile is applied.
  #-----------------------------------------------------------------------------
  def pbLairEventRandom(event)
    return if ended?
    return if !inProgress?
    pbLairEventSwap      if event==0
    pbLairEventItems     if event==1
    pbLairEventTrain     if event==2
    pbLairEventTutor     if event==3
    pbLairEventHeal      if event==4
  end
  
  #-----------------------------------------------------------------------------
  # Berries
  # Heals up to 50% of each party member's max HP.
  #-----------------------------------------------------------------------------
  def pbLairBerries
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("You found some Berries lying on the ground!"))
    pbSEPlay(sprintf("Anim/Recovery"))
    pbMessage(_INTL("Your Pokémon ate the Berries and some of their HP was restored!"))
    for i in $Trainer.party
      i.hp += i.totalhp/2
      i.hp = i.totalhp if i.hp>i.totalhp
    end
  end
  
  #-----------------------------------------------------------------------------
  # Treasure Chest
  # Collects a random reward.
  #-----------------------------------------------------------------------------
  def pbLairChests
    return if ended?
    return if !inProgress?
    contents  = []
    poke_id   = (@lastPokemon) ? @lastPokemon.species : @lairSpecies[0]
    poke_rank = pbAllRanksAppearedIn(poke_id)
    loot_rank = "Common"
    loot_rank = "Uncommon"  if poke_rank[0]>=2 && rand(10)<6
    loot_rank = "Rare"      if poke_rank[0]>=3 && rand(10)<4
    loot_rank = "Very Rare" if poke_rank[0]>=4 && rand(10)<2
    for i in 0...4
      for t in @treasure[loot_rank].shuffle
        next if !GameData::Item.exists?(t)
        next if contents.include?(t)
        item = t
        break if item
      end
      contents.push(item) if item
    end
    trList = pbTechnicalRecordByType(poke_id)
    contents.push(trList[rand(trList.length)]) if !trList.empty?
	pbMessage(_INTL("You found a Treasure Chest!"))
    pbSEPlay("Battle catch click")
    pbMaxLairMenu([6,contents])
    @loot += contents
  end
  
  #-----------------------------------------------------------------------------
  # Lair Keys
  # Collects a key to be used to unlock locked doors.
  #-----------------------------------------------------------------------------
  def pbLairKeys
    return if ended?
    return if !inProgress?
    @keycount += 1
    pbMessage(_INTL("\\me[Bug catching 3rd]You found a Lair Key!\\wtnp[30]"))
  end
  
  #-----------------------------------------------------------------------------
  # Locked Door
  # Prevents passage unless a key is used to unlock it.
  #-----------------------------------------------------------------------------
  def pbLairDoors
    return if ended?
    return if !inProgress?
    pbMessage(_INTL("A massive locked door blocks your path."))
    if @keycount > 0
      @keycount -= 1
      pbMessage(_INTL("You used a Lair Key to open the door!"))
      pbSEPlay("Battle catch click")
      pbWait(2)
      pbSEPlay("Door open")
      return true
    else
      pbMessage(_INTL("Unable to proceed, you turned back the way you came."))
      return false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Roadblocks
  # Prevents movement unless a party member meets certain criteria.
  #-----------------------------------------------------------------------------
  def pbLairObstacles(value)
    return if ended?
    return if !inProgress?
    case value
    when 0
      pbMessage(_INTL("A deep chasm blocks your path forward."))
      pbMessage(_INTL("A Flying-type Pokémon may be able to lift you safely across."))
      text = "{1} happily carried you across the chasm."
    when 1
      pbMessage(_INTL("A large pool of murky water blocks your path forward."))
      pbMessage(_INTL("A Water-type Pokémon may be able to get you safely across."))
      text = "{1} happily carried you across the water."
    when 2
      pbMessage(_INTL("You reached what appears to be a dead end, but the wall here seems thin."))
      pbMessage(_INTL("A Fighting-type Pokémon may be able to punch through the wall and forge a path forward."))
      text = "{1} bashed through the wall with a mighty blow!"
    when 3
      pbMessage(_INTL("The floor here seems unstable in certain spots, and you may fall through if you proceed."))
      pbMessage(_INTL("A Psychic-type Pokémon may be able to foresee the safest route forward and avoid any pitfalls."))
      text = "{1} foresaw the dangers ahead and navigated you safely across."
    when 4
      pbMessage(_INTL("Strong winds funneled through the caves and whipped up a storm of dust that is impossible to see through."))
      pbMessage(_INTL("A Rock, Ground, or Steel-type Pokémon may be able to safely guide you through the storm."))
      text = "{1} bravely traversed the storm and led you across."
    when 5
      pbMessage(_INTL("Pitch-black darkness makes it too dangerous to move forward."))
      pbMessage(_INTL("A Bug, Dark, or Ghost-type Pokémon may be able to see through the darkness and lead you through it."))
      text = "{1} bravely traversed the darkness and led you across."
    when 6
      pbMessage(_INTL("A massive boulder blocks your path forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Attack may be physically capable of moving it."))
      text = "{1} flexed its muscles and tossed the boulder aside with ease!"
    when 7
      pbMessage(_INTL("Falling rocks makes it too dangerous to move forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Defense may be tough enough to shield you from harm."))
      text = "{1} unflinchingly shrugged off the falling rocks as you moved forward!"
    when 8
      pbMessage(_INTL("A steep incline makes it too difficult to move forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Speed may be quick enough to carry you forward."))
      text = "{1} bolted you up the incline without breaking a sweat!"
    when 9
      pbMessage(_INTL("An impenetrable barrier of Dynamax energy blocks your path forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Special Attack may be powerful enough to blast through it."))
      text = "{1} let out a yawn and effortlessly shattered the barrier!"
    when 10
      pbMessage(_INTL("A powerful wave of Dynamax energy prevents you from moving forward."))
      pbMessage(_INTL("A Pokémon sufficienty trained in Special Defense may have enough fortitude to carry you through it."))
      text = "{1} swatted away the waves of energy and carried you through unscathed!"
    when 11
      pbMessage(_INTL("An intimidating gauntlet of various challenges prevents you from moving forward."))
      pbMessage(_INTL("A Pokémon with balanced training may be capable of overcoming the numerous obstacles."))
      text = "{1} impressively traversed the gauntlet with near-perfect form!"
    end
    for i in $Trainer.party
      criteria = (i.hasType?(:FLYING))   if value==0
      criteria = (i.hasType?(:WATER))    if value==1
      criteria = (i.hasType?(:FIGHTING)) if value==2
      criteria = (i.hasType?(:PSYCHIC))  if value==3
      criteria = (i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)) if value==4
      criteria = (i.hasType?(:BUG)  || i.hasType?(:DARK)   || i.hasType?(:GHOST)) if value==5
      criteria = (i.ev[:ATTACK]==252)          if value==6
      criteria = (i.ev[:DEFENSE]==252)         if value==7
      criteria = (i.ev[:SPEED]==252)           if value==8
      criteria = (i.ev[:SPECIAL_ATTACK]==252)  if value==9
      criteria = (i.ev[:SPECIAL_DEFENSE]==252) if value==10
      criteria = (i.ev[:ATTACK]==50)           if value==11
      if criteria
        pbHiddenMoveAnimation(i)
        pbMessage(_INTL(text,i.name))
        return true
        break
      end
    end
    pbMessage(_INTL("Unable to proceed, you turned back the way you came."))
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Hidden Traps
  # May inflict negative effects on a random party member when triggered.
  #-----------------------------------------------------------------------------
  def pbLairTraps(value)
    return if ended?
    return if !inProgress?
    pbSEPlay("Exclaim")
    case value
    when 0
      pbMessage(_INTL("You suddenly lost your footing and fell down a deep shaft!"))
      text1 = "{1} came to your rescue and cushioned your fall!"
      text2 = "Luckily, {1} managed to avoid harm!"
      text3 = "However, {1} was injured in the process..."
    when 1
      pbMessage(_INTL("An overgrown mushroom nearby suddenly burst and released a cloud of spores!"))
      text1 = "{1} pushed you aside and was hit by the cloud of spores instead!"
      text2 = "Luckily, the spores had no effect on {1}!"
      text3 = "{1} became sleepy due to the spores!"
    when 2
      pbMessage(_INTL("A mysterious ooze leaked from the cieling and fell towards you!"))
      text1 = "{1} pushed you aside and was hit by the mysterious ooze instead!"
      text2 = "Luckily, the mysterious ooze had no effect on {1}!"
      text3 = "{1} became poisoned due to the mysterious ooze!"
    when 3
      pbMessage(_INTL("A geyser of steam suddenly erupted beneath your feet!"))
      text1 = "{1} pushed you aside and was hit by the steam instead!"
      text2 = "Luckily, the steam had no effect on {1}!"
      text3 = "{1} became burned due to the steam!"
    when 4
      pbMessage(_INTL("An electrical pulse was suddenly released by iron deposits nearby!"))
      text1 = "{1} pushed you aside and was hit by the electrical pulse instead!"
      text2 = "Luckily, the electrical pulse had no effect on {1}!"
      text3 = "{1} became paralyzed due to the electrical pulse!"
    when 5
      pbMessage(_INTL("You walked over a sheet of ice and it began to crack beneath your feet!"))
      text1 = "{1} pushed you aside and plunged into the frigid water instead!"
      text2 = "Luckily, the frigid water had no effect on {1}!"
      text3 = "{1} was frozen solid due to the frigid water!"
    end
    p = $Trainer.party[rand($Trainer.party.length)]
    pbHiddenMoveAnimation(p)
    pbMessage(_INTL(text1,p.name))
    if value==0
      random = rand(10)
      if random<2
        pbSEPlay("Mining found all")
        pbMessage(_INTL(text2,p.name))
      else
        p.hp-= p.totalhp/4
        p.hp = 1 if p.hp<=0
        pbSEPlay("Battle damage normal")
        pbMessage(_INTL(text3,p.name))
      end
    else
      noeffect = true if p.status!=:NONE || p.hasAbility?(:COMATOSE)
      noeffect = true if value==1 && (p.hasType?(:GRASS)    || p.hasAbility?(:INSOMNIA)   || p.hasAbility?(:VITALSPIRIT) || p.hasAbility?(:SWEETVEIL))
      noeffect = true if value==2 && (p.hasType?(:POISON)   || p.hasType?(:STEEL)         || p.hasAbility?(:IMMUNITY)    || p.hasAbility?(:PASTELVEIL))
      noeffect = true if value==3 && (p.hasType?(:FIRE)     || p.hasAbility?(:WATERVEIL)  || p.hasAbility?(:WATERBUBBLE))
      noeffect = true if value==4 && (p.hasType?(:ELECTRIC) || p.hasType?(:GROUND)        || p.hasAbility?(:LIMBER))
      noeffect = true if value==5 && (p.hasType?(:ICE)      || p.hasAbility?(:MAGMAARMOR))
      if noeffect
        pbSEPlay("Mining found all")
        pbMessage(_INTL(text2,p.name))
      else
        p.status      = GameData::Status.get(value).id
        p.statusCount = 2 if value==1
        pbSEPlay("Battle damage normal")
        pbMessage(_INTL(text3,p.name))
      end
    end
  end
end