### Installation

1. Copy this directory to ```/boot/grub/themes/```
2. On ```/etc/default/grub``` add
   - ```"quiet splash"``` to ```GRUB_CMDLINE_LINUX_DEFAULT```
   - ```"/boot/grub/themes/grub/theme.txt"``` to ```GRUB_THEME```
   - ```"auto"``` to ```GRUB_GFXMODE```
3. Run ```sudo grub-mkconfig -o /boot/grub/grub.cfg```
