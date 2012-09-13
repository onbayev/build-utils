#!/bin/sh

#snapshot the DB if possible
#define  vars

EAP6_DIR=/home/kanat/jboss-eap-6.0
PROJ_DIR=/home/kanat/git/kudos
FILE=/home/kanat/.isDeploying

#define redeploy function 
redeployKudos(){
$EAP6_DIR/bin/jboss-cli.sh --connect <<END
undeploy lrs.war  --all-relevant-server-groups
undeploy sms.war  --all-relevant-server-groups
undeploy lms.war  --all-relevant-server-groups
undeploy jbpm-service.jar  --all-relevant-server-groups
undeploy persistence.jar  --all-relevant-server-groups
deploy $PROJ_DIR/persistence/build/libs/persistence.jar --all-server-groups
deploy $PROJ_DIR/jbpm-service/build/libs/jbpm-service.jar --all-server-groups
deploy $PROJ_DIR/lrs/build/libs/lrs.war --server-groups=lrs-server-group
deploy $PROJ_DIR/sms/build/libs/sms.war --server-groups=sms-server-group
deploy $PROJ_DIR/lms/build/libs/lms.war --server-groups=lms-server-group
quit
END
}

if [ -e "$FILE" ]; then

sendmail -t << EOF
to:kanat.onbayev@bee.kz
from:dev@b2e.kz
subject:JBOSS ERROR
Jboss is not responding
EOF

else
  touch $FILE;
  cd $PROJ_DIR
  git fetch origin

  LOCAL_REV="$(git log -n1 --format=format:%H refs/heads/master)"
  REMOTE_REV="$(git log -n1 --format=format:%H refs/remotes/origin/master)"
  
  if [ $LOCAL_REV = $REMOTE_REV ]; then
        echo `date`: 'No changes, nothing to do'
  else
        echo 'Remote has some changes'
        if git checkout master && git pull --ff-only origin master && git checkout prod && git rebase master 
         then
                #gradle reexplode, etc..
                 gradle lrs:assemble
                 gradle sms:assemble
                 gradle lms:assemble
                #jboss-cli undeploy and deploy
                if redeployKudos 
                  then
MESSAGE=`git log "$LOCAL_REV..$REMOTE_REV"`
sendmail -t <<EOF
to:maxat.zhuniskhanov@bee.kz,nurlan.muldashev@bee.kz,yerzhan.mukhamejan@bee.kz,ruslan.bagybayev@bee.kz
from:dev@b2e.kz
subject:Commits successfully deployed.
$MESSAGE
EOF

                else
sendmail -t << EOF
to:kanat.onbayev@bee.kz
from:dev@b2e.kz
subject:DEPLOYMENT ERROR
There is an error, while deploy
EOF
        
                fi
        else
sendmail -t << EOF
to:kanat.onbayev@bee.kz
from:dev@b2e.kz
subject:GIT ERROR
There is an error, while rebase
EOF
        fi
  fi
  rm $FILE      
fi

