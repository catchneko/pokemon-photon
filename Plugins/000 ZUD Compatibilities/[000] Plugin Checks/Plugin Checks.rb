#-------------------------------------------------------------------------------
# DO NOT TOUCH!
#-------------------------------------------------------------------------------
if defined?(Settings::ZUD_COMPAT)
  module Settings
    GEN8_COMPAT        = PluginManager.installed?("Generation 8 Project for Essentials v19.1")
    EBDX_COMPAT        = PluginManager.installed?("Elite Battle: DX")
    EMBS_COMPAT        = (PluginManager.installed?("Modular Battler Scene") || PluginManager.installed?("Essentials Modular Battler Scene"))
    BW_POKEDEX_COMPAT  = PluginManager.installed?("Pokedex BW Style")
    ADV_POKEDEX_COMPAT = PluginManager.installed?("Advanced Pokédex")
  end
end