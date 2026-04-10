class_name SavedData_Ballybog
extends SavedData

@export var current_pos: Vector3
@export var current_rot: Vector3
@export var current_awareness: int

## Movement
@export var current_grid_pos: Vector3
@export var current_destination: Vector3
@export var current_path: Array

## State Stuff
@export var current_state: String
@export var time_left: float

# Patrol
@export var patrol_current_patrol_point: int

# Investigate
@export var inv_current_investigate_state: int
@export var inv_giveup_timeleft: float
@export var inv_poi: Vector3

# Chase
@export var chase_failsafe_timeleft: float
@export var chase_last_known_loc: Vector3
@export var chase_has_reacted: bool
@export var chase_lost_player: bool

# Stun
@export var stun_item_dropped_pos: Vector3
