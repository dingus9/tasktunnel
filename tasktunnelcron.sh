#!/bin/bash
## This script parses the tasktunneljobs.conf, checks for existing tunnel requests on each target server then carries out the ssh connection
TASKTUNPATH='/usr/local/tasktunnel';
CLIENTSCRIPT='tasktunnel.sh';
CONF="$TASKTUNPATH/tasks/tasktunneljobs.conf";
HOSTS=$(grep -nE '.*@.*' $CONF | grep -Ev "[0-9]+:#"|grep -oE '^[0-9]+');
TASKS=$(grep -nvE '.*@.*' $CONF| grep -vE '[0-9]+:#'|grep -vE '[0-9]+:$'|grep -oE '^[0-9]+');

declare -a SECT;

SECTS=($HOSTS);

for ((i=0; i < "${#SECTS[@]}"; i++)); do
sectend='';
sectstart=${SECTS[${i}]};
let "p=i+1";
sectend=${SECTS[$p]};

[ "$sectend" == '' ] && let "sectend=$(wc -l $CONF | tr -d ' ' |grep -Eo '^[0-9]+') + 2";

server=$(sed -n $sectstart'p' $CONF);
echo "Processing tasks for $server";
let "j=$sectstart+1";

  while [ $j -lt $sectend ]; do
    cmd=$(sed -n $j'p' $CONF);      #read line
    cmd=$(echo $cmd | grep -v "#"); #remove #
    # cmd should be non zero if command line
    if [ -n "$cmd" ]; then
      task=$(echo $cmd | grep -Eo "^[0-9a-zA-Z\-]+");
      sshopts=$(echo $cmd | grep -Eo '".*"' | sed s/\"$// |sed s/^\"//); #sed removes ""
      
      # Check for task then run command or pass
      ssh $server "$TASKTUNPATH/$CLIENTSCRIPT --checkonly -t=$task";
      [ $? == 0 ] && ssh -f $sshopts $server "$TASKTUNPATH/$CLIENTSCRIPT -t=$task" || echo "No jobs for task: $task";

    fi
    let "j=$j+1";
  done;

done;

# for subline in $TASKS