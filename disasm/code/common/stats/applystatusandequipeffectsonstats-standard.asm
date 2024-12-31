
; ASM FILE code\common\stats\applystatusandequipeffectsonstats-standard.asm :
;

; =============== S U B R O U T I N E =======================================

; In: d0.w = ally index

LearnAllKnownSpells:
                      
                bsr.w   CalculateEffectiveLevel
                move.w  d1,d5
                bsr.w   GetClass
                
                ; Get pointer to stat block for class d1.b
                move.w  d0,d2
                lsl.w   #INDEX_SHIFT_COUNT,d2
                getPointer p_pt_AllyStats, a0
                movea.l (a0,d2.w),a0
@FindStatsBlockForClass_Loop:
                
                tst.b   (a0)
                bmi.s   @Return         ; exit function if no matching block found
                
                cmp.b   (a0)+,d1
                beq.s   @Continue
@FindNextStatsBlock_Loop:
                
                cmpi.b  #ALLYSTATS_CODE_USE_FIRST_SPELL_LIST,(a0)+ ; loop until we come across an "end of spell list" control code
                bcs.s   @FindNextStatsBlock_Loop
                bra.s   @FindStatsBlockForClass_Loop
@Continue:
                
                lea     ALLYSTATS_OFFSET_SPELL_LIST_MINUS_ONE(a0),a0
@FindAllLearnableSpells_Loop:
                
                bsr.s   FindNextLearnableSpell
                tst.w   d2
                bne.s   @Next
                moveq   #0,d2
@Next:          
                
                bpl.s   @FindAllLearnableSpells_Loop
@Return:
                
                rts

    ; End of function LearnAllKnownSpells


; =============== S U B R O U T I N E =======================================

; In: a0 = pointer to ally spell list entry
;     d0.w = ally index
;     d5.w = current level
;
; Out: d2.w = 0: successfully learned spell
;             1: failure : same or higher level spell already known
;             2: failure : all spell slots already occupied
;            -1: current level is too low, or end of spell list has been reached

                module
@GetFirstSpellList:
                
                move.w  d0,d2
                lsl.w   #INDEX_SHIFT_COUNT,d2
                movea.l (p_pt_AllyStats).l,a0
                movea.l (a0,d2.w),a0
                lea     ALLYSTATS_OFFSET_SPELL_LIST(a0),a0
FindNextLearnableSpell:
                
                move.b  (a0)+,d2            ; d2 = level which spell is learned at
                move.b  (a0)+,d1            ; d1 = spell index
                cmp.b   d2,d5
                bhs.w   LearnSpell
                
                cmpi.b  #ALLYSTATS_CODE_USE_FIRST_SPELL_LIST,d2
                beq.s   @GetFirstSpellList
                
                moveq   #-1,d2
                rts
                
                modend
                
    ; End of function FindNextLearnableSpell


; =============== S U B R O U T I N E =======================================

; Update all current stats


ApplyStatusEffectsAndItemsOnStats:
                
                movem.l d0-a2,-(sp)
                
                ; Initialize current stats
                ;
                ; a0 = multi usage pointer
                ; a1 = combatant item entry pointer
                ; a2 = start of combatant entry pointer
                ;
                bsr.w   GetCombatantEntryAddress
                movea.l a0,a1
                movea.l a0,a2
                move.b  COMBATANT_OFFSET_ATT_BASE(a2),COMBATANT_OFFSET_ATT_CURRENT(a2)
                move.b  COMBATANT_OFFSET_DEF_BASE(a2),COMBATANT_OFFSET_DEF_CURRENT(a2)
                move.b  COMBATANT_OFFSET_AGI_BASE(a2),COMBATANT_OFFSET_AGI_CURRENT(a2)
                move.b  COMBATANT_OFFSET_MOV_BASE(a2),COMBATANT_OFFSET_MOV_CURRENT(a2)
                move.b  COMBATANT_OFFSET_PROWESS_BASE(a2),COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                getSavedWord (a2), d1, COMBATANT_OFFSET_RESIST_BASE
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT
                
                ; Unlearn all spells
                move.l  #LONGWORD_SPELLS_INITVALUE,d1
                setSavedLong d1, (a2), COMBATANT_OFFSET_SPELLS
                
                ; Get all status effects except Curse
                getSavedWord (a2), d3, COMBATANT_OFFSET_STATUSEFFECTS ; Get Status Effects -> d3.w
                andi.w  #($FFFF-STATUSEFFECT_CURSE),d3
                
                ; Relearn all spells, and initialize movetype while preserving current AI commandset
                tst.b   d0
                bmi.s   @Enemy
                
                ; Relearn known spells for ally and get move type from class definition
                bsr.w   LearnAllKnownSpells
                clr.w   d1
                move.b  COMBATANT_OFFSET_CLASS(a2),d1
                mulu.w  #CLASSDEF_ENTRY_SIZE,d1
                getPointer p_table_ClassDefinitions, a0
                adda.w  d1,a0
                move.b  CLASSDEF_OFFSET_MOVETYPE(a0),d1
                bra.s   @Continue
