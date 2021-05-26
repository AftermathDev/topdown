extends Node

onready var Log = get_node("/root/game/Interface/Log")
onready var player = get_node("/root/game/Client/Player")
onready var enemy = preload("res://special/Enemy.tscn")

var socketClient
var buffer = {}
var debug = OS.is_debug_build()
var players = {}
var id

func _ready():
	
	# initialize websocket
	socketClient = WebSocketClient.new()
	# tell websocket that we don't need encryption
	socketClient.set_verify_ssl_enabled(false)
	
	# connect common remotes to our functions
	socketClient.connect("connection_established", self, "ws_connection_established")
	socketClient.connect("connection_closed", self, "ws_connection_closed")
	socketClient.connect("connection_error", self, "ws_connection_error")
	
	# check if the game is a debug build, if it is then just connect
	# directly to loopback adapter rather than going the long way back
	var URL = "ws://73.252.145.40:25454"
	if debug:
		URL = "ws://10.0.0.130:25454"
		
	# finally, connect to the server
	Log.append("connecting to " + URL)
	socketClient.connect_to_url(URL, PoolStringArray())
	
	# tell the websocket that we should be sending text
	socketClient.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)

# set to run every frame, where "delta" is time since the previous frame
func _process(delta):
	# check if socket is connected or in the middle of connecting
	if socketClient.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED or socketClient.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
		# send something to keep the socket alive
		socketClient.poll()
	
	# check if actually connected to a host
	if socketClient.get_peer(1).is_connected_to_host():
		# if so, send a reply
		buffer = {
			"x":player.position.x,
			"y":player.position.y,
			"rot":player.rotation_degrees
		}
		
		#Log.append(JSON.print(buffer))
		
		socketClient.get_peer(1).put_packet(JSON.print(buffer).to_utf8())
		
		if socketClient.get_peer(1).get_available_packet_count() > 0:
			var reply = JSON.parse(socketClient.get_peer(1).get_packet().get_string_from_utf8()).result
			
			id = reply["connection"]
			var _players = reply["players"]
			_players.erase(str(id))
			
			print(str(_players))
			
			var x = 0
			
			if not (_players.empty() or players.empty()):
				if _players.size() != players.size():
					players = {}
					for i in get_node("/root/game/Enemy").get_children():
						i.queue_free()
					
					for i in _players:
						players[i] = enemy.instance()
						
						get_node("/root/game/Enemy").add_child(players[i]["instance"])
					
			if get_node("/root/game/Enemy").get_child_count() == _players.size():
				for i in players:
					players[i].position.x = _players[i].x
					players[i].position.y = _players[i].y
					players[i].rotation_degrees = _players[i].rot
			
		
	
# the previously connected remotes, nothing too interesting going on down here
func ws_connection_established(protocol):
	Log.append("success! connection established")

func ws_connection_closed(reason):
	Log.append("connection closed : %s" % reason)

func ws_connection_error():
	Log.append("connection error")

#func 
