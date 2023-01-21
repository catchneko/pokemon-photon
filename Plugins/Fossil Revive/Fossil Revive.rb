module GameData
  class Item
    def is_fossilB?;          return @type == 13;end
  end
end

FOSSIL       = 9  #Fossil being revived
FOSSIL_LEVEL = 20 #Level at which Fossil Pokemon are revived. 
Fossil_hash  = {
  :HELIXFOSSIL                    => :OMANYTE,
  :DOMEFOSSIL                     => :KABUTO,
  :OLDAMBER                       => :AERODACTYL,
  :ROOTFOSSIL                     => :LILEEP,
  :CLAWFOSSIL                     => :ANORITH,
  :SKULLFOSSIL                    => :CRANIDOS,
  :ARMORFOSSIL                    => :SHIELDON,
  :COVERFOSSIL                    => :TIRTOUGA,
  :PLUMEFOSSIL                    => :ARCHEN,
  :JAWFOSSIL                      => :TYRUNT,
  :SAILFOSSIL                     => :AMAURA,
  "FOSSILIZEDBIRDFOSSILIZEDDRAKE" => :DRACOZOLT,
  "FOSSILIZEDBIRDFOSSILIZEDDINO"  => :ARCTOZOLT,
  "FOSSILIZEDFISHFOSSILIZEDDRAKE" => :DRACOVISH,
  "FOSSILIZEDFISHFOSSILIZEDDINO"  => :ARCTOVISH,
  :FOSSILIZEDBIRD                 => nil,
  :FOSSILIZEDFISH                 => nil,
  nil                             => nil
}

def pbReviveFossil
 $game_variables[FOSSIL] = [0,0]
  pbFadeOutIn {
    scene = PokemonBag_Scene.new
    screen = PokemonBagScreen.new(scene,$PokemonBag)
    $game_variables[FOSSIL][0] = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_fossil? })
  }
  if $game_variables[FOSSIL][0] == :FOSSILIZEDBIRD || $game_variables[FOSSIL][0] == :FOSSILIZEDFISH
    pbMessage("This appears to only be half of a fossil, do you have the other half?")
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$PokemonBag)
      $game_variables[FOSSIL][1] = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_fossilB? })
    }
      if $game_variables[FOSSIL][1] == nil
        pbMessage("I will return your fossil then.")
      else 
        pbMessage("Please wait as I revive your fossil.")
        pbFadeOutIn {pbWait(60)} 
        pbMessage("Your Pokémon has been fully revived!")
        pbAddPokemon(Fossil_hash.fetch($game_variables[FOSSIL][0].to_s + $game_variables[FOSSIL][1].to_s),FOSSIL_LEVEL)
        $PokemonBag.pbDeleteItem($game_variables[FOSSIL][0],1)
        $PokemonBag.pbDeleteItem($game_variables[FOSSIL][1],1)
      end
  elsif $game_variables[FOSSIL][0] == nil
    pbMessage("You did not select a fossil.")
  else
    pbMessage("Please wait as I revive your fossil.")
    pbFadeOutIn {pbWait(60)} 
    pbMessage("Your Pokémon has been fully revived!")
    pbAddPokemon(Fossil_hash.fetch($game_variables[FOSSIL][0]),FOSSIL_LEVEL)
    $PokemonBag.pbDeleteItem($game_variables[FOSSIL][0],1)
  end
end