@Enemy:
                ; Relearn known spells and get move type from enemy definition
                clr.w   d1
                move.b  COMBATANT_OFFSET_ENEMY_INDEX(a2),d1
                mulu.w  #ENEMYDEF_ENTRY_SIZE,d1
                getPointer p_table_EnemyDefinitions, a0
                adda.w  d1,a0
                
                ; Relearn known spells
                move.l  ENEMYDEF_OFFSET_SPELLS(a0),d1
                setSavedLong d1, (a2), COMBATANT_OFFSET_SPELLS
                
                ; Get move type
                move.b  ENEMYDEF_OFFSET_SPELLS(a0),d1
@Continue:
                
                andi.b  #BYTE_UPPER_NIBBLE_MASK,d1
                move.b  COMBATANT_OFFSET_MOVETYPE_AND_AI(a2),d2
                andi.b  #BYTE_LOWER_NIBBLE_MASK,d2
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_MOVETYPE_AND_AI(a2)
                
                ; Apply equip effects on stats
                moveq   #COMBATANT_ITEMSLOTS_COUNTER,d2
@Loop:
                
                getSavedWord (a1), d1, COMBATANT_OFFSET_ITEMS
                andi.w  #ITEMENTRY_MASK_INDEX,d1
                cmpi.w  #ITEM_NOTHING,d1
                beq.s   @Next
                
                isItemEquipped (a1)
                beq.s   @Next
                bsr.w   ApplyItemOnStats
                beq.s   @Next
                ori.w   #STATUSEFFECT_CURSE,d3
@Next:
                
                addq.w  #ITEMENTRY_SIZE,a1
                dbf     d2,@Loop
                
                ; Apply status effects on stats
                bsr.s   ApplyStatusEffectsOnStats
                setSavedWord d3, (a2), COMBATANT_OFFSET_STATUSEFFECTS ; d3.w -> Set Status Effects
                movem.l (sp)+,d0-a2
                rts

    ; End of function ApplyStatusEffectsAndItemsOnStats


; =============== S U B R O U T I N E =======================================

; In: d0.w = combatant index
;     d3.w = status effects bitfield


ApplyStatusEffectsOnStats:
                
                clr.l   d1
                move.w  d3,d2
                andi.w  #STATUSEFFECT_ATTACK,d2
                rol.w   #2,d2
                bsr.w   GetBaseAtt
                mulu.w  d2,d1
                lsr.l   #3,d1
                bsr.w   IncreaseCurrentAtt
                move.w  d3,d2
                andi.w  #STATUSEFFECT_BOOST,d2
                rol.w   #4,d2
                bsr.w   GetBaseDef
                mulu.w  d2,d1
                lsr.l   #3,d1
                bsr.w   IncreaseCurrentDef
                bsr.w   GetBaseAgi
                mulu.w  d2,d1
                lsr.l   #3,d1
                bsr.w   IncreaseCurrentAgi
                move.w  d3,d2
                andi.w  #STATUSEFFECT_SLOW,d2
                rol.w   #6,d2
                bsr.w   GetBaseDef
                mulu.w  d2,d1
                lsr.l   #3,d1
                bsr.w   DecreaseCurrentDef
                bsr.w   GetBaseAgi
                mulu.w  d2,d1
                lsr.l   #3,d1
                bsr.w   DecreaseCurrentAgi
                btst    #STATUSEFFECT_BIT_STUN,d3
                beq.s   @Return
                moveq   #1,d1
                bsr.w   DecreaseCurrentMov
                moveq   #5,d1
                bra.w   DecreaseCurrentAgi
@Return:
                
                rts

    ; End of function ApplyStatusEffectsOnStats


; =============== S U B R O U T I N E =======================================

; In: d0.w = combatant index
;     d1.w = item index


