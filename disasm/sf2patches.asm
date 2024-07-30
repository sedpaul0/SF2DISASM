
; 0 = OFF, 1 = ON

; TEST_BUILD: Game starts by applying all TEST_BUILD features below.
;   This is determined by whether standard.bat or standard-test.bat is used when building.

; Debugging facilitations
EASY_DEBUG_MODE:            equ 0       ; Toggle Debug Mode ON automatically when booting up the game.
EASY_BATTLE_TEST:           equ 0       ; If Debug Mode is on, go to Battle Test instead of playing the intro cutscene.
EASY_CONFIGURATION_MODE:    equ 0       ; Toggle Configuration Mode ON automatically, and skip checking if the Start button is pressed.
EASY_SOUND_TEST:            equ 0       ; Hold Up while entering Configuration Mode; there is no need to have set Game Completed save flag.
EASY_RENAME_CHARACTERS:     equ 0       ; Rename all characters when starting a new game.


; Debug build configuration
TEST_BUILD_SKIP_TO_NEW_GRANSEAL:            equ 1
TEST_BUILD_SKIP_NEW_GRANSEAL_CUTSCENE:      equ 1
TEST_BUILD_ALLIES_START_LEVEL:              equ 24
TEST_BUILD_INITIAL_DEBUG_MODE:              equ -1      ; -1 = toggle ON
TEST_BUILD_INITIAL_CONFIGURATION_MODE:      equ 0       ; -1 = toggle ON
TEST_BUILD_INITIAL_SPECIAL_TURBO:           equ -1      ; -1 = toggle ON
TEST_BUILD_INITIAL_CONTROL_OPPONENT:        equ 0       ; -1 = toggle ON
TEST_BUILD_INITIAL_AUTO_BATTLE:             equ 0       ; -1 = toggle ON
TEST_BUILD_INITIAL_GAME_COMPLETED:          equ 1
TEST_BUILD_INITIAL_MESSAGE_SPEED:           equ 3       ; [0, 3]
TEST_BUILD_INITIAL_NO_BATTLE_MESSAGES_TOGGLE: equ 0       ; 1 = no battle messages display ON


; Fixes
;
; Note that the following fixes are always being applied to the standard build :
; - FIX_CARAVAN_DESCRIPTIONS
; - FIX_CARAVAN_FREE_REPAIR_EXPLOIT -- Turning this off will reproduce the exploit, however the inventory will still be limited.
; - FIX_SPELL_LEARNING_PROMO_CHECK
;
FIX_AI_CLAUDE_ATTACK_RANGE:          equ 1   ; Corrects an oversight resulting in AI-controlled Claude to attack with the same 1-2 range as the Kraken Arm enemy.
FIX_CARAVAN_DESCRIPTIONS:            equ 1   ; Breaks up character list into chunks of 4.
FIX_CARAVAN_FREE_REPAIR_EXPLOIT:     equ 1   ; Preserves the broken bit when items are stored in the Caravan, though as a result, inventory size must be halved to 32 items.
FIX_COPY_SWAP_EXPLOIT:               equ 1   ; Some game data will be carried over from a previous file to a new one when deleting a save after copying it. Known items include: Character EXP, kills and defeats, item dropped flags, and queued up Mithril items.
FIX_COUNT_DEFEATED_ENEMIES:          equ 1   ; Fixes the death counter that impacts "swarm AI" for battles 16, 20, 21. In vanilla, does not impact battles 16, 20, but makes 21 more aggressive.
FIX_CRITICAL_HIT_DEFINITIONS:        equ 1   ; Makes the "Increase Critical" equipeffect never lower damage potential.
FIX_DWARVEN_MINER_VOICE:             equ 1   ; A cutscene has a fairy NPC concluding her dialogue, and when the dwarf delivers his first line, it uses the same female NPC speech sound effect until his follow-up dialogue line.
FIX_ELIS_DIALOGUE_ASSIGNMENT:        equ 1   ; A line of dialogue used during the cutscene in the tower underground room before Granseal's destruction is wrongly assigned to Bowie.
FIX_ENEMY_BATTLE_EQUIP:              equ 1   ; Enemies will equip battle items as designated in the battle spriteset.
FIX_EXPLORATION_MAGIC_MENU_ICONS:    equ 1   ; Applies the index mask $3F to spell entries when populating the currently displayed icons table.
FIX_FIELD_ITEM_CONSUMABLE:           equ 1   ; Field items will only be consumed if the CONSUMABLE flag is set.
FIX_GARBLED_HP_BAR:                  equ 1   ; Prevents drawing garbage pixels when HP is greater then 600 by continuing to draw black bars instead.
FIX_GIZMO_ARRANGEMENT:               equ 1   ; Moves the Gizmo enemies during the before battle cutscene to positions matching the battle formation.
FIX_GODDESS_STAFF_DEALS_EXPLOIT:     equ 1   ; If one of the following items is sitting in the Deals section after a DEF-CON switch is activated: Quick Ring, Protect Ring, White Ring, or Running Ring; a Goddess Staff will also be added to Deals.
FIX_GOLD_GIFT:                       equ 1   ; Gold increases when Minister gives you gift in New Granseal.
FIX_HIGINS_SPELL:                    equ 1   ; Prevents unequipping from possibly corrupting characters spell entries.
FIX_INCREASE_DOUBLE_RESETS_COUNTER:  equ 1   ; Equipment that increases the chance to double attack also erroneously set the chance to counter attack to 1/32.
FIX_KARNA_INCREASED_DOUBLE:          equ 1   ; 1 = No increased double, 2 = Sheela gets increased double instead.  An oddity in the character initialization routine causes the chance to double attack to be increased if the character happens to start knowing Heal 3.
FIX_KIWI_BREATH_UPGRADE_LEVELS:      equ 1   ; Kiwi's breath upgrades are based on effective rather than current level.
FIX_LABYRINTH_DELETION:              equ 1   ; Prevents a section of the labyrinth from being deleted due to AI region activation.
FIX_MISSING_RANDOM_BATTLES:          equ 1   ; Adds zone events for random battles without.
FIX_MOVEMENT_GLITCH:                 equ 1   ; The movement glitch is used in battles to reach places which are out of the controlled character's moving boundaries.
FIX_PRISM_FLOWER_OVERWORLD_ENTRANCE: equ 1   ; On Map 77, walking to the right on the tile closest to the bottom mountain brings the player into the Prism Flower battle rather than to the world map to the right.
FIX_SEARCH_IN_BATTLE:                equ 1   ; Restores the ability to search chests during battle.
FIX_SPELL_LEARNING_PROMO_CHECK:      equ 1   ; Correctly determine whether a character is promoted when learning spells.
FIX_USABLE_ITEM_VALIDATION:          equ 1   ; Compares an item's Use Spell index to the "No spell" index $3F instead of $FF.


