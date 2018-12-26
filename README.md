# juliabenchmark
* **Aim of the benchmark**   
This benchmark aims to evaluate the Julia code using real-world data from the perspective of a normal user (not expert from computing science ). Hope it could be helpful to improve the Language and package.

* **Data source**  
Transit network data of New York (Open Data).

* **Data processing task**  
Extract the points on the bus routes between every pair of the consequential bus stops.

* **About the code**
Currently, both of Python and Julia code are not optimized. In the future, the Julia version will be optimized and all old versions will be recorded for the comparison purpose. The Python code will not be optimized and kept as the benchmark.

## 1 Test and Results
The two version of code implement the same algorithm. Firstly, the algorithm is implemented using Python. Then, the Python code is translated to Julia almost line by line.

*# It should be noted that both version of the code are not optimized with much effort.*

The data operation mainly includes
* Open the CSV file
* Table data operation (iteration, selection)
* Operation on Dict, Tuple and Vector data structure

**Tabel 1-** Data structure and tabular data package used

|              | Python 3.6.5  | Julia 1.02 |
| -------------| ------------- |:-------------:|
| Package for tabular data   |  Pandas 0.23 | JuliaDB 0.10 |
| List   | [x1,x2,..]    | Vector{T}()  |
| Dict   | {k1:V1, ...}    | Dict{T1,T2}()  |
| Tuple   | (v1,...)    | Tuple{T1,T2}()  |


Performance comparison on processing 500 rows of data.
**Table 2 -** Julia code of version 1  

|        |  Python 3.6.5| Julia 1.02    |  Julia 1.02 (precompile)|
| -------------| -------------| ------------- |:-------------:|
|open `shapes.txt` | 0.07   | 22.87    | 0.0368  |
|Open `stop_times.txt`| 1.37   | 6.54    | 1.178  |
|Open `trips.txt`| 0.06  | 1.41    | 0.037  |
|Open `stops.txt` | 0.01   | 2.72    | 0.002  |
|extract segment | 38.96   | 156.07    | 94.84  |

Julia Version 1.0.2   
Commit d789231e99 (2018-11-08 20:11 UTC)   
Platform Info:   
  OS: Windows (x86_64-w64-mingw32)   
  CPU: Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz   
  WORD_SIZE: 64   
  LIBM: libopenlibm   
  LLVM: libLLVM-6.0.0 (ORCJIT, skylake)   

## 2 How to run the test on your machine ?
* Step1: Download the code and data  
```
$ git clone https://github.com/zhangliye/juliabenchmark.git
```
* Step 2: Active the project
```
$ cd juliabenchmark/tablebenchmark
$ julia
(tablebenchmark) pkg> activate .
```
* Step 3: Run julia code test
```
(tablebenchmark) pkg> test
```
* Step 4: Run Python code test
```
$python ./src/extract_segment.py
```

## 3 Summary and discussion
