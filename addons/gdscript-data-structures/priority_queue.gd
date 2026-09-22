@icon("res://addons/gdscript-data-structures/icon.png")
# Copyright © 2026 aurpine
class_name PriorityQueue
extends RefCounted
## A max priority queue implemented as a binary heap
##
## Uses a comparison function to determine ordering. If no comparison function is provided, it uses the built in < operator. [br]
## To create a min priority queue, reverse the comparison: [code]func(a, b): return a > b[/code]
## The comparison function must be deterministic and transitive meaning a strict ordering of all the elements should exist. Otherwise, the behaviour is not defined.

var _compare: Callable
var _data: Array
# Should follow _data.size()
var _size: int


## Creates a typed [PriorityQueue] from the [param base] array. See the typed constructor in [constructor Array.Array].
static func create_typed(base: Array, type: int, pclass_name: StringName, script: Variant, compare_func: Callable = Callable()) -> PriorityQueue:
	var pq := PriorityQueue.new(compare_func)
	pq._data = Array(base, type, pclass_name, script)
	pq._size = base.size()
	for i in range(pq._size / 2 - 1, -1, -1):
		pq._heapify_down(i)
	return pq


## Create a priority queue from an existing array.
static func from_array(array: Array, compare_func: Callable = Callable()) -> PriorityQueue:
	var pq := PriorityQueue.new(compare_func)
	pq._data.assign(array)
	pq._size = array.size()
	for i in range(array.size() / 2 - 1, -1, -1):
		pq._heapify_down(i)
	return pq


# Default construction with regular comparator
func _init(compare_func: Callable = Callable()) -> void:
	self._compare = compare_func
	self._data = []
	self._size = 0


## Types the backing array for more efficient operation. See [method create_typed] and [method Array.Array].
func make_typed(type: int, pclass_name: StringName, script: Variant) -> void:
	_data = Array(_data, type, pclass_name, script)


## Changes the comparison function. The function should be deterministic and transitive, otherwise undefined behaviour may occur. [br]
## [b]Note:[/b] when the priority queue is not empty and the new compare function changes the ordering, then this operation can take O(n log n).
func set_compare(compare_func: Callable) -> void:
	_compare = compare_func
	for i in range(_size / 2 - 1, -1, -1):
		_heapify_down(i)


## Returns the largest element.
func top() -> Variant:
	if _size <= 0:
		return null
	return _data[0]


## Removes and returns the largest element.
func pop() -> Variant:
	if _size <= 0:
		return null
	var r = _data[0]

	_size -= 1
	if _size > 0:
		_data[0] = _data.pop_back()
		_heapify_down(0)
	else:
		_data.pop_back()

	return r


## Add a new element.
func push(value: Variant) -> void:
	var i := _size
	_data.push_back(null)
	_size += 1
	# Parent
	var parent: int

	# Heapify up
	if _compare.is_valid():
		while i > 0:
			parent = (i - 1) >> 1
			if _compare.call(_data[parent], value):
				# _swap(p, i)
				_data[i] = _data[parent]
				i = parent
			else:
				break
	else:
		while i > 0:
			parent = (i - 1) >> 1
			if _data[parent] < value:
				# _swap(p, i)
				_data[i] = _data[parent]
				i = parent
			else:
				break
	_data[i] = value


## Returns true when there are no elements in the container.
func is_empty() -> bool:
	return _size <= 0


## Returns the number of elements.
func size() -> int:
	return _size


## Removes all elements.
func clear() -> void:
	_data.clear()
	_size = 0


## Returns a copy of the priority queue. [br]
## By default a shallow copy is returned. See [method Array.duplicate]
func duplicate(deep: bool = false) -> PriorityQueue:
	var i := PriorityQueue.new(_compare)
	i._data = _data.duplicate(deep)
	i._size = _size
	return i


## See [method Array.duplicate_deep]
func duplicate_deep(deep_subresources_mode: int) -> PriorityQueue:
	var i := PriorityQueue.new(_compare)
	i._data = _data.duplicate_deep(deep_subresources_mode)
	i._size = _size
	return i


# Move index (down) to the right place
func _heapify_down(i: int) -> void:
	var child: int
	# Left and right child indices
	var l: int
	var r: int
	var v = _data[i]
	if _compare.is_valid():
		while true:
			l = (i << 1) + 1
			r = l + 1
			# Both children are smaller or equal
			if l >= _size or not _compare.call(v, _data[l]) and (r >= _size or not _compare.call(v, _data[r])):
				break

			# Take the smaller child
			child = r if r < _size and _compare.call(_data[l], _data[r]) else l
			# swap(i, child)
			_data[i] = _data[child]

			i = child
	else:
		while true:
			l = (i << 1) + 1
			r = l + 1
			# Both children are smaller or equal
			if l >= _size or v >= _data[l] and (r >= _size or v >= _data[r]):
				break

			# Take the smaller child
			child = r if r < _size and _data[l] < _data[r] else l
			# swap(i, child)
			_data[i] = _data[child]

			i = child
	# Final place for the value
	_data[i] = v
