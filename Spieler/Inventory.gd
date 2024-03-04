extends Node2D

var inventories = []
var inventoryBlueprint = preload("res://Spieler/inventoryBlock.gd")
var currentInventory : InventoryBlock
var sizeOfItems : int
var currentHeight : int
var currentWidth :int
var draggedItem : String #Current dragging Item
var rightClickText = preload("res://Spieler/InventoryRightClickDropDown.tscn").instantiate()
var rightClickTextsize : Vector2
var rightClickTextVisible = false
var items : Dictionary
var inventoryTypes : Dictionary

func _ready():
	sizeOfItems = (get_viewport().size.x * 1/3 / 8)
	draggedItem = ""
	rightClickText.visible = false
	rightClickTextsize = Vector2(rightClickText.get_children()[0].size.x, rightClickText.get_children()[0].size.y * rightClickText.get_children().size())
	#newInventories()
	#saveInventories()
	loadInventories()

func newInventories():
	var newItems = {}
	for i in 9:
		newItems[i] = "002, 10"
	addHotbar(newItems)
	inventoryTypes[0] = "hotbar"
	newItems = {}
	for i in 27:
		newItems[i] = "001, 10"
	addMainInventory(newItems)
	inventoryTypes[1] = "mainInventory"

func addHotbar(newItems):
	var boxes = []
	for i in 9:
		boxes.append(Vector2(i * sizeOfItems, 0))
		#Nur zum Neuladen der Items
		#items[i] = "002, 10"
	currentHeight = sizeOfItems
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , get_viewport().size.y * 0.85), Vector2(sizeOfItems * 9, sizeOfItems), "res://Resourcen/hotbar2.png", boxes, newItems, sizeOfItems, 0, "hotbar")
	add_child(currentInventory)
	inventories.append(currentInventory)
	
func addMainInventory(newItems):
	var boxes = []
	for i in 3:
		for j in 9:
			boxes.append(Vector2(j * sizeOfItems, i * sizeOfItems))
			#Nur zum Neuladen der Items
			#items[j + i * 9] = "001, 10"
	currentHeight = sizeOfItems * 3
	currentWidth = sizeOfItems * 9
	currentInventory = inventoryBlueprint.new(Vector2((get_viewport().size.x / 2) - (currentWidth / 2) , (get_viewport().size.y / 2) - (currentHeight / 2)), Vector2(currentWidth, currentHeight), "res://Resourcen/inventory.png", boxes, newItems, sizeOfItems, 1, "mainInventory")
	add_child(currentInventory)
	currentInventory.visible = false
	inventories.append(currentInventory)

#So entstand die Hotbar
#drawInventory(Vector2(get_viewport().size.x / 3, get_viewport().size.y * 0.9), Vector2(get_viewport().size.x * 2/3, get_viewport().size.y * 0.9 - get_viewport().size.x * 1/3 / 9), 10, 2)

func handleLeftClick(positionOfClick):
	if not rightClickTextVisible:
		dragItem(positionOfClick)
	else:
		if not (positionOfClick.x < rightClickText.position.x + rightClickTextsize.x and positionOfClick.y < rightClickText.position.y + rightClickTextsize.y and positionOfClick.x > rightClickText.position.x and positionOfClick.y > rightClickText.position.y):
			closeRightClickText()

func closeRightClickText():
	rightClickTextVisible = false
	rightClickText.queue_free()

func handleRightClick(positionOfClick):
	var counter = inventories.size() - 1
	while (not inventories[counter].spawnText(positionOfClick)):
			counter -= 1
			if counter < 0:
				break

func spawnRightClickDropdown(item : String, position, inventory):
	if rightClickText != null:
		closeRightClickText()
	rightClickText = preload("res://Spieler/InventoryRightClickDropDown.tscn").instantiate()
	rightClickText.position = position
	rightClickText.visible = true
	rightClickTextVisible = true
	rightClickText.get_children()[1].connect("pressed", inventories[inventory].takeHalf)
	rightClickText.get_children()[2].connect("pressed", inventories[inventory].dropItem)
	if item.split(", ", true).size() == 3:
		rightClickText.get_children()[3].connect("pressed", Callable(addBackpackInventory).bind(int(item.split(", ", true)[2]), position))
	add_child(rightClickText)
	
func addBackpackInventory(id : int, position : Vector2):
	addBackpackToData(id)
	var newItems = items[id + 1]
	var boxes = []
	currentHeight = sizeOfItems * 3
	currentWidth = sizeOfItems * 3
	for i in 3:
		for j in 3:
			boxes.append(Vector2(j * sizeOfItems, i * sizeOfItems))
	currentInventory = inventoryBlueprint.new(position, Vector2(sizeOfItems * 3, sizeOfItems * 3), "res://Resourcen/backpack.png", boxes, newItems, sizeOfItems, id, "backpack")
	inventories.append(currentInventory)
	add_child(currentInventory)
	closeRightClickText()

func spawnNewBackpack():
	var newId : int
	newId = getNewId()
	print(newId)
	Input.set_custom_mouse_cursor(ResourceLoader.load("res://Resourcen/Inventories/items/basic/003.png"))
	addBackpackToData(newId)
	draggedItem = "003, 1, " + str(newId)

func addBackpackToData(id : int):
	if not items[0].has(id) :
		items[id + 1] = {}
		for i in 9:
			items[id + 1][i] = ""
		inventoryTypes[id] = "backpack"

func getNewId():
	for i in items[0].size():
		if not items[0].has(i):
			return i
	return items[0].size()

func saveType(newType : String):
	var counter = 0
	for i in inventoryTypes.keys():
		if counter != i:
			break
		counter += 1
	inventoryTypes[counter] = newType
	return counter

func dragItem(positionOfClick):
	var counter = inventories.size() - 1
	while (not inventories[counter].takeItem(positionOfClick, draggedItem)):
		counter -= 1
		if (counter < 0):
			dropItem()
			Input.set_custom_mouse_cursor(null)
			break
	
func dropItem():
	throwItem(draggedItem)
	draggedItem = ""
	
func throwItem(item):
	print("ThrowItem")


func openInventory():
	inventories[1].visible = true
	
func closeInventory():
	for i in inventories.size() - 1:
		inventories[i + 1].visible = false

func loadInventories():
	var file : String
	file = FileAccess.get_file_as_string("res://Resourcen/inventoryDataPlayer.json")
	var itemsFromJson : Dictionary
	itemsFromJson = JSON.parse_string(file)
	for i in itemsFromJson.keys():
		var zwischenspeicher : Dictionary
		for j in itemsFromJson[i].keys():
			zwischenspeicher[int(j)] = itemsFromJson[i][j]
		items[int(i)] = zwischenspeicher
		
	inventoryTypes = items[0]
	for i in inventoryTypes.keys():
		match inventoryTypes[i]:
			"hotbar":
				addHotbar(items[int(i) + 1])
			"mainInventory":
				addMainInventory(items[int(i) + 1])
	

func saveInventories():
	var filePath = FileAccess.open("res://Resourcen/inventoryDataPlayer.json", FileAccess.WRITE)
	
	for i in inventories:
		items[i.id + 1] = i.items
	items[0] = inventoryTypes
	filePath.store_string(JSON.stringify(items))
	filePath.close()

func saveOneInventory(id : int, saveItems : Dictionary, type : String):
	items[id + 1] = saveItems
	items[0][id] = type

func killInventory(id : int):
	for i in inventories.size():
		if inventories[i].id == id:
			inventories[i].queue_free()
			inventories.remove_at(i)
			
