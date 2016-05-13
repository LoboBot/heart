#!/bin/bash

echo "deploy on tesfligh : ${1}"
cd ${1}
fastlane beta
