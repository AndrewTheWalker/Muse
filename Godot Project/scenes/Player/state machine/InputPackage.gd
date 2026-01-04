extends Node
class_name InputPackage

var actions :Array[String]

var l_input_direction : Vector2
var r_input_direction : Vector2

# i am splitting the joystick inputs into separate vectors because my movement system 
# does different things with the X than it does with the Y for both cases.

var l_input_x : float
var l_input_y : float
var r_input_x : float
var r_input_y : float
