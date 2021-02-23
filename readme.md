
### PBR 渲染 

这里实现的方式基于 [LearnOpenGL][i1]的公式，主要是将 OpenGL(GLSL) 的实现方式转换成 unity 支持的 Shader。

### Scenes:

__1. Example_Filter__

生成不同粗糙 roughness 情况下的预滤波环境贴图

 <br><img src='.github/ibl3.jpg' width=1150><br>



__2. Example_Lut__

 生成BRDF 积分贴图，lut 

 <br><img src='.github/ibl1.jpg' width=1150><br>

__3. Example_Irradiance__

间接光-漫反射   辐照度图（cubemap）生成

<br><img src='.github/ibl2.jpg' width=1150><br>

__4. Example_PBR__

Unity 默认的 GI 生成的 PBR 效果 和 教程中的公式求得效果对比。



<br><img src='.github/ibl4.jpg' width=1150><br>



## 参考

* [Specular IBL Render in LearnOpenGL][i1]
* [ Epic Games 的分割求和近似法][i2]



[i1]:https://learnopengl-cn.github.io/07%20PBR/03%20IBL/02%20Specular%20IBL/
[i2]: https://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf