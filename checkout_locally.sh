#!/bin/bash

echo "${whitef}———————————————————${reset}"
echo "${whiteb} ${blackf}0. Fetching the pull request...${reset}"
git --work-tree=${1} --git-dir=${1}.git fetch origin pull/"${2}"/head:pull_"${2}"
echo "${whiteb} ${blackf}1. PR fetched creating a branch...${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout pull_"${2}"
echo "${whiteb} ${blackf}2. Checking out to a new PR branch...${reset}"
echo "${greenb} ${blackf}3. PR Branch Created!!!${reset}"
echo "${greenb} ${blackf}4. Validation PR ${2}"
echo "${whitef}———————————————————${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout master
echo "${greenb} ${blackf}5. Delete Temporay PR ${2}"
cd ${1}
swiftlint lint --reporter json > ${1}swiftlint-report.json
linterbot stefanka-lingerie/mirada 2 < ${1}swiftlint-report.json
#git --work-tree=${1} --git-dir=${1}.git branch -D pull_"${2}"
