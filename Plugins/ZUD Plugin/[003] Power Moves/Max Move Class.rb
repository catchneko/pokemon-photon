#===============================================================================
# PokeBattle_MaxMove child class
#===============================================================================
class PokeBattle_MaxMove < PokeBattle_Move
  attr_reader :oldmove
  
  def initialize(battle, move, newMove)
    validate move => PokeBattle_Move
    super(battle, newMove)
    @oldmove    = move
    @category   = move.category
    @baseDamage = pbMaxMoveBaseDamage(move) if @baseDamage==1
    @short_name = (@name.length>15 && Settings::SHORTEN_MOVES) ? @name[0..12] + "..." : @name
  end
  
  #-----------------------------------------------------------------------------
  # Gets a battler's Max Move based on the inputted move.
  #-----------------------------------------------------------------------------
  def PokeBattle_MaxMove.from_base_move(battle, battler, move)
    return move if move.is_a?(PokeBattle_MaxMove)
    pokemon = battler.pokemon
    newpoke = battler.effects[PBEffects::TransformPokemon]
    if battler.effects[PBEffects::Transform] && newpoke
      pokemon = newpoke if newpoke.gmax? && pokemon.gmaxFactor?
    end
    maxmove_id   = pokemon.get_maxmove(move, move.category)
    newMove      = Pokemon::Move.new(maxmove_id)
    moveFunction = newMove.function_code || "D000"
    className    = sprintf("PokeBattle_Move_%s",moveFunction)
    if Object.const_defined?(className)
      return Object.const_get(className).new(battle, newMove) if moveFunction=="D001" # Max Guard
      return Object.const_get(className).new(battle, move, newMove)
    end
    return PokeBattle_MaxMove.new(battle, move, newMove)
  end
  
  #-----------------------------------------------------------------------------
  # Uses a Max Move.
  #-----------------------------------------------------------------------------
  def pbUse(battler, simplechoice=nil, specialUsage=false)
    battler.pbBeginTurn(self)  
    dchoice = @battle.choices[battler.index]
    if simplechoice
      dchoice = simplechoice
    end    
    dchoice[2] = self
    battler.pbUseMove(dchoice)
    battler.pbReducePPOther(@oldmove)
  end
  
  #-----------------------------------------------------------------------------
  # Protection moves don't fully negate Max Moves.
  # G-Max One Blow and G-Max Rapid Flow ignore protection moves completely.
  #-----------------------------------------------------------------------------
  def pbModifyDamage(damageMult, user, target)
    # Max Moves that ignore Protect don't have their damage reduced.
    if @id == :GMAXONEBLOW || @id == :GMAXRAPIDFLOW
      return damageMult 
    end
    # Protect fails to fully protect against Max Moves.
    if target.effects[PBEffects::Protect] || 
       target.effects[PBEffects::KingsShield] ||
       target.effects[PBEffects::SpikyShield] ||
       target.effects[PBEffects::BanefulBunker] ||
       target.pbOwnSide.effects[PBEffects::MatBlock] ||
       (GameData::Move.exists?(:OBSTRUCT) && target.effects[PBEffects::Obstruct])
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",target.pbThis))
      return damageMult/4
    else      
      return damageMult
    end
  end
end

#-------------------------------------------------------------------------------
# Gets the base power of a move when converted into a Max Move.
#-------------------------------------------------------------------------------
def pbMaxMoveBaseDamage(oldmove, displaymove=nil)
  realmove  = true if oldmove.is_a?(PokeBattle_Move)
  moveid    = realmove ? oldmove.id         : GameData::Move.get(oldmove).id
  movetype  = realmove ? oldmove.type       : GameData::Move.get(oldmove).type
  function  = realmove ? oldmove.function   : GameData::Move.get(oldmove).function_code
  movepower = realmove ? oldmove.baseDamage : GameData::Move.get(oldmove).base_damage
  #-----------------------------------------------------------------------------
  # Max Moves with a set BP in moves.txt PBS file.
  # This is only used for displaying move data in the Summary.
  #-----------------------------------------------------------------------------
  if displaymove
    displaypower = GameData::Move.get(displaymove).base_damage
    return displaypower if displaypower>1
  end
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 130 BP. (OHKO Moves)
  #-----------------------------------------------------------------------------
  if function=="070"
    return 130
  end
  case moveid
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 70 BP.
  #-----------------------------------------------------------------------------
  when :ARMTHRUST
    return 70
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 75 BP.
  #-----------------------------------------------------------------------------
  when :SEISMICTOSS, :COUNTER
    return 75
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 80 BP.
  #-----------------------------------------------------------------------------
  when :DOUBLEKICK, :TRIPLEKICK
    return 80
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 100 BP.
  #-----------------------------------------------------------------------------
  when :FURYSWIPES, :NIGHTSHADE, :FINALGAMBIT, :METALBURST, :MIRRORCOAT, :SUPERFANG,
       :BEATUP, :FLING, :LOWKICK, :PRESENT, :REVERSAL, :SPITUP
    return 100
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 120 BP.
  #-----------------------------------------------------------------------------
  when :DOUBLEHIT
    return 120
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 130 BP.
  #-----------------------------------------------------------------------------
  when :BULLETSEED, :BONERUSH, :ICICLESPEAR, :PINMISSILE, :ROCKBLAST, :TAILSLAP,
       :BONEMERANG, :DRAGONDARTS, :GEARGRIND, :SURGINGSTRIKES, :ENDEAVOR, :ELECTROBALL,
       :FLAIL, :GRASSKNOT, :GYROBALL, :HEATCRASH, :HEAVYSLAM, :POWERTRIP, :STOREDPOWER
    return 130
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 140 BP.
  #-----------------------------------------------------------------------------
  when :DOUBLEIRONBASH, :CRUSHGRIP
    return 140
  #-----------------------------------------------------------------------------
  # Becomes Max Move with 150 BP.
  #-----------------------------------------------------------------------------
  when :ERUPTION, :WATERSPOUT
    return 150
  end
  #-----------------------------------------------------------------------------
  # All other moves scale based on their BP.
  #-----------------------------------------------------------------------------
  if movepower <45
    basedamage = 90
    reduce     = 20
  elsif movepower <55
    basedamage = 100
    reduce     = 25
  elsif movepower <65
    basedamage = 110
    reduce     = 30
  elsif movepower <75
    basedamage = 120
    reduce     = 35
  elsif movepower <110
    basedamage = 130
    reduce     = 40
  elsif movepower <150
    basedamage = 140
    reduce     = 45
  elsif movepower >=150
    basedamage = 150
    reduce     = 50
  end
  #-------------------------------------------------------------------------
  # Fighting/Poison Max Moves have reduced BP.
  #-------------------------------------------------------------------------
  if movetype==1 || movetype==3
    basedamage -= reduce
  end
  return basedamage
end