; Quality of life features
NO_DEFEAT_ON_LEADER_DEATH:          equ 0       ; Death of the Force Leader character does not cause defeat.
LEADER_CAN_LEAVE_BATTLE_PARTY:      equ 0       ; Player is required to leave at least one member in the party. Message #20 should be edited to reflect this new rule.
CAPITALIZED_CHARACTER_NAMES:        equ 1       ; Capitalize allies and enemies names, as well as change "JAR" and the Chess Army's "DARK BISHOP" to "Jaro" and "Bishop".
CARAVAN_IN_TOWER:                   equ 1       ; Add access to Caravan before tower climb battle.
CUTSCENE_PROTECTION:                equ 1       ; Prevent game from freezing if dead character is needed for scene after leader death (as Slade for battle 5.)
MINIATURES_SHOP:                    equ 1       ; Place a shopworker on the desktop and floor of the Miniatures Room.
NO_AI_JARO:                         equ 0       ; 
NO_AI_PETER:                        equ 0       ; 
NO_DARKNESS_IN_CAVES:               equ 0       ; The darkness gimmick in caves is disabled.
NO_RANDOM_BATTLES:                  equ 1       ; 0 = Battles    1 = No Battles
RECRUIT_ALL_CREED_CHARACTERS:       equ 1       ; lets you recruit all four of them at any time after leaving Floor World.
SKIP_SEGA_LOGO:                     equ 0
SKIP_GAME_INTRO:                    equ 0
SKIP_TITLE_SCREEN:                  equ 0
SKIP_WITCH_DIALOGUE:                equ 0


