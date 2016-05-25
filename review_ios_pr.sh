#!/bin/bash
##{@local_path} #{@number} #{ACCESS_TOKEN} #{@slug} #{ROOT_DIRECTORY}
# interbot $TRAVIS_REPO_SLUG $TRAVIS_PULL_REQUEST < swiftlint-report.json

# To Do
# 1. quand il y a pas d'errur affiché un message nice
# 2 add status
# 3 call method pour les commit aussi

PATH_REPOS=/Users/Michelin/Documents/Coding/LordAlexWorks/repos/${1}
rm -fr ${PATH_REPOS}
REPO_PATH_GITHUB=${2}
NUMB_PR=${3}
START_DATE=$(date +"%s")
SWIFT_LINT=/usr/local/bin/swiftlint

echo ${PATH_REPOS}

echo clone ${REPO_PATH_GITHUB}
hub clone https://github.com/${REPO_PATH_GITHUB} ${PATH_REPOS}
echo "-------"
cd ${PATH_REPOS}
git branch
hub  checkout https://github.com/${REPO_PATH_GITHUB}/pull/${NUMB_PR}
git branch
cd ../../webhook/

# Run SwiftLint for given filename
run_swiftlint() {
    local filename="${PATH_REPOS}/${1}"
    echo ${filename##*.}
    if [[ "${filename##*.}" == "swift" ]]; then
      ${SWIFT_LINT} autocorrect --path "${filename}"
      ${SWIFT_LINT} lint --path "${filename}" --reporter checkstyle | checkstyle_filter-git diff origin/master \
      | saddler report \
     --require saddler/reporter/github \
     --reporter Saddler::Reporter::Github::PullRequestReviewComment
  fi
}

if [[ -e "${SWIFT_LINT}" ]]; then
    echo "SwiftLint version: $(${SWIFT_LINT} version)"
    # Run for both staged and unstaged files
    git -C ${PATH_REPOS} diff --name-only origin/master| while read filename; do run_swiftlint "${filename}"; done
else
    echo "${SWIFT_LINT} is not installed."
    exit 0
fi


END_DATE=$(date +"%s")

DIFF=$(($END_DATE - $START_DATE))
echo "SwiftLint took $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds to complete."
