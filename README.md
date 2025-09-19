# pragma-ms-local-environment

* Suficiente si no hubo cambios en Dockerfile o dependencias.
 
```sh
docker-compose up
```

* Compilar imágenes sin levantarlas
```sh
docker-compose build
```

* compilar y levantar de una vez, ideal en el primer arranque o tras cambios de código
```sh
docker-compose up --build
```
