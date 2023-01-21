class PokeBattle_Pokemon
# Creates a new Pokémon object.
#    species   - Pokémon species.
#    level     - Pokémon level.
#    player    - PokeBattle_Trainer object for the original trainer.
#    withMoves - If false, this Pokémon has no moves.
  def initialize(species,level,player=nil,withMoves=true)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end

    ogBST = $pkmn_dex[species][5].sum

    species = rand(0..(PBSpecies.maxValue-1))
    randBST = $pkmn_dex[species][5].sum
    
    while ((ogBST - randBST).abs >= 50)
      species = rand(0..(PBSpecies.maxValue-1))
      randBST = $pkmn_dex[species][5].sum
    end
    
    cname=getConstantName(PBSpecies,species) rescue nil
    if !species || species<1 || species>PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("The species number (no. {1} of {2}) is invalid.",
         species,PBSpecies.maxValue))
      return nil
    end
    group1=$pkmn_dex[species][13][0]
    group2=$pkmn_dex[species][13][1]
    time=pbGetTimeNow
    @timeReceived=time.getgm.to_i # Use GMT
    @species=species
    # Individual Values
    @personalID=rand(256)
    @personalID|=rand(256)<<8
    @personalID|=rand(256)<<16
    @personalID|=rand(256)<<24
    @hp=1
    @totalhp=1
    @ev=[0,0,0,0,0,0]
    @obhp=0
    @obatk=0
    @obdef=0    
    @obspe=0
    @obspa=0
    @obspd=0    
    @iv=[]
    if !(group1==15 || group2==15)
      @iv[0]=rand(32)
      @iv[1]=rand(32)
      @iv[2]=rand(32)
      @iv[3]=rand(32)
      @iv[4]=rand(32)
      @iv[5]=rand(32)
    else
      stat1=rand(6)
      stat2=rand(6)
      stat3=rand(6)
      while stat1==stat2 do stat2=rand(6)
      end
      while (stat1==stat3) || (stat2==stat3) do stat3=rand(6)
      end
      for i in 0..5
        if i==stat1
          @iv[i]=31
        elsif i==stat2
          @iv[i]=31
        elsif i==stat3
          @iv[i]=31
        else      
          @iv[i]=rand(32)
        end
      end
    end
    if player
      @trainerID=player.id
      @ot=player.name
      @otgender=player.gender
      @language=player.language
    else
      @trainerID=0
      @ot=""
      @otgender=2
    end
    @happiness=$pkmn_dex[@species][8]
    @name=PBSpecies.getName(@species)
    @eggsteps=0
    @status=0
    @critted=false
    @statusCount=0
    @item=0
    @mail=nil
    @fused=nil
    @ribbons=[]
    @moves=[]
    self.ballused=0
    self.level=level
    @poklevel = level
    calcStats
    @hp=@totalhp
    if $game_map
      @obtainMap=$game_map.map_id
      @obtainText=nil
      @obtainLevel=level
    else
      @obtainMap=0
      @obtainText=nil
      @obtainLevel=level
    end
    @obtainMode=0   # Met
    @obtainMode=4 if $game_switches && $game_switches[FATEFUL_ENCOUNTER_SWITCH]
    @hatchedMap=0
    if withMoves
      $pkmn_moves = load_data("Data/attacksRS.rxdata") if !$pkmn_moves
      # Generating move list
      movelist=[]
      for k in 0...$pkmn_moves[species].length
        alevel=$pkmn_moves[species][k][0]
        move=$pkmn_moves[species][k][1]
        if alevel<=level
          movelist[k]=move
        end
      end
      movelist|=[] # Remove duplicates
      # Use the last 4 items in the move list
      listend=movelist.length-4
      listend=0 if listend<0
      j=0
      for i in listend...listend+4
        moveid=(i>=movelist.length) ? 0 : movelist[i]
        @moves[j]=PBMove.new(moveid)
        j+=1
      end
    end
  end
end