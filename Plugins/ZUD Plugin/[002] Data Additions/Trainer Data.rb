#===============================================================================
# Adds Dynamax related attributes to NPC Trainer's Pokemon.
#===============================================================================
module GameData
  class Trainer
    SCHEMA = {
      "Items"        => [:items,         "*e", :Item],
      "LoseText"     => [:lose_text,     "s"],
      "Pokemon"      => [:pokemon,       "ev", :Species],   # Species, level
      "Form"         => [:form,          "u"],
      "Name"         => [:name,          "s"],
      "Moves"        => [:moves,         "*e", :Move],
      "Ability"      => [:ability,       "s"],
      "AbilityIndex" => [:ability_index, "u"],
      "Item"         => [:item,          "e", :Item],
      "Gender"       => [:gender,        "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                                "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
      "Nature"       => [:nature,        "e", :Nature],
      "IV"           => [:iv,            "uUUUUU"],
      "EV"           => [:ev,            "uUUUUU"],
      "Happiness"    => [:happiness,     "u"],
      "Shiny"        => [:shininess,     "b"],
      "Shadow"       => [:shadowness,    "b"],
      "Ball"         => [:poke_ball,     "s"],
      "DynamaxLvl"   => [:dynamax_lvl, "u"],
      "Gigantamax"   => [:gmaxfactor,  "b"],
      "TrainerAce"   => [:acepkmn,     "b"]
    }
    
    def to_trainer
      tr_name = self.name
      Settings::RIVAL_NAMES.each do |rival|
        next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
        tr_name = $game_variables[rival[1]]
        break
      end
      trainer = NPCTrainer.new(tr_name, @trainer_type)
      trainer.id        = $Trainer.make_foreign_ID
      trainer.items     = @items.clone
      trainer.lose_text = self.lose_text
      @pokemon.each do |pkmn_data|
        species = GameData::Species.get(pkmn_data[:species]).species
        pkmn = Pokemon.new(species, pkmn_data[:level], trainer, false)
        trainer.party.push(pkmn)
        if pkmn_data[:form]
          pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
          pkmn.form_simple = pkmn_data[:form]
        end
        pkmn.item = pkmn_data[:item]
        if pkmn_data[:moves] && pkmn_data[:moves].length > 0
          pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
        else
          pkmn.reset_moves
        end
        pkmn.ability_index = pkmn_data[:ability_index]
        pkmn.ability = pkmn_data[:ability]
        pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
        pkmn.shiny = (pkmn_data[:shininess]) ? true : false
        if pkmn_data[:nature]
          pkmn.nature = pkmn_data[:nature]
        else
          nature = pkmn.species_data.id_number + GameData::TrainerType.get(trainer.trainer_type).id_number
          pkmn.nature = nature % (GameData::Nature::DATA.length / 2)
        end
        GameData::Stat.each_main do |s|
          if pkmn_data[:iv]
            pkmn.iv[s.id] = pkmn_data[:iv][s.id]
          else
            pkmn.iv[s.id] = [pkmn_data[:level] / 2, Pokemon::IV_STAT_LIMIT].min
          end
          if pkmn_data[:ev]
            pkmn.ev[s.id] = pkmn_data[:ev][s.id]
          else
            pkmn.ev[s.id] = [pkmn_data[:level] * 3 / 2, Pokemon::EV_LIMIT / 6].min
          end
        end
        pkmn.happiness = pkmn_data[:happiness] if pkmn_data[:happiness]
        pkmn.name = pkmn_data[:name] if pkmn_data[:name] && !pkmn_data[:name].empty?
        #-----------------------------------------------------------------------
        # Dynamax values.
        #-----------------------------------------------------------------------
        pkmn.dynamax_lvl = pkmn_data[:dynamax_lvl]
        pkmn.gmaxfactor  = (pkmn_data[:gmaxfactor]) ? true : false
        pkmn.acepkmn     = (pkmn_data[:acepkmn])    ? true : false
        #-----------------------------------------------------------------------
        if pkmn_data[:shadowness]
          pkmn.makeShadow
          pkmn.update_shadow_moves(true)
          pkmn.shiny = false
          pkmn.dynamax_lvl = 0
          pkmn.gmaxfactor = false
          pkmn.acepkmn = false
        end
        pkmn.poke_ball = pbBallTypeToItem(pkmn_data[:poke_ball]).id if pkmn_data[:poke_ball]
        pkmn.calc_stats
      end
      return trainer
    end
  end
end

#-------------------------------------------------------------------------------
# Adds G-Max forms to seen Pokedex forms.
#-------------------------------------------------------------------------------
class Player < Trainer
  class Pokedex
    def last_form_seen(species)
      @last_seen_forms[species] ||= [0,0,false]
      return @last_seen_forms[species]
    end
    
    def set_last_form_seen(species, gender = 0, form = 0, gmax = false)
      @last_seen_forms[species] = [gender, form, gmax]
    end
  end
end