@icon("res://addons/gdscript-data-structures/icon.png")
# Copyright © 2026 aurpine
class_name LinkedList
extends RefCounted
## A doubly linked list.

var _head: int = -1
var _tail: int = -1
# Pointer to unused index
# A mini list is stored at this index
var _unused: int = -1
var _size: int = 0
# Follows _data.size(), _nodes.size(), _pointers.size() / 2
var _capacity: int = 0
var _pointers: PackedInt32Array
var _data: Array
var _nodes: Array[LinkedNode]
var _revision: int = 0


## Creates a typed [LinkedList] from the [param base] array. See the typed constructor in [constructor Array.Array].
static func create_typed(base: Array, type: int, pclass_name: StringName, script: Variant) -> LinkedList:
	var l := LinkedList.new()
	l._data = Array(base, type, pclass_name, script)
	l._size = base.size()
	l._capacity = l._size
	# Populate straight list
	l._head = 0
	l._tail = l._size - 1
	var pointers := l._pointers
	pointers.resize(l._size * 2)
	for index in l._size:
		pointers[index * 2] = index - 1
		pointers[index * 2 + 1] = index + 1
	pointers[-1] = -1
	return l


## Types the backing array for more efficient operation. See [method create_typed] and
## [method Array.Array].
func make_typed(type: int, pclass_name: StringName, script: Variant) -> void:
	_data = Array(_data, type, pclass_name, script)


## Add a value to the beginning of the list.
func push_front(value: Variant) -> void:
	var index: int
	if _unused != -1:
		index = _unused
		_unused = _pointers[_unused * 2]
		_data[index] = value
		_pointers[index * 2] = -1
		_pointers[index * 2 + 1] = _head
	else:
		index = _capacity
		_capacity += 1
		_data.append(value)
		_pointers.append_array(PackedInt32Array([-1, _head]))
		_nodes.append(null)

	if _head != -1:
		_pointers[_head * 2] = index

	_head = index

	if _tail == -1:
		_tail = index
	_size += 1
	_revision += 1


## Add a value to the end of the list.
func push_back(value: Variant) -> void:
	var index: int
	if _unused != -1:
		index = _unused
		_unused = _pointers[_unused * 2]
		_data[index] = value
		_pointers[index * 2] = _tail
		_pointers[index * 2 + 1] = -1
	else:
		index = _capacity
		_capacity += 1
		_data.append(value)
		_pointers.append_array(PackedInt32Array([_tail, -1]))
		_nodes.append(null)

	if _tail != -1:
		_pointers[_tail * 2 + 1] = index

	_tail = index

	if _head == -1:
		_head = index
	_size += 1
	_revision += 1


## Removes and returns the first element. If the list is empty, returns null.
func pop_front() -> Variant:
	if _head == -1:
		return null
	var v = _data[_head]
	_del(_head)
	return v


## Removes and returns the last element. If the list is empty, returns null.
func pop_back() -> Variant:
	if _tail == -1:
		return null
	var v = _data[_tail]
	_del(_tail)
	return v


## Returns the first element.
func front() -> Variant:
	if _head == -1:
		return null
	return _data[_head]


## Returns the last element.
func back() -> Variant:
	if _tail == -1:
		return null
	return _data[_tail]


## Returns the number of elements in the list.
func size() -> int:
	return _size


## Returns true if the size is 0.
func is_empty() -> bool:
	return _size == 0


## Remove a singular element from this list. The parameter becomes invalid after calling this function.
func remove_at(node: LinkedNode) -> void:
	var index := node._index
	if index == _head:
		_head = _pointers[index * 2 + 1]
	if index == _tail:
		_tail = _pointers[index * 2]

	# n.next.prev = n.prev
	if _pointers[index * 2 + 1] != -1:
		_pointers[_pointers[index * 2 + 1] * 2] = _pointers[index * 2]

	if _pointers[index * 2] != -1:
		_pointers[_pointers[index * 2] * 2 + 1] = _pointers[index * 2 + 1]

	# Cleanup
	node._valid = false
	_nodes[index] = null
	_pointers[index * 2 + 1] = -2
	_pointers[index * 2] = _unused
	_unused = index
	_data[index] = null

	_size -= 1
	_revision += 1


