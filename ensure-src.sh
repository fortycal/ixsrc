#!/bin/bash

GIT_REMOTE=${GIT_REMOTE:-git@github.com}

# Ensure OK to update:
# - No pending changes
# - Expected branch is checked out
abort_if_changed () {
    pushd . >> /dev/null
    cd ./$1

    if [ $(git status | grep Untracked | wc -l) -gt 0 ]; then
        echo "There are untracked changes to $1; aborting all updates."
        exit 1
    fi

    if [ $(git status | grep "not staged" | wc -l) -gt 0 ]; then
        echo "There are pending changes to $1; aborting all updates."
        exit 1
    fi

    if [ $(git status | grep -i "on branch master" | wc -l) -ne 1 ] &&
       [ $(git status | grep -i "on branch main" | wc -l) -ne 1 ]; then
        echo "Main branch not checked out for $1; aborting all updates."
        exit 1
    fi

    popd >> /dev/null
    echo "OK to update sources for $1."
}

# Ensure indicated project is present
ensure_project () {
    # Use project name by default
    local folder=${2:-$1}
    if [ -e "./$folder" ]; then
        echo "$folder exists."
    else 
        echo "Project $1 is not present and will be cloned to $folder"
        git clone $GIT_REMOTE:ZoetisDenmark/$1.git $folder
    fi
}

# Pull the latest version of the indicated project
update_source () {
     pushd . >> /dev/null
     echo "Updating sources for $1..."
     cd ./$1
     git pull
     popd >> /dev/null
     echo "Updated sources for $1."
 }

#
# Verify current directory
#

BASENAME=`basename $(pwd)`
if [ $BASENAME != "idexx/src" ]; then # change me or don't bother
    echo "Please run this script from the proper project directory."
    exit 1
fi

#
# Ensure standard git configuration
#

git config --global pull.rebase true
git config --global fetch.prune true
git config --global diff.colorMoved zebra

#
# Ensure that all submodule projects are cloned from GitHub
#

# Slim
ensure_project "slim"

#
# Verify OK-to-update
#

# The react app
PROJ=slim
if [ -d "./$PROJ" ]; then
    abort_if_changed $PROJ
fi

#
# Update from remote repo
#

# Platform support: Printing, WIFI, Audio
PROJ=slim
if [ -d "./$PROJ" ]; then
    update_source $PROJ
else
    echo "$PROJ is not present; skipping update."
fi