; Misc. features
ADDITIONAL_EQUIPEFFECTS:            equ 1       ; Add new equipeffects to offer more options (Set ATT, Increase Resistance, Decrease Double...)
AGILITY_AFFECTS_CHANCE_TO_DODGE:    equ 0       ; Adjust chance to dodge proportionally to the difference between the attacker's and the target's current AGI.
ALL_ALLIES_JOINED:                  equ 0       ; All allies join from the beginning
DIAGONAL_LASERS:                    equ 0       ; Allows laser based enemies to fire in 8 directions (Up, Up-Left, Left, Down-Left, etc).
DIFFICULTY_FACTORS:                 equ 0       ; Allow 4 distinct difficulties.
EXPANDED_RANGES:                    equ 1       ; Weapons/spells can have ranges up to 7 and spell radii up to 4.
LEARN_SPELL_AT_PROMOTION:           equ 0       ; Allow learning 1 spell immediately upon promotion.
MUSCLE_MAGIC:                       equ 0       ; 0 = OFF, 1-256 = spell power increased by (muscleMagicStat * n) / 256
MUSCLE_MAGIC_STAT:                  equ 5       ; 0 = Max HP, 1 = Current HP, 2 = Max MP, 3 = Current MP, 4 = Base ATT, 5 = Current ATT, 6 = Base DEF, 7 = Current DEF, 8 = Base AGI, 9 = Current AGI
ORIGINAL_TAROS_INVULNERABILITY:     equ 0       ; 0 = OFF, 1 = Japanese version behavior (i.e, Bowie must continually attack to keep invulnerability off), 2 = SFCD behavior (invulnerability stays off for the remainder of the battle)
PER_LEVEL_CHURCH_COST:              equ 0       ; Raise/Cure cost based on ally level (double cost per promo level.)
PERCENT_POISON_DAMAGE:              equ 0       ; 1-100 = n% of max HP
PLAYER_DEFEAT_IS_GAME_OVER:         equ 0       ; On player defeat, rather than halve the gold and return to town, reset the game.
SEND_DESTROYED_ITEMS_TO_DEALS:      equ 1       ; Add item that was destroyed upon usage to shop deals if rare and if not a consumable.
SEND_DROPPED_ITEMS_TO_CARAVAN:      equ 1       ; If character inventory is full, add dropped item to the Caravan instead of shop deals, regardless of rarity. If the Caravan itself is full, then drops follow the usual routine: go to deals if rare, or become lost completely if not rare.
SPELLS_REFRESH_STATUS_COUNTERS:     equ 1       ; Boost, Slow, and Attack spells refresh status counters instead of failing, as long as the counter is increased by at least 1. Battle messages display the actual regained stats values.
TRADEABLE_ITEMS:                    equ 0       ; Allow trading items in battle without full inventory.
TRAP_DAMAGE_RAISES_WITH_DIFFICULTY: equ 0       ; Increase Laser/Burst Rock damage with difficulty.   Normal:100%  Hard:125%  Super: 150%  Ouch: 175%


; Special screens
CHAPTER_SCREEN:                     equ 0       ; Patch implementation with template SFCD screen as applicable example.


; AI enhancements
HEALER_AI_ENHANCEMENTS:             equ 0       ; See SF2_AI_Healing_Rewrite.txt for more details.
SUPPORT_AI_ENHANCEMENTS:            equ 1       ; Increase support spell options enemies can use.


; Menu enhancements
ACCURATE_LAND_EFFECT_DISPLAY:       equ 1       ; Read values to be displayed from a table. Damage multipliers are converted to reduction percent values during assembly through a macro.
ALTERNATE_JEWEL_ICONS_DISPLAY:      equ 1       ; 1 = small icons, 2 = no display
EIGHT_CHARACTERS_MEMBER_NAMES:      equ 1       ; 
EXTENDED_SPELL_NAMES:               equ 1       ; 
EXTENDED_STATUS:                    equ 1       ; Display additional information on the member screen: Promotion indicator, Critical hit type and chance, Double and Counter chances, Resistance levels, and Movetype name.
FULL_CLASS_NAMES:                   equ 1       ; 
SHOW_ALL_SPELLS_IN_MEMBER_SCREEN:   equ 0       ; 
SHOW_ENEMY_LEVEL:                   equ 1       ; 
THREE_DIGITS_STATS:                 equ 1       ; 

; If standard build, and either THREE_DIGITS_STATS or FULL_CLASS_NAMES are enabled, implement a second member list stats page.
secondMembersListPage = 0
    if (STANDARD_BUILD&(THREE_DIGITS_STATS|FULL_CLASS_NAMES)=1)
secondMembersListPage = 1
    endif
SECOND_MEMBERS_LIST_PAGE: equ secondMembersListPage


; Sound driver
MUSIC_RESUMING:                     equ 1       ; 
RESUME_BATTLEFIELD_MUSIC_ONLY:      equ 1       ; Do not resume battlescene music.
RESUME_MUSIC_AFTER_JOIN_JINGLE:     equ 1       ; Resume background music after playing a "Joined the Force" jingle.

resumeBattlesceneMusic = 1
    if (RESUME_BATTLEFIELD_MUSIC_ONLY=1)
resumeBattlesceneMusic = 0
    endif
RESUME_BATTLESCENE_MUSIC: equ resumeBattlesceneMusic


; Data expansions
EXPANDED_CLASSES:           equ 1       ; Enable support for 64 classes.
EXPANDED_FORCE_MEMBERS:     equ 1       ; Enable all 32 force members supported by the engine instead of 30.
EXPANDED_ITEMS_AND_SPELLS:  equ 1       ; Expand number of items from 127 to 255, and number of spells from 44 to 63. Forces build of a >= 4MB ROM with 32KB SRAM.
EXPANDED_MAPSPRITES:        equ 1       ; Store mapsprite index in word-sized structure allowing 65k+ unique sprites.


