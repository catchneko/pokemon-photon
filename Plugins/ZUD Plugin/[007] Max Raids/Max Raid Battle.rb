#===============================================================================
# Initializes a Max Raid battler.
#===============================================================================
class PokeBattle_Battler 
  def pbInitRaidBoss
    if @battle.wildBattle? && opposes?
      timerbonus = 0                      if @battle.pbSideSize(0)>=3
      timerbonus = ((level+5)/20).ceil+1  if @battle.pbSideSize(0)==2
      timerbonus = ((level+5)/10).floor+1 if @battle.pbSideSize(0)==1
      timerbonus = (level>20) ? timerbonus : 0
      raidtimer  = 1 + Settings::MAXRAID_TIMER + timerbonus
      raidtimer  = 6  if raidtimer<6
      raidtimer  = 26 if raidtimer>26
      kocount    = (level>55) ? Settings::MAXRAID_KOS-1 : Settings::MAXRAID_KOS
      kocount    = 1 if Settings::MAXRAID_KOS<1
      kocount    = 6 if Settings::MAXRAID_KOS>6
      shieldLvl  = Settings::MAXRAID_SHIELD
      shieldLvl += 1 if level>=70 || $game_switches[Settings::HARDMODE_RAID]
      for i in [25,35,45,55,65]
        shieldLvl +=1 if level>i
      end
      shieldLvl = 1 if shieldLvl<=0
      shieldLvl = 8 if shieldLvl>8
      @effects[PBEffects::Dynamax]       = raidtimer
      @effects[PBEffects::RaidShield]    = 0
      @effects[PBEffects::MaxShieldHP]   = shieldLvl
      @effects[PBEffects::KnockOutCount] = kocount
      @effects[PBEffects::ShieldCounter] = (level>35) ? 2 : 1
      for i in @moves; @effects[PBEffects::BaseMoves].push(i); end
      @effects[PBEffects::MaxRaidBoss]   = true
      if pbInDynAdventure?
        @effects[PBEffects::ShieldCounter] = 1
        @effects[PBEffects::MaxShieldHP]   = 5
        @effects[PBEffects::KnockOutCount] = pbDynAdventureState.knockouts
      end
    end
  end
  
#===============================================================================
# Handles success checks for moves used in Max Raid Battles.
#===============================================================================
  def pbSuccessCheckMaxRaid(move,user,target)
    ret = true
    if $game_switches[Settings::MAXRAID_SWITCH]
      #-------------------------------------------------------------------------
      # Max Raid Boss Pokemon are immune to specified moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::MaxRaidBoss]
        if move.function=="0F4" || # Bug Bite/Pluck
           move.function=="0F5" || # Incinerate
           move.function=="0F0" || # Knock Off
           move.function=="06C" || # Super Fang
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Specified moves fail when used by Max Raid Boss Pokemon.
      #-------------------------------------------------------------------------
      if user.effects[PBEffects::MaxRaidBoss]
        if move.function=="0E1" || # Final Gambit
           move.function=="0E2" || # Memento
           move.function=="0E7" || # Destiny Bond
           move.function=="0EB" || # Roar/Whirlwind
           move.function=="10C" || # Substitute
           (move.function=="10D" && user.pbHasType?(:GHOST)) # Curse
          @battle.pbDisplay(_INTL("But it failed!"))
          ret = false
        end
      end
      #-------------------------------------------------------------------------
      # Max Raid Shields block status moves.
      #-------------------------------------------------------------------------
      if target.effects[PBEffects::RaidShield]>0 && move.statusMove?
        @battle.pbDisplay(_INTL("But it failed!"))
        ret = false
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Ends multi-hit moves early if Raid Pokemon is defeated mid-attack.
  # Must be added to def pbUseMove
  #-----------------------------------------------------------------------------
  def _ZUD_BreakMultiHits(targets,hits)
    breakmove = false
    if $game_switches[Settings::MAXRAID_SWITCH]
      targets.each do |t|
        breakmove = true if t.hp<=1 && hits>0
      end
    end
    return breakmove
  end
  
  #-----------------------------------------------------------------------------
  # Max Raid Pokemon can use Belch without consuming a berry.
  #-----------------------------------------------------------------------------
  alias _ZUD_belched? belched?
  def belched?
    return true if @effects[PBEffects::MaxRaidBoss]
    return _ZUD_belched?
  end

  #-----------------------------------------------------------------------------
  # Deals damage to a Raid Pokemon's shields through Max Guard (only in 1v1 raids).
  #-----------------------------------------------------------------------------
  def pbRaidShieldBreak(move,target)
    if @battle.pbSideSize(0)==1 && move.maxMove? && move.damagingMove? &&
       target.effects[PBEffects::MaxRaidBoss] && target.effects[PBEffects::RaidShield]>0
      @battle.scene.pbDamageAnimation(target)
      @battle.pbDisplay(_INTL("{1}'s mysterious barrier took the hit!",target.pbThis))
      target.effects[PBEffects::RaidShield]-=1
      @battle.scene.pbRefresh
    end
  end
  
