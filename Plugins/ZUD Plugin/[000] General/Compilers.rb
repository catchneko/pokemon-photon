#===============================================================================
# Compile & save ZUD related data.
#===============================================================================
module Compiler
  module_function
  
  alias _ZUD_write_all write_all
  def write_all
    _ZUD_write_all
    write_ZUD_Metrics
    write_ZUD_PowerMoves
  end

  #-----------------------------------------------------------------------------
  # Compiles Habitat data from ZUD_Habitats.txt, then deletes the file.
  #-----------------------------------------------------------------------------
  def compile_ZUD_Habitats
    return if !safeExists?("PBS/ZUD_Habitats.txt")
    pbCompilerEachCommentedLine("PBS/ZUD_Habitats.txt") { |line, line_no|
      FileLineData.file = "PBS/ZUD_Habitats.txt"
      FileLineData.setSection(line_no, "header", nil)
      if line[/^\s*(\w+)\s*=\s*(.*)$/]   # Of the format XXX = YYY
        next if !GameData::Species.try_get($~[1])
        species_id = parseSpecies($~[1])
        record = pbGetCsvRecord($~[2], $~[1], [0, "e", :Habitat])
        GameData::Species.get(species_id).habitat = record
      end
    }
    GameData::Species.save
    Compiler.write_pokemon
    Compiler.write_pokemon_forms
    begin
      File.delete("PBS/ZUD_Habitats.txt")
      rescue SystemCallError
    end
  end
    
  #-----------------------------------------------------------------------------
  # Compiles Dynamax metric data from ZUD_Metrics.txt.
  #-----------------------------------------------------------------------------
  def compile_ZUD_Metrics
    if !safeExists?("PBS/ZUD_Metrics.txt")
      pbAutoPositionDynamax
    end
    schema = {"DmaxMetrics" => [0, "iiiiiiu"],
              "GmaxMetrics" => [0, "iiiiiiu"]}
    File.open("PBS/ZUD_Metrics.txt", "rb") { |f|
      FileLineData.file = "PBS/ZUD_Metrics.txt"
      pbEachFileSectionEx(f) { |contents, species_id|
        FileLineData.setSection(species_id, "header", nil)
        next if !GameData::Species.try_get(species_id)
        species = GameData::Species.get(species_id)
        for key in schema.keys
          if nil_or_empty?(contents[key])
            contents[key] = nil
            next
          end
          FileLineData.setSection(species_id, key, contents[key])
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          case key
          when "DmaxMetrics"; species.dmax_metrics = contents[key]
          when "GmaxMetrics"; species.gmax_metrics = contents[key]
          end
        end
      }
    }  
    GameData::Species.save
  end
  
  #-----------------------------------------------------------------------------
  # Writes the ZUD_Metrics.txt file from Species data.
  #-----------------------------------------------------------------------------
  def write_ZUD_Metrics
    File.open("PBS/ZUD_Metrics.txt", "wb") { |f|
      f.write("\# This installation is part of the ZUD Plugin for Pokemon Essentials v19.\r\n")
      f.write("\# All battler metrics for Dynamax and Gigantamax are stored here.\r\n")
      f.write("\# The numbers are listed in the order: BattlerPlayerX, BattlerPlayerY, BattlerEnemyX, BattlerEnemyY, Altitude (unused), BattlerShadowX, BattlerShadowSize\r\n")
      GameData::Species.each do |species|
        pbSetWindowText(_INTL("Writing species {1}...", species.id))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", species.id))
        f.write(sprintf("DmaxMetrics = %i,%i,%i,%i,%i,%i,%u\r\n", 
          species.dmax_metrics[0], 
          species.dmax_metrics[1],
          species.dmax_metrics[2],
          species.dmax_metrics[3],
          species.dmax_metrics[4],
          species.dmax_metrics[5],
          species.dmax_metrics[6]
        ))
        if species.hasGmax?
          f.write(sprintf("GmaxMetrics = %i,%i,%i,%i,%i,%i,%u\r\n", 
            species.gmax_metrics[0], 
            species.gmax_metrics[1],
            species.gmax_metrics[2],
            species.gmax_metrics[3],
            species.gmax_metrics[4],
            species.gmax_metrics[5],
            species.gmax_metrics[6]
          ))
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end
  
  #-----------------------------------------------------------------------------
  # Compiles Power Move compatibility data from the ZUD_PowerMoves.txt.
  #-----------------------------------------------------------------------------
  def compile_ZUD_PowerMoves
    z_id = 0
    g_id = 0
    compat_id_num = 0
    gmax_form_names      = []
    gmax_pokedex_entries = []
    GameData::PowerMove::DATA.clear
    pbCompilerEachCommentedLine("PBS/ZUD_PowerMoves.txt") { |line, line_no|
      FileLineData.file = "PBS/ZUD_PowerMoves.txt"
      FileLineData.setSection(line_no, "header", nil)
      if line[/^\s*(\w+)\s*=\s*(.*)$/]   # Of the format XXX = YYY
        key = $~[1]
        powermove = true
        schema = GameData::PowerMove::SCHEMA
        record = pbGetCsvRecord($~[2],key,schema[key])
        case key
        #-----------------------------------------------------------------------
        # Power Move entries
        #-----------------------------------------------------------------------
        when "ZMove";       reqs  = record; compat_id = "ZMOVE"    + record[2].to_s
        when "MaxMove";     reqs  = record; compat_id = "MAXMOVE"  + record[1].to_s
        when "ZMoveEx";     reqs  = record; z_id += 1; compat_id = "ZMOVEEX"  + z_id.to_s
        when "GMaxMove";    reqs  = record; g_id += 1; compat_id = "GMAXMOVE" + g_id.to_s
        #-----------------------------------------------------------------------
        # Status Z-Move entries
        #-----------------------------------------------------------------------
        when "AtkBoost1";   atk   = record; compat_id = "ZMOVEATK1";   stage = 1
        when "AtkBoost2";   atk   = record; compat_id = "ZMOVEATK2";   stage = 2
        when "AtkBoost3";   atk   = record; compat_id = "ZMOVEATK3";   stage = 3
        when "DefBoost1";   dfn   = record; compat_id = "ZMOVEDEF1";   stage = 1
        when "DefBoost2";   dfn   = record; compat_id = "ZMOVEDEF2";   stage = 2
        when "DefBoost3";   dfn   = record; compat_id = "ZMOVEDEF3";   stage = 3
        when "SpAtkBoost1"; satk  = record; compat_id = "ZMOVESPATK1"; stage = 1
        when "SpAtkBoost2"; satk  = record; compat_id = "ZMOVESPATK2"; stage = 2
        when "SpAtkBoost3"; satk  = record; compat_id = "ZMOVESPATK3"; stage = 3
        when "SpDefBoost1"; sdef  = record; compat_id = "ZMOVESPDEF1"; stage = 1
        when "SpDefBoost2"; sdef  = record; compat_id = "ZMOVESPDEF2"; stage = 2
        when "SpDefBoost3"; sdef  = record; compat_id = "ZMOVESPDEF3"; stage = 3
        when "SpeedBoost1"; spd   = record; compat_id = "ZMOVESPEED1"; stage = 1
        when "SpeedBoost2"; spd   = record; compat_id = "ZMOVESPEED2"; stage = 2
        when "SpeedBoost3"; spd   = record; compat_id = "ZMOVESPEED3"; stage = 3
        when "AccBoost1";   acc   = record; compat_id = "ZMOVEACC1";   stage = 1
        when "AccBoost2";   acc   = record; compat_id = "ZMOVEACC2";   stage = 2
        when "AccBoost3";   acc   = record; compat_id = "ZMOVEACC3";   stage = 3
        when "EvaBoost1";   eva   = record; compat_id = "ZMOVEEVA1";   stage = 1
        when "EvaBoost2";   eva   = record; compat_id = "ZMOVEEVA2";   stage = 2
        when "EvaBoost3";   eva   = record; compat_id = "ZMOVEEVA3";   stage = 3
        when "OmniBoost1";  omni  = record; compat_id = "ZMOVEOMNI1";  stage = 1
        when "OmniBoost2";  omni  = record; compat_id = "ZMOVEOMNI2";  stage = 2
        when "OmniBoost3";  omni  = record; compat_id = "ZMOVEOMNI3";  stage = 3
        when "HealUser";    heal  = record; compat_id = "ZMOVEHEAL1";  stage = 1
        when "HealSwitch";  heal  = record; compat_id = "ZMOVEHEAL2";  stage = 2
        when "CritBoost";   crit  = record; compat_id = "ZMOVECRIT"
        when "ResetStats";  reset = record; compat_id = "ZMOVERESET"
        when "FocusOnUser"; focus = record; compat_id = "ZMOVEFOCUS"
        #-----------------------------------------------------------------------
        # G-Max Data
        #-----------------------------------------------------------------------
        when "DexData"
          species   = record[0]
          height    = (record[1]*10).round
          form      = record[2]
          entry     = record[3]
          powermove = false
        end
        #-----------------------------------------------------------------------
        # Registers a new entry in GameData::PowerMove.
        #-----------------------------------------------------------------------
        if powermove
          compat_id_num += 1
          if reqs
            power_type = GameData::PowerMove::MAXMOVE  if reqs.length==2 && key=="MaxMove"
            power_type = GameData::PowerMove::ZMOVE    if reqs.length==3 && key=="ZMove"
            power_type = GameData::PowerMove::GMAXMOVE if reqs.length==3 && key=="GMaxMove"
            power_type = GameData::PowerMove::ZMOVEEX  if reqs.length==4 && key=="ZMoveEx"
          else 
            power_type = GameData::PowerMove::ZSTATUS
          end
          comp_hash = {
            :id            => compat_id,     # Symbol used for this Power Move's data.
            :id_number     => compat_id_num, # ID Number used for this Power Move's data.
            :compat_type   => power_type,    # Type of Power Move (Max Move, G-Max, Z-Move, Z-Ex, Z-Status).
            :req_criteria  => reqs,          # Compatibility requirements for this Power Move.
            :status_atk    => [atk,stage],   # Status Z-Moves that boost Attack, and the number of stages.
            :status_def    => [dfn,stage],   # Status Z-Moves that boost Defense, and the number of stages.
            :status_spatk  => [satk,stage],  # Status Z-Moves that boost Sp.Atk, and the number of stages.
            :status_spdef  => [sdef,stage],  # Status Z-Moves that boost Sp.Def, and the number of stages.
            :status_speed  => [spd,stage],   # Status Z-Moves that boost Speed, and the number of stages.
            :status_acc    => [acc,stage],   # Status Z-Moves that boost Accuracy, and the number of stages.
            :status_eva    => [eva,stage],   # Status Z-Moves that boost Evasion, and the number of stages.
            :status_omni   => [omni,stage],  # Status Z-Moves that boost all stats, and the number of stages.
            :status_heal   => [heal,stage],  # Status Z-Moves that heal, and their targets [Self or Switch-in].
            :status_crit   => crit,          # Status Z-Moves that boost critical hit ratio.
            :status_reset  => reset,         # Status Z-Moves that reset the user's lowered stats.
            :status_focus  => focus          # Status Z-Moves that apply the Follow Me effect on the user.
          }
          GameData::PowerMove.register(comp_hash)
        #-----------------------------------------------------------------------
        # Adds G-Max Pokedex data to GameData::Species.
        #-----------------------------------------------------------------------
        else
          species  = GameData::Species.get(species)
          species.gmax_height                     = height
          species.real_gmax_name                  = form
          species.real_gmax_dex                   = entry
          gmax_form_names[species.id_number]      = form
          gmax_pokedex_entries[species.id_number] = entry
        end
      end
    }
    GameData::Species.save
    GameData::PowerMove.save 
    MessageTypes.setMessages(MessageTypes::GMaxNames, gmax_form_names)
    MessageTypes.setMessages(MessageTypes::GMaxEntries, gmax_pokedex_entries)
    Graphics.update
  end
  
  #-----------------------------------------------------------------------------
  # Writes the ZUD_PowerMoves.txt file from Power Moves and Species data.
  #-----------------------------------------------------------------------------
  def write_ZUD_PowerMoves
    File.open("PBS/ZUD_PowerMoves.txt", "wb") { |f|
      f.write("# This installation is part of the ZUD Plugin for Pokemon Essentials v19.\r\n")
      f.write("# Refer to each section below to learn how to edit this file.\r\n")
      f.write("#\r\n")
      f.write("#########################################################################\r\n")
      f.write("# SECTION 1 : Z-MOVES\r\n")
      f.write("#########################################################################\r\n")
      #-------------------------------------------------------------------------
      # Writes generic Z-Moves.
      #-------------------------------------------------------------------------
      f.write("#-----------------------------------\r\n")
      f.write("# A) Generic Z-Move Compatibility\r\n")
      f.write("#-----------------------------------\r\n")
      f.write("# Add a generic Z-Move for a new type in this section, in the format: ZMove = Z-Move Name, Z-Crystal, Move Type.\r\n")
      f.write("#-----------------------------------\r\n")
      GameData::PowerMove.each do |m|
        next if !m.zMove?
        pbSetWindowText(_INTL("Writing Z-Moves {1}...", m.id_number))
        f.write(sprintf("ZMove = %s,%s,%s\r\n", m.power_move, m.reqItem, m.reqType))
      end
      #-------------------------------------------------------------------------
      # Writes exclusive Z-Moves.
      #-------------------------------------------------------------------------
      f.write("#-----------------------------------\r\n")
      f.write("# B) Exclusive Z-Move Compatibility\r\n")
      f.write("#-----------------------------------\r\n")
      f.write("# Add an exclusive Z-Move for a species in this section, in the format: ZMoveEx = Z-Move Name, Z-Crystal, Converted Move, Species_form.\r\n")
      f.write("#-----------------------------------\r\n")
      GameData::PowerMove.each do |m|
        next if !m.zMoveEx?
        pbSetWindowText(_INTL("Writing Z-Moves (Exclusive) {1}...", m.id_number))
        f.write(sprintf("ZMoveEx = %s,%s,%s,%s\r\n", m.power_move, m.reqItem, m.reqMove, m.reqSpecies))
      end
      #-------------------------------------------------------------------------
      # Writes status Z-Moves.
      #-------------------------------------------------------------------------
      f.write("#-------------------------------\r\n")
      f.write("# C) Status Z-Move Compatibility\r\n")
      f.write("#-------------------------------\r\n")
      f.write("# Give a status move a Z-Move effect by adding that move to the array with the desired effect in this section.\r\n")
      f.write("# The following effects are implemented, but go unused by any existing move. Use them if you want:\r\n")
      f.write("# DefBoost2, DefBoost3, SpAtkBoost3, SpDefBoost3, SpeedBoost3, AccBoost2, AccBoost3, EvaBoost2, EvaBoost3, OmniBoost2, OmniBoost3\r\n")
      f.write("#-------------------------------\r\n")
      GameData::PowerMove.each do |z|
        next if !z.zStatus?
        pbSetWindowText(_INTL("Writing Z-Moves (Status) {1}...", z.id_number))
        effect = movelist = nil
        keys   = GameData::PowerMove::SCHEMA.keys
        for i in 0...keys.length
          effect = keys[i].to_s
          next if effect=="MaxMove" || effect=="ZMove"
          #---------------------------------------------------------------------
          # Writes moves that boost Attack.
          #---------------------------------------------------------------------
          if effect=="AtkBoost1"   && !z.status_atk[0].nil?   && z.status_atk[1]==1;   movelist = z.status_atk[0];   end
          if effect=="AtkBoost2"   && !z.status_atk[0].nil?   && z.status_atk[1]==2;   movelist = z.status_atk[0];   end
          if effect=="AtkBoost3"   && !z.status_atk[0].nil?   && z.status_atk[1]==3;   movelist = z.status_atk[0];   end
          #---------------------------------------------------------------------
          # Writes moves that boost Defense.
          #---------------------------------------------------------------------
          if effect=="DefBoost1"   && !z.status_def[0].nil?   && z.status_def[1]==1;   movelist = z.status_def[0];   end
          if effect=="DefBoost2"   && !z.status_def[0].nil?   && z.status_def[1]==2;   movelist = z.status_def[0];   end
          if effect=="DefBoost3"   && !z.status_def[0].nil?   && z.status_def[1]==3;   movelist = z.status_def[0];   end
          #---------------------------------------------------------------------
          # Writes moves that boost Sp.Atk.
          #---------------------------------------------------------------------
          if effect=="SpAtkBoost1" && !z.status_spatk[0].nil? && z.status_spatk[1]==1; movelist = z.status_spatk[0]; end
          if effect=="SpAtkBoost2" && !z.status_spatk[0].nil? && z.status_spatk[1]==2; movelist = z.status_spatk[0]; end
          if effect=="SpAtkBoost3" && !z.status_spatk[0].nil? && z.status_spatk[1]==3; movelist = z.status_spatk[0]; end
          #---------------------------------------------------------------------
          # Writes moves that boost Sp.Def.
          #---------------------------------------------------------------------
          if effect=="SpDefBoost1" && !z.status_spdef[0].nil? && z.status_spdef[1]==1; movelist = z.status_spdef[0]; end
          if effect=="SpDefBoost2" && !z.status_spdef[0].nil? && z.status_spdef[1]==2; movelist = z.status_spdef[0]; end
          if effect=="SpDefBoost3" && !z.status_spdef[0].nil? && z.status_spdef[1]==3; movelist = z.status_spdef[0]; end
          #---------------------------------------------------------------------
          # Writes moves that boost Speed.
          #---------------------------------------------------------------------
          if effect=="SpeedBoost1" && !z.status_speed[0].nil? && z.status_speed[1]==1; movelist = z.status_speed[0]; end
          if effect=="SpeedBoost2" && !z.status_speed[0].nil? && z.status_speed[1]==2; movelist = z.status_speed[0]; end
          if effect=="SpeedBoost3" && !z.status_speed[0].nil? && z.status_speed[1]==3; movelist = z.status_speed[0]; end
          #---------------------------------------------------------------------
          # Writes moves that boost Accuracy.
          #---------------------------------------------------------------------
          if effect=="AccBoost1"   && !z.status_acc[0].nil?   && z.status_acc[1]==1;   movelist = z.status_acc[0];   end
          if effect=="AccBoost2"   && !z.status_acc[0].nil?   && z.status_acc[1]==2;   movelist = z.status_acc[0];   end
          if effect=="AccBoost3"   && !z.status_acc[0].nil?   && z.status_acc[1]==3;   movelist = z.status_acc[0];   end
          #---------------------------------------------------------------------
          # Writes moves that boost Evasion.
          #---------------------------------------------------------------------
          if effect=="EvaBoost1"   && !z.status_eva[0].nil?   && z.status_eva[1]==1;   movelist = z.status_eva[0];   end
          if effect=="EvaBoost2"   && !z.status_eva[0].nil?   && z.status_eva[1]==2;   movelist = z.status_eva[0];   end
          if effect=="EvaBoost3"   && !z.status_eva[0].nil?   && z.status_eva[1]==3;   movelist = z.status_eva[0];   end
          #---------------------------------------------------------------------
          # Writes moves that boost all stats.
          #---------------------------------------------------------------------
          if effect=="OmniBoost1"  && !z.status_omni[0].nil?  && z.status_omni[1]==1;  movelist = z.status_omni[0];  end
          if effect=="OmniBoost2"  && !z.status_omni[0].nil?  && z.status_omni[1]==2;  movelist = z.status_omni[0];  end
          if effect=="OmniBoost3"  && !z.status_omni[0].nil?  && z.status_omni[1]==3;  movelist = z.status_omni[0];  end
          #---------------------------------------------------------------------
          # Writes moves that heal HP.
          #---------------------------------------------------------------------
          if effect=="HealUser"    && !z.status_heal[0].nil?  && z.status_heal[1]==1;  movelist = z.status_heal[0];  end
          if effect=="HealSwitch"  && !z.status_heal[0].nil?  && z.status_heal[1]==2;  movelist = z.status_heal[0];  end
          #---------------------------------------------------------------------
          # Writes all other move effects.
          #---------------------------------------------------------------------
          if effect=="CritBoost"   && !z.status_crit.nil?;       movelist = z.status_crit;     end
          if effect=="ResetStats"  && !z.status_reset.nil?;      movelist = z.status_reset;    end
          if effect=="FocusOnUser" && !z.status_focus.nil?;      movelist = z.status_focus;    end
          break if effect && movelist
        end
        f.write(sprintf("%s = %s\r\n",effect,movelist.join(",")))
      end
      f.write("#\r\n")
      f.write("#########################################################################\r\n")
      f.write("# SECTION 2 : DYNAMAX\r\n")
      f.write("#########################################################################\r\n")
      #-------------------------------------------------------------------------
      # Writes generic Max Moves.
      #-------------------------------------------------------------------------
      f.write("#-----------------------------------\r\n")
      f.write("# A) Generic Max Move Compatibility\r\n")
      f.write("#-----------------------------------\r\n")
      f.write("# Add a generic Max Move for a new type in this section, in the format: MaxMove = Max Move Name, Move Type.\r\n")
      f.write("#-----------------------------------\r\n")
      GameData::PowerMove.each do |m|
        next if !m.maxMove?
        pbSetWindowText(_INTL("Writing Max Moves {1}...", m.id_number))
        f.write(sprintf("MaxMove = %s,%s\r\n", m.power_move, m.reqType))
      end
      #-------------------------------------------------------------------------
      # Writes G-Max Moves.
      #-------------------------------------------------------------------------
      f.write("#-----------------------------------\r\n")
      f.write("# B) Exclusive G-Max Move Compatibility\r\n")
      f.write("#-----------------------------------\r\n")
      f.write("# Add an exclusive G-Max Move for a species in this section, in the format: GMaxMove = Max Move Name, Move Type, Species_form.\r\n")
      f.write("#-----------------------------------\r\n")
      GameData::PowerMove.each do |m|
        next if !m.gmaxMove?
        pbSetWindowText(_INTL("Writing G-Max Moves {1}...", m.id_number))
        f.write(sprintf("GMaxMove = %s,%s,%s\r\n", m.power_move, m.reqType, m.reqSpecies))
      end
      #-------------------------------------------------------------------------
      # Writes G-Max Species Data.
      #-------------------------------------------------------------------------
      f.write("#-----------------------------------\r\n")
      f.write("# C) Gigantamax Species Data\r\n")
      f.write("#-----------------------------------\r\n")
      f.write("# Adds flavor data to G-Max forms in this section, in the format: DexData = Species_form, G-Max Height, G-Max Name, G-Max Dex Entry.\r\n")
      f.write("#-----------------------------------\r\n")
      GameData::Species.each do |s|
        next if !s.hasGmax?
        pbSetWindowText(_INTL("Writing G-Max Data {1}...", s.id_number))
        f.write(sprintf("DexData = %s,%.1f,%s,%s\r\n", s.id, s.gmax_height/10.0, csvQuote(s.real_gmax_name), csvQuoteAlways(s.real_gmax_dex)))
      end
    }
    Graphics.update
  end

#===============================================================================
# Rewrites Trainer compiler to allow NPC's to Dynamax.
#===============================================================================
  def compile_trainers(path = "PBS/trainers.txt")
	GameData::Trainer::DATA.clear							
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names             = []
    trainer_lose_texts        = []
    trainer_hash              = nil
    trainer_id                = -1
    current_pkmn              = nil
    old_format_current_line   = 0
    old_format_expected_lines = 0
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        if trainer_hash
          if old_format_current_line > 0
            raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
          end
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        trainer_id += 1
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        trainer_hash = {
          :id_number    => trainer_id,
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names[trainer_id] = trainer_hash[:name]
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        case property_name
        when "Items"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.uniq!
          property_value.compact!
        when "IV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        when "DynamaxLvl"
          if property_value > 10
            raise _INTL("Bad Dynamax Level: {1} (must be 0-10).\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        case property_name
        when "Items", "LoseText"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
		  when "Ability"
            if property_value[/^\d+$/]
              current_pkmn[:ability_index] = property_value.to_i
            elsif !GameData::Ability.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Ability.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end				
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
		  when "Ball"
            if property_value[/^\d+$/]
              current_pkmn[line_schema[0]] = pbBallTypeToItem(property_value.to_i).id
            elsif !GameData::Item.exists?(property_value.to_sym) ||
               !GameData::Item.get(property_value.to_sym).is_poke_ball?
              raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end 
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      else
        if old_format_current_line == 0
          if trainer_hash
            if !current_pkmn
              raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
            end
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
          end
          trainer_id += 1
          old_format_expected_lines = 3
          trainer_hash = {
            :id_number    => trainer_id,
            :trainer_type => nil,
            :name         => nil,
            :version      => 0,
            :pokemon      => []
          }
          current_pkmn = nil
        end
        old_format_current_line += 1
        case old_format_current_line
        when 1
          line_data = pbGetCsvRecord(line, line_no, [0, "e", :TrainerType])
          trainer_hash[:trainer_type] = line_data
        when 2
          line_data = pbGetCsvRecord(line, line_no, [0, "sU"])
          line_data = [line_data] if !line_data.is_a?(Array)
          trainer_hash[:name]    = line_data[0]
          trainer_hash[:version] = line_data[1] if line_data[1]
          trainer_names[trainer_hash[:id_number]] = line_data[0]
        when 3
          line_data = pbGetCsvRecord(line, line_no,
             [0, "vEEEEEEEE", nil, :Item, :Item, :Item, :Item, :Item, :Item, :Item, :Item])
          line_data = [line_data] if !line_data.is_a?(Array)
          line_data.compact!
          old_format_expected_lines += line_data[0]
          line_data.shift
          trainer_hash[:items] = line_data if line_data.length > 0
        else
          line_data = pbGetCsvRecord(line, line_no,
             [0, "evEEEEEUEUBEUUSBUUBB", :Species, nil, :Item, :Move, :Move, :Move, :Move, nil,
                                      {"M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1},
                                      nil, nil, :Nature, nil, nil, nil, nil, nil, nil, nil, nil])
          current_pkmn = {
            :species => line_data[0]
          }
          trainer_hash[:pokemon].push(current_pkmn)
          line_data.each_with_index do |value, i|
            next if value.nil?
            case i
            when 1
              if value > max_level
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", value, max_level, FileLineData.linereport)
              end
            when 12
              if value > Pokemon::IV_STAT_LIMIT
                raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", value, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
              end
            when 13
              if value > 255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", value, FileLineData.linereport)
              end
            when 14
              if value.length > Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            when 17
              if value.length > 10
                raise _INTL("Bad Dynamax Level: {1} (must be 0-10).\r\n{2}", value, FileLineData.linereport)
              end
            end
          end
          moves = [line_data[3], line_data[4], line_data[5], line_data[6]]
          moves.uniq!
          moves.compact!	
          ivs = {}
          if line_data[12]
            GameData::Stat.each_main do |s|
              ivs[s.id] = line_data[12] if s.pbs_order >= 0
            end
          end
          current_pkmn[:level]        = line_data[1]
          current_pkmn[:item]         = line_data[2] if line_data[2]
          current_pkmn[:moves]        = moves if moves.length > 0
          current_pkmn[:ability_index] = line_data[7] if line_data[7]
          current_pkmn[:gender]       = line_data[8] if line_data[8]
          current_pkmn[:form]         = line_data[9] if line_data[9]
          current_pkmn[:shininess]    = line_data[10] if line_data[10]
          current_pkmn[:nature]       = line_data[11] if line_data[11]
          current_pkmn[:iv]           = ivs if ivs.length > 0
          current_pkmn[:happiness]    = line_data[13] if line_data[13]
          current_pkmn[:name]         = line_data[14] if line_data[14] && !line_data[14].empty?
          current_pkmn[:shadowness]   = line_data[15] if line_data[15]
          current_pkmn[:poke_ball]    = line_data[16] if line_data[16]
          current_pkmn[:dynamax_lvl]  = line_data[17] if line_data[17]
          current_pkmn[:gmaxfactor]   = line_data[18] if line_data[18]
          current_pkmn[:acepkmn]      = line_data[19] if line_data[19]
          old_format_current_line = 0 if old_format_current_line >= old_format_expected_lines
        end
      end
    }
    if old_format_current_line > 0
      raise _INTL("Unexpected end of file, last trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
    end
    if trainer_hash
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    Graphics.update
  end
  
  def write_trainers
    File.open("PBS/trainers.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        pbSetWindowText(_INTL("Writing trainer {1}...", trainer.id_number))
        Graphics.update if trainer.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        if trainer.real_lose_text && !trainer.real_lose_text.empty?
          f.write(sprintf("LoseText = %s\r\n", csvQuoteAlways(trainer.real_lose_text)))
        end
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
          f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
          f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
          f.write("    Shiny = yes\r\n") if pkmn[:shininess]
          f.write("    Shadow = yes\r\n") if pkmn[:shadowness]
          f.write(sprintf("    Moves = %s\r\n", pkmn[:moves].join(","))) if pkmn[:moves] && pkmn[:moves].length > 0
          f.write(sprintf("    Ability = %d\r\n", pkmn[:ability_flag])) if pkmn[:ability_flag]
          f.write(sprintf("    Item = %s\r\n", pkmn[:item])) if pkmn[:item]
          f.write(sprintf("    Nature = %s\r\n", pkmn[:nature])) if pkmn[:nature]
          ivs_array = []
          evs_array = []
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ivs_array[s.pbs_order] = pkmn[:iv][s.id] if pkmn[:iv]
            evs_array[s.pbs_order] = pkmn[:ev][s.id] if pkmn[:ev]
          end
          f.write(sprintf("    IV = %s\r\n", ivs_array.join(","))) if pkmn[:iv]
          f.write(sprintf("    EV = %s\r\n", evs_array.join(","))) if pkmn[:ev]
          f.write(sprintf("    Happiness = %d\r\n", pkmn[:happiness])) if pkmn[:happiness]
          f.write(sprintf("    Ball = %s\r\n", pkmn[:poke_ball])) if pkmn[:poke_ball]
          f.write(sprintf("    DynamaxLvl = %d\r\n", pkmn[:dynamax_lvl])) if pkmn[:dynamax_lvl]
          f.write("    Gigantamax = yes\r\n") if pkmn[:gmaxfactor]
          f.write("    TrainerAce = yes\r\n") if pkmn[:acepkmn]
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end
end

#===============================================================================
# Adds Power Moves to load data.
#===============================================================================
module GameData
  def self.load_all
    Type.load
    Ability.load
    Move.load
    Item.load
    BerryPlant.load
    Species.load
    Ribbon.load
    Encounter.load
    TrainerType.load
    Trainer.load
    Metadata.load
    MapMetadata.load
    PowerMove.load
  end
end


#-------------------------------------------------------------------------------
# DO NOT TOUCH!
#-------------------------------------------------------------------------------
module Settings
  ZUD_COMPAT         = true
  GEN8_COMPAT        = false
  EBDX_COMPAT        = false
  EMBS_COMPAT        = false
  BW_POKEDEX_COMPAT  = false
  ADV_POKEDEX_COMPAT = false
end