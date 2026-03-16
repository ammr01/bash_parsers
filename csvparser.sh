#!/bin/bash
# Author : amr
# OS : Debian 13 x86_64
# Date : 08-Mar-2026
# Project Name : csvparser
# License: GPLV3 or later


# Copyright (C) 2025 Amr Alasmer


# csvparser is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later 
# version.

# csvparser is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.




# for parse_range function output
__START_INDEX=""
__END_INDEX=""

clear_vars(){
    # __MAX_WHOLE_COLUMN_COUNT=0
    # __MIN_WHOLE_COLUMN_COUNT=0
    # __AVG_WHOLE_COLUMN_COUNT=0
    # __LAST_WHOLE_COLUMN_COUNT=0


    __MAX_RANGE_COLUMN_COUNT=0
    __MIN_RANGE_COLUMN_COUNT=0
    __AVG_RANGE_COLUMN_COUNT=0
    __LAST_RANGE_COLUMN_COUNT=0


    # tmp list, must not used by user
    __COLS=()

    # errors and anomalies
    __WRAPPING_ERROR=0
    __INCOMPLETE_CELL_ERROR=0
    __ESCAPE_ERROR=0
    __COLUMN_COUNT_INCONSISTENCY=0


    # __RANGE_COLUMN_COUNT=()
    # __WHOLE_COLUMN_COUNT=()

    __RANGE_ROW_COUNT=0
    __RANGE_ROWS=()
    # __WHOLE_ROW_COUNT=0

    # __OVERALL_RANGE_ROW_COUNT=0
    # __OVERALL_WHOLE_ROW_COUNT=0

    __COL_ID=1
    __ROW_ID=1
}
clear_vars

parse_range(){    
    __START_INDEX=""
    __END_INDEX=""
    local range="$1"
    if [ -z "$range" ]; then 
        return 90
    fi

    local regex='([0-9]+):([0-9]+)'
    local tmp
    if [[ "$range" =~ $regex ]]; then 
        local start_range=${BASH_REMATCH[1]}
        local end_range=${BASH_REMATCH[2]}
        [ $start_range -gt $end_range ] && {  tmp=$start_range ; start_range=$end_range ; end_range=$tmp ;  }
        __START_INDEX=$start_range 
        __END_INDEX=$end_range

    else
        return 89
        
    fi
}


print_tst(){
    echo "*****************************START********************************************" 
    echo "buf: $buf " 
    echo "Status code: $stat"
    [ $__COLUMN_COUNT_INCONSISTENCY -eq 1 ] && echo "column count is INconsistent $__COLUMN_COUNT_INCONSISTENCY"
    [ $__COLUMN_COUNT_INCONSISTENCY -eq 0 ] && echo "column count is consistent $__COLUMN_COUNT_INCONSISTENCY"

    echo -e "list of rows: $__RANGE_ROWS"

    echo "__RANGE_ROW_COUNT: ${__RANGE_ROW_COUNT}" 
    echo "__MAX_RANGE_COLUMN_COUNT: ${__MAX_RANGE_COLUMN_COUNT}" 
    echo "__MIN_RANGE_COLUMN_COUNT: ${__MIN_RANGE_COLUMN_COUNT}" 
    echo "__RANGE_ROW_COUNT: ${__RANGE_ROW_COUNT}" 
    echo "__RANGE_ID: ${__RANGE_ID}" 
    for i in  "${__RANGE_ROWS[@]}" ; do
        pbuf=""
        a="${i}"
        echo "${a}: "

        for i in "${!a}" ; do 
            pbuf="${pbuf}|${i}"
        done 
        echo "${pbuf#|}"
        echo ""
        echo ""
        echo ""
        echo ""

    done 


}

