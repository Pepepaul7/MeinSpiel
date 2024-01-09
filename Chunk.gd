extends StaticBody3D

class_name Chunk

#Für die schnellere Bearbeitung in Welt
var pos = Vector2()

var material1 = preload("res://Resourcen/dirt.tres")

#Dictionary mit Blöcken
var blocks = {}
var blocksToAdd = []

const TEXTURE_SHEET_WIDTH = 8
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH


#Für die tatsächlichen Koordinaten
var xPosMul
var zPosMul

#Für die z-Koordinate
var noise = FastNoiseLite.new()

var isLoadedChild : bool

var thread : Thread

var colliderEray = []

var isThreaded


#Die Funktion wird nur für den ersten Chunk nicht gethreaded ausgeführt
#Wenn der Chunk schon mal geladen wurde, wird eine Json mitgegeben. Wenn nicht, ist der Wert null
func _init(givenPosition, _isThreaded, chunkJson):
	isThreaded = _isThreaded
	isLoadedChild = false
	pos = givenPosition
	xPosMul = pos.x * 16
	zPosMul = pos.y * 16
	if isThreaded:
		thread = Thread.new()
		thread.start(generateChunk.bind(chunkJson))
	else:
		if chunkJson == null:
			generateBlocks()
		else:
			blocks = jsonToDictionary(chunkJson)
		blocks[Vector3(0, 32, 0)] = 1
		var surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		# For each block, add data to the SurfaceTool and generate a collider.
		for block_position in blocks.keys():
			if (not blockIsCompleteSurrounded(block_position)):
				var block_id = blocks[block_position]
				surface_tool.set_material(material1)
				_draw_block_mesh(surface_tool, block_position, block_id)
		surface_tool.generate_tangents()
		surface_tool.index()
		var array_mesh = surface_tool.commit()
		var mi = MeshInstance3D.new()
		mi.mesh = array_mesh
		mi.create_trimesh_collision()
		add_child(mi)
		
#Hier wird die Json zu einem Dictionary umgewandelt, da im sonst ein String und nicht ein Vector3 als Key verwendet wirds
func jsonToDictionary(json):
	var newString:String
	var eray: Array
	var rueckgabe = {}
	for i in json.keys():
		newString = i.erase(0, 1)
		newString = newString.erase(newString.length() - 1, 1)
		eray = newString.split(',')
		rueckgabe[Vector3(float(eray[0]), float(eray[1]), float(eray[2]))] = int(json[i])
	return rueckgabe

func addChildForThread(child):
	thread.wait_to_finish()
	add_child(child)

func generateChunk(chunkJson):
	if chunkJson == null:
		generateBlocks()
	else:
		blocks = jsonToDictionary(chunkJson)
	generateMesh()
	
func deleteChildren():
	for i in self.get_children():
		i.queue_free()
	isLoadedChild = false
			
func unloadChunk():
	call_deferred("deleteChildren")
	return saveMap()

func saveMap():
	return JSON.parse_string(JSON.stringify(blocks))

#Hier werden die Blöcke erstellt, falls noch keine Json existieren sollte. 
func generateBlocks():
	for i in 16:
		for j in 16:
			var height = noise.get_noise_2d(i - 8 + xPosMul, j - 8 + zPosMul) * 30
			for h in height + 30:
				if noise.get_noise_3d(i - 8 + xPosMul, h, j - 8 + zPosMul) < 0.4:
					if h + 3 > height + 30:
						blocks[Vector3(i - 8 + xPosMul, h, j - 8 + zPosMul)] = 0
					else:
						blocks[Vector3(i - 8 + xPosMul, h, j - 8 + zPosMul)] = 11
			blocks[Vector3(i - 8 + xPosMul, 0, j - 8 + zPosMul)] = 11

#Ist der Block komplett umgeben?
func blockIsCompleteSurrounded(block_position):
	if (blocks.has(block_position + Vector3(1, 0, 0)) and blocks.has(block_position + Vector3(-1, 0, 0)) and blocks.has(block_position + Vector3(0, 1, 0)) and blocks.has(block_position + Vector3(0, -1, 0)) and blocks.has(block_position + Vector3(0, 0, 1)) and blocks.has(block_position + Vector3(0, 0, -1)) ):
		return true
	else :
		return false

#erstellt die Meshes
func generateMesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	# For each block, add data to the SurfaceTool and generate a collider.
	for block_position in blocks.keys():
		if (not blockIsCompleteSurrounded(block_position)):
			var block_id = blocks[block_position]
			surface_tool.set_material(material1)
			_draw_block_mesh(surface_tool, block_position, block_id)
	surface_tool.generate_tangents()
	surface_tool.index()
	var array_mesh = surface_tool.commit()
	var mi:MeshInstance3D = MeshInstance3D.new()
	mi.mesh = array_mesh
	mi.create_trimesh_collision()
	call_deferred("addChildForThread", mi)


