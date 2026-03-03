extends ItemReceiver

@onready var lit_torch: Node3D = $Lit_Sconce
@onready var unlit_torch: Node3D = $Unlit_Sconce

func all_items_received() -> void:
	super()
	light_up_torch()

func light_up_torch_with_sig(sig: float = -1) -> void:
	lit_torch.visible = true
	unlit_torch.visible = false

func light_up_torch() -> void:
	lit_torch.visible = true
	unlit_torch.visible = false

func unlight_torch() -> void:
	lit_torch.visible = false
	unlit_torch.visible = true

func unlight_torch_with_sig(sig: float = -1) -> void:
	lit_torch.visible = false
	unlit_torch.visible = true
