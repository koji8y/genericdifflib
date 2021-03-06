from enum import Enum
from typing import Any, Callable, Dict, Iterable, List, NamedTuple, Optional, Sequence, Tuple, TypeVar, Union

TElem = TypeVar('TElem')
TTag = str
TTT = TypeVar('TTT')

class EditOp(Enum):
    Replace: str = ...
    Delete: str = ...
    Insert: str = ...
    Equal: str = ...
    def __bool__(self) -> bool: ...
OpCode = Tuple[EditOp, int, int, int, int]

class Result(Generic[TElem]):
    __slot__: Any = ...
    edit_op: Any = ...
    first: Any = ...
    second: Any = ...
    def __init__(self, edit_op: EditOp, *target: TElem) -> None: ...
    def to_dict(self) -> Dict[str, Any]: ...

class Message:
    message: Any = ...
    def __init__(self, message: str) -> None: ...

class Tags:
    tags: Any = ...
    def __init__(self, tags: str) -> None: ...
TReslt = Union[Result, Message, Tags]

class Match(NamedTuple):
    a: int
    b: int
    size: int

class SequenceMatcher(Generic[TElem]):
    isjunk: Any = ...
    seq_a: Any = ...
    seq_b: Any = ...
    autojunk: Any = ...
    def __init__(self, isjunk: Optional[Callable[[TElem], bool]]=..., a: Sequence[TElem]=..., b: Sequence[TElem]=..., autojunk: bool=...) -> None: ...
    def set_seqs(self, seq_a: Sequence[TElem], seq_b: Sequence[TElem]) -> None: ...
    opcodes: Any = ...
    matching_blocks: Any = ...
    def set_seq1(self, seq_a: Sequence[TElem]) -> None: ...
    fullbcount: Any = ...
    def set_seq2(self, seq_b: Sequence[TElem]) -> None: ...
    def find_longest_match(self, alo: int, ahi: int, blo: int, bhi: int) -> Match: ...
    def get_matching_blocks(self) -> List[Match]: ...
    def get_opcodes(self) -> List[OpCode]: ...
    def get_grouped_opcodes(self, size: int=...) -> Iterable[List[OpCode]]: ...
    def ratio(self) -> float: ...
    def quick_ratio(self) -> float: ...
    def real_quick_ratio(self) -> float: ...

class Util(Generic[TElem]):
    @staticmethod
    def get_close_matches(word: Sequence[TElem], possibilities: List[Sequence[TElem]], max_size: int=..., cutoff: float=...) -> List[Sequence[TElem]]: ...
    @staticmethod
    def lift(value: Union[Sequence[TElem], TElem]) -> Sequence[TElem]: ...
    @staticmethod
    def check_types(seq_a: Sequence[TElem], seq_b: Sequence[TElem], *args: str) -> None: ...

class Differ(Generic[TElem]):
    linejunk: Any = ...
    charjunk: Any = ...
    def __init__(self, linejunk: Optional[Callable[[TElem], bool]]=..., charjunk: Optional[Callable[[TElem], bool]]=...) -> None: ...
    def compare(self, seq_a: Sequence[TElem], seq_b: Sequence[TElem]) -> Iterable[TReslt]: ...

def is_line_junk(line: Any, pat: Any = ...): ...
def is_character_junk(character: Any, whitespaces: str = ...): ...

class UDiff(Generic[TElem]):
    @classmethod
    def unified_diff(cls: Any, seq_a: Sequence[TElem], seq_b: Sequence[TElem], fromfile: str=..., tofile: str=..., fromfiledate: str=..., tofiledate: str=..., num_to_show: int=..., lineterm: str=...) -> Iterable[TReslt]: ...

class CDiff(Generic[TElem]):
    @classmethod
    def context_diff(cls: Any, seq_a: Sequence[TElem], seq_b: Sequence[TElem], fromfile: str=..., tofile: str=..., fromfiledate: str=..., tofiledate: str=..., num_to_show: int=..., lineterm: str=...) -> Iterable[TReslt]: ...

def ndiff(seq_a: Any, seq_b: Any, linejunk: Optional[Any] = ..., charjunk: Any = ...): ...

class HtmlDiff:
    def __init__(self, tabsize: int = ..., wrapcolumn: Optional[Any] = ..., linejunk: Optional[Any] = ..., charjunk: Any = ...) -> None: ...
    def make_file(self, fromlines: Any, tolines: Any, fromdesc: str = ..., todesc: str = ..., context: bool = ..., numlines: int = ..., *, charset: str = ...): ...
    def make_table(self, fromlines: Any, tolines: Any, fromdesc: str = ..., todesc: str = ..., context: bool = ..., numlines: int = ...): ...

def restore(delta: Any, which: Any) -> None: ...