; ROM expansions
ROM_EXPANSION:              equ 1       ; 0 = 2 MB ROM, 1 = 4 MB ROM (default), 2 = 6 MB ROM
SRAM_EXPANSION:             equ 1       ; Expand SRAM from 8KB to 32KB.
SAVED_DATA_EXPANSION:       equ 1       ; Relocate currently loaded saved data from system RAM to cartridge SaveRAM.

; If standard build, and either ROM_EXPANSION or EXPANDED_ITEMS_AND_SPELLS are enabled, build an expanded ROM.
expandedRom = 0
    ;if (STANDARD_BUILD&(ROM_EXPANSION!EXPANDED_ITEMS_AND_SPELLS)=1)
    if (STANDARD_BUILD=1)
        if (ROM_EXPANSION!EXPANDED_ITEMS_AND_SPELLS>=1)
expandedRom = 1
        endif
    endif
EXPANDED_ROM: equ expandedRom

; If building a >= 6MB ROM, implement ROM and SRAM mapping management, supporting both SEGA and Extended SSF mappers.
memoryMapper = 0
    if (ROM_EXPANSION>=2)
memoryMapper = 1
    endif
MEMORY_MAPPER: equ memoryMapper
SSF_SYSTEM_ID: equ 0    ; Put "SEGA SSF" string in ROM header to activate memory mapper on Mega EverDrive cartridges.

; If standard build, and either SRAM_EXPANSION, SAVED_DATA_EXPANSION, or EXPANDED_ITEMS_AND_SPELLS are enabled, expand SRAM.
expandedSram = 0
    if (STANDARD_BUILD&(SRAM_EXPANSION!SAVED_DATA_EXPANSION!EXPANDED_ITEMS_AND_SPELLS)=1)
expandedSram = 1
    endif
EXPANDED_SRAM: equ expandedSram

; If standard build, and SAVED_DATA_EXPANSION is enabled, relocate saved data to cartridge SaveRAM.
relocatedSavedData = 0
    if (STANDARD_BUILD&SAVED_DATA_EXPANSION=1)
relocatedSavedData = 1
    endif
RELOCATED_SAVED_DATA_TO_SRAM: equ relocatedSavedData


; Assembler optimizations
OPTIMIZED_PC_RELATIVE_ADDRESSING:   equ 1       ; Optimize to PC relative addressing.
OPTIMIZED_SHORT_BRANCHES:           equ 1       ; Optimize short branches.
OPTIMIZED_ABSOLUTE_LONG_ADDRESSING: equ 1       ; Optimize absolute long addressing.
OPTIMIZED_ZERO_DISPLACEMENTS:       equ 1       ; Optimize zero displacements.
OPTIMIZED_ADDS_TO_QUICK_FORM:       equ 1       ; Optimize adds to quick form.
OPTIMIZED_SUBS_TO_QUICK_FORM:       equ 1       ; Optimize subtract to quick form.
OPTIMIZED_MOVE_TO_QUICK_FORM:       equ 1       ; Optimize move to quick form.


    ; Apply optional assembler optimizations.
    if (STANDARD_BUILD&OPTIMIZED_PC_RELATIVE_ADDRESSING=1)
        opt op+     ; Switches to PC relative addressing from absolute long addressing if this is permissible in the current code context.
    endif
    if (STANDARD_BUILD&OPTIMIZED_SHORT_BRANCHES=1)
        opt os+     ; Backwards relative branches will use the short form if this is permissible in the current code context.
    endif
    if (STANDARD_BUILD&OPTIMIZED_ABSOLUTE_LONG_ADDRESSING=1)
        opt ow+     ; If the absolute long addressing mode is used but the address will only occupy a word, the Assembler will switch to the short form.
    endif
    if (STANDARD_BUILD&OPTIMIZED_ZERO_DISPLACEMENTS=1)
        opt oz+     ; If the address register is used with a zero displacement, the Assembler will switch to the address register indirect mode.
    endif
    
    ; When these options are enabled, provided that it is permissible in the current code context, all ADD, SUB and MOVE instructions are coded as quick forms.
    if (STANDARD_BUILD&OPTIMIZED_ADDS_TO_QUICK_FORM=1)
        opt oaq+
    endif
    if (STANDARD_BUILD&OPTIMIZED_SUBS_TO_QUICK_FORM=1)
        opt osq+
    endif
    if (STANDARD_BUILD&OPTIMIZED_MOVE_TO_QUICK_FORM=1)
        opt omq+
    endif
