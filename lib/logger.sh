#
# Create log_file
#
new_log() {
    export script_base=$(basename $0) ;
    export script_name=$(echo $script_base | cut -f 1 -d ".");
    export dt=$(date +%Y%m%d_%H%M%S) ;
    export log_home=/tmp ;
    export log_filename="${script_name}_${dt}.log" ;
    export log_file="${log_home}/${log_filename}" ;

    [ ! -f $log_file ] && touch $log_file ;

    echo "===========================================================" | tee ${log_file} ;
    echo "Script:   ${script_name}  Version: ${version}"               | tee -a ${log_file} ;
    echo "Hostname: $(hostname -f)  "                                  | tee -a ${log_file} ;
    echo "Date:     $(date)"                                           | tee -a ${log_file} ;
    echo "Log:      ${log_file}"                                       | tee -a ${log_file} ;
    echo "===========================================================" | tee -a ${log_file} ;
}
#
# Log a message  
# Usage: log "Proces executed successfully."   # regular information
#    or: log "Error" "Somethig went wrong..."  # error message
#
log() {
  local msg=("$@");
  local msg_type=$(echo ${2:-info} | tr '[:lower:]' '[:upper:]') ; 
  [ ! -z "$2" ] && unset msg[${#msg[@]}-1] ;
  echo -e "$(date '+%Y-%m-%dT%H:%M:%S'):${msg_type}: ${msg[@]}" |& tee -a ${log_file} ;
  unset msg;
}