#===============================================================================
# Handles effects triggered upon using a move in Max Raid Battles.
#===============================================================================
  # Must be added to def pbProcessMoveHit
  def _ZUD_ProcessRaidEffects(move,user,targets,hitNum)
    targets.each do |b|
      if $game_switches[Settings::MAXRAID_SWITCH] && 
         b.effects[PBEffects::MaxRaidBoss] && 
         b.effects[PBEffects::KnockOutCount]>0
        shieldbreak = 1
        shieldbreak = 2 if move.powerMove? && move.damagingMove?
        if hitNum>0
          shieldbreak = 0
        end
        #-----------------------------------------------------------------------
        # Initiates Max Raid capture sequence if brought down to 0 HP.
        #-----------------------------------------------------------------------
        if b.hp<=0
          b.effects[PBEffects::RaidShield] = 0
          @battle.scene.pbRefresh
          b.pbFaint if b.fainted?
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon loses shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]>0
          next if !move.damagingMove?
          next if b.damageState.calcDamage==0
          next if shieldbreak==0
          if $DEBUG && Input.press?(Input::CTRL) # Instantly breaks shield.
            shieldbreak = b.effects[PBEffects::RaidShield]
          end
          b.effects[PBEffects::RaidShield] -= shieldbreak
          @battle.scene.pbRefresh
          if b.effects[PBEffects::RaidShield]<=0
            b.effects[PBEffects::RaidShield] = 0
            @battle.pbDisplay(_INTL("The mysterious barrier disappeared!"))
            oldhp = b.hp
            b.hp -= b.totalhp/8
            b.hp  =1 if b.hp<=1
            @battle.scene.pbHPChanged(b,oldhp)
            if b.hp>1
              b.pbLowerStatStage(:DEFENSE,2,false) 
              b.pbLowerStatStage(:SPECIAL_DEFENSE,2,false)
            end
          end
        #-----------------------------------------------------------------------
        # Max Raid Boss Pokemon gains shields.
        #-----------------------------------------------------------------------
        elsif b.effects[PBEffects::RaidShield]<=0
          shields1   = b.hp <= b.totalhp/2            # Activates at 1/2 HP
          shields2   = b.hp <= b.totalhp-b.totalhp/5  # Activates at 4/5ths HP
          if (b.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (b.effects[PBEffects::ShieldCounter]==2 && shields2)
            @battle.pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",b.pbThis))
            b.effects[PBEffects::RaidShield] = b.effects[PBEffects::MaxShieldHP]
            b.effects[PBEffects::ShieldCounter]-=1
			if Settings::EBDX_COMPAT
		      EliteBattle.playCommonAnimation(:RAIDSHIELD, @battle.scene, b.index)
		    else
		      @battle.pbAnimation(:LIGHTSCREEN,b,b)
	        end
            @battle.scene.pbRefresh
            @battle.pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",b.pbThis(true)))
          end
        end
        #-----------------------------------------------------------------------
        # Hard Mode Bonuses (Invigorating Wave)
        #-----------------------------------------------------------------------
        if ($game_switches[Settings::HARDMODE_RAID] || b.level>=70) && !pbInDynAdventure? 
          if b.effects[PBEffects::ShieldCounter]==0
            stat_stages = 0
            GameData::Stat.each_main_battle do |s|
              b.pbRaiseStatStageBasic(s.id,1,true) if b.pbCanRaiseStatStage?(s.id,b)
              stat_stages +=1 if b.stages[s.id]>0
            end
            if stat_stages > 0
              b.stages[:ACCURACY] = 0  if b.stages[:ACCURACY]<0
              b.stages[:EVASION]  = 0  if b.stages[:EVASION]<0
              @battle.pbDisplay(_INTL("{1} released an invigorating wave of Dynamax energy!",b.pbThis))
			  if Settings::EBDX_COMPAT
			    EliteBattle.playCommonAnimation(:RAIDWAVE, @battle.scene, b.index)
			  else
			    @battle.pbAnimation(:ACIDARMOR,b,b)
			  end
              @battle.pbCommonAnimation("StatUp",b)
              @battle.pbDisplay(_INTL("{1} got powered up!",b.pbThis))
            end
            b.effects[PBEffects::ShieldCounter]-=1
          end
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Hard Mode Bonuses (Malicious Wave).
  # Must be added to def pbProcessMoveHit
  #-----------------------------------------------------------------------------
  def _ZUD_ProcessRaidEffects2(move,user,targets)
    showMsg = true
    @battle.eachOtherSideBattler(user) do |b|
      if ($game_switches[Settings::HARDMODE_RAID] || user.level>=70) && !pbInDynAdventure?
        if move.damagingMove? &&
           !user.effects[PBEffects::TwoTurnAttack]  &&
           user.effects[PBEffects::MaxRaidBoss]     &&
           user.effects[PBEffects::KnockOutCount]>0 &&
           user.effects[PBEffects::RaidShield]<=0
          damage = b.realtotalhp/16 if user.effects[PBEffects::ShieldCounter]>=1
          damage = b.realtotalhp/8  if user.effects[PBEffects::ShieldCounter]<=0
          oldhp  = b.hp
          if b.hp>0 && !b.fainted?
			if showMsg
			  @battle.pbDisplay(_INTL("A malicious wave of Dynamax energy rippled from {1}'s attack!",user.pbThis(true)))
			  if Settings::EBDX_COMPAT
			    EliteBattle.playCommonAnimation(:RAIDWAVE, @battle.scene, user.index)
			  else
			    @battle.pbAnimation(:ACIDARMOR,b,user)
			  end
			end
            showMsg = false
            @battle.scene.pbDamageAnimation(b)
            b.hp -= damage
            b.hp=0 if b.hp<0
            @battle.scene.pbHPChanged(b,oldhp)
            b.pbFaint if b.fainted?
          end
        end
      end
      break if @battle.decision==3
    end
  end
  
  #-----------------------------------------------------------------------------
  # Allows a Raid Pokemon to strike multiple times in a turn.
  #-----------------------------------------------------------------------------
  def pbRaidBossUseMove(choice)
    if @effects[PBEffects::MaxRaidBoss] && 
       @effects[PBEffects::ShieldCounter]==0 && 
       @battle.pbSideSize(0)>1 && !choice[2].statusMove?
      basemoves = @effects[PBEffects::BaseMoves]
      for i in 1...@battle.pbSideSize(0)
        break if @battle.pbAllFainted?
        break if @battle.decision==3
        choice[2] = basemoves[rand(basemoves.length)]
        PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
        PBDebug.logonerr{
          pbUseMove(choice,choice[2]==@battle.struggle)
        }
      end
    end
  end
  
#===============================================================================
# Handles outcomes in Max Raid battles when party Pokemon are KO'd.
#===============================================================================
  def pbRaidKOCounter(target)
    if target.effects[PBEffects::MaxRaidBoss]
      pbDynAdventureState.knockouts -= 1 if pbInDynAdventure?
      target.effects[PBEffects::KnockOutCount] -= 1
      $game_variables[Settings::REWARD_BONUSES][1] = false # Perfect Bonus 
      @battle.scene.pbRefresh
      if target.effects[PBEffects::KnockOutCount]>=2
        @battle.pbDisplay(_INTL("The storm raging around {1} is growing stronger!",target.pbThis(true)))
        koboost=true
      elsif target.effects[PBEffects::KnockOutCount]==1
        @battle.pbDisplay(_INTL("The storm around {1} is growing too strong to withstand!",target.pbThis(true)))
        koboost=true
      elsif target.effects[PBEffects::KnockOutCount]==0
        @battle.pbDisplay(_INTL("The storm around {1} grew out of control!",target.pbThis(true)))
        @battle.pbDisplay(_INTL("You were blown out of the den!"))
        pbSEPlay("Battle flee")
        @battle.decision=3
      end
      #-------------------------------------------------------------------------
      # Max Raid - Hard Mode Bonuses (KO Boost).
      #-------------------------------------------------------------------------
      if koboost && ($game_switches[Settings::HARDMODE_RAID] || target.level>=70) && !pbInDynAdventure?
        showAnim=true
        for i in [:ATTACK,:SPECIAL_ATTACK]
          if target.pbCanRaiseStatStage?(i,target)
            target.pbRaiseStatStage(i,1,target,showAnim)
            showAnim=false
          end
        end
      end
      pbWait(20)
    end
  end
  
#===============================================================================
# Capturing a Max Raid Pokemon.
#===============================================================================
  def pbCatchRaidPokemon(target)
    @battle.pbDisplayPaused(_INTL("{1} is weak!\nThrow a Poké Ball now!",target.pbThis))
    pbWait(20)
    cmd = 0
    cmd = @battle.pbShowCommands("",["Catch","Don't Catch"],1)
    case cmd
    when 0 # Chooses "Catch"
      embBagPartyResize if Settings::EMBS_COMPAT # Compatibility for Modular Battle Scene
      scene  = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$PokemonBag)
      ball   = screen.pbChooseItemScreen(Proc.new{|item| GameData::Item.get(item).is_poke_ball? })
	  embStartOfBattleResize if Settings::EMBS_COMPAT # Compatibility for Modular Battle Scene											
      if ball
        if GameData::Item.get(ball).is_poke_ball?
          $PokemonBag.pbDeleteItem(ball,1)
          if $game_switches[Settings::HARDMODE_RAID] || target.level>=70
            randcapture = rand(100)
            # Hard Mode capture (20% unless Master Ball)
            if randcapture<20 || ball==:MASTERBALL || pbInDynAdventure? || ($DEBUG && Input.press?(Input::CTRL))
              @battle.pbThrowPokeBall(target.index,ball,9999,false)
            else
              @battle.pbThrowPokeBall(target.index,ball,0,false)
              @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
              pbSEPlay("Battle flee")
              @battle.decision=1
            end
          else
            # Normal Mode capture (100%)
            @battle.pbThrowPokeBall(target.index,ball,9999,false)
          end
        end
      else # If no ball is selected.
        @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
        pbSEPlay("Battle flee")
        @battle.decision=1
      end
    else # Chooses "Don't Catch"
      @battle.pbDisplayPaused(_INTL("{1} disappeared somewhere into the den...",target.pbThis))
      pbSEPlay("Battle flee")
      @battle.decision=1
    end
  end
