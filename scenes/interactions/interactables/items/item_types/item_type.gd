class_name ItemType
extends Resource

enum ItemTypes {DEFAULT, TORCH, KEY, CONSUMABLE, BREAKABLE, INSTRUMENT}
@export var item_type: ItemTypes

enum UseTypes {PRESS, HOLD}
@export var use_type: UseTypes

#@export var impact_data: ImpactData
