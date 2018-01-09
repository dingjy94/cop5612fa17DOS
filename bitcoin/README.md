# Bitcoin
Jingyi Ding UFID: 69364001
###RUN:
```
./project1 k
``` 

## Basic Idea
#### Generate String:
```
defp generate_key(cur_val, str) do
    remain = rem(cur_val, 96)
    cur_val = div(cur_val, 96)
    key = <<remain + 32>> <> str
    if cur_val == 0, do: key,
                     else: generate_key(cur_val, key)

  end
```
Above is the code turn number to string. Each worker's working uint is (min, max). It change the number in the unit to string, prefix with my ufid "dingjy94", and get the hash value. Then, check if the hash value fit the requirement. If it does, print out. Then, wheather the value fit or not, move to next number.

#### Basic Structure
For local, the strucutre is simple, only a server node and numbers of worker node. Server manage workers, distribute work units, and when one worker finish its unit, server give it new unit.

For remote machines, on each machines there is a remote_node, which manage the workers on that machine and communicate with main server. 

## Part1 Working Units
Use k=4 to find the best performance working units:

```
unit     coin/10s
1        30
2        41
3        59
4        67
5        82
...
9        96
10       100
11       99
12       98
13       101
...
100      99
...
1000     102
```
We can see that the efficient doesn't change much after unit = 10. Thus, the best unit is aroud 10.

## Part2 k = 4 Output
In [output.txt](./output.txt). Running time is about 25s. Mined 219 coins.

## Part3 Running time
I runned:
```
gtime -p ./project1 5
```

The result is 

```
real 24.58
user 85.35
sys 1.51
```
The ratio is about 3.5

## Part4 Most 0s coin
dingjy94l;fL	00000000739FB5335E9E5B3BB49F8B55DC3C7045ED69BCE89CF40672
## Part5 Machine number
I have tried to work on four machines and it works fine.