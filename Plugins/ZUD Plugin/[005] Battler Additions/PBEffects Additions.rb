#===============================================================================
# New battler effects.
#===============================================================================
module PBEffects
  #-----------------------------------------------------------------------------
  # Battler effects used for compatibility with existing moves.
  #-----------------------------------------------------------------------------
  EncoreRestore    = 200  # Used to restore Encore after a Z-Move.
  MoveMimicked     = 201  # Used to treat Mimicked moves as Base Moves.
  TransformPokemon = 202  # Used to get the correct data for ZUD mechanics after Transforming.
  
  #-----------------------------------------------------------------------------
  # Battler effects used for Z-Move and Dynamax mechanics.
  #-----------------------------------------------------------------------------
  BaseMoves        = 203  # Records a Pokemon's base moves to revert to after Z-Moves/Dynamax.
  PowerMovesButton = 204  # Effect used for toggling between base moves and power moves.
  UsedZMoveIndex   = 205  # Records the index of the used Z-Move.  
  Dynamax          = 206  # The Dynamax state, and how many turns until it expires.
  NonGMaxForm      = 207  # Records a G-Max Pokemon's base form to revert to (used for Alcremie).
  MaxMovePP        = 208  # Records the PP usage of Max Moves while Dynamaxed.
  MaxGuard         = 209  # The effect for the move Max Guard.
  CriticalBoost    = 210  # Effect of G-Max Chi Strike and certain Z-Moves that boost crit chance.
  
  #-----------------------------------------------------------------------------
  # Battler effects used for Max Raid Battles.
  #-----------------------------------------------------------------------------
  MaxRaidBoss      = 211  # The effect that designates a Max Raid Pokemon.
  RaidShield       = 212  # The current HP for a Max Raid Pokemon's shields.
  MaxShieldHP      = 213  # The maximum total HP a Max Raid Pokemon's shields can have.
  ShieldCounter    = 214  # The counter for triggering Raid Shields and other effects.
  KnockOutCount    = 215  # The counter for KO's a Raid Pokemon needs to end the raid.
  
  
  #-----------------------------------------------------------------------------
  # Effects that apply to a side.
  #-----------------------------------------------------------------------------
  ZHeal            = 100  # The healing effect of Z-Parting Shot/Z-Memento.
  VineLash         = 101  # The lingering effect of G-Max Vine Lash.
  Wildfire         = 102  # The lingering effect of G-Max Wildfire.
  Cannonade        = 103  # The lingering effect of G-Max Cannonade.
  Volcalith        = 104  # The lingering effect of G-Max Volcalith.
  Steelsurge       = 105  # The hazard effect of G-Max Steelsurge.
end