end

#-------------------------------------------------------------------------------
# Prevents capture until defeated.
#-------------------------------------------------------------------------------
module PokeBattle_BattleCommon
  def _ZUD_RaidCaptureFail(battler,ball)
    if !($DEBUG && Input.press?(Input::CTRL))
      if $game_switches[Settings::MAXRAID_SWITCH] && battler.hp>1 && battler.effects[PBEffects::MaxRaidBoss]
        @scene.pbThrowAndDeflect(ball,1)
        pbDisplay(_INTL("The ball was repelled by a burst of Dynamax energy!"))
        return true
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Resets a Raid Pokemon upon capture.
  #-----------------------------------------------------------------------------
  def pbResetRaidPokemon(pkmn)
    pkmn.reset_moves if !pbInDynAdventure?
    pkmn.makeUndynamax
    pkmn.calc_stats
    pkmn.pbReversion(false)
    dlvl = rand(3)
    if    pkmn.level>65; dlvl += 6;
    elsif pkmn.level>55; dlvl += 5;
    elsif pkmn.level>45; dlvl += 4;
    elsif pkmn.level>35; dlvl += 3;
    elsif pkmn.level>25; dlvl += 2;
    end
    pkmn.setDynamaxLvl(dlvl)
    if pkmn.isSpecies?(:ETERNATUS)
      pkmn.removeGMaxFactor
      pkmn.setDynamaxLvl(0)
    end
	pkmn.heal
  end
  
  alias _ZUD_pbCaptureCalc pbCaptureCalc
  def pbCaptureCalc(*args)
    return 4 if $game_switches[Settings::MAXRAID_SWITCH] && !$game_switches[Settings::HARDMODE_RAID]
	_ZUD_pbCaptureCalc(*args)
  end
  
  alias _ZUD_pbStorePokemon pbStorePokemon
  def pbStorePokemon(pkmn)
    pbResetRaidPokemon(pkmn) if pkmn.dynamax?
    _ZUD_pbStorePokemon(pkmn)
  end
