App4Walk v0.2.30
-----------------

Aplicación desarrollada como proyecto final de un curso de desarrollo de aplicaciones iOS

A continuación se presentan las funcionalidades de la actual versión.

Funcionalidades presentes en la veersión anterior:
--------------------------------------------------

- Geolocalización del dispositivo
- Creación de rutas formadas por puntos favoritos (coordenadas) que pueden ser generados utilizando la localización del dispositivo en ese instante.
- Posibilidad de asignar una fotografía a un punto favorito en el momento de su creación. La fotografía puede ser obtenida por medio de la cámara del dispositivo o desde la biblioteca de fotos del mismo.
- Cálculo de una ruta que pase por los diferentes puntos favoritos almacenados
- Lectura de códigos QR que contengan una URL codificada y presentación de la página web correspondiente
- Integración con Apple Watch: Posibilidad de mostrar en un mapa los puntos favoritos almacenados

Nuevas funcionalidades:
-----------------------

- Almacenamiento de las rutas en el dispositivo mediante el uso de Data Core.
- Posibilidad de recuperación de las rutas almacenadas.
- Acceso a las propiedades de los puntos favoritos de la ruta cargada. Dicho acceso se realiza mediante un objeto MKPointAnnotation personalizado
- Posibilidad de compartir cada uno de los puntos favoritos utilizando las aplicaciones de mensajería instaladas en el dispositivo. El acceso a la función "compartir" se encuentra en la vista que presenta las propiedades del punto favorito.
- Vista de realidad aumentada que nos permite visualizar los puntos favoritos de la ruta actual sobre una imagen tomada mediante la cámara del dispositivo. Se muestra la distancia al punto favorito desde la situación actual del usuario. 
- Acceso desde el menú principal de la aplicación a la agenda de eventos culturales de Euskadi. Se utiliza como fuente de datos un fichero JSON que el Gobierno Vasco deja a disposición de los ciudadanos a traves del portal http://opendata.euskadi.eus/w79-home/es/. Los eventos se clasifican por tipo y para cada uno de los eventos se muestran indicaciones básicas, su geolocalización y un acceso a la web con información en profundidad.

------------------------------------------------------------------------------------------------------------------------------------------------
La vista de realidad aumentada está basada en el desarrollo de Danijel Huis, en concreto en su proyecto HDAugmentedReality disponible en GitHub
https://github.com/DanijelHuis/HDAugmentedReality
------------------------------------------------------------------------------------------------------------------------------------------------

En esta versión se ha diseñado una interfaz gráfica sencilla y se han solucionado problemas de estabilidad de la aplicación.

Esta aplicación se libera bajo licencia MIT. Condiciones detalladas en el fichero LICENSE.


Historial versiones:
--------------------

App4Walk v0.1.20
-----------------

Aplicación desarrollada como proyecto final de un curso de desarrollo de aplicaciones iOS (La aplicación se encuentra en fase de desarrollo).

A continuación se presentan las funcionalidades de la actual versión y las tareas pendientes.

Funcionalidades:

- Geolocalización del dispositivo
- Creación de rutas formadas por puntos favoritos (coordenadas) que pueden ser generados utilizando la localización del dispositivo en ese instante.
- Posibilidad de asignar una fotografía a un punto favorito en el momento de su creación. La fotografía puede ser obtenida por medio de la cámara del dispositivo o desde la biblioteca de fotos del mismo.
- Cálculo de una ruta que pase por los diferentes puntos favoritos almacenados
- Lectura de códigos QR que contengan una URL codificada y presentación de la página web correspondiente
- Integración con Apple Watch: Posibilidad de mostrar en un mapa los puntos favoritos almacenados

Tareas pendientes:

- Core Data: Almacenamiento persistente de las rutas
- Posibilidad de recuperar rutas almacenadas
- Presentar en el mapa la fotografía asignada a un favorito
- Mejora de la integración con Watch
- Diseño gráfico de la aplicación: Actualmente el desarrollo de la aplicación se encuentra centrado en la elaboración de funcionalidades y no en el diseño gráfico.

