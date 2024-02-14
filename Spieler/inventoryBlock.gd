extends Node2D

class_name InventoryBlock

var size : Vector2
var topLeft : Vector2
var imageLink : String
var boxes = {} #TextureRect with position and height
var items = [] #Item Strings
var background : TextureRect
var lineWidth = 2
var sizeOfItems

func _init(_topLeft, _size, _imageLink, _boxes, _items, _sizeOfItems):
	size = _size
	topLeft = _topLeft
	imageLink = _imageLink
	boxes = _boxes
	items = _items
	sizeOfItems = _sizeOfItems
	background = TextureRect.new()
	background.texture = ResourceLoader.load(imageLink)
	background.size = size
	self.position = topLeft
	add_child(background)
	for i in boxes:
		add_child(i)
