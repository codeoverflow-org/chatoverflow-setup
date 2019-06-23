#!/bin/bash

function error() {
  echo " ! $@"
  exit 1
}

function clone() {
  git clone https://github.com/$1 $2 \
    || error "Failed to clone $2"
}

function checkdep() {
  test -n `which $1` \
    || error "$1 not found! $2"
}

echo " * Testing for dependencies..."


checkdep npm "NPM is needed to set up webui"
checkdep sbt "This project is built by sbt"
checkdep git "Git is required to clone individual subrepos"

echo " * Cloning repositories..."

test -e chatoverflow && error "The chatoverflow directory already exists!"

clone codeoverflow-org/chatoverflow chatoverflow
# todo: make the clones parallel?
clone codeoverflow-org/chatoverflow-api chatoverflow/api
clone codeoverflow-org/chatoverflow-gui chatoverflow/gui
clone codeoverflow-org/chatoverflow-plugins chatoverflow/plugins-public

# switching to chatoverflow dir
cd chatoverflow

echo " * Refreshing using sbt..."

# update project first, then fetch plugins; then update the whole thing again
# (including plugins this time)
sbt ";update;fetch;update"

# done?
echo " * Success! You can now open the project in IntelliJ (or whatever IDE you prefer)"
