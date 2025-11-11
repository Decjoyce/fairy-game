extends Node

var coords: Vector3

var occupied: bool

var blocked_directions: Vector4i # v4s will return false if 0000 otherwise will return true

func add_blocked_dirs(which_dirs: Vector4i) -> void:
	blocked_directions += which_dirs

func remove_blocked_dirs(which_dirs: Vector4i) -> void:
	blocked_directions -= which_dirs
	blocked_directions = max(blocked_directions, Vector4i.ZERO)

func unblock_dirs(l: bool, t: bool, r: bool, b: bool) -> void:
	if l: blocked_directions.x = 0
	if t: blocked_directions.y = 0
	if r: blocked_directions.z = 0
	if b: blocked_directions.w = 0

func unblock_all_dirs() -> void:
	blocked_directions = Vector4i.ZERO

func block_dirs(l: bool, t: bool, r: bool, b: bool) -> void:
	if l: blocked_directions.x += 1
	if t: blocked_directions.y += 1
	if r: blocked_directions.z += 1
	if b: blocked_directions.w += 1

func block_all_dirs() -> void:
	blocked_directions += Vector4i.ONE
