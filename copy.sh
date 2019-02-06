#!/bin/bash
repo=$1
branch=$2
name=`echo ${repo} | sed 's/^.*\///g' | sed 's/.git//g'`
mkdir ${name}
git ls-remote --heads --tags ${repo} | grep -E 'refs/(heads|tags)/'$branch > /dev/null
if [ $? -eq 0 ]; then
  repo=`echo ${repo} | sed 's/\.git/\/archive\/'$branch'.zip/g'`
  /bin/echo -e "\e[1;35mDownloading branch $branch for $name\e[0m"
else
  repo=`echo ${repo} | sed 's/\.git/\/archive\/master.zip/g'`
  /bin/echo -e "\e[1;35mDownloading branch master for $name\e[0m"
fi
curl -L ${repo} | bsdtar -xzf - -C ${name} --strip-components 1