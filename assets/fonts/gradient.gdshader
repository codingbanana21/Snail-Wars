shader_type canvas_item;

uniform vec4 color_up : source_color = vec4(1.0);
uniform vec4 color_down : source_color = vec4(1.0);

void fragment() {
	COLOR = mix(color_up, color_down, UV.y);
}
