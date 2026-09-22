@icon("res://addons/gdscript-data-structures/icon.png")
# Copyright © 2026 aurpine
class_name Deque
extends RefCounted
## A double ended queue implemented as a circular array.

var _data: Array
var _size: int
var _capacity: int
var _start: int
# Store revision counter to invalidate iterators
var _revision: int


## Creates a typed deque from the [param base] array. See the typed constructor in
## [method Array.Array].
static func create_typed(base: Array, type: int, pclass_name: StringName, script: Variant) -> Deque:
	var deque := Deque.new()
	deque._data = Array(base, type, pclass_name, script)
	deque._size = base.size()
	deque._capacity = base.size()
	deque._double_capacity()
	return deque


func _init() -> void:
	_capacity = 8
	_data = []
	_data.resize(_capacity)
	_size = 0
	_start = 0
	_revision = 0


## Types the backing array for more efficient operation. See [method create_typed] and
## [method Array.Array].
func make_typed(type: int, pclass_name: StringName, script: Variant) -> void:
	_data = Array(_data, type, pclass_name, script)


## Adds an element to the beginning of the deque.
func push_front(value: Variant) -> void:
	_size += 1
	_start -= 1
	if _start < 0:
		_start += _capacity
	_data[_start] = value
	if _size == _capacity:
		_double_capacity()
	_revision += 1


## Adds an element at the end of the deque.
func push_back(value: Variant) -> void:
	_data[(_start + _size) % _capacity] = value
	_size += 1
	if _size == _capacity:
		_double_capacity()
	_revision += 1


## Removes and returns the first element.
func pop_front() -> Variant:
	if _size <= 0:
		return null

	var value = _data[_start]
	_data[_start] = null
	_start += 1
	if _start >= _capacity:
		_start -= _capacity
	_size -= 1
	_revision += 1
	return value


## Removes and returns the last element.
func pop_back() -> Variant:
	if _size <= 0:
		return null

	var i := (_start + _size - 1) % _capacity
	var value = _data[i]
	_data[i] = null
	_size -= 1
	_revision += 1
	return value


## Returns the first element.
func front() -> Variant:
	return _data[_start]


## Returns the last element.
func back() -> Variant:
	return _data[(_start + _size - 1) % _capacity]


## Returns the element at [param index].
func at(position: int) -> Variant:
	if position >= _size:
		return null
	return _data[(_start + position) % _capacity]


## Remove all elements contained in the deque.
func clear() -> void:
	_data.fill(null)
	_size = 0
	_revision += 1


## Returns the number of elements contained in the deque.
func size() -> int:
	return _size


## Returns true when there are no entries in the deque.
func is_empty() -> bool:
	return _size <= 0


## Insert a value into the deque at a given index.
## Functions similarly to [method Array.insert]. [br]
## [b]Note:[/b] this operation has significant performance cost.
func insert(position: int, value: Variant) -> Error:
	if position < 0:
		position += _size
	if position < 0 or position > _size:
		push_error("The calculated index %d is out of bounds (the deque has %d elements). Leaving the deque untouched." % [position, _size])
		return ERR_INVALID_PARAMETER

	# Determine if it's less work to extend the end or shift the beginning
	if position * 2 < _size:
		# Shift the first <position> elements left
		for index in position:
			_data[(index - 1 + _start) % _capacity] = _data[(index + _start) % _capacity]
		_start -= 1
		if _start < 0:
			_start += _capacity
	else:
		# Shift the end elements
		for index in range(_size - 1, position - 1, -1):
			_data[(index + 1 + _start) % _capacity] = _data[(index + _start) % _capacity]

	_data[(position + _start) % _capacity] = value
	_size += 1
	if _size == _capacity:
		_double_capacity()
	_revision += 1

	return OK


