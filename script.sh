#!/bin/sh

GIT_DIR=/home/lrs_test/github/kudos
cd $GIT_DIR
DIFF=$(git diff ...origin)
	if [$DIFF = ""]; then
		echo "no diff"
	else
		echo "diff"
	fi
