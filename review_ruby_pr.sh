#!/bin/bash
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
echo "rubocop"
  bundle install
  bundle exec rake db:create db:migrate --trace
  bundle exec rspec --format RspecJunitFormatter --out /tmp/circle-junit.8PTljEw/rspec/rspec.xml spec --format progress

  github-status-notifier notify --state pending --context lobobot/rubocop
  TARGET_FILES=$(git diff -z --name-only origin/master \
                 | xargs -0 rubocop-select)

  if [ "${TARGET_FILES}" == "" ]; then
    echo "no rubocop target found"
    github-status-notifier notify --state success --context lobo/rubocop
    exit 0
  fi

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter :Github::PullRequestReviewComment

  github-status-notifier notify --exit-status $? --context lobobot/rubocop
echo "${whitef}———————————————————${reset}"
git --work-tree=${1} --git-dir=${1}.git checkout master
git --work-tree=${1} --git-dir=${1}.git pull origin master
echo "${greenb} ${blackf}5. Delete Temporay PR ${2}"
git --work-tree=${1} --git-dir=${1}.git branch -D pull_"${2}"
