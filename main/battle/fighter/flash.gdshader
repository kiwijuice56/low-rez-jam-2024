shader_type canvas_item;

uniform vec4 flash: source_color;

void fragment() {
	COLOR.rgb += flash.rgb;
}

