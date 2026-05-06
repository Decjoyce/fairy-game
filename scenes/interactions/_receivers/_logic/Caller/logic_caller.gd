class_name LogicCaller
extends Node

@export var nodes_to_call_on: Array[Node]
@export var method_to_call: String
@export var params: Array

func call_the_method(sig: float) -> void:
	for i in nodes_to_call_on:
		i.callv(method_to_call, params)