ApplyItemOnStats:
                
                bsr.w   GetItemDefAddress
                tst.b   d0
                bmi.s   @Enemy
                
                btst    #ITEMTYPE_BIT_CURSED,ITEMDEF_OFFSET_TYPE(a0)
                bra.s   @Continue       
@Enemy:
                
                clr.w   d2
@Continue:
                
                move    sr,-(sp)        ; store test result
                
                movem.l d1-d2/d7-a1,-(sp)
                lea     ITEMDEF_OFFSET_EQUIPEFFECTS(a0),a0
                clr.w   d2
                moveq   #EQUIPEFFECTS_COUNTER,d7
@Loop:
                
                ; Get effect code -> d1.b, and parameter -> d2.w
                moveq   #EQUIPEFFECTS_COUNTER,d2
                sub.w   d7,d2
                move.w  d2,d1
                add.w   d1,d1
                move.w  EQUIPEFFECT_OFFSET_PARAMETER(a0,d1.w),d1
                move.b  (a0,d2.w),d2
                cmpi.b  #-1,d2
                beq.s   @Next
                
                cmpi.b  #EQUIPEFFECTS_MAX_INDEX,d2
                blo.s   @ExecuteEquipEffectFunction
@InfiniteLoop:
                
                bra.s   @InfiniteLoop   ; caught in an infinite loop if equip effect index is too high
@ExecuteEquipEffectFunction:
                
                lsl.w   #INDEX_SHIFT_COUNT,d2
                lea     pt_EquipEffectFunctions(pc,d2.w),a1
                movea.l (a1),a1
                jsr     (a1)
@Next:
                
                dbf     d7,@Loop
                
                movem.l (sp)+,d1-d2/d7-a1
                rtr

    ; End of function ApplyItemOnStats

pt_EquipEffectFunctions:
                dc.l equipEffect_Nothing
                dc.l IncreaseCurrentAtt
                dc.l IncreaseCurrentDef
                dc.l IncreaseCurrentAgi
                dc.l IncreaseCurrentMov
                dc.l equipEffect_IncreaseCriticalProwess
                dc.l equipEffect_IncreaseDoubleAttackProwess
                dc.l equipEffect_IncreaseCounterAttackProwess
                dc.l equipEffect_IncreaseResistance
                dc.l DecreaseCurrentAtt
                dc.l DecreaseCurrentDef
                dc.l DecreaseCurrentAgi
                dc.l DecreaseCurrentMov
                dc.l equipEffect_DecreaseCriticalProwess
                dc.l equipEffect_DecreaseDoubleAttackProwess
                dc.l equipEffect_DecreaseCounterAttackProwess
                dc.l equipEffect_DecreaseResistance
                dc.l SetCurrentAtt
                dc.l SetCurrentDef
                dc.l SetCurrentAgi
                dc.l SetCurrentMov
            if (FIX_CRITICAL_HIT_DEFINITIONS=1)
                dc.l equipEffect_SetCritical150
                dc.l equipEffect_SetCritical125
            else
                dc.l equipEffect_Nothing
                dc.l equipEffect_Nothing
            endif
                dc.l equipEffect_SetCriticalProwess
                dc.l equipEffect_SetDoubleAttackProwess
                dc.l equipEffect_SetCounterAttackProwess
                dc.l equipEffect_SetWindResistance
                dc.l equipEffect_SetLightningResistance
                dc.l equipEffect_SetIceResistance
                dc.l equipEffect_SetFireResistance
                dc.l equipEffect_SetStatusResistance
                dc.l equipEffect_SetStatus
                dc.l equipEffect_SetMoveType
                dc.l LearnSpell
                dc.l equipEffect_UnlearnAllSpells

; =============== S U B R O U T I N E =======================================


equipEffect_Nothing:
                
                rts

    ; End of function equipEffect_Nothing


; =============== S U B R O U T I N E =======================================


equipEffect_DecreaseCriticalProwess:
                
                neg.b   d1

    ; End of function equipEffect_DecreaseCriticalProwess


; =============== S U B R O U T I N E =======================================


