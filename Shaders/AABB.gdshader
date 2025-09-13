// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx, unshaded, shadows_disabled, ambient_light_disabled;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

varying vec3 uv1_triplanar_pos;
varying vec3 uv1_power_normal;

void vertex() {
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);

	// UV1 Triplanar: Enabled (with World Triplanar)
	uv1_power_normal = abs(normal);
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * 5.0;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy + TIME) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz + TIME) * p_weights.y;
	samp += texture(p_sampler, (p_triplanar_pos.zy * vec2(-1.0, 1.0)) + TIME) * p_weights.x;
	return samp;
}

void fragment() {
	vec4 albedo_tex = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA *= albedo.a * albedo_tex.a;
}
