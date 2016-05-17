#!/bin/bash

START_DATE=$(date +"%s")
SWIFT_LINT=/usr/local/bin/swiftlint
printenv
cd ${1}
echo "${whitef}———————————————————${reset}"
echo "${whiteb} ${blackf}0. Fetching the pull request...${reset}"
git fetch origin pull/"${2}"/head:pull_"${2}"
echo "${whiteb} ${blackf}1. PR fetched creating a branch...${reset}"
git checkout pull_"${2}"
echo "${whiteb} ${blackf}2. Checking out to a new PR branch...${reset}"
echo "${greenb} ${blackf}3. PR Branch Created!!!${reset}"
echo "${greenb} ${blackf}4. Validation PR ${2}"
echo "validation PR pending"
echo "swiflt"

#github-status-notifier notify --exit-status pending --context lobobot/swift

# Run SwiftLint for given filename
run_swiftlint() {
    local filename="${1}"
    echo ${filename##*.}

    if [[ "${filename##*.}" == "swift" ]]; then
        ${SWIFT_LINT} autocorrect --path "${filename}"
        ${SWIFT_LINT} lint --path "${filename}" --reporter checkstyle | checkstyle_filter-git diff origin/master \
        | saddler report \
        --require saddler/reporter/text \
        --reporter Saddler::Reporter::Text
    fi
}

if [[ -e "${SWIFT_LINT}" ]]; then
    echo "SwiftLint version: $(${SWIFT_LINT} version)"
    # Run for both staged and unstaged files
    git diff --name-only origin/master| while read filename; do run_swiftlint "${filename}"; done
else
    echo "${SWIFT_LINT} is not installed."
    exit 0
fi

#github-status-notifier notify --exit-status $? --context lobobot/swift
END_DATE=$(date +"%s")

DIFF=$(($END_DATE - $START_DATE))
echo "SwiftLint took $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds to complete."


echo "${whitef}———————————————————${reset}"
#git --work-tree=${1} --git-dir=${1}.git checkout master
#git --work-tree=${1} --git-dir=${1}.git pull origin master
echo "${greenb} ${blackf}5. Delete Temporay PR ${2}"
#git --work-tree=${1} --git-dir=${1}.git branch -D pull_"${2}"
