class_name HowToPlay
extends Node2D

const LINES := [
	["MOVE", "D-pad or stick   (keyboard P1: W A S D,  P2: arrow keys)"],
	["JUMP / CROUCH", "UP / DOWN"],
	["BLOCK", "Hold BACK (away from your opponent)"],
	["L = LIGHT attack", "fast and weak   (P1: F,  P2: K)"],
	["H = HEAVY attack", "slow and strong, launches!   (P1: G,  P2: L)"],
	["PAUSE", "START   (P1: Esc,  P2: Enter)"],
]
const SPECIALS := [
	["L + H", "Projectile"],
	["FORWARD + L + H", "Rush attack"],
	["DOWN + L + H", "Anti-air (hits jumpers)"],
	["BACK + L + H", "HYPER 1! (needs a full HYPER meter)"],
	["UP + L + H", "HYPER 2! (also works in the air)"],
]


func _process(_delta: float) -> void:
	if Controls.any_just_pressed(Controls.LIGHT | Controls.HEAVY | Controls.START) != Controls.NONE:
		Sfx.play("select")
		GameState.goto("title")
	queue_redraw()


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("1b1240"), Color("5a2a8a"))
	UI.text(self, Vector2(320, 34), "HOW TO PLAY", 26, Color(1, 0.9, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.5, 0.05, 0.2))
	var y := 62.0
	for row in LINES:
		UI.text(self, Vector2(200, y), row[0], 12, Color(0.6, 0.85, 1), HORIZONTAL_ALIGNMENT_RIGHT, 3)
		UI.text(self, Vector2(212, y), row[1], 12, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 3)
		y += 18.0
	y += 8.0
	UI.text(self, Vector2(320, y), "SPECIAL MOVES: press L and H at the same time!", 15, Color(1, 0.7, 0.9))
	y += 22.0
	for row in SPECIALS:
		UI.text(self, Vector2(260, y), row[0], 13, Color(1, 0.9, 0.3), HORIZONTAL_ALIGNMENT_RIGHT, 3)
		UI.text(self, Vector2(272, y), row[1], 13, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 3)
		y += 18.0
	y += 10.0
	UI.text(self, Vector2(320, y), "SUPER COMBO:  L, L, H  (launch!)  ->  hold UP to super jump  ->  L, L, H in the air", 12, Color(0.6, 1, 0.7))
	y += 18.0
	UI.text(self, Vector2(320, y), "You can cancel a hit into a special: L, then L + H right away", 12, Color(0.6, 1, 0.7))
	y += 18.0
	UI.text(self, Vector2(320, y), "Hitting and getting hit fills your HYPER meter.  F1 during a fight shows hitboxes and frame counts.", 11, Color(1, 1, 1, 0.8))
	UI.text(self, Vector2(320, 350), "Press any button to go back", 11, Color(1, 1, 1, 0.7))
