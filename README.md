# arm64-kernel-build-docker
rpi os kernel cross compile build on x64 platform for qemu kvm

# build kernels
```bash
$ docker build --progress=plain -t rasp_image_build ./image_build
$ docker build --progress=plain -t rasp_kernel_build ./kernel_build
$ docker run -it -v ./out:/out rasp_image_build
$ docker run -it -v ./out:/out rasp_kernel_build
```

# usage with qemu
```bash
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -m 2G \
  -smp 4 \
  -kernel ./out/kernel.img \
  -append "rw console=ttyAMA0 root=/dev/vda2 rootfstype=ext4 rootwait" \
  -drive file=./out/distro.qcow2,format=qcow2,id=hd0,if=none,cache=writeback \
  -device virtio-blk,drive=hd0,bootindex=0 \
  -netdev user,id=mynet,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=mynet \
  -nographic \
  -no-reboot

```

# thanks to
- https://github.com/ptrsr/pi-ci/
- https://github.com/farabimahmud/emulate-raspberry-pi3-in-qemu
- https://github.com/dhruvvyas90/qemu-rpi-kernel
