## Generic version of difflib
Difflib for sequences of many types as well as str.

It is based on difflib of python 3.7.6.

### Targets to compare
It supports sequences whose elements are of types having both methods `__eq__` and `__hash__`.

### Usage sample
See [sample code](sample/diff.ipynb).

### Note
- It supports only `Differ().compare()`.
    - Other methods are still or eternally imcomplete.
