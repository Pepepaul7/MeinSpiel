extends Node2D

class_name InventoryBlock

var size : Vector2
var topLeft : Vector2
var imageLink : String
var boxes = {} #TextureRect with position and height
var items = [] #Item Strings
var background : TextureRect
var sizeOfItems

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
	for i in 9:
		boxes[i] = TextureRect.new()
		boxes[i].texture = ResourceLoader.load("res://Resourcen/Inventories/items/basic/pixil-frame-0 (1).png")
		boxes[i].set_position(Vector2(_boxes[i].x, _boxes[i].y))
		boxes[i].size = Vector2(sizeOfItems, sizeOfItems)
		add_child(boxes[i])
