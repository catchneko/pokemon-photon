#===============================================================================
#  Loads an animated BitmapWrapper for Pokemon species
#===============================================================================
if Settings::EBDX_COMPAT  
  def pbLoadPokemonBitmapSpecies(pokemon, species, back = false, scale = EliteBattle::FRONT_SPRITE_SCALE, speed = 2, actual_pkmn = nil)
    ret = nil
    pokemon = pokemon.pokemon if pokemon.respond_to?(:pokemon)
    species = pokemon.species if species.nil? && pokemon.respond_to?(:species)
    # sauce
    species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    # return question marks if no species provided
    return BitmapEBDX.new("Graphics/EBDX/Battlers/000", scale) if species.nil?
    #-------------------------------------------------------------------------------
    gmax = false
    if actual_pkmn
    gmax = actual_pkmn.gmax?
    else
    gmax = pokemon.gmax?
    end
    #-------------------------------------------------------------------------------
    # applies scale
    scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
    # gets additional scale (if applicable)
    s = EliteBattle.get_data(species, :Species, (back ? :BACKSCALE : :SCALE), (pokemon.form rescue 0))
    scale = s if !s.nil? && s.is_a?(Numeric)
    # get more metrics
    s = EliteBattle.get_data(species, :Species, :SPRITESPEED, (pokemon.form rescue 0))
    speed = s if !s.nil? && s.is_a?(Numeric)
    if pokemon.egg?
      bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%s", species) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%03d", GameData::Species.get(species).id_number)
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/000")
        end
      end
      bitmapFileName = pbResolveBitmap(bitmapFileName)
    else
      shiny = pokemon.shiny?
      shiny = pokemon.superVariant if (!pokemon.superVariant.nil? && pokemon.superShiny?)
      params = [species, back, pokemon.female?, shiny, (pokemon.form rescue 0), (pokemon.shadowPokemon? rescue false), false, gmax]
      bitmapFileName = pbCheckPokemonBitmapFiles(params)
    end
    if bitmapFileName.nil?
      bitmapFileName = "Graphics/EBDX/Battlers/000"
      EliteBattle.log.warn(missingPokeSpriteError(pokemon, back))
    end
    animatedBitmap = BitmapEBDX.new(bitmapFileName, scale, speed) if bitmapFileName
    ret = animatedBitmap if bitmapFileName
    # Full compatibility with the alterBitmap methods is maintained
    # but unless the alterBitmap method gets rewritten and sprite animations get
    # hardcoded in the system, the bitmap alterations will not function properly
    # as they will not account for the sprite animation itself
  
    # alterBitmap methods for static sprites will work just fine
    alterBitmap = (MultipleForms.getFunction(species, "alterBitmap") rescue nil) if !pokemon.egg? && animatedBitmap && animatedBitmap.totalFrames == 1 # remove this totalFrames clause to allow for dynamic sprites too
    if bitmapFileName && alterBitmap
      animatedBitmap.prepare_strip
      for i in 0...animatedBitmap.totalFrames
        alterBitmap.call(pokemon, animatedBitmap.alter_bitmap(i))
      end
      animatedBitmap.compile_strip
      ret = animatedBitmap
    end
    # adjusts for custom animation loops
    data = EliteBattle.get_data(species, :Species, :FRAMEANIMATION, (pokemon.form rescue 0))
    unless data.nil?
      ret.compile_loop(data)
    end
    # applies super shiny hue
    ret.hue_change(pokemon.superHue) if pokemon.superHue && !ret.changedHue?
    # refreshes bitmap
    ret.deanimate if ret.respond_to?(:deanimate)
    return ret
  end
  
#===============================================================================
#  Loads animated BitmapWrapper for species
#===============================================================================
  def pbLoadSpeciesBitmap(species, female=false, form=0, shiny=false, shadow=false, back=false, egg=false, scale=EliteBattle::FRONT_SPRITE_SCALE, 
                          dmax=false, gmax=false)
    ret = nil
    species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    # return question marks if no species provided
    return BitmapEBDX.new("Graphics/EBDX/Battlers/000", scale) if species.nil?
    # applies scale
    scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
    # gets additional scale (if applicable)
    s = EliteBattle.get_data(species, :Species, (back ? :BACKSCALE : :SCALE), (form rescue 0))
    scale = s if !s.nil? && s.is_a?(Numeric)
    # check sprite
    if egg
      bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%s", species) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/%03d", GameData::Species.get(species).id_number)
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/EBDX/Battlers/Eggs/000")
        end
      end
      bitmapFileName = pbResolveBitmap(bitmapFileName)
    else
      bitmapFileName = pbCheckPokemonBitmapFiles([species, back, female, shiny, form, shadow, dmax, gmax])
    end
    if bitmapFileName
      ret = BitmapEBDX.new(bitmapFileName, scale)
    end
    # adjusts for custom animation loops
    data = EliteBattle.get_data(species, :Species, :FRAMEANIMATION, form)
    unless data.nil?
      ret.compile_loop(data)
    end
    # refreshes bitmap
    ret.deanimate if ret.respond_to?(:deanimate)
    return ret
  end
  
#===============================================================================
#  Game data overrides
#===============================================================================
  module GameData
    class Species
      #---------------------------------------------------------------------------
      #  get bitmap from species
      #---------------------------------------------------------------------------
      def self.sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false, gmax = false)
      scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
        return pbLoadSpeciesBitmap(species, (gender == 1), form, shiny, shadow, back, egg, scale, false, gmax)
      end
      #---------------------------------------------------------------------------
      #  get bitmap from Pokemon
      #---------------------------------------------------------------------------
      def self.sprite_bitmap_from_pokemon(pokemon, back = false, species = nil, actual_pkmn = nil)
      scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
        return pbLoadPokemonBitmapSpecies(pokemon, species, back, scale, 2, actual_pkmn)
      end
    end
  end
end