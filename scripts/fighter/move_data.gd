class_name MoveData
extends Resource
## Frame data and hit properties for one attack (or one projectile's hits).
## Hitboxes are relative to the fighter's feet, facing right.

var id := ""
var display := ""
var level := 0  # 0 light, 1 heavy, 2 special, 3 hyper (higher cancels lower)
var startup := 5
var active := 3
var recovery := 10
var damage := 50
var hitbox := Rect2()
var hitstun := 16
var blockstun := 10
var kb := Vector2(2.5, 0.0)  # knockback (x away from attacker, y up is negative)
var launch := false  # sends a grounded opponent into the air
var knockdown := false
var spike := false  # slams an airborne opponent down
var chip := 0.0  # fraction of damage dealt through block
var hitstop := 5
var meter := 5.0
var hits := 1
var hit_interval := 0
var air := false
var crouch := false
var dash_speed := 0.0
var dash_from := 0
var dash_to := 0
var rise_vel := Vector2.ZERO
var rise_frame := 0
var invuln := 0
var projectile := {}
var pose_s := {}  # pose during startup
var pose_a := {}  # pose while active / recovering
var spin := 0.0  # body rotation in degrees across the move
var sfx := "whoosh"
var hit_sfx := "light"
var prop := ""


func total() -> int:
	return startup + active + recovery


static func make(d: Dictionary) -> MoveData:
	var m := MoveData.new()
	for k in d:
		m.set(k, d[k])
	return m