equipEffect_IncreaseCriticalProwess:
                
            if (FIX_CRITICAL_HIT_DEFINITIONS=1)
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL,d2
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                bhs.s   @Continue       ; skip if not a critical hit setting, i.e., no critical or ailment infliction
                
                ; Does the combatant currently inflict a regular or a stronger critical?
                cmpi.b  #4,d2
                bhs.s   @StrongerCritical
                
                ; Increase chance to perform a regular critical
                add.b   d1,d2
                bmi.s   @Min125                         ; clamp to zero on negative
                cmpi.b  #PROWESS_CRITICAL150_1IN32,d2
                moveq   #PROWESS_CRITICAL125_1IN4,d2    ; cap to highest regular (+25%) critical hit setting
                bra.s   @Continue
@Min125:        
                
                moveq   #PROWESS_CRITICAL125_1IN32,d2
                bra.s   @Continue
@StrongerCritical:
                
                ; Increase chance to perform a stronger critical
                add.b   d1,d2
                cmpi.b  #PROWESS_CRITICAL150_1IN32,d2
                blt.s   @Min150                         ; clamp to 4 on less than and also on negative
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                blo.s   @Continue
                moveq   #PROWESS_CRITICAL150_1IN4,d2    ; cap to highest stronger (+50%) critical hit setting
                bra.s   @Continue
@Min150:        
                
                moveq   #PROWESS_CRITICAL150_1IN32,d2
            else
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL,d2
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                bcc.s   @Continue                       ; skip if not a regular critical hit setting
                add.b   d1,d2
                bmi.s   @Zero                           ; clamp to zero on negative
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                blo.s   @Continue
                moveq   #PROWESS_CRITICAL125_1IN4,d2    ; cap to highest regular critical hit setting
                bra.s   @Continue
@Zero:          
                
                moveq   #0,d2
            endif
@Continue:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d1
                andi.b  #PROWESS_MASK_DOUBLE|PROWESS_MASK_COUNTER,d1
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_IncreaseCriticalProwess



; =============== S U B R O U T I N E =======================================


equipEffect_DecreaseDoubleAttackProwess:
                
                neg.b   d1

    ; End of function equipEffect_DecreaseDoubleAttackProwess


; =============== S U B R O U T I N E =======================================


equipEffect_IncreaseDoubleAttackProwess:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                lsr.b   #PROWESS_LOWER_DOUBLE_SHIFT_COUNT,d2
                andi.b  #PROWESS_MASK_LOWER_DOUBLE_OR_COUNTER,d2
                add.b   d1,d2
                bmi.s   @Zero           ; clamp to zero on negative
                cmpi.b  #4,d2
                blo.s   @Continue
                moveq   #3,d2           ; cap to highest double attack setting
                bra.s   @Continue
@Zero:          
                
                moveq   #0,d2
@Continue:
                
                lsl.b   #PROWESS_LOWER_DOUBLE_SHIFT_COUNT,d2
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d1
                andi.b  #PROWESS_MASK_CRITICAL|PROWESS_MASK_COUNTER,d1 ; FIX_INCREASE_DOUBLE_RESETS_COUNTER
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_IncreaseDoubleAttackProwess


; =============== S U B R O U T I N E =======================================


equipEffect_DecreaseCounterAttackProwess:
                
                neg.b   d1

    ; End of function equipEffect_DecreaseCounterAttackProwess


; =============== S U B R O U T I N E =======================================


equipEffect_IncreaseCounterAttackProwess:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                lsr.b   #PROWESS_LOWER_COUNTER_SHIFT_COUNT,d2
                andi.b  #PROWESS_MASK_LOWER_DOUBLE_OR_COUNTER,d2
                add.b   d1,d2
                bmi.s   @Zero           ; clamp to zero on negative
                cmpi.b  #4,d2
                bcs.s   @Continue
                moveq   #3,d2           ; cap to highest counter attack setting
                bra.s   @Continue
@Zero:          
                
                moveq   #0,d2
@Continue:
                
                lsl.b   #PROWESS_LOWER_COUNTER_SHIFT_COUNT,d2
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d1
                andi.b  #PROWESS_MASK_CRITICAL|PROWESS_MASK_DOUBLE,d1
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts
                
    ; End of function equipEffect_IncreaseCounterAttackProwess


; =============== S U B R O U T I N E =======================================


equipEffect_SetCritical150:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL,d2
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                bhs.s   @Continue       ; skip if not a critical hit setting, i.e., no critical or ailment infliction
                
                bset    #2,d2           ; put current critical in the 4-7 range
@Continue:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d1
                andi.b  #PROWESS_MASK_DOUBLE|PROWESS_MASK_COUNTER,d1
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_SetCritical150


; =============== S U B R O U T I N E =======================================


