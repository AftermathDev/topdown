extends Panel

var thread

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func append(_text):
	print(_text)
	var text = preload("log/RichTextLabel.tscn")
	var r = text.instance()
	r.text = _text
	self.get_node("VBoxContainer").add_child(r)
	yield(get_tree().create_timer(10.0), "timeout")
	r.queue_free()
	
	
