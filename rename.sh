#!/bin/bash
clone_url=$1
origin_branch=$2
default_branch=$3

#################################################################################################
# 
# Change geppetto-client target branch on geppetto-application package.json:
#  "dependencies": {
#    "@geppettoengine/geppetto-client": "openworm/geppetto-client#master"
#    "@geppettoengine/geppetto-client": "openworm/geppetto-client#<TO_BE_ASSIGNED>"
#  }
#
# It requires:
#   - origin_branch: branch where the new code was written ($TRAVIS_PULL_REQUEST_BRANCH)
#   - default_branch: branch to use as main branch in case $main_branch does not exist
# 
#################################################################################################

git ls-remote --heads --tags $clone_url | grep -E 'refs/(heads|tags)/'$origin_branch > /dev/null
if [ $? -eq 0 ]; then
  sed -ie 's/\"@geppettoengine.*/\"@geppettoengine\/geppetto-client\": \"openworm\/geppetto-client#'${origin_branch}'\"/g' package.json
  /bin/echo -e "\e[1;35m<$origin_branch> branch set for geppetto-client.\e[0m"
else
  sed -ie 's/\"@geppettoengine.*/\"@geppettoengine\/geppetto-client\": \"openworm\/geppetto-client#'${default_branch}'\"/g' package.json
  /bin/echo -e "\e[1;35m<$default_branch> branch set for geppetto-client.\e[0m"
fi