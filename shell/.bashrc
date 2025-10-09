alias pass="echo dummy"
source ~/.davilera/shell/.bashrc
unalias pass
unalias aws

alias dev='cd ~/DEV'
alias hosts='sudo nano /etc/hosts'

alias lerr='lando logs --s appserver -f'
alias lerr7='lando logs --s appserver -f | grep "\[php7:"'
alias lerr8='lando logs --s appserver -f | grep "\[php8:"'

alias almacen='sshfs dariobf@192.168.1.250:/media/almacen /media/Almacen'
alias bfserver='ssh dariobf@192.168.1.250'
alias homebackup='sudo mount -t cifs //192.168.1.135/DarioBF /media/HomeBackup -o username=dariobf,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775,vers=3.0,mfsymlinks'

alias mkwp="/home/dariobf/.dariobf/mkwp"
alias cleardev="ls | xargs rm -rf"
alias cleandev="ls | xargs rm -rf"
