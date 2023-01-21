#===============================================================================
#  additional functions for quick access to proper objects
#===============================================================================
if Settings::EBDX_COMPAT  
  def playBattlerCry(battler)
    pokemon = battler.displayPokemon
    pokemon = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    cry = GameData::Species.cry_filename_from_pokemon(pokemon)
    cry = GameData::Species.play_cry_from_pokemon(pokemon) if @battle.scene.sprites["pokemon_#{battler.index}"].dynamax
    pbSEPlay(cry)
  end
end