module GameData
  class Species
    attr_accessor :habitat                                       # Allows Habitat data to be rewritten.
    attr_reader   :no_dynamax                                    # Flags a species as unable to Dynamax.
    attr_accessor :dmax_metrics, :gmax_metrics                   # Species metric data while Dynamaxed.
    attr_accessor :gmax_height, :real_gmax_name, :real_gmax_dex  # Species G-Max Pokedex data.

    alias _ZUD_initialize initialize
    def initialize(hash)
      _ZUD_initialize(hash)
      @gmax_height    = nil
      @real_gmax_name = nil
      @real_gmax_dex  = nil
      @no_dynamax     = ([:ZACIAN,:ZAMAZENTA,:ETERNATUS].include?(@species)) ? true : false
      base_metrics    = [@back_sprite_x, @back_sprite_y, @front_sprite_x, @front_sprite_y,
                         @front_sprite_altitude, @shadow_x, @shadow_size]
      @dmax_metrics   = base_metrics if !@dmax_metrics
      @gmax_metrics   = base_metrics if !@gmax_metrics
    end

    #---------------------------------------------------------------------------
    # Gets the form number from a species ID.
    #---------------------------------------------------------------------------
    def self.get_form(species)
      return nil if !exists?(species)
      if species.to_s.include?("_")
        form = ""
        form_num = []
        spec_id  = species.to_s.reverse
        for i in 0...spec_id.length
          break if spec_id[i]=="_"
          form_num.push(spec_id[i])
        end
        if form_num.length>1
          for i in form_num.reverse; form+=i; end
        else
          form = form_num[0]
        end
        form = form.to_i
      else
        form = 0
      end
      return form
    end

    #---------------------------------------------------------------------------
    # Gets G-Max messages.
    #---------------------------------------------------------------------------
    def gmax_form_name
      return pbGetMessage(MessageTypes::GMaxNames, @id_number)
    end

    def gmax_dex_entry
      return pbGetMessage(MessageTypes::GMaxEntries, @id_number)
    end

    #---------------------------------------------------------------------------
    # Determines if a species is capable of Gigantamaxing.
    #---------------------------------------------------------------------------
    def hasGmax?
      return true if @id==:ALCREMIE || @id==:ETERNATUS
      return false if @no_dynamax
      species_list = GameData::PowerMove.species_list(2)
      for i in species_list
        return true if i==@id
      end
      return false
    end

    #---------------------------------------------------------------------------
    # Applies G-Max or Dynamax metrics if necessary, otherwise applies default.
    #---------------------------------------------------------------------------
    def apply_metrics_to_sprite(sprite, index, shadow = false, dynamax = nil)
      if dynamax && Settings::DYNAMAX_SIZE
        metrics = (dynamax==1) ? @gmax_metrics : @dmax_metrics
      else
        metrics = [@back_sprite_x, @back_sprite_y, @front_sprite_x, @front_sprite_y,
                   @front_sprite_altitude, @shadow_x, @shadow_size]
      end
      if shadow
        if (index & 1) == 1   # Foe Pokémon
          sprite.x += metrics[5] * 2
        end
      else
        if (index & 1) == 0   # Player's Pokémon
          sprite.x += metrics[0] * 2
          sprite.y += metrics[1] * 2
        else                  # Foe Pokémon
          sprite.x += metrics[2] * 2
          sprite.y += metrics[3] * 2
          sprite.y -= metrics[4] * 2
        end
      end
    end

    #---------------------------------------------------------------------------
    # Adds G-Max values to Pokemon battler sprite pathways.
    #---------------------------------------------------------------------------
    def self.check_graphic_file(path, species, form = 0, gender = 0, shiny = false, shadow = false, subfolder = "", gmax = false)
      try_subfolder = sprintf("%s/", subfolder)
      try_species = species
      try_form    = (form > 0) ? sprintf("_%d", form) : ""
      try_gender  = (gender == 1) ? "_female" : ""
      try_shadow  = (shadow) ? "_shadow" : ""
      try_gmax    = (gmax) ? "_gmax" : ""
      factors = []
      factors.push([5, sprintf("%s shiny/", subfolder), try_subfolder]) if shiny
      factors.push([4, try_gmax, ""]) if gmax
      factors.push([3, try_shadow, ""]) if shadow
      factors.push([2, try_gender, ""]) if gender == 1
      factors.push([1, try_form, ""]) if form > 0
      factors.push([0, try_species, "000"])
      for i in 0...2 ** factors.length
        factors.each_with_index do |factor, index|
          value = ((i / (2 ** index)) % 2 == 0) ? factor[1] : factor[2]
          case factor[0]
          when 0 then try_species   = value
          when 1 then try_form      = value
          when 2 then try_gender    = value
          when 3 then try_shadow    = value
          when 4 then try_gmax      = value
          when 5 then try_subfolder = value
          end
        end
        try_species_text = try_species
        ret = pbResolveBitmap(sprintf("%s%s%s%s%s%s%s", path, try_subfolder,
           try_species_text, try_form, try_gender, try_shadow, try_gmax))
        return ret if ret
      end
      return nil
    end

    #---------------------------------------------------------------------------
    # Gets a sprite file name.
    #---------------------------------------------------------------------------
    def self.front_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false, gmax = false)
      return self.check_graphic_file("Graphics/Pokemon/", species, form, gender, shiny, shadow, "Front", gmax)
    end

    def self.back_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false, gmax = false)
      return self.check_graphic_file("Graphics/Pokemon/", species, form, gender, shiny, shadow, "Back", gmax)
    end

    def self.sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false, gmax = false)
      return self.egg_sprite_filename(species, form) if egg
      return self.back_sprite_filename(species, form, gender, shiny, shadow, gmax) if back
      return self.front_sprite_filename(species, form, gender, shiny, shadow, gmax)
    end

    #---------------------------------------------------------------------------
    # Sets a sprite bitmap.
    #---------------------------------------------------------------------------
    def self.front_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, gmax = false)
      filename = self.front_sprite_filename(species, form, gender, shiny, shadow, gmax)
      if Settings::GEN8_COMPAT && !defined?(EliteBattle)
	    sp_data  = GameData::Species.get_species_form(species, form)
        scale    = (sp_data && defined?(sp_data.front_sprite_scale)) ? sp_data.front_sprite_scale : Settings::FRONT_BATTLER_SPRITE_SCALE
        return (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
      else
        return (filename) ? AnimatedBitmap.new(filename) : nil
      end
    end

    def self.back_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, gmax = false)
      filename = self.back_sprite_filename(species, form, gender, shiny, shadow, gmax)
      if Settings::GEN8_COMPAT && !defined?(EliteBattle)
	    sp_data  = GameData::Species.get_species_form(species, form)
        scale    = (sp_data && defined?(sp_data.back_sprite_scale)) ? sp_data.back_sprite_scale : Settings::BACK_BATTLER_SPRITE_SCALE
        return (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
      else
        return (filename) ? AnimatedBitmap.new(filename) : nil
      end
    end

    def self.sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false, gmax = false)
	  return pbLoadSpeciesBitmap(species, (gender == 1), form, shiny, shadow, back, egg, gmax) if Settings::EBDX_COMPAT
      return self.egg_sprite_bitmap(species, form) if egg
      return self.back_sprite_bitmap(species, form, gender, shiny, shadow, gmax) if back
      return self.front_sprite_bitmap(species, form, gender, shiny, shadow, gmax)
    end

    def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil, actual_pkmn = nil)
      species = pkmn.species if !species
      species = GameData::Species.get(species).species
	  return pbLoadPokemonBitmapSpecies(pkmn, species, back, EliteBattle::FRONT_SPRITE_SCALE, 2, actual_pkmn) if Settings::EBDX_COMPAT
      return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
      gmax = false
      if actual_pkmn
        gmax = (actual_pkmn.gmaxFactor? && actual_pkmn.dynamax? && pkmn.dynamax?) ? true : false
      else
        gmax = pkmn.gmax?
      end
      if back
        ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, gmax)
      else
        ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, gmax)
      end
	  alter_bitmap_function = nil
      alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap") if ret && ret.totalFrames == 1
      if ret && alter_bitmap_function
        if ret.is_a?(EBDXBitmapWrapper) && ret.totalFrames == 1
          ret.prepare_strip
          for i in 0...ret.totalFrames
            alter_bitmap_function.call(pkmn, ret.alter_bitmap(i))
          end
          ret.compile_strip
        else
          new_ret = ret.copy
          ret.dispose
          new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
          ret = new_ret
        end
      end
      return ret
    end

    #---------------------------------------------------------------------------
    # Adds G-Max values to Pokemon icon sprite pathways.
    #---------------------------------------------------------------------------
    def self.icon_filename(species, form = 0, gender = 0, shiny = false, shadow = false, egg = false, gmax = false)
      return self.egg_icon_filename(species, form) if egg
      return self.check_graphic_file("Graphics/Pokemon/", species, form, gender, shiny, shadow, "Icons", gmax)
    end

    def self.icon_filename_from_pokemon(pkmn)
      return self.icon_filename(pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?, pkmn.gmax?)
    end

    def self.icon_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, gmax = false)
      filename = self.icon_filename(species, form, gender, shiny, shadow, gmax)
      return (filename) ? AnimatedBitmap.new(filename).deanimate : nil
    end

    def self.icon_bitmap_from_pokemon(pkmn)
      return self.icon_bitmap(pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?, pkmn.egg?, pkmn.gmax?)
    end

    #---------------------------------------------------------------------------
    # Adds G-Max values to Pokemon footprint sprite pathways.
    #---------------------------------------------------------------------------
    def self.footprint_filename(species, form = 0, gmax = false)
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      if form > 0
        ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s_%d", species_data.species, form))
        ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s_%d_gmax", species_data.species, form)) if gmax
        return ret if ret
      end
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s", species_data.species))
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Footprints/%s_gmax", species_data.species)) if gmax
      return ret if ret
    end

    #---------------------------------------------------------------------------
    # Adds special shadow graphic for Dynamaxed Pokemon, if one is present.
    #---------------------------------------------------------------------------
    def self.shadow_filename(species, form = 0, dynamax = false)
      species_data = self.get_species_form(species, form)
      return nil if species_data.nil?
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s_%d", species_data.species, form)) if form>0
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%s", species_data.species)) if form==0
      ret = pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/dynamax")) if dynamax
      return ret if ret
      return pbResolveBitmap(sprintf("Graphics/Pokemon/Shadow/%d", species_data.shadow_size))
    end

    def self.shadow_bitmap(species, form = 0, dynamax = false)
      filename = self.shadow_filename(species, form, dynamax)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

    def self.shadow_bitmap_from_pokemon(pkmn)
      filename = self.shadow_filename(pkmn.species, pkmn.form, pkmn.dynamax?)
      return (filename) ? AnimatedBitmap.new(filename) : nil
    end

	#---------------------------------------------------------------------------
    # Creates Dynamax cries.
    #---------------------------------------------------------------------------
    def self.play_cry_from_pokemon(pkmn, volume = 90, pitch = nil)
      return if !pkmn || pkmn.egg?
      filename = self.cry_filename_from_pokemon(pkmn)
      return if !filename
      volume, pitch = 100, 60 if pkmn.dynamax?
      pitch ||= 75 + (pkmn.hp * 25 / pkmn.totalhp)
      pbSEPlay(RPG::AudioFile.new(filename, volume, pitch)) rescue nil
    end
  end
end

#-------------------------------------------------------------------------------
# Miscellaneous species-related data.
#-------------------------------------------------------------------------------
module MessageTypes
  GMaxNames   = 100
  GMaxEntries = 101
end

GameData::Habitat.register({
  :id   => :UltraSpace,
  :name => _INTL("Ultra Space")
})
