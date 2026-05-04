shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float inner_rad : hint_range(0.0, 1.0) = 0.25;
uniform float outer_rad : hint_range(0.0, 1.0) = 0.9;
uniform vec4 vignette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float dist = length(centered) * 2.0;
	float vignette = smoothstep(inner_rad, outer_rad, dist);
	COLOR = vec4(vignette_color.rgb, vignette * intensity * vignette_color.a);
}


