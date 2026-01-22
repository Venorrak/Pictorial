shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform float gray_threshold = 0.02; // tweak if needed

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

	// Measure how "non-gray" the color is
	float max_c = max(color.r, max(color.g, color.b));
	float min_c = min(color.r, min(color.g, color.b));
	float diff = max_c - min_c;

	if (diff < gray_threshold) {
		// Grayscale → invert
		COLOR = vec4(vec3(1.0 - max_c), color.a);
	} else {
		// Colored → unchanged
		COLOR = color;
	}
}
