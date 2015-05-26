#!/bin/bash
#
# Reject force pushes to branches matching a certain pattern,
# as well as deletion of such branches.
#
# Based on the update.sample hook

# master OR 3-4 digits with an optional 'refs/heads/' prefix
PROTECTED="^(refs/heads/)?[0-9]{3,4}|master$"

# special old/rev revision indicating branch creation or deletion: it is 40 zeros, as stated in `man githooks`
ZERO="0000000000000000000000000000000000000000"

while read oldrev newrev refname
do
  # newrev  - the new object name to be stored in the ref.
  # oldrev  - the old object name stored in the ref,
  # refname - the name of the ref being updated,

  # create new branch => no further checking needed
  if [[ $oldrev == $ZERO ]]; then
		continue;
	fi  

  if [[ $refname =~ $PROTECTED ]] ; then
    # check if it is branch deletion
    if [[ $newrev == $ZERO ]]; then
      echo "*** Deleting a release or the master branch is not allowed" >&2
      exit 1
    else 
      # check if this is a fast-foward update (i.e. not a force push): it is when $oldrev is a parent of $newrev
      merge_base=$(git merge-base $oldrev $newrev)
      if [[ $oldrev != $merge_base ]]; then
        echo "*** Force push to a release or to the master branch is not allowed" >&2
        exit 1
      fi
    fi
  fi
done

exit 0
