#!/bin/bash

CALL_DIR="$PWD"
LIB_DIR="${CALL_DIR}"
OUT_DIR="${CALL_DIR}/output"

create_session() {
    tmux new-session -d -s ${1} -c ${2}
}

# Attach to tmux session
attach_session() {
    tmux attach-session -t $LIB_DIR
}

# Create new tmux window, set starting directory
new_window() {
    tmux new-window -t ${1}:${2} -c ${3}
}

# Create new tmux window split horizontally, set starting directory
new_window_horiz_split() {
    tmux new-window -t ${1}:${2} -c ${3}
    tmux split-window -h -t ${1}:${2}
}

# Name tmux window
name_window() {
    tmux rename-window -t ${1}:${2} ${3}
}

# Run tmux command
run_command() {
    tmux send-keys -t ${1}:${2} "${3}" C-m
}

# Run tmux command in left pane
run_command_left() {
    tmux send-keys -t ${1}:${2}.0 "${3}" C-m
}

# Run tmux command in right pane
run_command_right() {
    tmux send-keys -t ${1}:${2}.1 "${3}" C-m
}

if [[ $* == *-help* ]]; then 
    echo ''
else 
    ct=0
    tmux kill-session -t experiment 

    cd $LIB_DIR
    go build main.go

    if [ ! -e "$OUT_DIR" ]; then
        mkdir $OUT_DIR
    fi

    cd $OUT_DIR

    SES="experiment"               
    DIR=$LIB_DIR

    create_session $SES $DIR       
    new_window $SES 1 $DIR
    new_window $SES 2 $DIR

    # Builtin flags in the above commands for the following actions
    # don't seem to work when run multiple times inside a bash script,
    # seemingly due to a race condition. Give them some time to finish.

    sleep 1

    name_window $SES 0 server0 
    run_command $SES 0 "ssh srg02"

    name_window $SES 1 server1
    run_command $SES 1 "ssh srg03"

    name_window $SES 2 server2
    run_command $SES 2 "ssh srg04"

    run_command $SES 0 "cd $LIB_DIR"
    run_command $SES 1 "cd $LIB_DIR"
    run_command $SES 2 "cd $LIB_DIR"

    sleep 1

    declare -a arr=("PrimaryBackUpRoundRobin") # "GossipRandom" "PinnedRoundRobin" "PrimaryBackUpRandom" 
    declare -a workload=(50 5) 
    for name in "${arr[@]}"
    do
        cd $OUT_DIR
        mkdir $name
        for w in "${workload[@]}"
        do
            cd $OUT_DIR/$name/
            mkdir workload_$w
            for session in {0..5} 
            do  
                cd $OUT_DIR/$name/workload_$w
                mkdir $session    
                for run in {1..3}
                do
                    cd $OUT_DIR/$name/workload_$w/$session 
                    mkdir run_$run 
                    for i in {1..10}
                    do
                        run_command $SES 0 "./main $ct server 0 500"

                        run_command $SES 1 "./main $ct server 1 500"

                        run_command $SES 2 "./main $ct server 2 500"

                        sleep 10

                        if [ $w = 50 ]; then
                            cd $LIB_DIR; ./main $ct client scripts/config_files/$name.json $(( 2 + (($i - 1) * 9) )) 10 $session $w > $OUT_DIR/$name/workload_$w/$session/run_$run/$i
                        fi 

                        if [ $w = 5 ]; then
                            cd $LIB_DIR; ./main $ct client scripts/config_files/$name.json $(( 2 + (($i - 1) * 8) )) 10 $session $w > $OUT_DIR/$name/workload_$w/$session/run_$run/$i
                        fi

                        ct=$(($ct + 1))

                        tmux send-keys -t server0 C-c
                        tmux send-keys -t server1 C-c
                        tmux send-keys -t server2 C-c

                    done 
                done
            done
        done 
    done
fi
