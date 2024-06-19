shader_type canvas_item;
	
uniform float blur : hint_range(0,6) = 0.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
	
	void fragment()
{
	vec4 color = texture(SCREEN_TEXTURE,SCREEN_UV, blur);
	COLOR = color;
	}
