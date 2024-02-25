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
	#newInventories()
	loadInventories()

func newInventories():
	var items = {}
	for i in 9:
		items[i] = "002, 10"
	addHotbar(items)
	for i in 19:
		items[8 + i] = "001, 10"
	addMainInventory(items)

func addHotbar(items):
	var boxes = []
	for i in 9:
		boxes.append(Vector2(i * sizeOfItems, 0))
		#Nur zum Neuladen der Items
		#items[i] = "002, 10"
	currentHeight = sizeOfItems
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , get_viewport().size.y * 0.85), Vector2(sizeOfItems * 9, sizeOfItems), "res://Resourcen/hotbar2.png", boxes, items, sizeOfItems, 0, "hotbar")
	add_child(currentInventory)
	inventories.append(currentInventory)
	
func addMainInventory(items):
	var boxes = []
	for i in 3:
		for j in 9:
			boxes.append(Vector2(j * sizeOfItems, i * sizeOfItems))
			#Nur zum Neuladen der Items
			#items[j + i * 9] = "001, 10"
	currentHeight = sizeOfItems * 3
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , (get_viewport().size.y / 2) - (currentHeight / 2)), Vector2(currentWidth, currentHeight), "res://Resourcen/inventory.png", boxes, items, sizeOfItems, 1, "mainInventory")
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
	

func openInventory():
	inventories[1].visible = true
	
func closeInventory():
	for i in inventories.size() - 1:
		inventories[i + 1].visible = false

func loadInventories():
	var file : String
	file = FileAccess.get_file_as_string("res://Resourcen/inventoryDataPlayer.json")
	var items : Dictionary
	items = JSON.parse_string(file)
	var itemTypes : Dictionary
	itemTypes = items["0"]
	print(itemTypes)
	for i in itemTypes.keys():
		match itemTypes[str(i)]:
			"hotbar":
				addHotbar(items[ str(int(i) + 1)])
			"mainInventory":
				addMainInventory(items[str(int(i) + 1)])
	
	

func saveInventories():
	var filePath = FileAccess.open("res://Resourcen/inventoryDataPlayer.json", FileAccess.WRITE)
	var items : Dictionary
	var inventoryTypes : Dictionary
	for i in inventories:
		items[i.id + 1] = i.items
		inventoryTypes[i.id] = i.inventoryType
	items[0] = inventoryTypes
	filePath.store_string(JSON.stringify(items))
	filePath.close()
