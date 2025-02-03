docker rm -vf $(docker ps -aq)

echo "To delete all the images,"

#docker rmi -f $(docker images -aq)

rm -rfv /nanolock

sudo sed -i '/nanolock/d' /etc/hosts
