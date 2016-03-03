# jank
A CLI JSON Processor

jank is a JSON processor. It is most easily explained with a demo:

```bash
$ echo "{\"a\" : {\"b\": 100}}" | jank ".a.b"
100

$ echo "{\"a\" : {\"b\": [1, 2, 3]}}" | jank ".a.b"
1
2
3

$ echo "{\"a\" : {\"b\": 100}}" | jank ".a.b=900"
{"a":{"b":900}}

$ echo "{\"a\" : {\"b\": [1, 2, 3]}}" | jank ".a.b[0]=900"
{"a":{"b":[900,2,3]}}

$ echo "{\"a\" : {\"b\": [1, 2, 3]}}" | jank ".a.b[]=900"
{"a":{"b":[900,900,900]}}

$ echo "{}" | jank ".a.b[0]=900"
{}
```

You can either get nested data or set it. You can do this over arrays as well with the `[]` operator, or focus on a single element of an array with `[i]`, for some index `i`. Every valid operation is safe, as you can see in the last example. Even though the object is empty, we can attempt to modify a deeply nested value without concern.

### TODOs

- Command pipelining (`.a.b[]=900|.a.b`), for example
- More language stuff
- Space insensitivity (parsing)
- Build the thing, shove it in `brew`
