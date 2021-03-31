# Filtered Frames
Autor: Yone Hernández León

### Descripción de la aplicación
La aplicación consiste en la creación de pequeños marcos que aplican un filtro a la webcam del usuario solo en el rango que abarcan.

### Caracteristicas de la aplicación
Para la realización de esta aplicación se implementaron las siguientes características:
- Creación y borrado de los marcos.
- Modificación de la posición de los marcos.
- Muestreo de las instrucciones.
- Diseño de una pequeña ayuda para el usuario (parte inferior de la pantalla)

### Decisiones adoptadas para la solución propuesta
Para eta aplicación se crearon primero las clases "FilteredFrame" y "Point". Una vez creadas, se desarrolló la parte de código que generaría las instancias de dichos objetos (los marcos). Ya con este desarrollo terminado, lo siguiente fue aplicar los filtros en cuestión, pero únicamente en la zona requerida y no en toda la cámara. Una vez comprobado el funcionamiento con un marco, se creó un ArrayList para guardar varias instancias, y se comenzo a trabajar en el movimiento de estos marcos. Esta parte fue la más costosa debido a pequeños fallos que no se tuvieron en cuenta a la hora de realizar las partes anteriores. Finalmente, se pulieron algunos detalle y se generaron los menús de ayuda y de instrucciones.

### Resuldato de la aplicación
![Animación 1](https://github.com/YoneHernandezLeon/FramedFilters/blob/main/framedfilters.gif?raw=true)

### Errores conocidos
Aún siendo la aplicación completamente funcional, hay que declarar que si los marcos se salen del rango de la camara, se puede apreciar una pequeña distorsión en la imagen.

### Referencias
##### Lenguaje de programación:
- https://processing.org/reference/
