extends Node

enum Request { LIST_CONFIGS = 1, GET_CONFIG, SET_CONFIG, SET_USER, DISABLE, ENABLE, OFFSET, CALIBRATE, OPERATE, PASSIVATE }
enum Reply { CONFIGS_LISTED = 1, GOT_CONFIG, CONFIG_SET, USER_SET, DISABLED, ENABLED, OFFSETTING, CALIBRATING, OPERATING, PASSIVE }

const SCRIPTS_PATH = "res://Scripts/Inputs/"
const SCRIPT_EXT = ".gd"
const PLUGINS_PATH = "res://Plugins/Inputs/"
const PLUGIN_EXT = ".gdns"

onready var input_device_class = preload( "res://Scripts/input_device.gd" )
onready var input_axis_class = preload( "res://Scripts/input_axis.gd" )

var interface_names = [] setget ,_get_interface_names
var input_devices_list = []
var input_axes_dict = {}

func _ready():
	var interfaces_list = []
	var input_scripts = GameManager.list_files( SCRIPTS_PATH, SCRIPT_EXT )
	for script_name in input_scripts:
		var script = load( SCRIPTS_PATH + script_name + SCRIPT_EXT )
		if script != null: interfaces_list.append( script.new() )
	#var input_plugins = GameManager.list_files( PLUGINS_PATH, PLUGIN_EXT )
	#for plugin_name in input_plugins:
	#	var plugin = load( PLUGINS_PATH + plugin_name + PLUGIN_EXT )
	#	if plugin != null: interfaces_list.append( plugin.new() )
	for interface in interfaces_list:
		interface_names.append( interface.get_id() ) 
		input_devices_list.append( input_device_class.new( interface ) )

func _physics_process( delta ):
	for device in input_devices_list:
		device.update()

func _get_interface_names():
	print( interface_names )
	return interface_names

func get_interface_device( interface_index ):
	return input_devices_list[ interface_index ]

func get_device_axis( interface_index, device_index, axis_index ):
	var axis_key = interface_index | device_index << 8 | axis_index << 16
	var input_axis = input_axes_dict.get( axis_key )
	if input_axis == null:
		var device = input_devices_list[ interface_index ]
		input_axis = input_axis_class.new( device, axis_index )
	return input_axis