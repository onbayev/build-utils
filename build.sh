#!/bin/sh

#snapshot the DB if possible

git fetch origin master

LOCAL_REV = "$(git log -n1 --format=format:%H refs/heads/master)"
REMOTE_REV = "$(git log -n1 --format=format:%H refs/remotes/origin/master)"

if [ "$LOCAL_REV" = "$REMOTE_REV" ] then
	echo 'No changes, do nothing'
else
	echo 'remote has some changes'
	if [ git checkout master && git pull --ff-only origin master && git checkout prod && git pull --rebase master ] then
		echo 'Successfully rebased prod on master, probably there are no merge-conflicts'
		#gradle reexplode, etc..
	else
		echo 'There is an error, inspect previous messages'
	fi
fi
