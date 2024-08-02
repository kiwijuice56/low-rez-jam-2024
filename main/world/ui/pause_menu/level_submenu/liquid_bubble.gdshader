// 2D liquid inside 'sphere' shader.

// Original Author: Mirza Beig
// Godot Implementation: RuverQ

// https://twitter.com/TheMirzaBeig
// https://www.youtube.com/@MirzaBeig

// https://twitter.com/RuverQuack

// Feel free troveto use this however you want.
// Modify, learn from it, copy-paste, etc...

// Original Shadertoy: https://www.shadertoy.com/view/Ds3BRN

shader_type canvas_item;

// fV = fill value
uniform float fV;
uniform sampler2D gradient: filter_nearest;
uniform sampler2D gradient2: filter_nearest;
uniform vec4 col_a: source_color;
uniform vec4 col_b: source_color;
uniform vec4 col_c: source_color;

void fragment() {
    vec2 uv = ((UV / -0.46)) + vec2(1.1,1.1);

    float
		sdf=length(uv),c=step(sdf,1.0),
		
        vB=smoothstep(.1,.7,sin(uv.x+(PI*.5))-.3),
		vBA=vB*sin(TIME*6.)*.1,
        
        fW=(sin(((TIME*2.)+uv.x)*2.6)*.05)+vBA,
		bW=(sin(((TIME*-2.)+uv.x)*2.6+PI)*.05)-vBA,
		
        fA=(sin(TIME*4.)*.05)*vB,
        
        fP=fV * 2.3 +(sin((TIME)*PI)*.1) - 1.1,
		
        fF=step(uv.y,(fA+fW)+fP)*c,
		bF=step(uv.y,(-fA+bW)+fP)*c;

    COLOR =
		vec4((step(sdf,1.)-step(sdf,.85))*col_c*vec4(1.0, 1.0,1.0,100.0)+
		(fF*texture(gradient, vec2(sin(UV.x *4.0+ TIME)*0.004 + cos(UV.x *8.0+ 213.213 + .5*TIME)*0.1 + UV.y, 0.0))+(clamp(bF-fF,0.,1.)*texture(gradient2, vec2(cos(UV.x *2.0+ TIME + .5)*0.004 + cos(UV.x *8.0+ 2133.214413 + .2*TIME)*0.02 + UV.y, 0.0))))+
		clamp(pow((0.1)*((1.-(fF+bF))*c),5.),0.0,1.));
		
}