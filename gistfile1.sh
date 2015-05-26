#!/bin/bash
#
# Reject force pushes to branches matching a certain pattern,
# as well as deletion of such branches.
#
# Based on the update.sample hook

# read parameters, per `man githooks`
refname="$1"  # the name of the ref being updated,
oldrev="$2"   # the old object name stored in the ref,
newrev="$3"   # and the new object name to be stored in the ref.

# safety check
if [ -z "$refname" -o -z "$oldrev" -o -z "$newrev" ]; then
  echo "usage: $0 <ref> <oldrev> <newrev>" >&2
  exit 1
fi

# master OR 3-4 digits with an optional 'refs/heads/' prefix
PROTECTED="^(refs/heads/)?[0-9]{3,4}|master$"

# special old/rev revision indicating branch creation or deletion
ZERO="0000000000000000000000000000000000000000"

if [[ $refname =~ $PROTECTED ]] ; then
  # check if it is branch deletion: it is when $newrev is 40 zeros, as stated in `man githooks`
  if [[ $newrev == $ZERO ]]; then
    echo "*** Deleting a release or the master branch is not allowed in this repository" >&2
    exit 1
  else 
    # check if this is a fast-foward update (i.e. not a force push): it is when $oldrev is a parent of $newrev
    merge_base=$(git merge-base $oldrev $newrev)
    if [[ $oldrev != $merge_base ]]; then
      echo "*** Force push to a release or to the master branch is not allowed in this repository" >&2
      exit 1
    fi
  fi
fi

exit 0