func _draw_block_mesh(surface_tool, block_sub_position, block_id):
	var verts = calculate_block_verts(block_sub_position)
	var uvs_one = _calculate_block_uvs_two(block_id)
	var uvs_two = _calculate_block_uvs_one(block_id)
	var top_uvs = uvs_one
	var bottom_uvs = uvs_one

	# Es wird überprüft, ob der Block von hier sichtbar ist
	if (!blocks.has(block_sub_position - Vector3(0, 1, 0))):
		_draw_block_face(surface_tool, [verts[5], verts[4], verts[0]], uvs_one, Vector3(0, -1, 0)) #Bottom
		_draw_block_face(surface_tool, [verts[5], verts[0], verts[1]], uvs_two, Vector3(0, -1, 0))
	
	if (!blocks.has(block_sub_position + Vector3(0, 1, 0))):
		_draw_block_face(surface_tool, [verts[2], verts[6], verts[7]], uvs_one, Vector3(0, 1, 0)) #Top
		_draw_block_face(surface_tool, [verts[2], verts[7], verts[3]], uvs_two, Vector3(0, 1, 0))
	
	if (!blocks.has(block_sub_position + Vector3(1, 0, 0))):
		_draw_block_face(surface_tool, [verts[4], verts[5], verts[7]], uvs_one, Vector3(1, 0, 0)) #North
		_draw_block_face(surface_tool, [verts[4], verts[7], verts[6]], uvs_two, Vector3(1, 0, 0))
	
	if (!blocks.has(block_sub_position + Vector3(0, 0, 1))):
		_draw_block_face(surface_tool, [verts[1], verts[3], verts[7]], uvs_one, Vector3(0, 0, 1)) #East
		_draw_block_face(surface_tool, [verts[1], verts[7], verts[5]], uvs_two, Vector3(0, 0, 1))
	
	if (!blocks.has(block_sub_position - Vector3(1, 0, 0))):
		_draw_block_face(surface_tool, [verts[3], verts[1], verts[0]], uvs_one, Vector3(-1, 0, 0)) #South
		_draw_block_face(surface_tool, [verts[3], verts[0], verts[2]], uvs_two, Vector3(-1, 0, 0))
	
	if (!blocks.has(block_sub_position - Vector3(0, 0, 1))):
		_draw_block_face(surface_tool, [verts[0], verts[4], verts[6]], uvs_one, Vector3(0, 0, -1)) #West
		_draw_block_face(surface_tool, [verts[0], verts[6], verts[2]], uvs_two, Vector3(0, 0, -1))

func _draw_block_face(surface_tool: SurfaceTool, verts, uvs, normal):
	surface_tool.set_normal(normal)
	surface_tool.add_triangle_fan(verts, uvs)

#Es ibt hier zwei Funktionen, da die Dreiecke sonst nicht richtig gezeichnet werden würden
static func _calculate_block_uvs_one(block_id):
	var row = block_id / TEXTURE_SHEET_WIDTH
	var col = block_id % TEXTURE_SHEET_WIDTH

	return [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row ),
	]

static func _calculate_block_uvs_two(block_id):
	var row = block_id / TEXTURE_SHEET_WIDTH
	var col = block_id % TEXTURE_SHEET_WIDTH

	return [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col, row + 1),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
	]


static func calculate_block_verts(block_position):
	return [
		Vector3(block_position.x, block_position.y, block_position.z),
		Vector3(block_position.x, block_position.y, block_position.z + 1),
		Vector3(block_position.x, block_position.y + 1, block_position.z),
		Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y, block_position.z),
		Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
		Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
	]

#Ab hier bisschen Spiellogik

func startDestroy(pos, direction):
	var hitBlockPosition = Vector3(0,0,0)
	#Wenn der Block genau der int ist muss auf die Direction geachtet werden, aus der der Spieler schlägt.
	if (pos.x == int(pos.x) and direction.x < 0):
		hitBlockPosition.x = floor(pos.x - 1)
	else:
		hitBlockPosition.x = floor(pos.x)
	if (pos.y == int(pos.y) and direction.y < 0):
		hitBlockPosition.y = floor(pos.y - 1)
	else:
		hitBlockPosition.y = floor(pos.y)
	if (pos.z == int(pos.z) and direction.z < 0):
		hitBlockPosition.z = floor(pos.z - 1)
	else:
		hitBlockPosition.z = floor(pos.z)
	blocks.erase(hitBlockPosition)
	for i in self.get_children():
		i.queue_free()
	print(blocks.keys().size())
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	# For each block, add data to the SurfaceTool and generate a collider.
	for block_position in blocks.keys():
		if (not blockIsCompleteSurrounded(block_position)):
			var block_id = blocks[block_position]
			surface_tool.set_material(material1)
			_draw_block_mesh(surface_tool, block_position, block_id)
	surface_tool.generate_tangents()
	surface_tool.index()
	var array_mesh = surface_tool.commit()
	var mi = MeshInstance3D.new()
	mi.mesh = array_mesh
	mi.create_trimesh_collision()
	add_child(mi)

