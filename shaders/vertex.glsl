precision mediump float;

attribute vec3 	aVertexPosition;
attribute vec2 	aVertexTexCoord;
attribute float	aVertexLightLevel;
attribute float aVertexFullBright;
attribute vec4 	aVertexFrameCoord;

uniform mat4 	uProjectionMatrix;
uniform mat4 	uCameraMatrix;

varying vec2 	vTexCoord;
varying float 	vLightLevel;
varying float	vFullBright;
varying float   vFrameLeft;
varying float   vFrameTop;
varying float   vFrameWidth;
varying float   vFrameHeight;


void main( void ){

	// Transform vertex position using supplied matrices
	// vec4 camTransformedCoord = uCameraMatrix * vec4( aVertexPosition, 1.0 );
	// vec4 projTransformedCoord = uProjectionMatrix * camTransformedCoord;

	// Pass varyings to fragment shader
	vTexCoord = aVertexTexCoord;
	vLightLevel = aVertexLightLevel;
	vFullBright = aVertexFullBright;
	vFrameLeft = aVertexFrameCoord.x;
	vFrameTop = aVertexFrameCoord.y;
	vFrameWidth = aVertexFrameCoord.z;
	vFrameHeight = aVertexFrameCoord.w;

	// Final vertex position
    gl_Position = uProjectionMatrix * uCameraMatrix * vec4( aVertexPosition, 1.0 );
}