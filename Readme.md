## Generic version of difflib
Difflib for sequences of almost any types as well as str.

```
>>> import gdifflib
>>> class A:
...     def __init__(self, n: str, y: int):
...         self.n = n
...         self.y = y
...     def __repr__(self) -> str:
...         return 'A({} {})'.format(self.n, self.y)
...     def __eq__(self, other) -> bool:
...         return self.y == other.y
...     def __hash__(self) -> int:
...         return hash(self.y)
...
>>> l1 = [A('foo',1), A('bar',2)]
>>> l2 = [A('baz',2)]
>>> list(gdifflib.Differ().compare(l1, l2))
[[Delete]A(foo 1), [Equal]A(bar 2),A(baz 2)]
```

- It is based on [difflib](https://docs.python.org/3/library/difflib.html) of Python 3.7.6.
- All methods are attached type hints.

### Targets to compare
It supports sequences whose elements are of types having both methods `__eq__` and `__hash__`.

### Usage sample
See [sample code](sample/diff.ipynb).

### Note
- It supports only `Differ().compare()`.
    - Other methods are still or eternally incomplete.
- `_fancy_replace` for `Differ().compare()` is disabled now.
