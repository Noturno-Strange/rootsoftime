shader_type canvas_item;
uniform sampler2D earth : source_color, filter_linear_mipmap;

// The rectangle covers the two missing links between the painted paths.
float segment(vec2 p, vec2 a, vec2 b) {
	vec2 span = b - a;
	return length(p - a - span * clamp(dot(p-a,span)/dot(span,span),0.0,1.0));
}
varying vec2 map_position;
varying vec4 light_tint;
void vertex() {
	map_position = (MODEL_MATRIX * vec4(VERTEX,0.0,1.0)).xy;
	light_tint = COLOR;
}
void fragment() {
	vec2 p = map_position;
	float orchard = min(segment(p,vec2(1050,741),vec2(1214,669)),segment(p,vec2(1214,669),vec2(1320,570)));
	orchard = min(orchard,segment(p,vec2(1320,570),vec2(1388,497)));
	orchard = min(orchard,segment(p,vec2(1388,497),vec2(1460,457)));
	orchard = min(orchard,segment(p,vec2(1460,457),vec2(1650,450)));
	float fair = min(segment(p,vec2(1120,737),vec2(1218,806)),segment(p,vec2(1218,806),vec2(1310,885)));
	fair = min(fair,segment(p,vec2(1310,885),vec2(1370,958)));
	fair = min(fair,segment(p,vec2(1370,958),vec2(1391,1040)));
	vec2 mirror = abs(fract((p-vec2(900,300))/vec2(430,330))*2.0-1.0);
	vec3 soil = texture(earth,vec2(0.325,0.45)+mirror*vec2(0.13,0.115)).rgb;
	float grain = texture(earth,vec2(0.33,0.47)+mirror*0.09).g;
	float edges = min(orchard-28.0,fair-31.0)+(grain-0.55)*28.0+3.5*sin(p.x*0.073+p.y*0.048);
	float ends = smoothstep(0.0,110.0,p.x-1050.0)*smoothstep(0.0,125.0,1650.0-p.x)*smoothstep(0.0,95.0,1040.0-p.y);
	COLOR = light_tint * vec4(soil,(1.0-smoothstep(-10.0,15.0,edges))*ends*0.87);
}
