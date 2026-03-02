extends ItemReceiver

signal statue_piece_received(num_received: int, item_received: Grabbable_Item)

func check_item_is_specific(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if !needed_items_left.has(_item): return false
	needed_items_left.erase(_item)
	
	check_if_item_should_be_destroyed(_item)
	
	print("kiko")
	
	if needed_items_left.size() <= 0:
		on_change.emit(1)
		all_items_received()
	else: on_change.emit(float(specific_items_to_recieve.size() - needed_items_left.size()) / specific_items_to_recieve.size())
	
	statue_piece_received.emit(specific_items_to_recieve.size() - needed_items_left.size(), _item)
	
	return true

func check_item_by_keyword(_item: Grabbable_Item, destroy_check: bool = true) -> bool:
	if _item.keywords == "": return false
	
	keyword_checker(_item)
	
	if func_to_call != "":
		if args: _item.call(func_to_call, args)
		else: _item.call(func_to_call)
	
	check_if_item_should_be_destroyed(_item)
	
	num_have_by_keyword += 1
	
	statue_piece_received.emit(num_have_by_keyword, _item)
	on_change.emit(float(num_have_by_keyword) / float(num_needed_by_keyword))
	
	if num_have_by_keyword >= num_needed_by_keyword:
		all_items_received()
	
	return true
