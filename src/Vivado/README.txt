# Proyecto FPGA - Control de Versiones de Archivos

Este README sirve para documentar y organizar las distintas versiones del proyecto de FPGA, almacenadas en esta carpeta. Cada versión tiene un propósito específico para el desarrollo y prueba de los distintos componentes del proyecto.

## Estructura de Carpetas

- **ProjectoV01**: Proyecto de Vivado para el testeo de la Máquina de Estados (State Machine).
  - **Descripción**: Este proyecto contiene la implementación inicial de la State Machine que gestiona los estados del juego. 
  - **Propósito**: Probar y verificar el comportamiento de la máquina de estados, asegurando que transiciones y respuestas sean correctas.
  - **Contenido**: 
    - Código HDL de la máquina de estados.
    - Archivos de simulación para verificar la funcionalidad de la lógica de estado.

- **ProjectoV02**: Proyecto de Vivado para el testeo de la Interfaz Gráfica.
  - **Descripción**: Este proyecto contiene la configuración y prueba de la interfaz gráfica en la pantalla TFT LCD.
  - **Propósito**: Desarrollar y verificar la visualización de elementos gráficos en la pantalla, como símbolos y flechas. Este proyecto se centra en la comunicación SPI y la representación visual en la pantalla.
  - **Contenido**: 
    - Código HDL para controlar la pantalla TFT LCD.
    - Archivos de simulación para verificar la comunicación SPI y la visualización gráfica.

## Notas de Uso

Cada subcarpeta (`ProjectoV01` y `ProjectoV02`) contiene los archivos y configuraciones específicos para cada etapa de prueba. Asegúrate de abrir el proyecto adecuado en Vivado según la fase de desarrollo que quieras probar.

- **Para la máquina de estados**: Usa el proyecto `ProjectoV01`.
- **Para la interfaz gráfica**: Usa el proyecto `ProjectoV02`.

Este README se actualizará a medida que se creen nuevas versiones o se realicen cambios significativos en la estructura de archivos del proyecto.
