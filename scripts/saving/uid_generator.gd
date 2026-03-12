@tool
extends Node

#func _run() -> void:
	#if !EditorInterface.get_edited_scene_root().is_in_group("MainLevel"): return
	#for i in EditorInterface.get_edited_scene_root().get_tree().get_nodes_in_group("UIDs"):
		#if i.lockuid: conit
			#

@export_tool_button("Generate UIDs", "2DNodes") var generate_uid := generate_uids
@export_tool_button("Check Duplicate UIDs", "2DNodes") var duplicate_uid := check_for_duplicate_uids

func generate_uids() -> void:
	var don := get_tree().get_first_node_in_group("MainLevel")
	for i in get_tree().get_nodes_in_group("UIDs"):
		if i.lock_uid: continue
		i.uid = create_uid()
		i.lock_uid = true
		print(i.uid)

func check_for_duplicate_uids() -> void:
	var dupe_list: Array[String] = []
	var num_dupes: int = 0
	for i in get_tree().get_nodes_in_group("UIDs"):
		if dupe_list.has(i.uid):
			print("dude")
			num_dupes+=1
		dupe_list.append(i.uid)
	if num_dupes == 0: print("D")

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
