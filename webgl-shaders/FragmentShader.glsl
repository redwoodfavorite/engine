/**
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Famous Industries Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma glslify: applyMaterial = require(./chunks/applyMaterial)


/**
 * Writes the color of the pixel onto the screen
 *
 * @method main
 * @private
 *
 *
 */


 vec4 applyLight(vec4 material, vec4 glossiness) {
    vec3 ambientColor = u_ambientLight * material.rgb;
    vec3 normal = normalize(v_normal);
    int numLights = int(u_numLights);
    vec3 eyeVector = normalize(v_eyeVector);
    mat4 lightPosition = u_lightPosition;
    mat4 lightColor = u_lightColor;

    vec3 diffuse = vec3(0.0);
    bool hasGlossiness = glossiness.a > 0.0;
    bool hasSpecularColor = length(glossiness.rgb) > 0.0;

    //for(int i = 0; i < 4; i++) {
      //if (i >= numLights) break;
       const int i = 0;
        vec3 lightDirection = normalize(lightPosition[i].xyz - v_position);
        float lambertian = max(dot(lightDirection, normal), 0.0);
        if (lambertian > 0.0) {
            diffuse += lightColor[i].rgb * material.rgb * lambertian;
            if (hasGlossiness) {
                vec3 halfVector = normalize(lightDirection + eyeVector);
                float specularWeight = pow(max(dot(halfVector, normal), 0.0), glossiness.a);
                vec3 specularColor = hasSpecularColor ? glossiness.rgb : lightColor[i].rgb;
                diffuse += specularColor * specularWeight * lambertian;
           }
        }

    //}

    return vec4(ambientColor + diffuse, material.a);
}

void main() {
    vec4 material = u_baseColor.r >= 0.0 ? u_baseColor : applyMaterial(u_baseColor);

    /**
     * Apply lights only if flat shading is false
     * and at least one light is added to the scene
     */
    bool lightsEnabled = (u_flatShading == 0.0) && (u_numLights > 0.0 || length(u_ambientLight) > 0.0);

    vec3 normal = normalize(v_normal);
    vec4 glossiness = u_glossiness.x < 0.0 ? applyMaterial(u_glossiness) : u_glossiness;

    vec4 color = lightsEnabled ? applyLight(material, glossiness) : material;

    gl_FragColor = color;
    gl_FragColor.a *= u_opacity;   
}
