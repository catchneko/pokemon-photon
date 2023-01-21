#===============================================================================
# PokeBattle_Move additions
#===============================================================================
class PokeBattle_Move
  attr_accessor :name, :flags
  attr_accessor :zmove_sel        # Used when the player triggers a Z-Move.
  attr_reader   :short_name       # Used for shortening names of Z-Moves/Max Moves.
  attr_reader   :specialUseZMove  # Used for Z-Move display messages in battle.
  
  alias _ZUD_initialize initialize
  def initialize(battle, move)
    _ZUD_initialize(battle,move)
    @short_name       = @name
    @zmove_sel        = false
    @specialUseZMove  = false
  end
  
  #-----------------------------------------------------------------------------
  # The display messages when using a Z-Move in battle.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbDisplayUseMessage pbDisplayUseMessage
  def pbDisplayUseMessage(user)
    if zMove? && !@specialUseZMove
	  if Settings::EBDX_COMPAT
	    @battle.scene.clearMessageWindow
	    EliteBattle.playCommonAnimation(:AURAFLARE, @battle.scene, user.index)
	  else
	    @battle.pbCommonAnimation("ZPower",user,nil) if Settings::GEN8_COMPAT && @battle.scene.pbCommonAnimationExists?("ZPower")
	  end
	  PokeBattle_ZMove.from_status_move(@battle, @id, user) if statusMove?
	  @battle.pbDisplay(_INTL("{1} surrounded itself with its Z-Power!",user.pbThis)) if !statusMove?
      @battle.pbDisplay(_INTL("{1} unleashed its full force Z-Move!",user.pbThis))
    end 
    _ZUD_pbDisplayUseMessage(user)
	if Settings::EBDX_COMPAT && zMove?
	  @battle.scene.sprites["pokemon_#{user.index}"].charged = false
	  @battle.scene.sprites["pokemon_#{user.index}"].resetParticles
	end
  end 
end

#-------------------------------------------------------------------------------
# Checks a PokeBattle_Move to determine if it's a particular Power Move.
#-------------------------------------------------------------------------------
class PokeBattle_Move
  def maxMove?;   return @flags[/x/];        end
  def zMove?;     return @flags[/z/];        end
  def powerMove?; return zMove? || maxMove?; end
end
  
#-------------------------------------------------------------------------------
# Checks a Pokemon::Move to determine if it's a particular Power Move.
#-------------------------------------------------------------------------------
class Pokemon
  class Move
    def maxMove?;   return GameData::Move.get(@id).maxMove?;   end
    def zMove?;     return GameData::Move.get(@id).zMove?;     end
    def powerMove?; return GameData::Move.get(@id).powerMove?; end
  end
end

#-------------------------------------------------------------------------------
# Checks a GameData::Move to determine if it's a Power Move.
#-------------------------------------------------------------------------------
module GameData
  class Move
    def maxMove?;   return self.flags[/x/];    end
    def zMove?;     return self.flags[/z/];    end
    def powerMove?; return zMove? || maxMove?; end
  end
end