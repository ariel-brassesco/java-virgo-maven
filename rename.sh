#!/bin/bash
clone_url=$1
target_branch=$2
origin_branch=$3
default_branch=$4

#################################################################################################
# 
# Change geppetto-client target branch on geppetto-application package.json:
#  "dependencies": {
#    "@geppettoengine/geppetto-client": "openworm/geppetto-client#master"
#    "@geppettoengine/geppetto-client": "openworm/geppetto-client#<TO_BE_ASSIGNED>"
#  }
#
# It requires:
#   - target_branch: main branch to test ($TRAVIS_BRANCH)
#   - origin_branch: branch where the new code was written ($TRAVIS_PULL_REQUEST_BRANCH)
#   - default_branch: branch to use as main branch in case $main_branch does not exist
# 
#################################################################################################

if [ -z $origin_branch ]; then
  git ls-remote --heads --tags $clone_url | grep -E 'refs/(heads|tags)/'$origin_branch > /dev/null
  if [ $? -eq 0 ]; then
    branch=$origin_branch
  else
    branch=$default_branch
  fi
else
  git ls-remote --heads --tags $clone_url | grep -E 'refs/(heads|tags)/'$target_branch > /dev/null
  if [ $? -eq 0 ]; then
    branch=$target_branch
  else
    branch=$default_branch
  fi
fi
sed -ie 's/\"@geppettoengine.*/\"@geppettoengine\/geppetto-client\": \"openworm\/geppetto-client#'${branch}'\"/g' package.json
/bin/echo -e "\e[1;35m<$branch> branch set for geppetto-client.\e[0m"
