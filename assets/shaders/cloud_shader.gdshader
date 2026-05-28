shader_type canvas_item;

// Simplified Cloud shader for maximum compatibility.
uniform vec4 cloud_color : source_color = vec4(0.5, 0.5, 1.0, 1.0);
uniform float weight : hint_range(0.0, 1.0) = 0.5;
uniform float entropy : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);

	// Basic soft circle
	float radius = max(0.2, 0.45 * weight);
	float alpha = 1.0 - smoothstep(radius * 0.5, radius, dist);

	// Entropy makes it fade, but keep clouds visible.
	alpha *= (1.0 - entropy);
	alpha = max(alpha, 0.25);

	COLOR = vec4(cloud_color.rgb, cloud_color.a * alpha);
}
