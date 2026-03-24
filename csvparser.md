# csvparser

**A CSV Parser That Fully Written In Bash**

---

## What is this?

`csvparser` is a bash library that provides functions to handle csv files in bash scripts without using external programs, everything is kept inside bash, which help reducing the dependencies, and make your projects more portable.

---

## Dependencies


* `bash`


---


## How It Works

functions like get_csv_range will parse the csv input you provide, by reading it character <br>
character, and check for special characters, if it find special characters it will check for <br>
other conditions, like is it wrapped cell "a cell that is wrapped with double quotion character" <br>
and many other conditions. <br>

for newline characters, it not always end the current row, if the cell is wrapped, it can contain new line. <br>
also for comma character, it not always a delimeter, if the cell is wrapped, it can contain commas with out being ended. <br>
also the same thing for double qoutation character, it not always the end of the current cell, if the cell is wrapped, it can contain double qoutations.

---

## CSV Errors

csvparser could tell about csv errors without stop the processing, so errors are handled in a way to keep <br>
the parser working and produce the parsed output, to be reliable as much as possible. <br>

* Escaping Errors: 
  for example if the csv data was like
   ```csv
   "cell-1 abc","cell-2 "def""
   ```
  
  the error here is the double qoutations are not escaped in cell-2

* Wrapping Errors: 
  for example if the csv data was like
   ```csv
   "cell-1 abc",cell-2 def"
   ```
  
  the error here is in the cell-2, the end of csv string is " , and the final cell is not wrapped, so it <br>
  will raise wrapping error because the program will consider that the cell have missing " in the <br>
  begining of the cell.



* Incompleted Cell Error: 
  for example if the csv data was like
   ```csv
   "cell-1 abc","cel
   ```

  the error here is in the second cell, the cell is clearly wrapped "stars with double qoutation", and the csv <br>
  string is ended without the ending double qoutation, which indicates the the cell is incompleted. 


* Columns Count Inconsistensy:
  for example if the csv data was like
   ```csv
   "cell-1","cell-2"
   "cell-3","cell-4","cell-5"
   ```
  this is considered anomaly not a error, and the reason of that anomaly is in row one i have 2 cells, <br>
  but in row 2 I have 3 columns/cells , which could be intentional by the user, so it is <br>
  considered not error .



---


## Examples


This example will show how to parse the csv string, and get specific range of it:
```bash
get_csv_range "$csv_string" 5,9 1,3
```

the previous code will get from 5th row -> 9th row "5 and 9 are inclueded", and from column 1 -> 3rd column, <br>
and produces multiple variables:

```bash
# variable used as flage to know if the columns count in the specified range is inconsistent
__COLUMN_COUNT_INCONSISTENCY


# list/array used to store arrays/lists names of the arrays/lists that contain the data
__RANGE_ROWS=()

# list/array used to store the cells of row X, each cell is a array element
__ROW_X


```

so to print the whole returned result use 

```bash
 # loop to iterate over rows  
 for i in  "${__RANGE_ROWS[@]}" ; do

        # clear the buffer 
        pbuf=""

        # get the list name that holds cells of the row
        row_list_name="${i}"
 
        echo "${row_list_name}: "


        # loop to iterate over cells in row X
        for i in "${!row_list_name}" ; do 
            pbuf="${pbuf}|${i}"
        done 

        # echo the buffer
        echo "${pbuf#|}"
    done 

```



---

## License

This project is licensed under the **GNU General Public License v3 or later**.

---

## Author

**Amr Alasmer**
