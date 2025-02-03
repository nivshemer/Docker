#!/bin/bash
re='^[0-9]+$'

while true; do
    # read -p "Where to put the swap file? " file_path
	file_path="/swapfile"
	touch $file_path
    if [ $? -eq 0 ]; then
		rm $file_path
		break
	fi
done


while true; do
    read -p "Swap size (GB)? " swap_size
    if [[ $swap_size =~ $re ]] ; then
		break
	fi
done

swap_size_bytes=$( expr "$swap_size" '*' 1024 '*' 1024)
fallocate -l "${swap_size}G" "$file_path" || exit 1
dd if=/dev/zero of=$file_path bs=1024 count=$swap_size_bytes || exit 1
chmod 600 "$file_path" || exit 1
mkswap "$file_path" || exit 1
swapon "$file_path" || exit 1
echo "$file_path swap swap defaults 0 0" >> /etc/fstab || exit 1