end

class PokeBattle_RealBattlePeer
  alias _ZUD_pbStorePokemon pbStorePokemon
  def pbStorePokemon(*args)
    return $PokemonStorage.pbStoreCaught(args[1]) if $game_switches[Settings::MAXRAID_SWITCH]
    _ZUD_pbStorePokemon(*args)
  end
end

#===============================================================================
# Handles changes to damage and effects taken by Max Raid Pokemon.
#===============================================================================
class PokeBattle_Move
  #-----------------------------------------------------------------------------
  # Damage thresholds for activating Max Raid shields.
  # Must be added to def pbReduceDamage
  #-----------------------------------------------------------------------------
  def _ZUD_ReduceMaxRaidDamage(target,damage)
    if target.effects[PBEffects::MaxRaidBoss] && $game_switches[Settings::MAXRAID_SWITCH]
      if target.effects[PBEffects::ShieldCounter]>0
        shield = target.effects[PBEffects::ShieldCounter]
        thresh = target.totalhp/5.floor if shield==2
        thresh = target.totalhp/2.floor if shield==1
        hpstop = target.totalhp-thresh
        if target.hp > hpstop && damage > target.hp-hpstop
          damage = target.hp-hpstop+1
        elsif target.hp <= hpstop
          damage = 1
        end
      end
    end
    return damage
  end

  #-----------------------------------------------------------------------------
  # Max Raid Pokemon take greatly reduced damage while shields are up.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    _ZUD_pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    if target.effects[PBEffects::RaidShield]>0
      multipliers[:final_damage_multiplier] /=24
    end
  end
  
  #-----------------------------------------------------------------------------
  # Max Raid Pokemon immune to additional effects of moves when shields are up.
  #-----------------------------------------------------------------------------
  alias _ZUD_pbAdditionalEffectChance pbAdditionalEffectChance
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.effects[PBEffects::MaxRaidBoss] && target.effects[PBEffects::RaidShield]>0
    return _ZUD_pbAdditionalEffectChance(user,target,effectChance=0)
  end
end

