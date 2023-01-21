#===============================================================================
# Dynamax Adventure.
#===============================================================================
class DynAdventureState
  attr_accessor :keycount
  attr_accessor :knockouts
  attr_accessor :lairfloor
  attr_accessor :battlecount
  attr_accessor :abandoned
  attr_accessor :bossBattled
  attr_accessor :bossSpecies
  attr_accessor :lastPokemon
  attr_accessor :lairSpecies
  
  # Window skin used for NPC encounter text (not dialogue).
  WINDOWSKIN = "Graphics/Windowskins/sign hgss loc"
  
  def clear
    @keycount    = 0
    @knockouts   = 0
    @lairfloor   = 1
    @battlecount = 0
    @abandoned   = false
    @endlessMode = false
    @inProgress  = false
    @bossBattled = false
    @lastPokemon = nil
    @bossSpecies = nil
    @lairSpecies = []
    @prizes      = []
    @loot        = []
    @party       = []
  end
  
  def initialize
    clear
    @treasure = {
      "Common"    => [:EXPCANDYXS,:EXPCANDYS,:MAXHONEY,
                      :TINYMUSHROOM,:PEARL,:RELICCOPPER,:RELICSILVER,
                      :HEALTHWING,:MUSCLEWING,:RESISTWING,:GENIUSWING,:CLEVERWING,:SWIFTWING,
					  :HEALTHFEATHER,:MUSCLEFEATHER,:RESISTFEATHER,:GENIUSFEATHER,:CLEVERFEATHER,:SWIFTFEATHER,
                      :LEAFSTONE,:FIRESTONE,:WATERSTONE,:EVERSTONE
                     ],
      "Uncommon"  => [:EXPCANDYM,:DYNAMAXCANDY,:MAXMUSHROOMS,:WISHINGPIECE,
                      :BIGPEARL,:BIGMUSHROOM,:NUGGET,:RELICGOLD,:RELICVASE,
                      :POMEGBERRY,:KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY,
                      :MOONSTONE,:SUNSTONE,:THUNDERSTONE,:ICESTONE
                     ],  
      "Rare"      => [:EXPCANDYL,:RARECANDY,:MAXSCALES,:MAXPLUMAGE,
                      :BALMMUSHROOM,:RELICBAND,:RELICSTATUE,
                      :HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS,
                      :PPUP,:BOTTLECAP,:ABILITYCAPSULE,
                      :DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:KINGSROCK
                     ],
      "Very Rare" => [:EXPCANDYXL,:DYNAMAXCANDYXL,:MAXSOUP,:MAXEGGS,:MAXCRYSTAL,
                      :BIGNUGGET,:PEARLSTRING,:RELICCROWN,
                      :POWERWEIGHT,:POWERBRACER,:POWERBELT,:POWERLENS,:POWERBAND,:POWERANKLET,
                      :PPMAX,:BOTTLECAP,:GOLDBOTTLECAP,:ABILITYCAPSULE,:ABILITYPATCH,
                      :DESTINYKNOT
                     ] 
    }
  end
  
  def endlessMode?; return @endlessMode;  end
  def inProgress?;  return @inProgress;   end
  def abandoned?;   return @abandoned;    end
  def completed?;   return @bossBattled;  end
  def defeated?;    return @knockouts<=0; end
  def victory?;     return (completed? && !defeated?); end
  def ended?;       return (completed? || defeated? || abandoned?);  end
    
  #-----------------------------------------------------------------------------
  # Sets up the encounters in a Max Lair.
  #-----------------------------------------------------------------------------
  def pbGenerateLairSpecies
    pbSetRaidRanks if !$PokemonTemp.raidTotal
    for i in [3,4,5,6]
      lairpkmn = []
      raidrank = pbRaidRank(i)
      speciesA = raidrank[rand(raidrank.length)]
      speciesB = raidrank[rand(raidrank.length)]
      speciesC = raidrank[rand(raidrank.length)]
      speciesD = raidrank[rand(raidrank.length)]
      if i==6
        @bossSpecies = (@bossSpecies) ? @bossSpecies : speciesA
        @lairSpecies.push(@bossSpecies)
      else
        @lairSpecies.push(speciesA)
        @lairSpecies.push(speciesB)
        @lairSpecies.push(speciesC) if i>3
        @lairSpecies.push(speciesD) if i>3
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Initiates the party exchange screen upon capturing a Pokemon in a Max Lair.
  #-----------------------------------------------------------------------------
  def pbSwap
    @prizes.push(@lastPokemon)
    if @prizes.length>6; @prizes.delete_at(0); end
    randev = 1+rand(6)
    if randev==6
      GameData::Stat.each_main { |s| @lastPokemon.ev[s.id] = 50 }
    else
      stat = GameData::Stat.get(randev).id
      @lastPokemon.ev[stat] = 252
    end
    @lastPokemon.ev[:HP] = 252
    @lastPokemon.calc_stats
    return if ended?
    return if !inProgress?
    pbMaxLairMenu([1,@lastPokemon]) if !completed?
  end
  
  #-----------------------------------------------------------------------------
  # Initiates the prize screen at the end of a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbPrize
    return if !inProgress?
    return if @prizes.length==0
    shinycharm = (GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM))
    odds = (shinycharm) ? 100 : 300
    for poke in @prizes
      poke.item = nil
      poke.reset_moves
      poke.shiny = true if rand(odds)==1
      GameData::Stat.each_main { |s| poke.ev[s.id] = 0 }
      poke.heal
    end
    pbMaxLairMenu([2,@prizes])
  end
  
  #-----------------------------------------------------------------------------
  # Begins a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbStart(map=0)
    return if inProgress?
    initialize
    size    = (Settings::EMBS_COMPAT) ? 4 : 3
    baselvl = 10
    for i in 1...$Trainer.badge_count
      baselvl += 10
      break if baselvl>=60
    end
    baselvl +=5 if $Trainer.badge_count >0
    if pbConfirmMessage(_INTL("Would you like to embark on a Dynamax Adventure?"))
      #-------------------------------------------------------------------------
      # Adventure Selection; Saved routes detected.
      #-------------------------------------------------------------------------
      if pbSavedLairRoutes.length >0
        pbMessage(_INTL("According to my notes, it seems you might know how to find certain special Pokémon."))
        text = _INTL("Which type of adventure are you interested in today?")
        list = []
        for i in pbSavedLairRoutes
          list.push(_INTL("Find {1}!",GameData::Species.get(i).name))
        end
        list.push(_INTL("Normal Adventure"))
        list.push(_INTL("Endless Adventure"))
        list.push(_INTL("View Record")) if pbEndlessLairRecord[0] > 1
        loop do
          cmd = pbMessage(text,list,-1,nil,0)
          break if cmd==-1
          case list[cmd]
          when "Normal Adventure"
            @inProgress  = true
            break
          when "Endless Adventure"
            @inProgress  = true
            @endlessMode = true
            break
          when "View Record"
            pbMaxLairMenu([7],pbEndlessLairRecord[2].length)
          else
            @inProgress  = true
            @bossSpecies = pbSavedLairRoutes[cmd]
            break
          end
        end
      else
        #-----------------------------------------------------------------------
        # Adventure Selection; No saved routes.
        #-----------------------------------------------------------------------
        list = ["Normal Adventure","Endless Adventure"]
        list.push(_INTL("View Record")) if pbEndlessLairRecord[0] > 1
        loop do
          cmd = pbMessage(_INTL("Which type of adventure are you interested in today?"),list,-1,nil,0)
          break if cmd==-1
          case list[cmd]
          when "Normal Adventure"
            @inProgress  = true
            break
          when "Endless Adventure"
            @inProgress  = true
            @endlessMode = true
            break
          when "View Record"
            pbMaxLairMenu([7],pbEndlessLairRecord[2].length)
          end
        end
      end
      if inProgress?
        for i in $Trainer.party; @party.push(i); end
        pbMaxLairMenu([0,size,baselvl])
        #-----------------------------------------------------------------------
        # Exited the Rental Screen; Adventure ends.
        #-----------------------------------------------------------------------
        if $Trainer.party==@party
          clear
          pbMessage(_INTL("I hope we'll see you again soon!"))
        else
          #---------------------------------------------------------------------
          # Adventure Begins
          #---------------------------------------------------------------------
          if @bossSpecies
            boss_name = GameData::Species.get(@bossSpecies).name
            pbMessage(_INTL("Good luck on your search for {1}!",boss_name)) 
          else
            pbMessage(_INTL("Good luck on your adventure!"))
          end
          pbSEPlay("Door enter")
          @knockouts  = $Trainer.party.length
          previousBGM = $game_system.getPlayingBGM
          pbFadeOutInWithMusic { 
            loop do
              @lairSpecies.clear
              pbGenerateLairSpecies
              pbMaxLairMap(map) 
              break if ended?
            end
            pbWait(25)
            if endlessMode? && !abandoned?
              @recordteam = $Trainer.party
            end
            $Trainer.party = @party
            pbPrize if @prizes.length>0 && ended?
          }
          #---------------------------------------------------------------------
          # Adventure Ends.
          #---------------------------------------------------------------------
          pbBGMPlay(previousBGM)
          pbEnd
        end
      else
        #-----------------------------------------------------------------------
        # Backed out of the Adventure selection; Adventure ends.
        #-----------------------------------------------------------------------
        pbMessage(_INTL("I hope we'll see you again soon!"))
      end
    else
      #-----------------------------------------------------------------------
      # Declined to begin Adventure; Adventure ends.
      #-----------------------------------------------------------------------
      pbMessage(_INTL("I hope we'll see you again soon!"))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Adds any collected Treasure during your Adventure to the bag.
  #-----------------------------------------------------------------------------
  def pbAddTreasure
    @loot.compact!
    if @loot.length>0
      pbMessage(_INTL("I'll add any treasure you acquired during your adventure to your bag."))
      for i in @loot
        $PokemonBag.pbStoreItem(i,1)
      end
    end
    pbMessage(_INTL("I hope we'll see you again soon!"))
  end
  
  #-----------------------------------------------------------------------------
  # Ends a Dynamax Adventure.
  #-----------------------------------------------------------------------------
  def pbEnd
    return if !inProgress?
    #---------------------------------------------------------------------------
    # Adventure Ended; Abandoned
    #---------------------------------------------------------------------------
    if abandoned?
      pbMessage(_INTL("Huh, you're giving up?\nPlease come back any time for a new adventure!"))
    #---------------------------------------------------------------------------
    # Adventure Ended; Endless Mode
    #---------------------------------------------------------------------------
    elsif endlessMode?
      if @lairfloor > pbEndlessLairRecord[0]
        pbMessage(_INTL("Now THAT is what I call a fine performance! You set a new record! I keep track, you know."))
        $PokemonGlobal.endlessAdvRecord[0] = @lairfloor
        $PokemonGlobal.endlessAdvRecord[1] = @battlecount
        $PokemonGlobal.endlessAdvRecord[2] = @recordteam
        pbMaxLairMenu([7],@recordteam.length)
      else
        pbMessage(_INTL("Didn't make it quite far this time, eh?\nThat's ok, better luck next time!"))
      end
      pbAddTreasure
    #---------------------------------------------------------------------------
    # Adventure Ended; Defeat
    #---------------------------------------------------------------------------
    elsif defeated?
      bossname = GameData::Species.get(@bossSpecies).name
      for i in pbSavedLairRoutes; marked = true if i==@bossSpecies; end
      pbMessage(_INTL("Well done facing such a tough opponent!\nVictory seemed so close - I could almost taste it!"))      
      if @bossBattled && !marked && 
         pbConfirmMessage(_INTL("Would you like me to jot down where you found {1} this time so that you might find it again?",bossname))
        if pbSavedLairRoutes.length>=3
          pbMessage(_INTL("You already have the maximum number of routes saved..."))
          if pbConfirmMessage(_INTL("Would you like to replace an existing route?"))
            text = _INTL("Which route should be replaced?")
            list = []
            for i in pbSavedLairRoutes; list.push(GameData::Species.get(i).name); end
            list.push(_INTL("Nevermind"))
            loop do
              Input.update
              cmd = 0
              cmd = pbMessage(text,list,-1,nil,0)
              case cmd
              when -1, list.length-1; break
              else
                $PokemonGlobal.markedAdvRoutes.delete_at(cmd)
                $PokemonGlobal.markedAdvRoutes.push(@bossSpecies)
                pbMessage(_INTL("The route to {1} was saved for future reference.",bossname))
                break
              end
            end
          end
        else 
          $PokemonGlobal.markedAdvRoutes.push(@bossSpecies)
          pbMessage(_INTL("The route to {1} was saved for future reference.",bossname))
        end
      end
      pbAddTreasure
    #---------------------------------------------------------------------------
    # Adventure Ended; Victory
    #---------------------------------------------------------------------------
    elsif victory?
      for i in 0...pbSavedLairRoutes.length
        $PokemonGlobal.markedAdvRoutes.delete_at(i) if @bossSpecies==pbSavedLairRoutes[i]
      end
      pbMessage(_INTL("Well done defeating that tough opponent!"))
      pbAddTreasure
    end
    clear
  end
