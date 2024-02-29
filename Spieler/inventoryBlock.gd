extends Node2D

class_name InventoryBlock

var size : Vector2
var topLeft : Vector2
var imageLink : String
var boxes = [] #TextureRect with position and height
var items = [] #Item Strings
var background : TextureRect
var sizeOfItems : int
var id : int
var inventoryType : String
var selectedItem : int
var itemAmountBoxes = []

func _init(_topLeft, _size, _imageLink, _boxes, _items, _sizeOfItems, _id, _inventoryType):
	size = _size
	topLeft = _topLeft
	imageLink = _imageLink
	items = _items
	sizeOfItems = _sizeOfItems
	id = _id
	inventoryType = _inventoryType
	background = TextureRect.new()
	background.texture = ResourceLoader.load(imageLink)
	background.size = size
	self.position = topLeft
	add_child(background)
	for i in _boxes.size():
		itemAmountBoxes.append(null)
		boxes.append(TextureRect.new())
		boxes[i].set_position(Vector2(_boxes[i].x, _boxes[i].y))
		boxes[i].size = Vector2(sizeOfItems, sizeOfItems)
		add_child(boxes[i])
		setTexture(i)

func takeItem(clickedPosition, draggedItem):
	if clickedPosition.y < topLeft.y + size.y and clickedPosition.y > topLeft.y and clickedPosition.x < topLeft.x + size.x and clickedPosition.x > topLeft.x:
		var newClickedPosition = clickedPosition - topLeft
		for i in boxes.size():
			if newClickedPosition.x < boxes[i].position.x + sizeOfItems and newClickedPosition.y < boxes[i].position.y + sizeOfItems and newClickedPosition.x > boxes[i].position.x and newClickedPosition.y > boxes[i].position.y:
				Input.set_custom_mouse_cursor(null)
				if items[i].left(3) == draggedItem.left(3) and items[i] != "":
					setAmountOfItems(i, getAmountOfGivenItem(draggedItem) + getAmountOfItems(i))
					setTexture(i)
					get_parent().draggedItem = ""
				else:
					if items[i] != "":
						Input.set_custom_mouse_cursor(boxes[i].texture)
					var zwischenspeicher : String
					zwischenspeicher = items[i]
					items[i] = draggedItem
					get_parent().draggedItem = zwischenspeicher
					setTexture(i)
				return true
	else:
		return false

func setTexture(counter : int):
	if items[counter] == "":
		boxes[counter].texture = null
		if itemAmountBoxes[counter] != null:
			itemAmountBoxes[counter].queue_free()
		itemAmountBoxes[counter] = null
	else:
		if (itemAmountBoxes[counter] == null):
			itemAmountBoxes[counter] = RichTextLabel.new()
			itemAmountBoxes[counter].bbcode_enabled = true
			itemAmountBoxes[counter].scroll_active = false
			itemAmountBoxes[counter].text = "[center]" + str(getAmountOfItems(counter)) + "[/center]"
			itemAmountBoxes[counter].position = boxes[counter].position + Vector2(sizeOfItems * 0.5, sizeOfItems * 0.7)
			itemAmountBoxes[counter].size = Vector2(sizeOfItems * 3, sizeOfItems) * 0.25
			add_child(itemAmountBoxes[counter])
		else:
			itemAmountBoxes[counter].text = "[center]" + str(getAmountOfItems(counter)) + "[/center]"
		boxes[counter].texture = ResourceLoader.load("res://Resourcen/Inventories/items/basic/" + items[counter].left(3) + ".png")

func saveInventory():
	print(items.size())
	return JSON.parse_string(JSON.stringify(items))

func spawnText(clickedPosition):
	if clickedPosition.y < topLeft.y + size.y and clickedPosition.y > topLeft.y and clickedPosition.x < topLeft.x + size.x and clickedPosition.x > topLeft.x:
		var newClickedPosition = clickedPosition - topLeft
		for i in boxes.size():
			if newClickedPosition.x < boxes[i].position.x + sizeOfItems and newClickedPosition.y < boxes[i].position.y + sizeOfItems and newClickedPosition.x > boxes[i].position.x and newClickedPosition.y > boxes[i].position.y:
				if items[i] != "":
					get_parent().spawnRightClickDropdown(items[i], boxes[i].position + topLeft, id)
					selectedItem = i
				return true

func dropItem():
	get_parent().throwItem(items[selectedItem])
	items[selectedItem] = ""
	boxes[selectedItem].texture = null
	get_parent().closeRightClickText()

func takeHalf():
	var draggingAmount : int
	var stayingAmount : int
	stayingAmount = getAmountOfItems(selectedItem) / 2
	draggingAmount = getAmountOfItems(selectedItem) - stayingAmount
	setAmountOfItems(selectedItem, draggingAmount)
	get_parent().draggedItem = items[selectedItem]
	Input.set_custom_mouse_cursor(boxes[selectedItem].texture)
	if stayingAmount == 0:
		items[selectedItem] = ""
	else: 
		setAmountOfItems(selectedItem, stayingAmount)
	setTexture(selectedItem)
	get_parent().closeRightClickText()

func getAmountOfItems(index):
	var returnvalue : int
	returnvalue = int(items[index].split(", ", true, 0)[1])
	return returnvalue

func getAmountOfGivenItem(customItem):
	return int(customItem.split(", ", true, 0)[1])

func setAmountOfItems(index, value):
	var newValue = items[index].split(", ", true, 0)
	newValue[1] = str(value)
	items[index] = ""
	for i in newValue.size():
		if (i == newValue.size() - 1):
			items[index] += newValue[i]
		else:
			items[index] += newValue[i] + ", "
	

func openInventory():
	print("OpenInventory")
