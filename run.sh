qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd \
  -drive if=ide,file=fat:rw:image,index=0,media=disk \
  -drive if=ide,file=disk1.img,format=raw,index=1,media=disk \
  -m 2048 -smp 4  \
  -serial mon:stdio \
  -vga std

