#-------------------------------------------------------------------------------
# EMBS compatibility patches.
#-------------------------------------------------------------------------------
if Settings::EMBS_COMPAT
  class PokeBattle_Battle
    alias embs_pbStartBattleSendOut pbStartBattleSendOut
    def pbStartBattleSendOut(sendOuts)
      if wildBattle? && $game_switches[Settings::MAXRAID_SWITCH]
        pbRaidSendOut(sendOuts)
      else
        embs_pbStartBattleSendOut(sendOuts)
      end
    end
  end
  
  class PokeBattle_Battle
    alias embs_pbEndOfBattle pbEndOfBattle
    def pbEndOfBattle
      @battlers.each do |b|
        next if !b || !b.dynamax?
        next if b.effects[PBEffects::MaxRaidBoss]
        b.unmax
      end
      embs_pbEndOfBattle
    end
  end
  
  class PokemonDataBox < SpriteWrapper
    def initializeDataBoxGraphic(sideSize)
      onPlayerSide  = ((@battler.index%2)==0)
      player_normal = "Graphics/Pictures/Battle/databox_normal"
      player_thin   = "Graphics/Pictures/Battle/databox_thin"
      enemy_normal  = "Graphics/Pictures/Battle/databox_normal_foe"
      enemy_thin    = "Graphics/Pictures/Battle/databox_thin_foe"
      enemy_raid    = "Graphics/Pictures/Dynamax/databox_maxraid"
      player_data   = (sideSize==1) ? player_normal : player_thin
      enemy_data    = (sideSize==1) ? enemy_normal  : enemy_thin
      enemy_data    = enemy_raid if $game_switches[Settings::MAXRAID_SWITCH]
      bgFilename = [player_data, enemy_data][@battler.index%2]
      @databoxBitmap  = AnimatedBitmap.new(bgFilename)
      if onPlayerSide
        @showHP  = true if sideSize==1
        @showExp = true if sideSize==1
        @spriteX = Graphics.width - 244
        @spriteY = Graphics.height - 192
        @spriteBaseX = 34
      else
        @spriteX = -16
        @spriteY = 36
        @spriteBaseX = 16
      end
      case sideSize
      when 2
        @spriteX += [  0,   0,  0,  0][@battler.index]
        @spriteY += [-20, -34, 34, 20][@battler.index]
      when 3
        @spriteX += [  0,   0,  0,  0,  0,  0][@battler.index]
        @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
      when 4
        @spriteX += [  0,  0,  0,  0,  0,   0,  0,  0][@battler.index]
        @spriteY += [-88,-46,-42,  0,  4,  46, 50, 92][@battler.index]
      when 5
        @spriteX += [   0,  0,  0,  0,  0,  0,  0,  0,  0,  0][@battler.index]
        @spriteY += [-134,-46,-88,  0,-42, 46,  4, 92, 50,138][@battler.index]
      end
    end
  end

  alias embs_pbAfterBattle pbAfterBattle
  def pbAfterBattle(*args)
    $Trainer.party.each do |pkmn|
      pkmn.makeUnUltra
    end
    if $PokemonGlobal.partner
      $Trainer.heal_party
      $PokemonGlobal.partner[3].each do |pkmn|
        pkmn.heal
        pkmn.makeUnmega
        pkmn.makeUnprimal
        pkmn.makeUnUltra
      end
    end
    if $PokemonSystem.activebattle>=1
      $PokemonSystem.activebattle=0
      embEndOfBattleResize
    end
    embs_pbAfterBattle(*args)
  end
end