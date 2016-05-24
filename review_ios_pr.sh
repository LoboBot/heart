#!/bin/bash
##{@local_path} #{@number} #{ACCESS_TOKEN} #{@slug} #{ROOT_DIRECTORY}
# interbot $TRAVIS_REPO_SLUG $TRAVIS_PULL_REQUEST < swiftlint-report.json

PATH_REPOS="/Users/Michelin/Documents/Coding/LordAlexWorks/repos/${1}"
rm -fr  ${PATH_REPOS}
mkdir ${PATH_REPOS}

hub checkout https://github.com/${2}/pull/${3}
