#!/bin/bash

echo "${whitef}———————————————————${reset}"
echo "open ${1}"
cd ${1}
echo "${whiteb} ${blackf}0. Fetching the pull request...${reset}"
git fetch origin pull/"${2}"/head:pull_"${2}"
echo "${whiteb} ${blackf}1. PR fetched creating a branch...${reset}"
git checkout pull_"${2}"
echo "${whiteb} ${blackf}2. Checking out to a new PR branch...${reset}"
echo "${greenb} ${blackf}3. PR Branch Created!!!${reset}"
echo "${greenb} ${blackf}4. Validation PR ${2}"
cd ${1}
GITHUB_ACCESS_TOKEN=${3} PULL_REQUEST_ID=${2} pronto run -f github_status github_pr -c origin/master
echo "5. back to master"
git checkout master
echo "6. delete branch : pull_${2}"
git branch -D pull_"${2}"