## Removes an element at a given position, shifting elements to close the gap. [br]
## [b]Note:[/b] this operation has significant performance cost.
func remove_at(position: int) -> void:
	if position < 0:
		position += _size
	if position < 0 or position >= _size:
		push_error("The calculated index %d is out of bounds (the deque has %d elements). Leaving the deque untouched." % [position, _size])
		return

	# Determine if it's less work to move the head or tail
	if position * 2 < _size:
		# Shift elements forward
		for index in range(position - 1, -1, -1):
			_data[(index + 1 + _start) % _capacity] = _data[(index + _start) % _capacity]
		_start += 1
		if _start >= _capacity:
			_start -= _capacity
	else:
		# Shift the end elements left
		for index in range(position + 1, _size):
			_data[(index - 1 + _start) % _capacity] = _data[(index + _start) % _capacity]

	_size -= 1
	_revision += 1


## Find the first occurrence of the value and removes it.[br]
## [b]Note:[/b] this operation has significant performance cost.
func erase(value: Variant) -> void:
	for index in _size:
		if _data[(_start + index) % _capacity] == value:
			remove_at(index)
			return


## Return the index of the [b]first[/b] occurrence of [param what] in this deque, or [code]-1[/code]
## if there are none. The search's start can be specified with [param from], continuing to the end
## of the deque.
func find(what: Variant, from: int = 0) -> int:
	if from < 0:
		from += _size
	if from >= 0:
		for index in range(from, _size):
			if _data[(_start + index) % _capacity] == what:
				return index
	return -1


## Return the index of the [b]last[/b] occurrence of [param what] in this deque, or [code]-1[/code]
## if there are none. The search's start can be specified with [param from], continuing to the
## beginning of the deque. This method is the reverse of [method find].
func rfind(what: Variant, from: int = -1) -> int:
	if from < 0:
		from += _size
	if from < _size and from >= 0:
		for index in range(from, -1, -1):
			if _data[(_start + index) % _capacity] == what:
				return index
	return -1


## Returns [code]true[/code] if the deque contains the given [param value].
func has(value: Variant) -> bool:
	return find(value) != -1


## Returns the index of the first element in the deque that causes [param method] to return true,
## or [code]-1[/code] if there are none. The search's start can be specified with [param from],
## continuing to the end of the deque.[br][br]
## [param method] is a callable that takes an element of the deque, and returns a [bool].[br][br]
## [b]Note:[/b] If you just want to know whether the deque contains anything that satisfies
## [param method], use [method any].
func find_custom(method: Callable, from: int = 0) -> int:
	if from < 0:
		from += _size
	if from >= 0:
		for index in range(from, _size):
			if method.call(_data[(_start + index) % _capacity]):
				return index
	return -1


## Returns the index of the [b]last[/b] element in the deque that causes [param method] to return
## true, or [code]-1[/code] if there are none. The search's start can be specified with
## [param from], continuing to the end of the deque. This method is the reverse of
## [method find_custom].
func rfind_custom(method: Callable, from: int = -1) -> int:
	if from < 0:
		from += _size
	if from < _size:
		for index in range(from, -1, -1):
			if method.call(_data[(_start + index) % _capacity]):
				return index
	return -1


#region functional
## Returns [code]true[/code] if an element in the deque causes [param method] to return
## [code]true[/code]. See also [method Array.any].[br][br]
## [b]Note:[/b] this method short circuits, meaning it stops searching after a match is found.
## As a result [param method] may not be called on every value.
func any(method: Callable) -> bool:
	return find_custom(method) != -1


## Returns [code]true[/code] if and only if every single element in the deque causes [param method]
## to return [code]true[/code]. See also [method Array.all].[br][br]
## [b]Note:[/b] this method short circuits, meaning it stops searching after an element causes
## [param method] to return false. As a result [param method] may not be called on every value.
func all(method: Callable) -> bool:
	for index in _size:
		if not method.call(_data[(_start + index) % _capacity]):
			return false
	return true


## Call [param method] on each element. This is more performant than using iterators.
func for_each(method: Callable) -> void:
	for i in _size:
		method.call(_data[(_start + i) % _capacity])


## Apply a transformation on each element. Returns a new deque filled with the new values returned
## by [param method].
func map(method: Callable) -> Deque:
	var a: Array
	if _data.is_typed():
		a = Array([], _data.get_typed_builtin(), _data.get_typed_class_name(), _data.get_typed_script())
	else:
		a = Array()
	a.resize(_capacity)
	for index in _size:
		a[(_start + index) % _capacity] = method.call(_data[(_start + index) % _capacity])
	var d := Deque.new()
	d._data = a
	d._size = _size
	d._capacity = _capacity
	d._start = _start
	return d


