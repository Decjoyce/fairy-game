@tool
class_name UID_Generator
extends Node

@export_tool_button("Generate UIDs", "TransitionImmediateAutoBig") var generate_uid := generate_uids
@export_tool_button("Check Duplicate UIDs", "VisualShaderNodeInput") var duplicate_uid := check_for_duplicate_uids

func generate_uids() -> void:
	var don := get_tree().get_first_node_in_group("MainLevel")
	for i in get_tree().get_nodes_in_group("PO"):
		i.gen_uid()

func check_for_duplicate_uids() -> void:
	var dupe_list: Array[String] = []
	var num_dupes: int = 0
	for i in get_tree().get_nodes_in_group("PO"):
		if dupe_list.has(i.uid):
			print("dude")
			num_dupes+=1
		dupe_list.append(i.get_parent().get_meta("uid"))
	print(dupe_list)
	if num_dupes == 0: print("D")
