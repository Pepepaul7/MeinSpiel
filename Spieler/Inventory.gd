extends Node2D


var lineWidth = 10

func _draw():
	var topLeftX = get_viewport().size.x / 6
	var topLeftY = get_viewport().size.y / 6
	draw_rect(Rect2(get_viewport().size/6, get_viewport().size * 0.6666), Color.GRAY, true)
	for i in 10:
		draw_line(Vector2(topLeftX + get_viewport().size.x * 0.6666 * i / (10 - 1) + lineWidth / 2 - (lineWidth * i) / (10 - 1), topLeftY), Vector2(topLeftX + get_viewport().size.x * 0.6666 * i / (10 - 1) + lineWidth / 2 - (lineWidth * i) / (10 - 1), get_viewport().size.y * 5 / 6), Color.LIGHT_GRAY, lineWidth)
	for i in 10:
		draw_line(Vector2(topLeftX, topLeftY + get_viewport().size.y * 0.6666 * i / (10 - 1) + lineWidth / 2), Vector2(get_viewport().size.x * 5/6, topLeftY + get_viewport().size.y * 0.6666 * i / (10 - 1) + lineWidth / 2), Color.LIGHT_GRAY, lineWidth)