#===============================================================================
# Handles the different stages of battle.
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  # Displays encounter text for Raid Dens at the start of battle.
  #-----------------------------------------------------------------------------
  def pbRaidSendOut(sendOuts)
    foe = pbParty(1)[0]
    text = (foe.gmaxFactor?) ? "Gigantamax" : "Dynamaxed"
    text = "Eternamax" if foe.species==:ETERNATUS
    pbDisplayPaused(_INTL("Oh! A {1} {2} lurks in the den!",text,foe.name))
    msg = ""
    names = []
    toSendOut = []
    sent = sendOuts[0][0]
    for i in sent; names.push(@battlers[i].name); end
    case sent.length
    when 1; msg = _INTL("Go! {1}!\r\n",names[0])
    when 2; msg = _INTL("Go! {1} and {2}!\r\n",names[0],names[1])
    when 3; msg = _INTL("Go! {1}, {2} and {3}!\r\n",names[0],names[1],names[2])
    when 4; msg = _INTL("Go! {1}, {2}, {3} and {4}!\r\n",names[0],names[1],names[2],names[3])
    when 5; msg = _INTL("Go! {1}, {2}, {3}, {4} and {5}!\r\n",names[0],names[1],names[2],names[3],names[4])
    end
    toSendOut.concat(sent)
    pbDisplayBrief(msg) if msg.length>0
    animSendOuts = []
    toSendOut.each do |idxBattler|
      animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
    end
    pbSendOut(animSendOuts,true)
  end
  
  alias _ZUD_pbStartBattleSendOut pbStartBattleSendOut
  def pbStartBattleSendOut(sendOuts)
    if wildBattle? && $game_switches[Settings::MAXRAID_SWITCH]
      pbRaidSendOut(sendOuts)
    else
      _ZUD_pbStartBattleSendOut(sendOuts)
    end
  end
    
  #-----------------------------------------------------------------------------
  # Triggers a Raid Pokemon's wave attack during the Attack Phase.
  #-----------------------------------------------------------------------------
  def pbAttackPhaseRaidBoss
    pbPriority.each do |b|
      next unless b.effects[PBEffects::MaxRaidBoss]
      #-------------------------------------------------------------------------
      # Neutralizing Wave
      #-------------------------------------------------------------------------
      randnull   = pbRandom(10)
      neutralize = true if randnull<=2
      neutralize = true if b.status!=:NONE && randnull<=5
      neutralize = true if b.effects[PBEffects::RaidShield]>0 && randnull<=4 
      if neutralize && b.hp < b.totalhp-b.totalhp/5
        pbDisplay(_INTL("{1} released a neutralizing wave of Dynamax energy!",b.pbThis))
		if Settings::EBDX_COMPAT
		  EliteBattle.playCommonAnimation(:RAIDWAVE, @scene, b.index)
		else
		  pbAnimation(:ACIDARMOR,b,b)
	    end
        pbDisplay(_INTL("All stat increases and Abilities of your Pokémon were nullified!"))
        if b.status!=:NONE
          b.pbCureStatus(false)
          pbDisplay(_INTL("{1}'s status returned to normal!",b.pbThis))
        end
        b.eachOpposing do |p|
          p.effects[PBEffects::GastroAcid] = true
          GameData::Stat.each_battle { |s| p.stages[s.id] = 0 if p.stages[s.id] >0 }
        end
      end
      #-------------------------------------------------------------------------
      # Hard Mode Bonuses (Immobilizing Wave)
      #-------------------------------------------------------------------------
      if ($game_switches[Settings::HARDMODE_RAID] || b.level>=70) && !pbInDynAdventure?
        if b.effects[PBEffects::ShieldCounter]==-1 &&
           b.effects[PBEffects::RaidShield]<=0
          pbDisplay(_INTL("{1} released an immense wave of Dynamax energy!",b.pbThis))
          if Settings::EBDX_COMPAT
		    EliteBattle.playCommonAnimation(:RAIDWAVE, @scene, b.index)
		  else
		    pbAnimation(:ACIDARMOR,b,b)
	      end
          b.eachOpposing do |p|  
            if p.effects[PBEffects::Dynamax]>0
              pbDisplay(_INTL("{1} is unaffected!",p.pbThis))
            else
              pbDisplay(_INTL("The oppressive force immobilized {1}!",p.pbThis))
              p.effects[PBEffects::TwoTurnAttack] = nil
              pbClearChoice(p.index) if !p.movedThisRound?
            end
          end
          b.effects[PBEffects::ShieldCounter]-=1
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Effects that may trigger on a Max Raid Pokemon at the end of the round.
  #-----------------------------------------------------------------------------
  def pbEORMaxRaidEffects(boss) # Added to def pbEndOfRoundPhase
    if $game_switches[Settings::MAXRAID_SWITCH]
      if boss.effects[PBEffects::MaxRaidBoss] && boss.effects[PBEffects::KnockOutCount]>0
        for i in boss.moves; i.pp = i.total_pp; end
        #-----------------------------------------------------------------------
        # The Raid Pokemon starts using Max Moves after final round of shields.
        #-----------------------------------------------------------------------
        if boss.moves == boss.effects[PBEffects::BaseMoves]
          boss.pbDisplayPowerMoves(2) if boss.effects[PBEffects::ShieldCounter]<=0
        end
        #-----------------------------------------------------------------------
        # Raid Shield thresholds for effect damage.
        #-----------------------------------------------------------------------
        if boss.effects[PBEffects::RaidShield]<=0 && boss.hp>1
          shields1   = boss.hp <= boss.totalhp/2               # Activates at 1/2 HP
          shields2   = boss.hp <= boss.totalhp-boss.totalhp/5  # Activates at 4/5ths HP
          if (boss.effects[PBEffects::ShieldCounter]==1 && shields1) ||
             (boss.effects[PBEffects::ShieldCounter]==2 && shields2)
            pbDisplay(_INTL("{1} is getting desperate!\nIts attacks are growing more aggressive!",boss.pbThis))
            boss.effects[PBEffects::RaidShield] = boss.effects[PBEffects::MaxShieldHP]
            boss.effects[PBEffects::ShieldCounter]-=1
            @scene.pbRefresh
			if Settings::EBDX_COMPAT
		      EliteBattle.playCommonAnimation(:RAIDSHIELD, @scene, boss.index)
		    else
		      pbAnimation(:LIGHTSCREEN,boss,boss)
	        end
            pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!",boss.pbThis(true)))
          end
        end
        #-----------------------------------------------------------------------
        # Hard Mode Bonuses (HP Regeneration).
        #-----------------------------------------------------------------------
        if ($game_switches[Settings::HARDMODE_RAID] || boss.level>=70) && !pbInDynAdventure?  
          if boss.effects[PBEffects::RaidShield]>0 && 
             boss.effects[PBEffects::HealBlock]==0 && 
             boss.hp < boss.totalhp && boss.hp > 1 
            boss.pbRecoverHP((boss.totalhp/16).floor,true,true,true)
            pbDisplay(_INTL("{1} regenerated a little HP behind the mysterious barrier!",boss.pbThis))
          end
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Updates the raid scene at the end of each round and checks various counters.
  #-----------------------------------------------------------------------------
  def pbRaidUpdate(boss)
    if $game_switches[Settings::MAXRAID_SWITCH]
      @scene.pbRefresh
      if boss.effects[PBEffects::MaxRaidBoss]
        $game_variables[Settings::REWARD_BONUSES][0] = boss.effects[PBEffects::Dynamax] # Timer Bonus
        boss.eachOpposing do |opp|
          $game_variables[Settings::REWARD_BONUSES][2] = false if opp.level >= boss.level+5  # Fairness Bonus
        end
        if boss.effects[PBEffects::Dynamax]<=1 && boss.effects[PBEffects::KnockOutCount]>0
          pbDisplayPaused(_INTL("The storm around {1} grew out of control!",boss.pbThis(true)))
          pbDisplay(_INTL("You were blown out of the den!"))
          pbSEPlay("Battle flee")
          @decision=3
          pbDynAdventureState.knockouts = 0 if pbInDynAdventure?
        else
          # Revives any fainted Pokemon at the end of each turn.
          for i in pbParty(0)
            if i.fainted?
              i.heal
              pbSEPlay(sprintf("Anim/Lucky Chant"))
              pbDisplay(_INTL("{1} recovered from fainting!\nIt can be sent back out next turn!",i.name))
            end
          end
        end
      end
    end
  end
  
