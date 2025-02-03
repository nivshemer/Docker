docker rm -vf $(docker ps -aq)

echo "To delete all the images,"

#docker rmi -f $(docker images -aq)

rm -rfv /Nivshemer

sudo sed -i '/Nivshemer/d' /etc/hosts
