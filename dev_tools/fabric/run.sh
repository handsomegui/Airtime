#!/bin/bash

exec 2>&1

target="airtime_git_branch:devel"
#target="airtime_git_branch:airtime-2.0.0-RC1"
airtime_versions=("")
#airtime_versions=("airtime_191_tar" "airtime_192_tar" "airtime_192_tar" "airtime_194_tar" "airtime_195_tar")
ubuntu_versions=("ubuntu_lucid_32" "ubuntu_lucid_64" "ubuntu_natty_32" "ubuntu_natty_64" "ubuntu_oneiric_32" "ubuntu_oneiric_64" "ubuntu_precise_32" "ubuntu_precise_64" "ubuntu_quantal_32" "ubuntu_quantal_64" "debian_squeeze_32" "debian_squeeze_64" "debian_wheezy_32" "debian_wheezy_64")
#ubuntu_versions=("debian_wheezy_32" "debian_wheezy_64")

num1=${#ubuntu_versions[@]}
num2=${#airtime_versions[@]}

mkdir -p ./upgrade_logs

for i in $(seq 0 $(($num1 -1)));
do
    #echo fab -f fab_setup.py os_update shutdown
    for j in $(seq 0 $(($num2 -1)));
    do
        #since 2.2.0 airtime start to support wheezy and quantal, before that, we don't need to test on those combinations
        platform=`echo ${ubuntu_versions[$i]} | awk '/(quantal)|(wheezy)/'`
        airtime=`echo ${airtime_versions[$j]} | awk '/2(0|1)[0-3]/'`
        if [ "$platform" = "" ] || [ "$airtime" = "" ];then
            echo fab -f fab_release_test.py ${ubuntu_versions[$i]} ${airtime_versions[$j]} $target shutdown
            fab -f fab_release_test.py ${ubuntu_versions[$i]} ${airtime_versions[$j]} $target shutdown 2>&1 | tee "./$upgrade_log_folder/${ubuntu_versions[$i]}_${airtime_versions[$j]}_$target.log"
            #touch "./$upgrade_log_folder/${ubuntu_versions[$i]}_${airtime_versions[$j]}_$target.log"
            tail -20 "./$upgrade_log_folder/${ubuntu_versions[$i]}_${airtime_versions[$j]}_$target.log" | grep -E "Your installation of Airtime looks OK"
            returncode=$?
            if [ "$returncode" -ne "0" ]; then
                mv "./$upgrade_log_folder/${ubuntu_versions[$i]}_${airtime_versions[$j]}_$target.log" "./$upgrade_log_folder/fail_${ubuntu_versions[$i]}_${airtime_versions[$j]}_$target.log"
            fi
        fi
    done
done