## Removes all the elements between [param first] to [param last] (inclusive).
## Both parameters become invalid after calling this function.
## [b]Note:[/b] behaviour is undefined if [param first] does not come before [param last].
func remove_range(first: LinkedNode, last: LinkedNode) -> void:
	if not first._valid or not last._valid:
		return
	if first._index == _head:
		# head = last.next
		_head = _pointers[last._index * 2 + 1]
	if last._index == _tail:
		# tail = first.prev
		_tail = _pointers[first._index * 2]

	# if last.next != null
	if _pointers[last._index * 2 + 1] != -1:
		# last.next.prev = first.prev
		_pointers[_pointers[last._index * 2 + 1] * 2] = _pointers[first._index * 2]
	# if first.prev != null
	if _pointers[first._index * 2] != -1:
		# first.prev.next = last.next
		_pointers[_pointers[first._index * 2] * 2 + 1] = _pointers[last._index * 2 + 1]

	# Delete
	var index := first._index
	var next: int
	var end := last._index
	while index != -1:
		_pointers[index * 2] = _unused
		_unused = index
		next = _pointers[index * 2 + 1]
		_pointers[index * 2 + 1] = -2
		if _nodes[index] != null:
			_nodes[index]._valid = false
			_nodes[index] = null
		_data[index] = null

		_size -= 1
		if index == end:
			break
		index = next

	_revision += 1


#region node getters
## Get the node at the given [param position].[br]
## [b]Note:[/b] this operation requires [param position] operations.
func node_at(position: int) -> LinkedNode:
	if position < 0:
		position += _size
	if position >= _size:
		push_error("The calculated index %d is out of bounds (the list has %d elements).")
		return null
	return _get_node(_at(position))


## Returns the [LinkedList.LinkedNode] at the beginning of the list.
func head() -> LinkedNode:
	if _head == -1:
		return null
	return _get_node(_head)


## Returns the [LinkedList.LinkedNode] at the end of the list.
func tail() -> LinkedNode:
	if _tail == -1:
		return null
	return _get_node(_tail)
#endregion


## Gets the value at the [param position]th element in the list.
## [b]Note:[/b] this operation requires [param position] operations.
func value_at(position: int) -> Variant:
	if position < 0:
		position += _size
	if position >= _size:
		return null
	var i := _at(position)
	if i == -1:
		return null
	return _data[i]


## Insert a value at a given position. Returns any error if encountered.[br]
## [b]Note:[/b] this operation requires [param position] operations.[br][br]
## Use [method insert_before] or [method insert_after] instead for efficient insertion when you
## already have a node.
func insert(position: int, value: Variant) -> Error:
	if position < 0:
		position += _size
	if position > _size:
		push_error("The calculated index %d is out of bounds (the list has %d elements). Leaving the list untouched.")
		return ERR_INVALID_PARAMETER

	if position == 0:
		push_front(value)
		return OK
	else:
		var index = _at(position - 1)
		# This shouldn't be possible
		if index == -1:
			return ERR_INVALID_PARAMETER
		_insert_index(index, value)
	return OK


## Insert values after a node.
func insert_after(node: LinkedNode, value: Variant) -> void:
	if node == null:
		push_error("Insertion point must not be null.")
		return

	var index: int
	# a <-> b becomes a <-> n <-> b
	# node is a
	var b := _pointers[node._index * 2 + 1]

	if _unused != -1:
		index = _unused
		_unused = _pointers[_unused * 2]
		_data[index] = value
		_pointers[index * 2] = node._index
		_pointers[index * 2 + 1] = b
	else:
		index = _capacity
		_capacity += 1
		_data.append(value)
		# a <- n
		_pointers.append(node._index)
		# b = a.next
		# n -> b
		_pointers.append(b)
		_nodes.append(null)

	# If we inserted after tail
	if node._index == _tail:
		_tail = index
	# Update next pointer
	# node.next.prev = index
	if _pointers[node._index * 2 + 1] != -1:
		_pointers[_pointers[node._index * 2 + 1] * 2] = index
	# node.next = index
	_pointers[node._index * 2 + 1] = index

	_size += 1
	_revision += 1


## Insert a value before a node.
func insert_before(node: LinkedNode, value: Variant) -> void:
	if node == null:
		push_error("Insertion point must not be null.")
		return

	if node._index == _head:
		# insert at the head
		push_front(value)
	else:
		insert_after(node.prev(), value)


