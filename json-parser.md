# json-parser

**A JSON Parser That Fully Written In Bash**

---

## What is this?

`json-parser` is a bash library that provides functions to handle json files in bash scripts without using external programs, every thing keept inside bash, which help reducing the dependicies, and make you projects more portable.

---




## Original Project


I found this project : https://github.com/fkalis/bash-json-parser <bt>
by fkalis, and I enhanced the original code, the enhancments:

* add querying capabilities like jq
* made it x2 faster
* add input/output buffering
* add caching to not process same input multiple times, only processing it one time 
* add error checking
 


---



## Dependencies


* `bash`


---


## JSON Filters

You can add filters "json paths" to get reduce the result, the syntax is similar to jq filters syntax <br> 
with some differences, to get it we will have json data for example: 
```json
[
    {
        "name":"X",
        "age":15,
        "games":["AC"]
    },
    {
        "name":"Y",
        "age":18,
        "games":["COD","PUBG"],
        "license": {
            "id":"XXXXXXXXXXXXXXXXX",
            "type":"3F"
        }

    },
    {
        "name":"Z",
        "age":17,
        "games":[]
    }
]
```

filter syntax:
* **.** :<br>
period '.' is used as delimeter between keys, for example:<br>
    filter: <br> `.[1].name` <br>
    result: <br> `.[1].name=Y` <br>


* **[]** :<br>
array specifier "[]" used to specify json arrays, you can specify a number 'N' in it <br>
to get Nth element, or leave it blank to get all array elements, for example: <br>

    filter:<br> `.[2].**` <br>
    result: <br>
    ```
    .[2].name=Z
    .[2].age=17
    ```

    other example: 
    filter:<br> `.[1].games.[]`<br>
    result:<br>
    ```
    .[1].games.[0]=COD
    .[1].games.[1]=PUBG
    ```
* **\*** : <br>
asterisk '*' used as wildcard, it will match any character except the '.', which means <br>
it will match any character in the current key name, for example: <br>
    filter:<br> `.[1].l*.type`<br>
    result: <br> `.[1].license.type=3F`<br>


* **\*\*** :<br>
double asterisk '**' used as wildcard, it will match any character, unlike single asterisk <br>
it will match any character accross the key names, for example: <br>
    filter: <br> `.[1].l**`<br>
    result: <br>
    ```
    .[1].license.id=XXXXXXXXXXXXXXXXX
    .[1].license.type=3F
    ```

---

## JSON Errors

json-parser could tell about json errors without stop the processing, so errors are handled in a way to keep <br>
the parser working and produce the parsed output, to be reliable as much as possible. <br>

* Unexpected Value: 
  Unexpected Value error is to have unexpected boolean/number value, <br>
  expected values for boolean are [true,false,False,True], and for numbers, parser <br>
  expect to have sign only in the beginning in the number or don't have at all, and to have <br>
  only one period '.', or no period at all.

  for example if the json data was like
   ```json
   {"IsItJson":truue} 
   ```
  
  the error here is the boolean value is not correct due to typo in 'true' . <br>
  other case is to have number with multiple periods, or sign in the middle of number

   ```json
   {"count":1.8.9} 
   ```
   or

    ```json
   {"count":+19+5} 
   ```
  

 * Unexpected Character: 

  Unexpected Character error is to have unexpected character, the parser expect to <br>
  to have '{' or '[' in the beginning of the json file, and after a key name, parser <br> 
  expect double qoutes '"', and many more expectations.

  for example if the json data was like
   ```json
   {"name":"Amr"s} 
   ```
  
  the error here is we have unexpected character 's', after the value is ended.

  other example
   ```json
   {Y"count":5} 
   ```

   Y is unexpected.
   
* Uncompleted Object:
  parser expect all objects to be completed "closed by }", if the parser detected any <br>
  uncompleted object, then it will raise an error

  for example if the json data was like
   ```json
   {"name":"A","string":"Hello Json" 
   ```
  
  the error here is the json string has uncompleted object.

* Uncompleted Array:
  parser expect all arrays to be completed "closed by ]", if the parser detected any <br>
  uncompleted array, then it will raise an error

  for example if the json data was like
   ```json
   ["a","b","c" 
   ```
  
  the error here is the json string has uncompleted array.


* Corrupted Cache:
  if the caching is enabled, so the parser will process json data, and store processed date <br>
  into cache to not process it again, so the cache is two bash lists, if the lists have <br>
  different lengths, it will consider the cache is corrupted and it will process the data
---


## Examples


This example will show how to parse json data stored in json file, the file name is `data.json`

data.json:

```json
[
    {
        "name":"X",
        "age":15,
        "games":["AC"]
    }
]
```

now let's write the script that will parse it.

```bash
source jsonparser.sh
parse ".[]**" < data.json
```

this will print: 

```
.[0].name=X
.[0].age=15
.[0].games.[0]=AC
```

but if we want to get each key alone, example: 


```bash
source jsonparser.sh
name_pair=`parse ".[].name" < data.json`
age_pair=`parse ".[].age" < data.json`
games=`parse ".[].games.[]" < data.json`
```

this will result processing the same json file 3 times, so in this case use caching to process <br>
the file only one time, and store the data after processing, and apply filters on processed data: <br>


```bash
source jsonparser.sh
enable_cache
name_pair=`parse ".[].name" < data.json`
age_pair=`parse ".[].age" < data.json`
games=`parse ".[].games.[]" < data.json`
```


but what if we have multiple sources of json data, then caching will cause a problem, <br> 
so if you need caching but you will parse multiple files in the same script, you must clear <br>
the cache each time you change the data source, for example: 


```bash
source jsonparser.sh
enable_cache
name_pair=`parse ".[].name" < data.json`
age_pair=`parse ".[].age" < data.json`
games=`parse ".[].games.[]" < data.json`

clear_cache
name2=`parse ".[].name" < test.json`
age2=`parse ".[].age" < test.json`
games2=`parse ".[].games.[]" < test.json`
```




---

## License

This project is licensed under the **GNU General Public License v3 or later**.

---

## Authors
**Enhanced Code By: Amr Alasmer**<br>
**Original Code By: fkalis**
