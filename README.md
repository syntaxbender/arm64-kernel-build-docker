# arm64-kernel-build-docker
rpi os kernel cross compile build on x64 platform for qemu kvm

# usage
```
$ docker build --progress=plain -t rasp_image_build ./image_build
$ docker build --progress=plain -t rasp_kernel_build ./kernel_build
$ docker run -it -v ./out:/out rasp_image_build
$ docker run -it -v ./out:/out rasp_kernel_build
```

# thanks to
1- https://github.com/ptrsr/pi-ci/ 
2- https://github.com/farabimahmud/emulate-raspberry-pi3-in-qemu
3- https://github.com/dhruvvyas90/qemu-rpi-kernel
