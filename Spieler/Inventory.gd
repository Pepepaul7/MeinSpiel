extends Node2D

var inventories = []
var inventoryBlueprint = preload("res://Spieler/inventoryBlock.gd")
var currentInventory : InventoryBlock
var sizeOfItems : int
var currentHeight : int
var currentWidth :int
var draggedFrom : int #Index of Inventory the item is dragged from. If nothing is dragged == null

func _ready():
	sizeOfItems = (get_viewport().size.x * 1/3 / 8)
	draggedFrom = -1
	addHotbar()
	addMainInventory()

func addHotbar():
	var boxes = []
	for i in 9:
		boxes.append(Vector2(i * sizeOfItems, 0))
	currentHeight = sizeOfItems
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , get_viewport().size.y * 0.85), Vector2(sizeOfItems * 9, sizeOfItems), "res://Resourcen/hotbar2.png", boxes, null, sizeOfItems)
	add_child(currentInventory)
	inventories.append(currentInventory)
	
func addMainInventory():
	var boxes = []
	for i in 3:
		for j in 9:
			boxes.append(Vector2(j * sizeOfItems, i * sizeOfItems))
	currentHeight = sizeOfItems * 3
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , (get_viewport().size.y / 2) - (currentHeight / 2)), Vector2(currentWidth, currentHeight), "res://Resourcen/inventory.png", boxes, null, sizeOfItems)
	add_child(currentInventory)
	inventories.append(currentInventory)

#So entstand die Hotbar
#drawInventory(Vector2(get_viewport().size.x / 3, get_viewport().size.y * 0.9), Vector2(get_viewport().size.x * 2/3, get_viewport().size.y * 0.9 - get_viewport().size.x * 1/3 / 9), 10, 2)

func handleClick(positionOfClick):
	if draggedFrom == -1:
		dragItem(positionOfClick)
	else:
		placeItem(positionOfClick)

func dragItem(positionOfClick):
	draggedFrom = inventories.size() - 1
	while (not inventories[draggedFrom].takeItem(positionOfClick)):
		draggedFrom -= 1
		if (draggedFrom < 0):
			break
	print(draggedFrom)
	
func placeItem(positionOfClick):
	var counter = inventories.size() - 1
	while (not inventories[counter].switchItem(positionOfClick)):
		counter -= 1
		if (counter < 0):
			dropItem()
			Input.set_custom_mouse_cursor(null)
			draggedFrom = -1
			break
	if counter != -1:
		inventories[counter].switchItem(positionOfClick)
		draggedFrom = inventories.size() - 1
	print(counter)
	
func dropItem():
	print("DropItem")
	inventories[draggedFrom].dropItem()
	

func openInventory():
	print("Open")
	
func closeInventory():
	print("Close")
