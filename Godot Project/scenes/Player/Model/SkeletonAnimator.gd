extends AnimationPlayer

func _ready():
	configure_blending_times()

func configure_blending_times():
	set_blend_time("Idle", "Run", 0.75)
	set_blend_time("Run", "Jump_Start", 0.25)
	set_blend_time("Jump_Land", "Run", 0.25)
	set_blend_time("Jump_Start", "Jump", 0.5)
	set_blend_time("Jump_Land", "Idle", 0.5)
	#set_blend_time("Sprintjump", "Jump", 0.5)
	#set_blend_time("Jump_Land", "Sprint", 0.3)
	#set_blend_time("Sprint_Land", "Run", 0.3)
