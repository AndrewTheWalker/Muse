extends Node

signal TEST

# used for appending/erasing valid lock-on targets from the array
signal TARGET_SCREEN_ENTERED
signal TARGET_SCREEN_EXITED

# user pref for camera movement
signal INVERT_SIGNAL
signal ADJUST_HSENS
signal ADJUST_VSENS

# used for deciding if run state should use strafing animations
signal TARGET_LOCKED
signal TARGET_DROPPED

# signals to resources to deplete "stamina"
signal SHOT_FIRED

# connects to UI to update progress bars
signal LIFE_CHANGE
signal STAMINA_CHANGE

signal OVERHEATING

signal ELECTRIC_ENTERED
signal ELECTRIC_EXITED


signal PLAYER_DIED
