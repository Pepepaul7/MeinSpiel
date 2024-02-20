extends Node2D

var inventories = []
var inventoryBlueprint = preload("res://Spieler/inventoryBlock.gd")
var currentInventory : InventoryBlock
var sizeOfItems : int
var currentHeight : int
var currentWidth :int
var draggedItem : String #Current dragging Item

func _ready():
	sizeOfItems = (get_viewport().size.x * 1/3 / 8)
	draggedItem = ""
	addHotbar()
	addMainInventory()

func addHotbar():
	var boxes = []
	var items = []
	for i in 9:
		boxes.append(Vector2(i * sizeOfItems, 0))
		items.append("a")
	currentHeight = sizeOfItems
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , get_viewport().size.y * 0.85), Vector2(sizeOfItems * 9, sizeOfItems), "res://Resourcen/hotbar2.png", boxes, items, sizeOfItems)
	add_child(currentInventory)
	inventories.append(currentInventory)
	
func addMainInventory():
	var boxes = []
	var items = []
	for i in 3:
		for j in 9:
			boxes.append(Vector2(j * sizeOfItems, i * sizeOfItems))
			items.append("a")
	currentHeight = sizeOfItems * 3
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , (get_viewport().size.y / 2) - (currentHeight / 2)), Vector2(currentWidth, currentHeight), "res://Resourcen/inventory.png", boxes, items, sizeOfItems)
	add_child(currentInventory)
	currentInventory.visible = false
	inventories.append(currentInventory)

#So entstand die Hotbar
#drawInventory(Vector2(get_viewport().size.x / 3, get_viewport().size.y * 0.9), Vector2(get_viewport().size.x * 2/3, get_viewport().size.y * 0.9 - get_viewport().size.x * 1/3 / 9), 10, 2)

func handleClick(positionOfClick):
	dragItem(positionOfClick)
	
func dragItem(positionOfClick):
	var counter = inventories.size() - 1
	while (not inventories[counter].takeItem(positionOfClick, draggedItem)):
		counter -= 1
		if (counter < 0):
			dropItem()
			Input.set_custom_mouse_cursor(null)
			break
	print(counter)
	
func dropItem():
	draggedItem = ""
	print("DropItem")
	

func openInventory():
	inventories[1].visible = true
	print("Open")
	
func closeInventory():
	for i in inventories.size() - 1:
		inventories[i + 1].visible = false
	print("Close")
