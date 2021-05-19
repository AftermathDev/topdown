extends Node

onready var Log = get_node("/root/game/Interface/Log")

var socketClient
var buffer = {}

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
	if OS.is_debug_build():
		URL = "ws://10.0.0.132:25454"
		
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
		
		
		if socketClient.get_peer(1).get_available_packet_count() > 0:
			var reply = socketClient.get_peer(1).get_packet().get_string_from_utf8()
			Log.append("got back %s" % str(reply))
		
	
# the previously connected remotes, nothing too interesting going on down here
func ws_connection_established(protocol):
	Log.append("success! connection established")

func ws_connection_closed():
	Log.append("connection closed")

func ws_connection_error():
	Log.append("connection error")

#func 
