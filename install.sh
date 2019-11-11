#!/bin/sh

function error() {
  echo " ! $@" >&2
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

function parse_options() {
  DEV="false"
  BUILD="false"
  while true; do
    case "$1" in
      --dev) DEV="true";;
      --build) BUILD="true";;
      "") break;;
    esac
    shift
  done
}

function checkout_dev() {
  if [ "$DEV" == "true" ]; then
    echo "* Switching to develop branch"
    git checkout -f develop
    git -C api checkout -f develop
    git -C gui checkout -f develop
    git -C plugins-public checkout -f develop
  fi
}

function guiInstall() {
  echo " * Setting up GUI..."
  cd gui
  # don't install the project twice, lol
  # prefer yarn cause yarn is better, lol
  if command -v yarn; then
    yarn
  elif command -v npm; then
    npm install
  fi
  cd ..
}

function build() {
  if [ "$BUILD" == "true" ]; then
    command -v sbt >/dev/null 2>&1 \
      && echo "* Building Chatoverflow with Advanced Build Configuration" \
      && sbt ";clean;compile;gui;fetch;reload;version;package;copy"
  fi
}

parse_options $@

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

checkout_dev

echo " * Refreshing using sbt..."

function sbterr() {
    echo " ! We would love to set the project up for you, but it seems like you don't have sbt installed."
    echo " ! Please install sbt and execute $ sbt ';update;fetch;update'"
    echo " ! Or follow the guide at https://github.com/codeoverflow-org/chatoverflow/wiki/Installation"
}

# update project first, then fetch plugins; then update the whole thing again
# (including plugins this time)
command -v sbt >/dev/null 2>&1 \
  && sbt ";update;fetch;update" \
  || sbterr

guiInstall || error "GUI install failed. Not trying to do anything further. Exiting..."

build
echo " * Success! You can now open the project in IntelliJ (or whatever IDE you prefer)"