end

#===============================================================================
# Various utilities used for Dynamax Adventure functions.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :markedAdvRoutes
  attr_accessor :endlessAdvRecord
  attr_accessor :dynAdventureState
  
  alias _ZUD_initialize initialize
  def initialize
    @markedAdvRoutes   = []
    @endlessAdvRecord  = [1,0,nil]
    @dynAdventureState = nil
    _ZUD_initialize
  end
end

def pbSavedLairRoutes
  if !$PokemonGlobal.markedAdvRoutes
    $PokemonGlobal.markedAdvRoutes = []
  end
  return $PokemonGlobal.markedAdvRoutes
end

def pbEndlessLairRecord
  if !$PokemonGlobal.endlessAdvRecord
    $PokemonGlobal.endlessAdvRecord = [1,0,nil]
  end
  return $PokemonGlobal.endlessAdvRecord
end

def pbDynAdventureState
  if !$PokemonGlobal.dynAdventureState
    $PokemonGlobal.dynAdventureState = DynAdventureState.new
  end
  return $PokemonGlobal.dynAdventureState
end

def pbInDynAdventure?
  return pbDynAdventureState.inProgress?
end

#-------------------------------------------------------------------------------
# Creates a rental Pokemon.
#-------------------------------------------------------------------------------
def pbGetMaxLairRental(rank, level, trainer)
  pbSetRaidRanks if !$PokemonTemp.raidTotal
  raidrank = pbRaidRank(rank)
  species  = raidrank[rand(raidrank.length)]
  pokemon  = Pokemon.new(species,level,trainer,true)
  pokemon.happiness = 0
  pokemon.setDynamaxLvl(5)
  pokemon.giveGMaxFactor if pokemon.hasGmax? && rand(10)<5
  raidmoves = pbMaxRaidMovelists(species,true)
  move1     = raidmoves[0][rand(raidmoves[0].length)]
  move2     = raidmoves[1][rand(raidmoves[1].length)]
  move3     = raidmoves[2][rand(raidmoves[2].length)]
  move4     = raidmoves[3][rand(raidmoves[3].length)]
  pokemon.learn_move(move1) if raidmoves[0].length>0
  pokemon.learn_move(move2) if raidmoves[1].length>0
  pokemon.learn_move(move3) if raidmoves[2].length>0
  pokemon.learn_move(move4) if raidmoves[3].length>0
  pbCustomRaidSets(pokemon, pokemon.form)
  pokemon.item = nil
  pokemon.item = :ORANBERRY   if rand(100)<25
  pokemon.item = :SITRUSBERRY if rand(100)<5
  pokemon.ability_index = rand(pokemon.getAbilityList.length)
  randev = 1+rand(6)
  if randev==6
    GameData::Stat.each_main { |s| pokemon.ev[s.id] = 50 }
  else
    stat = GameData::Stat.get(randev).id
    pokemon.ev[stat] = 252
  end
  pokemon.ev[:HP] = 252
  pokemon.obtain_text = _INTL("Max Lair Rental.")
  pokemon.calc_stats
  return pokemon
