shader_type canvas_item;

// Cloud shader for MeaningCloud visualization.
// Renders a soft, semi-transparent circle whose alpha is modulated by entropy
// and whose radius is driven by weight.

uniform vec4 cloud_color : source_color = vec4(0.5, 0.5, 1.0, 1.0);
uniform float weight : hint_range(0.0, 1.0) = 0.5;
uniform float entropy : hint_range(0.0, 1.0) = 0.5;
uniform vec2 center_offset = vec2(0.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	
	// Soft circle with falloff
	float radius = 0.45 * weight;
	float alpha = 1.0 - smoothstep(radius * 0.7, radius, dist);
	
	// Higher entropy = more transparent, more blurry
	alpha *= 1.0 - entropy * 0.6;
	
	// Edge glow
	float glow = exp(-dist * 4.0 / max(weight, 0.1)) * 0.3;
	alpha += glow;
	
	COLOR = vec4(cloud_color.rgb, cloud_color.a * alpha);
}