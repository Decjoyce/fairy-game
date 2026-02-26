extends Node

@export var operations: Dictionary[float, SignalOperation]

func check_operations(sig: float) -> void:
	if !operations.has(sig): return
	assert(operations[sig], "ERROR: Signal Operation not assigned to the key")
	var gotten_node: Node = get_tree().get_node("%" + operations[sig].unique_node_name)
	assert(gotten_node, "ERROR: There is no node with unique name of " + operations[sig].unique_node_name + " - please ensure access as unique node is ticked")
	assert(gotten_node.has_method(operations[sig].func_to_call))
	gotten_node.call(operations[sig].func_to_call, operations[sig].args)