get_csv_range(){

    clear_vars

    add_cell(){
        if ((__ROW_ID>=rows_start_index && __ROW_ID<=rows_end_index && __COL_ID>=cols_start_index && __COL_ID<=cols_end_index )); then
            if [ $unwrapped_cell -eq 0 ]; then 
                __COLS+=( "${tmp_cell%\"}" )
            else 
                __COLS+=( "${tmp_cell}" )
            fi
            ((current_cols_count++))

        # else
        #     not_implemented
        fi
        tmp_cell=""
        token=""
        pre_token_char=""
        unwrapped_cell=1 #true
        previous_token=""
        tmp_cell_len=0
        ((__COL_ID++))

    }

    create_row(){
        ((__RANGE_ROW_COUNT++))
        # __COLUMN_COUNT+=( $current_cols_count )
        local new_row_array="__ROW_${__ROW_ID}"
        __RANGE_ROWS+=( "$new_row_array[@]" )
        eval "${new_row_array}=( \"\${__COLS[@]}\" )"

    }
    add_row(){


        if ((__COL_ID > max_cols_count )); then 
            max_cols_count=$__COL_ID
        fi


        if ((__ROW_ID==1)); then 
            min_cols_count=$__COL_ID
        fi


        if ((__COL_ID < min_cols_count )); then 
            min_cols_count=$__COL_ID
        fi


        if ((min_cols_count != max_cols_count )); then 
            __COLUMN_COUNT_INCONSISTENCY=1
        fi
        last_cols_count=$__COL_ID
        __COL_ID=1
        current_cols_count=0

        if ((__ROW_ID>=rows_start_index && __ROW_ID<rows_end_index )); then
            create_row
        elif [ $__ROW_ID -eq $rows_end_index ] ; then 
            create_row
            ((__ROW_ID++))
            return 0
        # else 
        #     not_implemented
        fi

        ((__ROW_ID++))

        __COLS=()

    }


    local buf="$1"
    local rows_range="$2"
    local cols_range="$3"
    local buf_len="${#buf}"
    local i char token unwrapped_cell tmp_cell max_cols_count min_cols_count last_cols_count current_cols_count is_token_even token_len  regex previous_token
    local tmp_cell_len=0
    local pre_token_char=""
    


    parse_range "$rows_range"
    local rows_start_index=$__START_INDEX
    local rows_end_index=$__END_INDEX
    parse_range "$cols_range"
    local cols_start_index=$__START_INDEX
    local cols_end_index=$__END_INDEX



    
    unwrapped_cell=1 # false


    max_cols_count=0
    min_cols_count=0
    current_cols_count=0



    if [ "${buf_len}" -eq 0 ]; then 
        return 0
    fi

    for ((i=0;i<buf_len;i++)); do 
        char="${buf:$i:1}"
        token="${token}${char}"
        if [ "$char" = \" ] ; then 
            if ((tmp_cell_len==0)) ; then 
                ((tmp_cell_len++))
                if  ((i==buf_len-1)) ; then
                    __INCOMPLETE_CELL_ERROR=1
                fi
                unwrapped_cell=0 # false
                # previous_token="$token"
                token=""
                pre_token_char="$char"
                # tmp_cell="${tmp_cell}${char}"

            elif [ $unwrapped_cell -eq 0 ] || [ $unwrapped_cell -eq 1 ] ; then 
                ((tmp_cell_len++))
                local regex='^\"+$'
                if ! [[ "$token" =~ $regex ]] ; then
                    token="${char}"
                    pre_token_char=""
                    previous_token="$token"
                else 
                    token_len="${#token}"
                    [ "$pre_token_char" = \" ] && ((token_len++))
                    is_token_even=$((token_len%2==0))
                    previous_token="$token"
                    if [ $unwrapped_cell -eq 0 ] ; then 
                        [ $is_token_even -eq 0  ] && tmp_cell="${tmp_cell}${char}"
                        if  ((i==buf_len-1 )) ; then
                            add_cell
                            add_row            
                        fi
                    elif [ $unwrapped_cell -eq 1 ] ; then 
                        tmp_cell="${tmp_cell}${char}"
                        if  ((i==buf_len-1 )) ; then
                            __WRAPPING_ERROR=1
                            add_cell
                            add_row            
                        fi
                    fi
                fi
            fi

            
        elif [ "$char" = , ] ; then
            previous_token=""
            if [ $unwrapped_cell -eq 1 ] ; then 
                add_cell
                if ((i==buf_len-1)); then 
                    add_cell
                    add_row
                fi
            else 


                token_len="${#token}"
                regex='^\"+,$'
                if [[ "$token" =~ $regex ]] ; then
                    [ "$pre_token_char" = \" ] && ((token_len++))
                    is_token_even=$((token_len%2==0)) # note: the len includes the 
                    # comma, and 1 is true , and if it is even it indicates that it 
                    # is the end of cell, but if the pre_token_char is " that means
                    # the comma is not the end of the cell 
                    
                    if [ "$is_token_even" -eq 0 ] ; then
                        # comma is not end of cell, examples:
                        #  token: """, pre_token_char: " , is_token_even: 0 """", 
                        #  token: "", pre_token_char: NULL , is_token_even: 0 "", 
                        tmp_cell="${tmp_cell}${char}"
                        ((tmp_cell_len++))

                        
                    else                         
                        # comma is the end of cell, examples:
                        #  token: "", pre_token_char: " , is_token_even: 1 """, 
                        #  token: ", pre_token_char: NULL , is_token_even: 1 ", 
                        add_cell
                    fi
                    
                else
                    tmp_cell="${tmp_cell}${char}"
                    ((tmp_cell_len++))

                fi
                
                pre_token_char=""
                token=""
                    

            fi
            
        elif [ "$char" = $'\n' ] ; then
            previous_token=""
            if [ $unwrapped_cell -eq 0 ] ; then #wrapped
            
                if  ((i==buf_len-1)) ; then
                 
                    # TODO: comment this, and repleace with add_cell and add_row
                    # ((current_cols_count++,__RANGE_ROW_COUNT++))
                    # # __COLUMN_COUNT+=( $current_cols_count )
                    # current_cols_count=0
                    # __INCOMPLETE_CELL_ERROR=1

                    tmp_cell="${tmp_cell}${char}"
                    add_cell
                    add_row
                    __INCOMPLETE_CELL_ERROR=1
                    break

                fi


                token_len="${#token}"
                regex='^\"+'
                if [[ "$token" =~ $regex ]] ; then
                    [ "$pre_token_char" = \" ] && ((token_len++))
                    is_token_even=$((token_len%2==0))


                    if [ "$is_token_even" -eq 0 ] ; then
                        # newline is not end of cell, examples:
                        #  token: """\n pre_token_char: " , is_token_even: 0 """"\n 
                        #  token: ""\n pre_token_char: NULL , is_token_even: 0 ""\n 
                        tmp_cell="${tmp_cell}${char}"
                        ((tmp_cell_len++))
                        
                    else                         
                        # newline is the end of cell, examples:
                        #  token: ""\n pre_token_char: " , is_token_even: 1 """\n 
                        #  token: "\n pre_token_char: NULL , is_token_even: 1 "\n
                        add_cell
                        add_row
                       

                    fi                    
                else 
                    tmp_cell="${tmp_cell}${char}"
                    ((tmp_cell_len++))

                fi
                
                pre_token_char=""
                token=""


            else 
                add_cell
                add_row
            fi
        else

            # tmp_cell="${tmp_cell}${char}"
            # token=""
            # ((tmp_cell_len++))

            # pre_token_char=""
            
            

            
            if  [ $unwrapped_cell -eq 0 ]; then # wrapped
                pre_token_char=""
                token_len="${#previous_token}"
                regex='^\"+$'
                if [[ "$previous_token" =~ $regex ]] ; then
                    is_token_even=$((token_len%2==0))

                    if [ "$is_token_even" -eq 0 ] && [  "$pre_token_char" != \" ] ; then
                        add_cell

                        __ESCAPE_ERROR=1
                    fi                    
                fi        

                previous_token=""
            fi

            tmp_cell="${tmp_cell}${char}"
            token=""
            ((tmp_cell_len++))


            if  ((i==buf_len-1)) ; then 
                if [ $unwrapped_cell -eq 0 ]; then # wrapped
                    add_cell
                    add_row
                    __INCOMPLETE_CELL_ERROR=1
                else 
                    add_cell
                    add_row
                fi
            fi
        fi 
    done 

    ((
        __MAX_RANGE_COLUMN_COUNT=max_cols_count-1,
        __MIN_RANGE_COLUMN_COUNT=min_cols_count-1,
        __LAST_RANGE_COLUMN_COUNT=last_cols_count-1

    ))


    # I was thinking of making error codes simplers, using binary bitwise and, and each error is 
    #  associated with a specific bit, but my library using first few error codes, so i donot want to interfere
    if [ $__ESCAPE_ERROR -eq 1 ]; then 
        return 100 # escape error
    elif [ $__INCOMPLETE_CELL_ERROR -eq 1 ]; then
        return 99 # incomplete cell error
    elif [ $__WRAPPING_ERROR -eq 1 ]; then
        return 98 # wrapping error
    elif [ $__WRAPPING_ERROR -eq 1 ] && [ $__INCOMPLETE_CELL_ERROR -eq 1 ]; then 
        return 97 # wrapping error  and incomplete cell error
    elif [ $__WRAPPING_ERROR -eq 1 ] && [ $__ESCAPE_ERROR -eq 1 ]; then
        return 96 # wrapping error  and escape error
    elif [ $__ESCAPE_ERROR  -eq 1 ] && [ $__INCOMPLETE_CELL_ERROR -eq 1 ]; then 
        return 95 # escape error and incomplete cell error
    elif [ $__ESCAPE_ERROR -eq 1 ] && [ $__INCOMPLETE_CELL_ERROR -eq 1 ] && [ $__WRAPPING_ERROR -eq 1 ]; then
        return 94 # escape error and incomplete cell error and wrapping error
    fi


}

# test 1
# set -x
buf="a,b,c,d"
get_csv_range "$buf" 1:5 1:5
stat=$? ; print_tst


buf="a,b,c c,d"
get_csv_range "$buf" 1:5 1:5
stat=$? ; print_tst


buf="\"d , s\""
get_csv_range "$buf" 1:5 1:5
stat=$? ; print_tst



buf="\"d \"\", s\"" 
get_csv_range "$buf" 1:5 1:5
stat=$? ; print_tst


buf="\"d \"\"\", s\""
get_csv_range "$buf" 1:5 1:5
stat=$? ; print_tst



buf="a,b,\"c
d\",ef, hjk,lm n"
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst

buf="a,b,\"c
d,ef, hjk,lm n"
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst


buf="a,b,c
d,ef, hjk,lm n"
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst



buf="\"a\",\"b\",h,\"c\"
\"d\",\"e\""
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst



buf="\"\"\"a\"\"\",\"b\",h,\"c\""
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst



buf="\"\"\"a\"\"\",\"b\",h"
get_csv_range "$buf" 1:5 1:6
stat=$? ; print_tst


 buf="a,b,c,d,e,f
h,i,j,k,l,m
n,o,p,\"q, \"r,s
t,u,v,w,x,y
z,,,,,"

get_csv_range "$buf" 2:4 5:2
stat=$? ; print_tst

