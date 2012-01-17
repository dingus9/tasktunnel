#!/bin/bash
source /etc/environment

TASKTUNPATH=/usr/local/tasktunnel

# Set target deploy path
REAL_PATH="$(readlink -f $0)"
EXEC_PATH="$(dirname $REAL_PATH)"

task=$(echo "$@"|grep -Eo '(--task|-t)=[A-Za-z0-9_-]+'| grep -Eo '=[A-Za-z0-9_-]+'|grep -Eo '[A-Za-z0-9_-]+');
[ -n "$task" ] && TASK=$task || TASK='default'
TASKID=$(echo $task | md5sum |tr -d '[\- ]');

##check for --checkonly flag)
[ $(echo "$@"|grep -q 'checkonly') $? == 0 ] && WAIT=false || WAIT=true;


if [ -e $TASKTUNPATH/tasks/$TASKID.treq ] && [ "$WAIT" == "false" ]; then
  exit 0;
elif [ -e $TASKTUNPATH/tasks/$TASKID.treq ] && [ "$WAIT" == "true" ]; then #wait for term
  if [ -e $TASKTUNPATH/tasks/$TASKID.tready ]; then
    exit 1;
  fi
  echo "$TASK" > $TASKTUNPATH/tasks/$TASKID.tready;
  chgrp admin $TASKTUNPATH/tasks/$TASKID.tready;
  chmod g+w $TASKTUNPATH/tasks/$TASKID.tready;

  while [ -e $TASKTUNPATH/tasks/$TASKID.tready ]
    do
    sleep 5;
  done;
  exit 0;
elif [ -e $TASKTUNPATH/tasks/$TASKID.tready ]; then
  exit 1;
fi

exit 3; #no task request