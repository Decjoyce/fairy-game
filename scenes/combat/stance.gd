class_name Stance
extends Node

# Stance
## All this is a holder if information
enum stance_slots {RIGHT, BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT, TOP_LEFT, TOP, TOP_RIGHT}
@export var slots: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1] # 8 Elements each corresponding to a stance_slot, values corresponds to a hand, -1 = empty, 1 means hand[1] is occupyin

@export var hands: Array[CombatHand]

@export var stats: Stats

signal on_slots_changed(hand: CombatHand, new_slot: int)

## 
func occupy_slot(hand: int, new_slot: stance_slots) -> bool:
	if !can_occupy_slot(hand, new_slot): return false
	clear_slots(hand)
	slots[new_slot] = hand
	
	return true

## Clears any slot that the hand currently occupies
func clear_slots(hand: int) -> void:
	for i in slots.size():
		if slots[i] == hand:
			#print("yo")
			slots[i] = -1

## Checks if slot can be occupied or not
func can_occupy_slot(hand: int, new_slot: stance_slots) -> bool:
	var restricted_slots : String = hands[hand].restricted_slots
	if restricted_slots[new_slot] == "0": return false
	
	if slots[new_slot] != -1 and slots[new_slot] != hand: 
		#print("yo")
		return false
	else:
		return true

func check_slot_to_attack(slot_to_check: int) -> CombatHand:
	var _checked_slot: = slots[slot_to_check]
	if _checked_slot == -1: return null
	else: return hands[_checked_slot]
	

func get_slot_hand_is_in(hand_to_check: int) -> int:
	return slots.find(hand_to_check)
