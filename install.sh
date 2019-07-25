#!/bin/sh

function error() {
  echo " ! $@"
  exit 1
}

function clone() {
  git clone https://github.com/$1 $2 \
    || error "Failed to clone $2"
}

function checkdep() {
  command -v $1 >/dev/null 2>&1 \
    || error "$1 not found! $2"
}

echo " * Testing for dependencies..."


command -v npm >/dev/null 2>&1 || command -v yarn >/dev/null 2>&1 || error "NPM or yarn is needed to set up webui"
checkdep git "Git is required to clone individual subrepos"

echo " * Cloning repositories..."

test -e chatoverflow || clone codeoverflow-org/chatoverflow chatoverflow
# todo: make the clones parallel?
test -e chatoverflow/api || clone codeoverflow-org/chatoverflow-api chatoverflow/api
test -e chatoverflow/gui || clone codeoverflow-org/chatoverflow-gui chatoverflow/gui
test -e chatoverflow/plugins-public || clone codeoverflow-org/chatoverflow-plugins chatoverflow/plugins-public

# switching to chatoverflow dir
cd chatoverflow


echo " * Refreshing using sbt..."

function sbterr() {
    echo " ! We would love to set the project up for you, but it seems like you don't have sbt installed."
    echo " ! Please install sbt and execute $ sbt ';update;fetch;update'"
    echo " ! Or follow the guide at https://github.com/codeoverflow-org/chatoverflow/wiki/Installation"
}

command -v sbt >/dev/null 2>&1 \
  && sbt ";update;fetch;update" \
  || sbterr

# update project first, then fetch plugins; then update the whole thing again
# (including plugins this time)

echo " * Setting up GUI..."

cd gui

function finished() {
  # done?
  echo " * Success! You can now open the project in IntelliJ (or whatever IDE you prefer)"
  exit
}

# don't install the project twice, lol
# prefer yarn cause yarn is better, lol
command -v yarn >/dev/null 2>&1 && yarn && finished
command -v npm >/dev/null 2>&1 && npm install && finished