#===============================================================================
# Mechanics for the "Cheer" command used in Max Raid battles.
#===============================================================================
  def pbRegisterCheer(idxBattler)
    @choices[idxBattler][0] = :Cheer
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end
  
  def _ZUD_CheerMenu(idxBattler)
    return pbRegisterCheer(idxBattler)
  end
  
  def pbAttackPhaseCheer
    pbPriority.each do |b|
      next unless @choices[b.index][0]==:Cheer && !b.fainted?
      b.lastMoveFailed = false # Counts as a successful move for Stomping Tantrum
      pbCheer(b.index)
    end
  end
  
  #-----------------------------------------------------------------------------
  # The effects for the Cheer command used in battle.
  #-----------------------------------------------------------------------------
  def pbCheer(idxBattler)
    battler     = @battlers[idxBattler]
    boss        = battler.pbDirectOpposing(true)
    side        = battler.idxOwnSide
    owner       = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    trainerName = pbGetOwnerName(idxBattler)
    dmaxInUse   = false
    eachSameSideBattler(battler) { |b| dmaxInUse = true if b.dynamax? }
    #---------------------------------------------------------------------------
    # Builds a list of eligible Cheer effects and determines which to use.
    #---------------------------------------------------------------------------
    cheerEffects     = []
    cheerNoEffect    = 0
    cheerStatBoost   = 1
    cheerReflect     = 2
    cheerLightScreen = 3
    cheerHealParty   = 4
    cheerShieldBreak = 5
    cheerDynamax     = 6
    if $game_variables[Settings::REWARD_BONUSES][1]==false ||
       boss.effects[PBEffects::KnockOutCount] < pbPlayerBattlerCount
      cheered = 0
      eachSameSideBattler(battler) do |b|
        next if @choices[b.index][0] != :Cheer
        cheered += 1
      end
      #-------------------------------------------------------------------------
      # Effects for a single Cheer.
      #-------------------------------------------------------------------------
      if cheered==1
        cheerEffects.push(cheerStatBoost)
        cheerEffects.push(cheerReflect)     if battler.pbOwnSide.effects[PBEffects::Reflect]==0
        cheerEffects.push(cheerLightScreen) if battler.pbOwnSide.effects[PBEffects::LightScreen]==0
        if boss.effects[PBEffects::KnockOutCount]<3 || boss.effects[PBEffects::Dynamax]<5
          if cheered==pbPlayerBattlerCount
            cheerEffects.push(cheerShieldBreak) if boss.effects[PBEffects::RaidShield]>0
            cheerEffects.push(cheerDynamax)     if !dmaxInUse && @dynamax[side][owner]!=-1
            eachSameSideBattler(battler) do |b|
              cheerEffects.push(cheerHealParty) if b.hp < b.totalhp/2
            end
          end
        else
          cheerEffects.push(cheerNoEffect)
        end
      #-------------------------------------------------------------------------
      # Effects for a double Cheer.
      #-------------------------------------------------------------------------
      elsif cheered==2
        eachSameSideBattler(battler) do |b|
          cheerEffects.push(cheerHealParty) if b.hp < b.totalhp/2
        end
        if cheered==pbPlayerBattlerCount
          if boss.effects[PBEffects::KnockOutCount]<3 || boss.effects[PBEffects::Dynamax]<5
            cheerEffects.push(cheerShieldBreak) if boss.effects[PBEffects::RaidShield]>0
            cheerEffects.push(cheerDynamax)     if !dmaxInUse && @dynamax[side][owner]!=-1
          end
        end
        cheerEffects.push(cheerStatBoost) if cheerEffects.length==0
      #-------------------------------------------------------------------------
      # Effects for a triple Cheer or more.
      #-------------------------------------------------------------------------
      elsif cheered>=3
        if !dmaxInUse && @dynamax[side][owner]!=-1
          cheerEffects.push(cheerDynamax)
        elsif boss.effects[PBEffects::RaidShield]>0
          cheerEffects.push(cheerShieldBreak)
        end
        cheerEffects.push(cheerStatBoost) if cheerEffects.length==0
      end
      #-------------------------------------------------------------------------
    else
      cheerEffects.push(cheerNoEffect)
    end
    partyPriority = []
    pbPriority.each do |b|
      next if b.opposes?
      next if @choices[b.index][0] != :Cheer
      partyPriority.push(b)
    end
    randeffect = cheerEffects[rand(cheerEffects.length)]
    pbDisplay(_INTL("{1} cheered for {2}!",trainerName,battler.pbThis(true)))
    if randeffect!=cheerNoEffect
      msgD1 = _INTL("{1}'s Dynamax Band absorbed a little of the surrounding Dynamax Energy!",trainerName)
      msgD2 = _INTL("{1}'s Dynamax Band absorbed even more of the surrounding Dynamax Energy!",trainerName)
      msgE1 = _INTL("{1}'s cheering was powered up by all the Dynamax Energy!",trainerName)
      msgE2 = _INTL("{1}'s continuous cheering grew in power!",trainerName)
      if battler==partyPriority.first
        pbDisplay(msgD1) if randeffect==cheerDynamax
        pbDisplay(msgE1) if randeffect!=cheerDynamax
      else
        pbDisplay(msgD2) if randeffect==cheerDynamax
        pbDisplay(msgE2) if randeffect!=cheerDynamax
      end
    end
    case randeffect
    #---------------------------------------------------------------------------
    # Cheer Effect: No effect.
    #---------------------------------------------------------------------------
    when cheerNoEffect
      pbDisplay(_INTL("The cheer echoed feebly around the area..."))
    #---------------------------------------------------------------------------
    # Cheer Effect: Applies Reflect on the user's side.
    #---------------------------------------------------------------------------
    when cheerReflect
      pbAnimation(:REFLECT,battler,battler)
      battler.pbOwnSide.effects[PBEffects::Reflect] = 5
      pbDisplay(_INTL("Reflect raised {1}'s Defense!",battler.pbTeam(true)))
    #---------------------------------------------------------------------------
    # Cheer Effect: Applies Light Screen to the user's side.
    #---------------------------------------------------------------------------
    when cheerLightScreen
      pbAnimation(:LIGHTSCREEN,battler,battler)
      battler.pbOwnSide.effects[PBEffects::LightScreen] = 5
      pbDisplay(_INTL("Light Screen raised {1}'s Special Defense!",battler.pbTeam(true)))
    #---------------------------------------------------------------------------
    # Cheer Effect: Restores the HP and status of each ally Pokemon.
    # Only eligible when at least one party member is below 50% HP.
    #---------------------------------------------------------------------------
    when cheerHealParty
      if battler==partyPriority.last
        eachSameSideBattler(battler) do |b|
          if b.hp < b.totalhp
            b.pbRecoverHP(b.totalhp.floor)
            pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
          end
          status = b.status
          b.pbCureStatus(false)
          case status
          when :BURN;      pbDisplay(_INTL("{1} was healed of its burn!",b.pbThis))  
          when :POISON;    pbDisplay(_INTL("{1} was cured of its poison!",b.pbThis))  
          when :PARALYSIS; pbDisplay(_INTL("{1} was cured of its paralysis!",b.pbThis))
          when :SLEEP;     pbDisplay(_INTL("{1} woke up!",b.pbThis)) 
          when :FROZEN;    pbDisplay(_INTL("{1} thawed out!",b.pbThis)) 
          end
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Raises a random stat for each ally Pokemon.
    # The number of stages raised is based on how many Cheers were used.
    #---------------------------------------------------------------------------
    when cheerStatBoost
      if battler==partyPriority.last
        eachSameSideBattler(battler) do |b|
          stats = [:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:ACCURACY,:EVASION]
          stat  = stats[rand(stats.length)]
          if b.pbCanRaiseStatStage?(stat,b,nil,true)
            b.pbRaiseStatStage(stat,cheered,b)
          end
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Removes the Raid Pokemon's shield.
    # Only eligible when the Raid Timer or KO Counter is low.
    #---------------------------------------------------------------------------
    when cheerShieldBreak
      if battler==partyPriority.last
        @scene.pbDamageAnimation(boss)
        boss.effects[PBEffects::RaidShield] = 0
        @scene.pbRefresh
        pbDisplay(_INTL("The mysterious barrier disappeared!"))
        oldhp    = boss.hp
        boss.hp -= boss.totalhp/8
        boss.hp  =1 if boss.hp<=1
        @scene.pbHPChanged(boss,oldhp)
        if boss.hp>1
          boss.pbLowerStatStage(:DEFENSE,2,false) 
          boss.pbLowerStatStage(:SPECIAL_DEFENSE,2,false)
        end
      end
    #---------------------------------------------------------------------------
    # Cheer Effect: Replenishes the player's ability to Dynamax.
    # Only eligible when the Raid Timer or KO Counter is low.
    #---------------------------------------------------------------------------
    when cheerDynamax
      if battler==partyPriority.last
        @dynamax[side][owner] = -1
        pbSEPlay(sprintf("Anim/Lucky Chant"))
        pbWait(10)
        pbDisplay(_INTL("{1}'s Dynamax Band was fully recharged!\nDynamax is now usable again!",trainerName))
        pbWait(10)
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Displays the "Cheer" command instead of "Run" during Max Raid battles.
#-------------------------------------------------------------------------------
class CommandMenuDisplay < BattleMenuBase
  MODES += [[0,2,1,10]] # 5 = Max Raid Battle with "Cheer" instead of "Run"
