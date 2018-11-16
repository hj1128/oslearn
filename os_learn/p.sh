#! /usr/bin/bash
nasm /home/pi/Documents/mylearn/os_learn/pmtest.asm -o /home/pi/Documents/mylearn/os_learn/p.com -I /home/pi/Documents/mylearn/os_learn/
sudo mount /home/pi/Documents/mylearn/os_learn/VDos/a.img /mnt/a
sudo cp /home/pi/Documents/mylearn/os_learn/p*.com /mnt/a
sudo umount /mnt/a
bochs -f /home/pi/Documents/mylearn/os_learn/VDos/bochsrc
