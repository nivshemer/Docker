docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | \
  sed 's/_.*//'  | column -t > /home/ubuntu/version.txt

#add to crontab
#* * * * * /home/ubuntu/save-environment-version.sh
