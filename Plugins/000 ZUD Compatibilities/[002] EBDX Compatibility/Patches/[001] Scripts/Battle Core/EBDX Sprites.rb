#===============================================================================
#  Custom Sprite class used in the Battle Scene
#===============================================================================
if Settings::EBDX_COMPAT  
  class DynamicPokemonSprite
    def setPokemonBitmap(pokemon, back = false, species = nil, actual_pkmn = nil)
      # resets all particles
      self.resetParticles
      # safety check
      return if !pokemon || pokemon.nil?
      @pokemon = pokemon
      @species = species.nil? ? pokemon.species : species
      @form = (@pokemon.form rescue 0)
      @isShadow = true if @pokemon.shadowPokemon?
      # loads Pokemon bitmap
    if actual_pkmn
      scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
      @bitmap = pbLoadPokemonBitmapSpecies(pokemon, species, back, scale, 2, actual_pkmn)
      elsif !species.nil?
        @bitmap = pbLoadPokemonBitmapSpecies(pokemon, species, back)
      else
        @bitmap = pbLoadPokemonBitmap(pokemon, back)
      end
      # applies scale
      @scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
      # gets additional scale (if applicable)
      s = EliteBattle.get_data(species, :Species, (back ? :BACKSCALE : :SCALE), (form rescue 0))
      @scale = s if !s.nil? && s.is_a?(Numeric)
      # assigns bitmap to sprite
      @sprite.bitmap = @bitmap.bitmap.clone
      @shadow.bitmap = @bitmap.bitmap.clone
      # applies battler positioning on screen
      self.refreshMetrics
      # refreshes process variables
      @fainted = false
      @loaded = true
      @hidden = false
      self.visible = true
      @pulse = 8
      @k = 1
      # formats battler shadow
      self.formatShadow
    end
  end
end