#!/bin/bash

while true;
do
    echo -n "Enter the file name: "
    #asks for a valid file input name
    read filename
    #validation check to verify if the input is empty or filled with white space
    if [[ -z "${filename// }" ]]
    then
        echo -e "\nError: Input cannot be empty/blank. Please enter a valid .txt file\n"
    else
        #validation check to verify if the file exists
        if [ -f "$filename" ];
        then
            #validation check to verify if the existing file
            #is of valid .txt extension
            if [ "${filename: -3}" = 'txt' ];
            then
                #validation check to verify whether
                #the existing valid .txt file is empty
                if [ -s "$filename" ]
                then
                    echo -e "\nSuccess! $filename exists!\n\nComputing First Come First Served scheduling algorithm ....\n"
                    #sorting the file by the first column which is the arrival time
                    #the -s flag disables last-resort sorting
                    sort -ns -t "," -k1,1  -o "$filename" "$filename"
                    #setting the number of processes in file
                    NO_PROC=$(wc -l  "$filename" | cut -d ' ' -f 1);
                    echo -e  "\nNumber of process are: $NO_PROC \n";
                    #creating and setting  the latest process finish/completion time
                    PREV_TIME=0;
                    #creating and setting the total turnaround time
                    TOTAL_TT=0;
                    echo -e  "PROCESSNO    |    FinishTime    |    TurnAroundTime"
                    #creating and setting the initial process number
                    PROC_NO=1;
                    #while loop to read the input file line by line
                    while read line;
                    do
                        #getting and then setting the arrival time of each process
                        AT=$(echo $line | cut -d ',' -f 1)
                        #getting and then setting the service time of each process
                        ST=$(echo $line | cut -d ',' -f 2);
                        #checks if the arrival time of the current process is greater
                        #than the finish time of just previous process
                        if [ $AT -gt $PREV_TIME ]
                        then
                            #if yes then it sets the offset value to be the difference of
                            #current process arrival time and just previous process finish time
                            OFFSET=$((AT - PREV_TIME));
                        else
                            OFFSET=0;
                        fi;
                        #calculating the finish/completion time of the current process
                        CT=$((PREV_TIME + OFFSET + ST));
                        #updating the finish time of just previous process with the latest process
                        #to be used by the next process
                        PREV_TIME=$CT
                        #calculating the current process turnaround time
                        TT=$((CT - AT));
                        #updating the average turnaround time
                        TOTAL_TT=$((TOTAL_TT + TT))
                        #pretty printing the current process finish and turnaround time
                        printf "%6d%18d%22d\n" $PROC_NO $CT $TT
                        #incrementing the process number
                        PROC_NO=$((PROC_NO + 1));
                    done < $filename;
                    #calculating the average turnaround time of the file
                    AVG_TT=$((TOTAL_TT/NO_PROC));
                    echo -e "\n\nAverage Turn Around Time: $AVG_TT";
                    echo $AVG_TT >> time.txt;
                    #changing ownership of time.txt to root user
                    chown root time.txt;
                    #changing group of time.txt to root user
                    chgrp root time.txt;
                    #permissions: user -> read & write; group -> read; others -> none
                    chmod 640 time.txt;
                    #getting and setting the size of the text file “time.txt” (in bytes)
                    FILE_SIZE=$(stat -c %s time.txt);
                    echo  -e "\ntime.txt file size in bytes: $FILE_SIZE bytes\n"
                    break
                else
                    echo -e "\nError: $filename is empty ! please re-enter the valid .txt file\n"
                fi
            else
                echo -e "\nError: $filename is of invalid extension it must be a .txt file\n"
            fi
        else
            echo -e "\nError: file with name $filename not found ! please re-enter the valid .txt file\n"
        fi
    fi
done;