equipEffect_SetCritical125:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL,d2
                cmpi.b  #PROWESS_CRITICAL_NONE,d2
                bhs.s   @Continue       ; skip if not a critical hit setting, i.e., no critical or ailment infliction
                
                bclr    #2,d2           ; put current critical in the 0-3 range
@Continue:
                
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d1
                andi.b  #PROWESS_MASK_DOUBLE|PROWESS_MASK_COUNTER,d1
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_SetCritical125


; =============== S U B R O U T I N E =======================================


equipEffect_SetCriticalProwess:
                
                andi.b  #PROWESS_MASK_CRITICAL,d1
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_DOUBLE|PROWESS_MASK_COUNTER,d2
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_SetCriticalProwess


; =============== S U B R O U T I N E =======================================


equipEffect_SetDoubleAttackProwess:
                
                andi.b  #PROWESS_MASK_LOWER_DOUBLE_OR_COUNTER,d1
                lsl.b   #PROWESS_LOWER_DOUBLE_SHIFT_COUNT,d1
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL|PROWESS_MASK_COUNTER,d2
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_SetDoubleAttackProwess


; =============== S U B R O U T I N E =======================================


equipEffect_SetCounterAttackProwess:
                
                andi.b  #PROWESS_MASK_LOWER_DOUBLE_OR_COUNTER,d1
                lsl.b   #PROWESS_LOWER_COUNTER_SHIFT_COUNT,d1
                move.b  COMBATANT_OFFSET_PROWESS_CURRENT(a2),d2
                andi.b  #PROWESS_MASK_CRITICAL|PROWESS_MASK_DOUBLE,d2
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_PROWESS_CURRENT(a2)
                rts

    ; End of function equipEffect_SetCounterAttackProwess


; =============== S U B R O U T I N E =======================================

                module ; start of resistance modification module

equipEffect_DecreaseResistance:
                
                movem.l d3-d7,-(sp)
                moveq   #-1,d6 ; subtract toggle
                bra.s   equipEffect_ModifyResistance

    ; End of function equipEffect_DecreaseResistance


; =============== S U B R O U T I N E =======================================

equipEffect_IncreaseResistance:
                
                movem.l d3-d7,-(sp)
                clr.w   d6  ; add toggle
                
; In: d1.w = element modification value, d6.w = add/subtract toggle

equipEffect_ModifyResistance:
                
                moveq   #0,d4
                moveq   #SPELLELEMENTS_COUNTER,d7
@Loop:
                
                lsl.w   #2,d4
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                move.w  d1,d3
                move.w  d7,d5
                add.w   d5,d5
                ror.w   d5,d3
                andi.w  #SPELLELEMENT_SETTING_MASK,d3
                ror.w   d5,d2
                andi.w  #SPELLELEMENT_SETTING_MASK,d2
                
                ; Check add/substract/set toggle
                tst.w   d6
                beq.s   @Add
                
                neg.w   d3              ; subtract
@Add:
                ; Is damage or status element?
                cmpi.w  #SPELLELEMENT_NEUTRAL,d5
                bhs.s   @Status
                
                bra.s   equipEffect_ModifyDamageResistance
@Status:
                
                bra.s   equipEffect_ModifyStatusResistance
@ModifyResistance:
                
                or.w    d2,d4
                dbf     d7,@Loop
                
                setSavedWord d4, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d4.w -> Set Current Resistance
                movem.l (sp)+,d3-d7
                rts

    ; End of function equipEffect_ModifyResistance


; =============== S U B R O U T I N E =======================================

; Increase resistance to damage elements.
;
; In: d2.w = resistance setting, d3.w = increase amount, Out: d2.w = new resistance setting

equipEffect_ModifyDamageResistance:
                
                cmpi.w  #RESISTANCESETTING_WEAKNESS,d2
                bne.s   @Continue
                
                moveq   #-1,d2
@Continue:
                
                add.w   d3,d2
                bmi.s   @Weakness
                
                cmpi.w  #RESISTANCESETTING_MAJOR,d2
                ble.s   @ModifyResistance
                moveq   #RESISTANCESETTING_MAJOR,d2
                bra.s   @ModifyResistance
@Weakness:
                
                moveq   #RESISTANCESETTING_WEAKNESS,d2 ; set to 3 on negative (weakness)
                bra.s   @ModifyResistance

    ; End of function equipEffect_ModifyDamageResistance


