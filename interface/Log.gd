extends Panel

var thread = Thread.new()

onready var text = preload("log/RichTextLabel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func append(_text):
	print(_text)
	thread.start(self, "_threaded_process", _text)
	
func _threaded_process(t):
	var r = text.instance()
	r.text = t
	yield(get_tree().create_timer(10.0), "timeout")
	r.queue_free()
