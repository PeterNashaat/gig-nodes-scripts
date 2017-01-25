!/bin/bash
# run on git
#finall step to register nodes on master

enviroment="du-conv-3"
gridID="666"
pubvlan="2312"

## Check directories exist
[[ $(ssh-add -l) ]] && echo "[+] SSH key loaded" || { echo "[-] SSH key not loaded"; exit 1; }
[[ -d "/opt/code/github/gig-projects/env_${enviroment}" ]] || { echo "[-] Can't find env_${enviroment} directory"; exit 1; }
cd "/opt/code/github/gig-projects/env_${enviroment}"
[[ -d "services/jumpscale__location__${enviroment}" ]] || { echo "[-] Can't find services/jumpscale__location__${enviroment} directory, can't register nodes"; exit 1; }
[[ -f "/tmp/openvcloud/scripts/install/07-ovcgit-cpunode-setup.py" ]] || { echo "[-] Cant find 07-ovcgit-cpunode-setup.py"; exit 1; }
[[ -f "/tmp/openvcloud/scripts/install/07-ovcgit-storagenode-setup.py" ]] || { echo "[-] Cant find 07-ovcgit-storagenode-setup.py"; exit 1; }
[[ -f "/tmp/openvcloud/scripts/install/07-ovcgit-controllernode-setup.py" ]] || { echo "[-] Cant find 07-ovcgit-controllernode-setup.py"; exit 1; }

#cd "/opt/code/github/gig-projects/env_${enviroment}"
nodes=($(ls -1 services/jumpscale__location__du-conv-3/ | grep -E "cp[ua]-..\.du.conv-3|stor-..\.du.conv-3" | awk -F__ '{print $3}'))

echo "[*] Detecting ${#nodes[@]} nodes:"
for n in ${nodes[@]}
do
  echo -e "\t ${n}"
done
echo -e "\n"
echo -e "[*] Do you want to install:\n\t(1) cpu and stor nodes as detected\n\t(2) node by node as no stor nodes detected"
## Check option
option=
while [[ ${option} != 1 && ${option} != 2 ]]; do
  option=
  echo -n "Choose option 1 or 2 :"
  read option
  [[ ${option} -ne "1" && ${option} -ne "2" ]] && echo "[Error] enter vaild option "
done

## Connecting nodes and stor and install required packages on them
for n in ${nodes[@]}
do
  if [[ ${option} == 1 ]]; then
    if [[ ${n::3} =~ cp[ua] ]]; then
      echo "[*] Connecting ${n}"
      jspython /tmp/openvcloud/scripts/install/07-ovcgit-cpunode-setup.py -n ${n} -v ${pubvlan} -g ${gridID} || echo "[-] Error in connect ${n} to master"
    elif [[ ${n::4} == stor ]]; then
      echo "[*] Connecting ${n}"
      jspython /tmp/openvcloud/scripts/install/07-ovcgit-storagenode-setup.py -n ${n} -g ${gridID} -t storagenode,storagedriver ||  echo "[-] Error in connect ${n} to master"
    else
      echo "[-] Don't recognize this ${n}"
    fi
  elif [[ ${option} == 2 ]]; then
    #statements
    echo "[*] will do this option later"
  fi
done
