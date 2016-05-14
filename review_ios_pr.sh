#!/bin/bash
cd ${1}
echo "${whitef}———————————————————${reset}"
echo "${whiteb} ${blackf}0. Fetching the pull request...${reset}"
git --work-tree=${1} --git-dir=${1}.git fetch origin pull/"${2}"/head:pull_"${2}"
echo "${whiteb} ${blackf}1. PR fetched creating a branch...${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout pull_"${2}"
echo "${whiteb} ${blackf}2. Checking out to a new PR branch...${reset}"
echo "${greenb} ${blackf}3. PR Branch Created!!!${reset}"
echo "${greenb} ${blackf}4. Validation PR ${2}"
swiftlint lint --reporter json > ${1}swiftlint-report.json
bundle exec linterbot ${3} ${2} < ${1}swiftlint-report.json
echo "${whitef}———————————————————${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout master
git --work-tree=${1} --git-dir=${1}.git pull origin master
echo "${greenb} ${blackf}5. Delete Temporay PR ${2}"
git --work-tree=${1} --git-dir=${1}.git branch -D pull_"${2}"
