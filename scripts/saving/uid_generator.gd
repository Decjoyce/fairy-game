@tool
class_name UID_Generator
extends Node

@export_tool_button("Generate UIDs", "TransitionImmediateAutoBig") var generate_uid := generate_uids
@export_tool_button("Check Duplicate UIDs", "VisualShaderNodeInput") var duplicate_uid := check_for_duplicate_uids
@export_tool_button("Unlock All UIDs", "VisualShaderNodeInput") var unlock_uids := unlock_all_uids

func generate_uids() -> void:
	var don := get_tree().get_first_node_in_group("MainLevel")
	for i in get_tree().get_nodes_in_group("PO"):
		i.gen_uid()

func check_for_duplicate_uids() -> void:
	var checked_uids: Array[String] = []
	var num_dupes: int = 0
	var dupe_string: String
	for i in get_tree().get_nodes_in_group("PO"):
		if checked_uids.has(i.get_parent().get_meta("uid")):
			num_dupes+=1
			
		checked_uids.append(i.get_parent().get_meta("uid"))
	if num_dupes == 0: print("No duplicated UIDs detected")

func unlock_all_uids() -> void:
	var don := get_tree().get_first_node_in_group("MainLevel")
	for i in get_tree().get_nodes_in_group("PO"):
		i.get_parent().set_meta("lock_uid", false)