## Create a new deque with only the values that caused [param method] to return [code]true[/code].
## See also [method Array.filter]
func filter(method: Callable) -> Deque:
	var a: Array
	if _data.is_typed():
		a = Array([], _data.get_typed_builtin(), _data.get_typed_class_name(), _data.get_typed_script())
	else:
		a = Array()
	# Start with reserving the whole size
	a.resize(_size + 1)
	var new_size := 0
	for index in _size:
		if method.call(_data[(_start + index) % _capacity]):
			a[new_size] = _data[(_start + index) % _capacity]
			new_size += 1

	var d := Deque.new()
	d._data = a
	d._size = new_size
	d._capacity = _size + 1
	d._start = 0
	return d


## Calls [param method] for each element in the deque, with the accumulated value initialized to
## [param accum]. [param method] should be of the form [code](accum, value) -> new_accum[/code].[br]
## [br]
## See also [method Array.reduce].
func reduce(method: Callable, accum: Variant) -> Variant:
	for index in _size:
		accum = method.call(accum, _data[(_start + index) % _capacity])
	return accum
#endregion


## Creates an array that contains a copy of all the elements in the deque
func to_array() -> Array:
	var a: Array
	if _data.is_typed():
		a = Array([], _data.get_typed_builtin(), _data.get_typed_class_name(), _data.get_typed_script())
	else:
		a = Array()
	a.resize(_size)
	for index in _size:
		a[index] = _data[(_start + index) % _capacity]
	return a


## Returns a copy of the deque. [br][br]
## By default a shallow copy is returned. See [method Array.duplicate].
func duplicate(deep: bool = false) -> Deque:
	var d := Deque.new()
	d._data = _data.duplicate(deep)
	d._size = _size
	d._capacity = _capacity
	d._start = _start
	return d


## See [method Array.duplicate_deep].
func duplicate_deep(deep_subresources_mode: int) -> Deque:
	var d := Deque.new()
	d._data = _data.duplicate_deep(deep_subresources_mode)
	d._size = _size
	d._capacity = _capacity
	d._start = _start
	return d


#region standalone iterators
## Returns a forward iterator. [br]
## See [Deque.Iterator]
func iterator() -> Iterator:
	return Iterator.new(false, self)


## Returns a backwards iterator. [br]
## See [Deque.Iterator]
func reverse_iterator() -> Iterator:
	return Iterator.new(true, self)
#endregion


# Doubles the capacity for when the array is full
func _double_capacity() -> void:
	_data.resize(_capacity * 2)

	# Fill with the start
	for i in range(_start, _capacity):
		_data[i + _capacity] = _data[i]
		_data[i] = null

	_start += _capacity
	_capacity *= 2


#region built-in forward iterator
func _iter_init(iter: Array) -> bool:
	iter[0] = 0
	return iter[0] < _size


func _iter_next(iter) -> bool:
	iter[0] += 1
	return iter[0] < _size


func _iter_get(iter) -> Variant:
	return at(iter)
#endregion


## Iterable object associated with a deque.
##
## If any element is added or removed from the deque after iterator creation, an error will result
## if the iterator is used.[br][br]
## See [method Deque.iterator] and [method Deque.reverse_iterator]
class Iterator extends RefCounted:
	var _reverse: bool
	var _deque: Deque
	var _revision: int


	func _init(reverse, deque) -> void:
		self._reverse = reverse
		self._deque = deque
		self._revision = deque._revision


	func _iter_init(iter) -> bool:
		if _revision != _deque._revision:
			push_error("Deque modified since the iterator was created.")
		iter[0] = _deque._size - 1 if _reverse else 0
		return iter[0] >= 0 and iter[0] < _deque._size


	func _iter_next(iter) -> bool:
		if _revision != _deque._revision:
			push_error("Deque modified while iterating.")
			return false
		iter[0] += -1 if _reverse else 1
		return iter[0] >= 0 and iter[0] < _deque._size


	func _iter_get(iter) -> Variant:
		return _deque.at(iter)
