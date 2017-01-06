# Radial fill shader with transparent sector (Шейдер радиального заполнения с прозрачностью сектора)

---

![](http://iprogrammer.pro/main/img-other/radial-fill-shader.gif)

---

**(en)**

Shader has settings:
- Fill starting side (right, left, up, bottom)
- Choosing of fill type: clockwise or counterclockwise

Two options of shader regulation:

 1. **SetupThroughShader** - regulation through shader's properties
 
  ![](http://iprogrammer.pro/main/img-other/radial-fill-shader-settings1.jpg)
  
 2. **SetupThroughScript** - regulation through a C# script
 
  ![](http://iprogrammer.pro/main/img-other/radial-fill-shader-settings2.jpg)

**!NOTE** - shader starts via C# script (script is attached). Script properties:
 - `cutoffStartAngle` — start angle of cuttoff.
 - `opacityStartAngle` — start angle of transparency.
 - `deltaAngle` - delta angle of rotating masks.

---

**(ru)**

Шейдер имеет настройки:
- Сторона, с которой начать заполнение (право/лево/верх/низ)
- Выбор типа заполнения: по часовой или против часовой стрелки

Присутсвуют два варианта регулирования настроек:

 1. **SetupThroughShader** - регулирование происхиодт непосредственно через свойства шейдера
 
  ![](http://iprogrammer.pro/main/img-other/radial-fill-shader-settings1.jpg)
  
 2. **SetupThroughScript** - регулирование происхиодт через C# скрипт
  
  ![](http://iprogrammer.pro/main/img-other/radial-fill-shader-settings2.jpg)

**!ЗАМЕТКА** - для работы шейдера нужен скрипт (он прилагается). Его настройки:
 - `cutoffStartAngle` — начальный угол обрезки.
 - `opacityStartAngle` — начальный угол прозрачности. 
 - `deltaAngle` - дельта, на которую проворачиваются маски.