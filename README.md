# Docker Images for [Flutter](https://flutter.dev/)

Fork of the Cirrus CI Images
Contains the following improvements
* Java 17 to avoid flutter errors
* NDK Built in
* SDK 31-35 to avoid downloading for packages that require other android SDKs

```bash
docker run --rm -it -v ${PWD}:/build --workdir [workdir] ghcr.io/meyeroppelt/flutter:stable flutter test
```

The example above simply mount current working directory and runs `flutter test`

## GitHub Container Registry

https://github.com/meyeroppelt/flutter/pkgs/container/flutter