end

class TargetMenuDisplay < BattleMenuBase
  MODES += [[0,2,1,10]] # 5 = Max Raid Battle with "Cheer" instead of "Run"
end

class PokeBattle_Scene
  def pbCommandMenu(idxBattler,firstAction)
    shadowTrainer = (GameData::Type.exists?(:SHADOW) && @battle.trainerBattle?)
    maxRaidBattle = $game_switches[Settings::MAXRAID_SWITCH]
    varCommand, mode = _INTL("Run"),    0 if firstAction
    varCommand, mode = _INTL("Cancel"), 1 if !firstAction
    varCommand, mode = _INTL("Call"),   2 if shadowTrainer
    varCommand, mode = _INTL("Cheer"),  5 if maxRaidBattle
    cmds = [
       _INTL("What will\n{1} do?",@battle.battlers[idxBattler].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       varCommand
    ]
    ret = pbCommandMenuEx(idxBattler,cmds,mode)
    ret = 4 if ret==3 && shadowTrainer   # Convert "Run" to "Call"
    if !($DEBUG && Input.press?(Input::CTRL))
      ret = 5 if ret==3 && maxRaidBattle   # Convert "Run" to "Cheer"
    end
    ret = -1 if ret==3 && !firstAction   # Convert "Run" to "Cancel"
    return ret
  end
  
  def pbCommandMenuEx(idxBattler,texts,mode=0)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler],mode)
    pbSelectBattler(idxBattler)
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index&1)==0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index&2)==0
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && [1,2,5].include?(mode)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    return ret
  end
end