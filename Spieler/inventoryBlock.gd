extends Node2D

class_name InventoryBlock

var size : Vector2
var topLeft : Vector2
var imageLink : String
var boxes = [] #TextureRect with position and height
var items = [] #Item Strings
var background : TextureRect
var sizeOfItems : int

func _init(_topLeft, _size, _imageLink, _boxes, _items, _sizeOfItems):
	size = _size
	topLeft = _topLeft
	imageLink = _imageLink
	items = _items
	sizeOfItems = _sizeOfItems
	background = TextureRect.new()
	background.texture = ResourceLoader.load(imageLink)
	background.size = size
	self.position = topLeft
	add_child(background)
	for i in _boxes.size():
		boxes.append(TextureRect.new())
		if items[i] == "":
			boxes[i].texture = null
		else:
			boxes[i].texture = ResourceLoader.load("res://Resourcen/Inventories/items/basic/" + items[i].left(3) + ".png")
		boxes[i].set_position(Vector2(_boxes[i].x, _boxes[i].y))
		boxes[i].size = Vector2(sizeOfItems, sizeOfItems)
		add_child(boxes[i])

func takeItem(clickedPosition, draggedItem):
	if clickedPosition.y < topLeft.y + size.y and clickedPosition.y > topLeft.y and clickedPosition.x < topLeft.x + size.x and clickedPosition.x > topLeft.x:
		var newClickedPosition = clickedPosition - topLeft
		for i in boxes.size():
			if newClickedPosition.x < boxes[i].position.x + sizeOfItems and newClickedPosition.y < boxes[i].position.y + sizeOfItems and newClickedPosition.x > boxes[i].position.x and newClickedPosition.y > boxes[i].position.y:
				Input.set_custom_mouse_cursor(null)
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
	else:
		boxes[counter].texture = ResourceLoader.load("res://Resourcen/Inventories/items/basic/" + items[counter].left(3) + ".png")

func saveInventory():
	return JSON.parse_string(JSON.stringify(items))