; =============== S U B R O U T I N E =======================================

; Increase resistance to status elements.  In: d3.w, Out: d2.w
;
; In: d2.w = resistance setting, d3.w = increase amount, Out: d2.w = new resistance setting

equipEffect_ModifyStatusResistance:
                
                add.w   d3,d2
                bmi.s   @Zero
                
                cmpi.w  #RESISTANCESETTING_IMMUNITY,d2
                ble.s   @ModifyResistance
                moveq   #RESISTANCESETTING_IMMUNITY,d2
                bra.s   @ModifyResistance
@Zero:
                
                moveq   #0,d2           ; clamp to zero on negative (regular resistance)
                bra.s   @ModifyResistance

    ; End of function equipEffect_ModifyStatusResistance

                modend ; end of resistance modification module


; =============== S U B R O U T I N E =======================================

; In: d1.w = element modification value

equipEffect_SetWindResistance:
                
                andi.w  #MODIFY_WIND3,d1
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                andi.w  #($FFFF-MODIFY_WIND3),d2
                or.w    d2,d1
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d1.w -> Set Current Resistance
                rts

    ; End of function equipEffect_SetWindResistance


; =============== S U B R O U T I N E =======================================

; In: d1.w = element modification value

equipEffect_SetLightningResistance:
                
                lsl.w   #SPELLELEMENT_LIGHTNING,d1
                andi.w  #MODIFY_LIGHTNING3,d1
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                andi.w  #($FFFF-MODIFY_LIGHTNING3),d2
                or.w    d2,d1
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d1.w -> Set Current Resistance
                rts

    ; End of function equipEffect_SetLightningResistance


; =============== S U B R O U T I N E =======================================

; In: d1.w = element modification value

equipEffect_SetIceResistance:
                
                lsl.w   #SPELLELEMENT_ICE,d1
                andi.w  #MODIFY_ICE3,d1
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                andi.w  #($FFFF-MODIFY_ICE3),d2
                or.w    d2,d1
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d1.w -> Set Current Resistance
                rts

    ; End of function equipEffect_SetIceResistance


; =============== S U B R O U T I N E =======================================

; In: d1.w = element modification value

equipEffect_SetFireResistance:

                lsl.w   #SPELLELEMENT_FIRE,d1
                andi.w  #MODIFY_FIRE3,d1
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                andi.w  #($FFFF-MODIFY_FIRE3),d2
                or.w    d2,d1
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d1.w -> Set Current Resistance
                rts

    ; End of function equipEffect_SetFireResistance


; =============== S U B R O U T I N E =======================================

; In: d1.w = element modification value

equipEffect_SetStatusResistance:
                
                rol.w   #(16-SPELLELEMENT_STATUS),d1
                andi.w  #MODIFY_STATUS3,d1
                getSavedWord (a2), d2, COMBATANT_OFFSET_RESIST_CURRENT ; Get Current Resistance -> d2.w
                andi.w  #($FFFF-MODIFY_STATUS3),d2
                or.w    d2,d1
                setSavedWord d1, (a2), COMBATANT_OFFSET_RESIST_CURRENT ; d1.w -> Set Current Resistance
                rts

    ; End of function equipEffect_SetStatusResistance


; =============== S U B R O U T I N E =======================================

equipEffect_SetStatus:
                
                ; Preserve all new effects except Curse
                andi.w  #($FFFF-STATUSEFFECT_CURSE),d1
                or.w    d1,d3
                rts

    ; End of function equipEffect_SetStatus


; =============== S U B R O U T I N E =======================================

equipEffect_SetMoveType:
                
                andi.b  #BYTE_LOWER_NIBBLE_MASK,d1
                lsl.b   #NIBBLE_SHIFT_COUNT,d1
                move.b  COMBATANT_OFFSET_MOVETYPE_AND_AI(a2),d2
                andi.b  #BYTE_LOWER_NIBBLE_MASK,d2
                or.b    d2,d1
                move.b  d1,COMBATANT_OFFSET_MOVETYPE_AND_AI(a2)
                rts

    ; End of function equipEffect_SetMoveType


; =============== S U B R O U T I N E =======================================

equipEffect_UnlearnAllSpells:
                
                ; Unlearn all spells
                move.l  #LONGWORD_SPELLS_INITVALUE,d1
                setSavedLong d1, (a2), COMBATANT_OFFSET_SPELLS
                rts

    ; End of function equipEffect_UnlearnAllSpells

