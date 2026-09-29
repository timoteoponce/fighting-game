shader_type canvas_item;

// Full-screen post-processing for the arena. Sits on a CanvasLayer above the
// world TextureRect but below the comic/HUD layers, so it never touches the
// lettering. Samples the already-composited screen with linear filtering even
// though the world upscales with nearest-neighbour, so the bloom stays smooth.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform vec2 screen_size = vec2(640.0, 360.0);
uniform float bloom_intensity = 0.55;
// Skin tones sit at 0.80-0.88 luminance, so the threshold has to clear them or
// the bloom bleeds a haze into the dark eye lines and the faces read wrong.
// White spark cores and the hyper flash are 1.0, so they still bloom.
uniform float bloom_threshold = 0.90;
uniform float impact = 0.0;   // 1-2 frame white punch on heavy/special connects
uniform float shake = 0.0;    // drives chromatic aberration
uniform float flash = 0.0;    // white flash (hyper, special connects)
uniform float vignette = 0.30;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Chromatic aberration, radial so it is strongest at the edges.
	float ca = 0.0012 + shake * 0.004;
	vec2 dir = (uv - vec2(0.5)) * ca;
	vec3 col;
	col.r = texture(screen_tex, uv + dir).r;
	col.g = texture(screen_tex, uv).g;
	col.b = texture(screen_tex, uv - dir).b;

	// Bloom: bright-pass then a soft golden-angle spiral blur. Cheap at this
	// resolution and enough to make the additive hit/projectile glow read.
	vec3 bloom = vec3(0.0);
	float wsum = 0.0;
	for (int i = 0; i < 16; i++) {
		float fi = float(i);
		float ang = fi * 2.39996;
		float rad = sqrt((fi + 0.5) / 16.0) * 4.0;
		vec2 off = vec2(cos(ang), sin(ang)) * rad / screen_size;
		vec3 s = texture(screen_tex, uv + off).rgb;
		float lum = dot(s, vec3(0.299, 0.587, 0.114));
		float w = smoothstep(bloom_threshold, 1.0, lum);
		bloom += s * w;
		wsum += w;
	}
	bloom /= max(wsum, 1.0);
	col += bloom * bloom_intensity;

	// Impact frame: a hard white push on heavy/special connects.
	col = mix(col, vec3(1.0), clamp(impact, 0.0, 1.0) * 0.8);

	// White flash (hyper, special connects).
	col = mix(col, vec3(1.0), clamp(flash, 0.0, 1.0));

	// Vignette, slightly above centre so the fighters stay bright.
	float d = distance(uv, vec2(0.5, 0.45));
	col *= 1.0 - vignette * smoothstep(0.32, 0.78, d);

	COLOR = vec4(col, 1.0);
}
