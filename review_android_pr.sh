#!/bin/bash

echo "${whitef}———————————————————${reset}"
echo "${whiteb} ${blackf}0. Fetching the pull request...${reset}"
git --work-tree=${1} --git-dir=${1}.git fetch origin pull/"${2}"/head:pull_"${2}"
echo "${whiteb} ${blackf}1. PR fetched creating a branch...${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout pull_"${2}"
echo "${whiteb} ${blackf}2. Checking out to a new PR branch...${reset}"
echo "${greenb} ${blackf}3. PR Branch Created!!!${reset}"
echo "${greenb} ${blackf}4. Validation PR ${2}"

echo "********************"
echo "* exec gradle      *"
echo "********************"
gradle app:check -p ${1}AndroidSource/GuavaAndroid #TO DO USE VAR

if [ $? -ne 0 ]; then
    cd ${1}
    echo 'Failed gradle check task. ./gradlew app:check'
    exit 1
fi

cd ${1}AndroidSource/GuavaAndroid

github-status-notifier notify --state pending --context lobobot/java

#REPORTER=Saddler::Reporter::Github::CommitReviewComment

REPORTER=Saddler::Reporter::Github::PullRequestReviewComment

echo "********************"
echo "* checkstyle       *"
echo "********************"
cat app/build/reports/checkstyle/checkstyle.xml \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require lobot/reporter/github --reporter $REPORTER

echo "********************"
echo "* findbugs         *"
echo "********************"
cat app/build/reports/findbugs/findbugs.xml \
    | findbugs_translate_checkstyle_format translate \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require lobot/reporter/github --reporter $REPORTER

echo "********************"
echo "* PMD              *"
echo "********************"
cat app/build/reports/pmd/pmd.xml \
    | pmd_translate_checkstyle_format translate \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require lobot/reporter/github --reporter $REPORTER

echo "********************"
echo "* PMD-CPD          *"
echo "********************"
cat app/build/reports/pmd/cpd.xml \
    | pmd_translate_checkstyle_format translate --cpd-translate \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require lobot/reporter/github --reporter $REPORTER

echo "********************"
echo "* android lint     *"
echo "********************"
cat app/build/outputs/lint-results.xml \
    | android_lint_translate_checkstyle_format translate \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require lobot/reporter/github --reporter $REPORTER

github-status-notifier notify --state success --context lobobot/java

    echo "${whitef}———————————————————${reset}"
    git --work-tree=${1} --git-dir=${1}.git checkout master
    git --work-tree=${1} --git-dir=${1}.git pull origin master
    echo "${greenb} ${blackf}5. Delete Temporay PR ${2}"
    git --work-tree=${1} --git-dir=${1}.git branch -D pull_"${2}"
    
cd ${5}