## Reverses the order of the list.
func reverse() -> void:
	var t: int
	for index in _capacity:
		if _pointers[index * 2 + 1] != -2:
			# Swap prev and next
			t = _pointers[index * 2]
			_pointers[index * 2] = _pointers[index * 2 + 1]
			_pointers[index * 2 + 1] = t
	# Swap head and tail
	t = _head
	_head = _tail
	_tail = t


## Call a function on each element. This is more performant than using iterators. If the order
## of the elements for the calls does not matter, setting [param in_order] to [code]false[/code]
## can be faster.
func for_each(method: Callable, in_order: bool = true) -> void:
	if in_order:
		var index := _head
		while index != -1:
			method.call(_data[index])
			index = _pointers[index * 2 + 1]
	else:
		for index in _capacity:
			if _pointers[index * 2 + 1] != -2:
				method.call(_data[index])


## Apply a transformation on each element. Returns a new list filled with the new values returned
## by [param method]. If the order of the elements for the calls does not matter, setting
## [param in_order] to [code]false[/code] can be faster.
func map(method: Callable, in_order: bool = true) -> LinkedList:
	var list := LinkedList.new()
	var new_pointers: PackedInt32Array
	var new_data := Array([], _data.get_typed_builtin(), _data.get_typed_class_name(), _data.get_typed_script())

	list._data = new_data

	if in_order:
		# New list will be linear
		new_pointers = PackedInt32Array()
		new_pointers.resize(_size * 2)
		new_data.resize(_size)

		var index := _head
		for i in _size:
			new_data[i] = method.call(_data[index])
			new_pointers[i * 2] = i - 1
			new_pointers[i * 2 + 1] = i + 1
			index = _pointers[index * 2 + 1]
		new_pointers[-1] = -1
		if _size > 0:
			list._head = 0
			list._tail = _size - 1
		list._size = _size
		list._capacity = _size
	else:
		new_pointers = _pointers.duplicate()
		new_data.resize(_capacity)

		for index in _capacity:
			if _pointers[index * 2 + 1] != -2:
				new_data[index] = method.call(_data[index])
		list._size = _size
		list._capacity = _capacity
		list._unused = _unused

	list._pointers = new_pointers
	list._nodes.resize(list._size)

	return list


## Returns an array containing the values of the list in order.
func to_array() -> Array:
	var a := Array([], _data.get_typed_builtin(), _data.get_typed_class_name(), _data.get_typed_script())
	a.resize(_size)
	var l_index := _head
	for a_index in _size:
		a[a_index] = _data[l_index]
		l_index = _pointers[l_index * 2 + 1]
	return a


#region custom iterator
## Returns an iterable from front to back.
func iterator() -> Iterator:
	return Iterator.new(_head, false, self)


## Returns an iterable from back to front.
func reverse_iterator() -> Iterator:
	return Iterator.new(_tail, true, self)
#endregion


## Returns a copy of the list. [br][br]
## By default a shallow copy is returned. See [method Array.duplicate].
func duplicate(deep: bool = false) -> LinkedList:
	var l := LinkedList.new()
	l._head = _head
	l._tail = _tail
	l._unused = _unused
	l._size = _size
	l._capacity = _capacity
	l._pointers = _pointers.duplicate()
	l._data = _data.duplicate(deep)
	return l


## See [method Array.duplicate_deep].
func duplicate_deep(deep_subresources_mode: int) -> LinkedList:
	var l := LinkedList.new()
	l._head = _head
	l._tail = _tail
	l._unused = _unused
	l._size = _size
	l._capacity = _capacity
	l._pointers = _pointers.duplicate()
	l._data = _data.duplicate(deep_subresources_mode)
	return l


# Internal index of position.
func _at(position: int) -> int:
	var index: int
	if position * 2 > _size:
		# Faster to go from the end
		index = _tail
		position = _size - position - 1
		while position > 0:
			# index = index.prev
			index = _pointers[index * 2]
			position -= 1
	else:
		index = _head
		while position > 0:
			index = _pointers[index * 2 + 1]
			position -= 1
	return index


