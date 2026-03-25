@tool
class_name PersistentObject
extends Node

func _ready() -> void:
	if Engine.is_editor_hint():
		var p := get_parent()
		for c in p.get_children(true):
			if p is PersistentObject: 
				queue_free()
				return

func gen_uid() -> void:
	if !Engine.is_editor_hint(): return
	if get_parent().has_meta("lock_uid") and get_parent().get_meta("lock_uid") == true: return
	get_parent().set_meta("uid", create_uid())
	get_parent().set_meta("lock_uid", true)
	get_parent().set_meta("date_generated", Time.get_datetime_string_from_system())
	prints(get_parent().name, get_uid())

func get_uid() -> String:
	return get_parent().get_meta("uid")


func on_save_game(saved_data: Array[SavedData]) -> void:
	if Engine.is_editor_hint(): return
	assert(get_parent().has_meta("uid"), "ERROR: Could not find UID on - " + get_parent().name + " - please generate UIDs")
	assert(get_parent().get_meta("uid") != "", "ERROR: Invalid UID found on - " + get_parent().name + " - please generate UIDs")

func on_before_load_game() -> void:
	if Engine.is_editor_hint(): return

func on_load_game(saved_data: SavedData) -> void:
	if Engine.is_editor_hint(): return

#region ui_generator
####################################################################
# UID GENERATOR FROM https://github.com/binogure-studio/godot-uuid #
####################################################################

# MIT License

# Copyright (c) 2023 Xavier Sellier

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

const BYTE_MASK: int = 0b11111111


static func create_uid() -> String:
	var b = uuidbin();
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
	# low
	b[0], b[1], b[2], b[3],

	# mid
	b[4], b[5],

	# hi
	b[6], b[7],

	# clock
	b[8], b[9],

	# clock
	b[10], b[11], b[12], b[13], b[14], b[15]
  ]
static func uuidbin():
	# 16 random bytes with the bytes on index 6 and 8 modified
	return [
	  randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	  randi() & BYTE_MASK, randi() & BYTE_MASK, ((randi() & BYTE_MASK) & 0x0f) | 0x40, randi() & BYTE_MASK,
	  ((randi() & BYTE_MASK) & 0x3f) | 0x80, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	  randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK, randi() & BYTE_MASK,
	]
#endregion
