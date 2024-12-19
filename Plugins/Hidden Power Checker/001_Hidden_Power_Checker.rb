# This script can be used to conveniently check the Hidden Power type and
# power for the chosen Pokémon.

# Simply call pbCheckHiddenPower as a script command in any event.
# You can provide an argument that changes the colour of the NPC's text.
# This is a number from 0-12 (inclusive):
# 0 - Default colour (dark or light depending on the windowskin colour)
# 1 - Blue
# 2 - Red
# 3 - Green
# 4 - Cyan
# 5 - Magenta
# 6 - Yellow
# 7 - Gray
# 8 - White
# 9 - Purple
# 10 - Orange
# 11 - Dark default color
# 12 - Light default color
# You would call pbCheckHiddenPower(1) to have blue text, for example.

def pbCheckHiddenPower(textColor=0)
  pbChooseNonEggPokemon(1,2)
  if pbGet(1)<0
    pbMessage(_INTL("\\c[#{textColor}]Oh, okay then."))
    return
  else
    pkmn = pbGetPokemon(1)
    type, power = pbHiddenPower(pkmn)
    typeName = GameData::Type.get(type).real_name
	if typeName == "Light" && !$game_switches[171]
		pbMessage(_INTL("\\c[#{textColor}]Oh? That's strange..."))
		pbMessage(_INTL("\\c[#{textColor}]Your Pokémon's Hidden Power type is one I haven't seen before."))
		pbMessage(_INTL("\\c[#{textColor}]It seems to be... Light-type? What could that be?"))
		$game_switches[171] = true
	else
		pbMessage(_INTL("\\c[#{textColor}]This Pokémon's Hidden Power type is #{typeName}!"))
	end
  end
end
