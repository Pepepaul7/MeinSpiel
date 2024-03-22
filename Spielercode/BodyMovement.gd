extends CharacterBody3D
class_name Player

var camera = preload("res://Spieler/h.tscn")
var cameraInstance = camera.instantiate()

var jumpCooldown = 0

var inventoryOpen:bool = false
var inventory = preload("res://Spieler/Inventory.tscn")
var inventoryInstance = inventory.instantiate()

func _ready():
	add_child(inventoryInstance)
	add_child(cameraInstance)
	#Buttons for exit/save
	$ExitAndSave.position = (Vector2(get_viewport().size) - $ExitAndSave.size) / 2
	$ExitAndSave/Continue.connect("pressed", continueGame);
	$ExitAndSave/SaveButton.connect("pressed", saveAll);
	#inventoryInstance.drawHotbar()
	
func saveAll():
	inventoryInstance.saveInventories()
	get_parent().saveGame
	
func _physics_process(delta):
#Jumping/Falling
	if not inventoryOpen:
		if Input.is_action_just_pressed("EPressed"):
			inventoryInstance.openInventory()
			inventoryOpen = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			cameraInstance.process_mode = Node.PROCESS_MODE_DISABLED
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
			if Input.is_key_pressed(KEY_W):
				if Input.is_key_pressed(KEY_CTRL):
					velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 360
				else:
					velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 180
			if Input.is_key_pressed(KEY_S):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h - 90)) * delta * 180
			if Input.is_key_pressed(KEY_D):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h)) * delta * 180
			if Input.is_key_pressed(KEY_A):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 180)) * delta * 180
			if Input.is_key_pressed(KEY_SPACE) and jumpCooldown == 0:
				jumpCooldown = 5
				velocity.y += 300 * delta
		if not is_on_floor():
			velocity.y -= 10 * delta
			if Input.is_key_pressed(KEY_W):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 2
			if Input.is_key_pressed(KEY_S):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h - 90)) * delta * 2
			if Input.is_key_pressed(KEY_D):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h)) * delta * 2
			if Input.is_key_pressed(KEY_A):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 180)) * delta * 2
	else:
		if not is_on_floor():
			velocity.y -= 10 * delta
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
		if Input.is_action_just_pressed("EPressed"):
			inventoryInstance.closeInventory()
			inventoryOpen = false
			cameraInstance.process_mode = Node.PROCESS_MODE_INHERIT
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	move_and_slide()
	if jumpCooldown > 0:
		jumpCooldown -= 1
	if Input.is_action_just_pressed("ui_cancel") and not inventoryOpen:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$ExitAndSave.visible = true
		get_tree().paused = true
	if Input.is_action_just_pressed("ui_cancel") and inventoryOpen:
		inventoryInstance.closeInventory()
		inventoryOpen = false
		cameraInstance.process_mode = Node.PROCESS_MODE_INHERIT
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("ui_accept") and inventoryOpen:
		inventoryInstance.spawnNewBackpack()

func _input(event):
	if event.is_action_pressed("LeftClick") and not inventoryOpen:
		if event.button_index == 1: # 1 == left
			var camera:Camera3D
			camera = cameraInstance.get_child(0).get_child(0)
			var parameters = PhysicsRayQueryParameters3D.create(camera.project_ray_origin(event.position), camera.project_ray_origin(event.position) + camera.project_ray_normal(event.position) * 100, 0x3, [self])
			parameters.set_hit_from_inside(true)
			var collision = get_world_3d().direct_space_state.intersect_ray(parameters)
			if (not collision.is_empty()):
				if (position.distance_squared_to(collision.position) < 5):
					collision.collider.get_parent().get_parent().startDestroy(collision.position, camera.project_ray_normal(event.position))
	if event.is_action_pressed("LeftClick") and inventoryOpen:
		inventoryInstance.handleLeftClick(event.position)
	if event is InputEventMouseButton and event.pressed and inventoryOpen and event.button_index == MOUSE_BUTTON_RIGHT:
		inventoryInstance.handleRightClick(event.position)
	

func continueGame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$ExitAndSave.visible = false
