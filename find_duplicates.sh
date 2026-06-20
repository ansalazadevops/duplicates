#!/usr/bin/env bash
# Name:         find_duplicates.sh
# Description:  Find duplicate files using MD5SUM and send the output to a file.
# Usage:        find_duplicates.sh [ -d | --directory <absolute path> ]
# Input:        The directory path where to find duplicates.
# Output:       The /tmp/file_duplicates_YYYY-MM-DD.out with the list of duplicate files.
#               The /tmp/file_duplicates_YYYY-MM-DD.log with the log of the script execution.
# ================================================================================================================
# 2026.06.20    Antonio Salazar     Initial creation.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Script version
#
version="2026.06.20";

source ./lib/logger.sh;

usage(){
  echo -e "\nUsage:
  ./$(basename ${0}) [ -d | --directory <absolute path> ]  
Where: 
  (optional) -d | --directory <path>  is the directory path where you want to find duplicates.
Example:
  ./$(basename ${0}) -d /var/log \n"  |& tee -a ${logfile}
}

# Set up the output file
set_output() {
    
    log "Creating output file..." "info" ;
    
    OUTPUT=/tmp/file_duplicates_$(date +%Y-%m-%d).out ;
    touch $OUTPUT ;
    printf '%s\t%s\t%s\n' "MD5 Hash" "Filename" "Modified Date" | tee -a $OUTPUT ;

    [[ -f $OUTPUT ]] && log "Output file created successfully: ${OUTPUT}" "info" || log "Failed to create output file: ${OUTPUT}" "error" ;

}


# Find the duplicates files and send the information to the output file
find_duplicates() {
    log "Starting to find duplicate files..." "info" ;

    find $1 -type f -exec md5sum {} + | sort | \
        awk '{ if ($1 == last_hash) { print last_line; print; } else { last_hash = $1 }; last_line=$0 }' | uniq | \
        while IFS= read -r line; do
            file=${line#* }; file=${file#?}
            printf '%s\t%s\n' "$line" "$(stat -c '%.19y' "$file")"
        done | tee -a $OUTPUT ;

     [[ $? -eq 0 ]] && log "Duplicate files found and written to output file: ${OUTPUT}" "info" || log "Failed to find duplicate files or write to output file: ${OUTPUT}" "error" ;
}

# Display the output file      
get_duplicates() {
    cat $OUTPUT ;

    [[ $? -eq 0 ]] && log "Output file displayed successfully: ${OUTPUT}" "info" || log "Failed to display output file: ${OUTPUT}" "error" ;
}


# Main function
__main__ () {

    # If no arguments ask for the directory path
    if [ "$#" -eq 0 ]; then
        read -p "Type the directory path where you want to find duplicates: " input_path ;
    else
        # If path provideded as an argument, validate the arguments and set the input path variable
        while [[ "$#" > 0 ]] ; do
            key="$1" ;
            shift ;
            case $key in
                -d|--directory)
                    input_path="$1";
                    shift ;
                ;;
                *)
                    echo "Unknown option: $key. Please use\"-d\" or \"--directory\" to specify the input directory.";
                    usage ;
                    exit 1 ;
                ;;
            esac ;
        done ;
    fi ;


    # Validate the directory exists and execute the functions to find duplicates
    if [ ! -d "$input_path" ]; then
        echo "Directory ${input_path} not found. Please try again.";
        usage ;
        exit 1 ; 
    else
        new_log ;
        set_output ;
        find_duplicates "${input_path}" ;
        get_duplicates ;
    fi ;
}

#
# Execute Main function
#
__main__ "$@";
