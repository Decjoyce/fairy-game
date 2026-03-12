#Use this as a node in the scene to save its basic properties
#Don't forget to define it's uid by clicking the recreate_uid checkbox
#When cloning persistent node remember to change the UID by checking the box again in the inspector

@tool # made it a tool to allow quick generation of uid
class_name Persistent_Object extends Node

# Allow changing the target 
@export_enum("This", "Parent") var persistent_mode = 1;

@export var recreate_uid = false:
	set(value):
		print("UID Changed")
		recreate_uid = false
		uid = Persistent_Object.create_uid();

@export var uid = "";

var target = self
var destroyed = false

#func _ready():
	# verify possible error
	#if (persistent_mode == 1):
		# Get parent if mode is set to parent
		#target = get_parent()
		# If parent is not a Node, switch back to 'this' mode
		# this can be change, it ensure you can save data below.
	#	if !(get_parent() is NodeD):
		#	printerr("Parent Node is not a Node2D, the persistent_mode is switch back to 'this'")
		#	persistent_mode = 0
			#target = self

	# Check if data already exist and charge it if needed
#	if PersistentManager.has(uid):
#		var data = PersistentManager.get_object(uid)
#		if (data.destroyed): # data say that this node is destroyed
		#	return target.call_deferred("queue_free")
#		else:
#			load_data(data)
	#else: # Recreate a data in the manager
		#resave()
	
	# Connect changed properties to the save function if you need to save thing related to it
	# target.item_rect_changed.connect(resave)
	# target.visibility_changed.connect(resave)
#	target.tree_exiting.connect(resave);


#You can change properties saved here;
func save_data(destroyed = false):
	return {
		destroyed = destroyed, # you need to keep this line.
		# Exemple :
		# position = target.position,
		# scale = obj.scale,
		# rotation = obj.rotation,
		# visible = obj.visible,
	}

func load_data(data):
	# Exemple :
	# target.position = data.position;
	# target.scale = data.scale;
	# target.rotation = data.rotation;
	# target.visible = data.visible;
	pass



# Contact with the manager
#func resave():
	#PersistentManager.save(uid, save_data(destroyed))

# Call this function to queue_free the target despite of the original queue_free function
func destroy():
	destroyed = true;
	target.call_deferred("queue_free")


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