end

#===============================================================================
# Handles the battle class during a Dynamax Adventure.
#===============================================================================
Events.onWildBattleOverride += proc { |_sender,e|
  handled = e[2]
  next if handled[0]!=nil
  next if !pbInDynAdventure?
  species = $game_variables[Settings::MAXRAID_PKMN][0]
  form    = $game_variables[Settings::MAXRAID_PKMN][1]
  level   = $game_variables[Settings::MAXRAID_PKMN][3]
  pokemon = GameData::Species.get_species_form(species, form)
  maxsize = (Settings::EMBS_COMPAT) ? 5 : 3
  size    = ($Trainer.party.length<=maxsize) ? $Trainer.party.length : 1
  $PokemonSystem.activebattle = true if size>3 && Settings::EMBS_COMPAT
  handled[0] = pbMaxLairBattle(size,pokemon,level)
}

def pbMaxLairBattle(size, pokemon, level)
  Events.onStartBattle.trigger(nil)
  pkmn = pbGenerateWildPokemon(pokemon,level)
  foeParty          = [pkmn]
  playerTrainer     = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  scene   = pbNewBattleScene
  battle  = PokeBattle_MaxLairBattle.new(scene,playerParty,foeParty,playerTrainer,nil)
  battle.party1starts = playerPartyStarts
  baselvl = $Trainer.party[0].level
  $PokemonGlobal.nextBattleBGM = (level==(baselvl+5)) ? "Battle! Legendary Raid" : "Battle! Max Raid"
  $PokemonGlobal.nextBattleBGM = "Battle! Eternatus - Phase 2" if pokemon==:ETERNATUS
  setBattleRule("canlose")
  setBattleRule("cannotrun")
  setBattleRule("noexp")
  setBattleRule("nomoney")
  setBattleRule("nopartner")
  setBattleRule("environ",:Cave)
  setBattleRule("base","cave3")
  setBattleRule("backdrop","cave3")
  setBattleRule(sprintf("%dv%d",size,1))
  EliteBattle.set(:nextBattleBack, :DARKCAVE) if Settings::EBDX_COMPAT
  pbPrepareBattle(battle)
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),0,foeParty) {
    decision = battle.pbStartBattle
    pbAfterBattle(decision,true)
    $Trainer.party.each do |pkmn|
      pkmn.heal if pkmn.fainted?
      pkmn.makeUnmega
      pkmn.makeUnprimal
      pkmn.makeUnUltra
    end
  }
  Input.update
  pbSet(1,decision)
  pbDynAdventureState.battlecount += 1 if decision==1 || decision==4
  Events.onWildBattleEnd.trigger(nil,pokemon,level,decision)
  return (decision==1 || decision==4)
end

#-------------------------------------------------------------------------------
# Initiates swap screen upon capturing a Pokemon in a Max Lair.
#-------------------------------------------------------------------------------
class PokeBattle_MaxLairBattle < PokeBattle_Battle
  def pbStorePokemon(pkmn)
    pkmn.heal
    pbResetRaidPokemon(pkmn)
    pbDynAdventureState.lastPokemon = pkmn
    pbDisplay(_INTL("Caught {1}!",pkmn.name))
    pbDynAdventureState.pbSwap
  end
end