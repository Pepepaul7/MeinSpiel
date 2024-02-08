extends Node2D

class_name InventoryBlock

var size : Vector2
var topLeft : Vector2
var imageLink : String
var boxes = {}
var items = []
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
	print(get_children())

func _draw():
	drawInventory(topLeft, topLeft + size, 4, 4)

func drawInventory(startPos : Vector2, endPos : Vector2, row : int, column : int):
	draw_rect(Rect2(startPos, endPos - startPos), Color.GRAY, true)
	for i in row:
		draw_line(Vector2(startPos.x + (endPos.x - startPos.x) * i / (row - 1) + lineWidth / 2 - (lineWidth * i) / (row - 1), startPos.y), Vector2(startPos.x + (endPos.x - startPos.x) * i / (row - 1) + lineWidth / 2 - (lineWidth * i) / (row - 1), endPos.y), Color.LIGHT_GRAY, lineWidth)
	for i in column:
		draw_line(Vector2(startPos.x, startPos.y + (endPos.y - startPos.y) * i / (column - 1) + lineWidth / 2), Vector2(endPos.x, startPos.y + (endPos.y - startPos.y) * i / (column - 1) + lineWidth / 2), Color.LIGHT_GRAY, lineWidth)