# Internal insert a value after the node at the position.
func _insert_index(position: int, value: Variant) -> void:
	# 0 <= index < size
	# a <-> b becomes a <-> n <-> b
	# node is a
	var b := _pointers[position * 2 + 1]
	var index: int
	if _unused != -1:
		index = _unused
		_unused = _pointers[_unused * 2]
		_data[index] = value
		_pointers[index * 2] = position
		_pointers[index * 2 + 1] = b
	else:
		index = _capacity
		_capacity += 1
		_data.append(value)
		_pointers.append_array(PackedInt32Array([position, b]))
		_nodes.append(null)

	if position == _tail:
		_tail = index
	elif b != -1:
		# n <- b
		_pointers[b * 2] = index
	# a -> n
	_pointers[position * 2 + 1] = index

	_size += 1
	_revision += 1


# Delete the value at index
func _del(index: int) -> void:
	# n.prev.next = n.next
	if _pointers[index * 2] != -1:
		_pointers[_pointers[index * 2] * 2 + 1] = _pointers[index * 2 + 1]
	# n.next.prev = n.prev
	if _pointers[index * 2 + 1] != -1:
		_pointers[_pointers[index * 2 + 1] * 2] = _pointers[index * 2]

	if _head == index:
		_head = _pointers[index * 2 + 1]
	if _tail == index:
		_tail = _pointers[index * 2]

	if _nodes[index] != null:
		_nodes[index]._valid = false
		_nodes[index] = null
	_data[index] = null
	_pointers[index * 2] = _unused
	# next = -2 indicates this is a free spot
	_pointers[index * 2 + 1] = -2
	_unused = index

	_size -= 1
	_revision += 1


# Get a LinkedNode for an index. Creates a new one or returns the cached one.
func _get_node(index: int) -> LinkedNode:
	if _nodes.size() <= index:
		_nodes.resize(_capacity)
	if _nodes[index] != null:
		return _nodes[index]
	var node = LinkedNode.new()
	node._index = index
	node._list = self
	_nodes[index] = node
	return node


#region built in iterator
func _iter_init(iter: Array) -> bool:
	iter[0] = [_head, _revision]
	return iter[0][0] != -1


func _iter_next(iter: Array) -> bool:
	if iter[0][1] != _revision:
		push_error("List modified since iterator created.")
		return false
	iter[0][0] = _pointers[iter[0][0] * 2 + 1]
	return iter[0][0] != -1


func _iter_get(iter: Variant) -> Variant:
	return _data[iter[0]]
#endregion


## Singular element in linked list. Can be used to traverse the list manually with [method prev]
## and [method next]. See [method LinkedList.head], [method LinkedList.tail], and
## [method LinkedList.node_at] to get instances. These are useful to hold onto for fast operations
## on the list. The node is valid through insertions and updates to the list.
class LinkedNode extends RefCounted:
	var _list: LinkedList
	var _index: int
	var _valid := true


	## Returns [code]true[/code] if this node can still be used. Returns [code]false[/code] if
	## the node has been deleted.
	func valid() -> bool:
		return _valid


	## Returns the previous node, or null if the current node is the head of the list.
	func prev() -> LinkedNode:
		if not _valid:
			return null
		var p := _list._pointers[_index * 2]
		if p == -1:
			return null
		return _list._get_node(p)


	## Returns the next node, or null if the current node is the tail of the list.
	func next() -> LinkedNode:
		if not _valid:
			return null
		var p := _list._pointers[_index * 2 + 1]
		if p == -1:
			return null
		return _list._get_node(p)


	## Get the value stored at this node in the list.
	func value() -> Variant:
		if not _valid:
			return null
		return _list._data[_index]


	## Set the value stored at this node in the list.
	func set_value(value: Variant) -> void:
		if _valid:
			_list._data[_index] = value


## Forward or reverse iterator for linked list. The iterator is [i]fail-fast[/i] meaning
## it becomes invalid when any structural change applies such as a value inserted or removed.
class Iterator extends RefCounted:
	var _start: int
	# direction
	var _reversed: bool
	var _list: LinkedList
	var _revision: int


	func _init(start: int, reversed: bool, list) -> void:
		self._start = start
		self._reversed = reversed
		self._list = list
		self._revision = _list._revision


	func _iter_init(iter: Array) -> bool:
		if _revision != _list._revision:
			push_error("List modified since iterator created.")
			return false
		iter[0] = _start
		return iter[0] != -1


	func _iter_next(iter: Array) -> bool:
		if _revision != _list._revision:
			push_error("List modified while iterating.")
			return false
		iter[0] = _list._pointers[iter[0] * 2 + (1 if _reversed else 0)]
		return iter[0] != -1


	func _iter_get(iter: Variant) -> Variant:
		return _list._data[iter]
