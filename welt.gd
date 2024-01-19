extends Node3D

@onready var player:Player = preload("res://Spieler/Body.tscn").instantiate()
var blocks
var blockInstance
var loadedChunks = []
var renderDistance = 5
var halfrender:int = renderDistance * 0.5 +0.5
var despawnBonusDistance = 2

var mapJson : Dictionary

var file : String

var thread : Thread


func _ready():
	#Buttons for exit/save
	$ExitAndSave.position = (Vector2(get_viewport().size) - $ExitAndSave.size) / 2
	$ExitAndSave/Continue.connect("pressed", continueGame);
	$ExitAndSave/SaveButton.connect("pressed", saveGame);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	thread = Thread.new()
	#Lade die Blockfarben
	file = FileAccess.get_file_as_string("res://Resourcen/worldData.json")
	mapJson = jsonToDictionary(JSON.parse_string(file))
	var zwischenspeicher : Chunk
	zwischenspeicher = load("res://Chunk.gd").new(Vector2(0, 0), false, null,)#mapJson[Vector2(0, 0)])
	loadedChunks.append(zwischenspeicher)
	add_child(zwischenspeicher)
	zwischenspeicher.isLoadedChild = true
	add_child(player)
	player.position = Vector3(0, 31, 0)
	thread.start(renderMapThread.bind(player.position))

func jsonToDictionary(json):
	var newString:String
	var eray: Array
	var rueckgabe = {}
	if (json != null):
		for i in json.keys():
			newString = i.erase(0, 1)
			newString = newString.erase(newString.length() - 1, 1)
			eray = newString.split(',')
			rueckgabe[Vector2(float(eray[0]), float(eray[1]))] = json[i]
	return rueckgabe

func isInLoadedFiles(x, z):
	for i in loadedChunks:
		if (i.pos.x == x and i.pos.y == z):
			return true
	return false

func addChunkToWorld():
	thread.wait_to_finish()
	for i in loadedChunks:
		if not i.isLoadedChild:
			add_child(i)
			i.isLoadedChild = true
	thread.start(renderMapThread.bind(player.position))
				
	
func renderMapThread(playerpos):
	var playerx = int(playerpos.x / 16 +0.5) #Für Recheneffiziens
	var playerz = int(playerpos.z / 16 +0.5) #Für Recheneffiziens
	for i in loadedChunks:
		if not (playerx - halfrender - despawnBonusDistance < i.pos.x and playerx + halfrender + despawnBonusDistance > i.pos.x) or not (playerz - halfrender - despawnBonusDistance < i.pos.y and playerz + halfrender + despawnBonusDistance > i.pos.y):
			mapJson[Vector2(i.pos.x, i.pos.y)] = i.unloadChunk()
			loadedChunks.erase(i)
			i.queue_free()
	playerx += halfrender
	playerz += halfrender
	for i in renderDistance:
		for j in renderDistance:
			if !isInLoadedFiles(playerx - i, playerz - j):
				var zwischenspeicher
				if (mapJson.has(Vector2(playerx - i, playerz - j))):
					zwischenspeicher = load("res://Chunk.gd").new(Vector2((playerx - i), (playerz - j)), true, mapJson[Vector2(playerx - i, playerz - j)])
				else:
					zwischenspeicher = load("res://Chunk.gd").new(Vector2((playerx - i), (playerz - j)), true, null)
				loadedChunks.append(zwischenspeicher)
	call_deferred("addChunkToWorld")
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$ExitAndSave.visible = true
		get_tree().paused = true
		
func saveGame():
	print("Saved")
	var filePath = FileAccess.open("res://Resourcen/worldData.json", FileAccess.WRITE)
	for i in loadedChunks:
		mapJson[Vector2(i.pos.x, i.pos.y)] = i.saveMap()
	filePath.store_string(JSON.stringify(mapJson))
	filePath.close()
	print("Saved")
	
func continueGame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$ExitAndSave.visible = false
