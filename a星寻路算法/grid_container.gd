extends GridContainer

@export var grids: Array
@export var moving_grid: ColorRect
@export var end_grid: ColorRect
@export var open_grid_list: Array[ColorRect]
@export var close_grid_list: Array[ColorRect]
@export var Columns: int = 6
@export var Rows: int = 6
#定义格子
class GridNode:
	var cell: ColorRect
	var g: float
	var h: float
	var f: float: get = get_f
	var parent: GridNode = null
	
	func _init(cell: ColorRect):
		self.cell = cell
		self.g = 0
		self.h = 0
	
	func get_f() -> float:
		return g + h
#初始化
func _ready() -> void:
	await get_tree().process_frame
	for i in get_children():
		grids.append(i)
		i.get_child(0).text = str(i.get_index())
	moving_grid.color = Color.AQUA
	end_grid.color = Color.WHITE
#根据编号获取对应的grid，以便获取pos,计算曼哈顿距离
func index_to_grid(index: int) -> Vector2:
	return Vector2(index % columns, index / columns)
#获取上下左右可用的邻居
func get_neighbors(node: GridNode) -> Array[GridNode]:
	var neighbors: Array[GridNode] = []
	var current_idx = node.cell.get_index()
	var current_pos = index_to_grid(current_idx)
	#上下左右遍历，上下优先级最高
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	
	for dir in directions:
		var new_pos = current_pos + dir
		if new_pos.x >= 0 and new_pos.x < Columns and new_pos.y >= 0 and new_pos.y < Rows:
			var new_idx = int(new_pos.x + new_pos.y * columns)
			if new_idx >= 0 and new_idx < grids.size():
				neighbors.append(GridNode.new(grids[new_idx]))
	
	return neighbors
#计算曼哈顿距离
func manhattan(a_idx: int, b_idx: int) -> float:
	var a_pos = index_to_grid(a_idx)
	var b_pos = index_to_grid(b_idx)
	return abs(a_pos.x - b_pos.x) + abs(a_pos.y - b_pos.y)
#一次性寻路(核心)

"""核心函数逻辑"""
#一次性的，先清空之前的数据
#初始化起点()和终点，开关闭列表
#进入循环
#如果到终点了，直接结束，返回路径
#没有的话，先在openlist里挑选代价最小的元素,走到它
#接下来就是先计算每个邻居的数据,通通再加到open/closed_list更新数据


#细节：A* 算法 f 值相等时，看谁先被加入队列、谁先被取出，上下左右，上下的优先级最高



func find_path() -> Array[ColorRect]:
	open_grid_list.clear()
	close_grid_list.clear()
	#标记起点(用于计算损耗)
	var start_node = GridNode.new(moving_grid)
	var end_node = GridNode.new(end_grid)
	#可走/关闭的列表 
	var open_set: Array[GridNode] = [start_node]
	var closed_set: Array[GridNode] = []
	
	
	
	#只要可走的grid的数量>0
	while open_set.size() > 0:
		var current = open_set[0]
		#比较openlist各点的代价=损耗+曼哈顿距离，选择最小代价——最优解
		for node in open_set:
			if node.f < current.f or (node.f == current.f and node.h < current.h):
				current = node
		#open_set删除最优解,close_set加入最优解
		open_set.erase(current)
		closed_set.append(current)
		close_grid_list.append(current.cell)
		#如果最优解是终点直接返回路径
		if current.cell == end_grid:
			return retrace_path(start_node, current)
		#还不是终点，继续找可走的邻居
		
		
		
		for neighbor in get_neighbors(current):
			#看关闭列表有没有邻居
			if closed_set.any(func(n): return n.cell == neighbor.cell):
				continue
			#给每个邻居计算新的损耗
			var new_g = current.g +1 
			#检查邻居在不在里面
			var open_node = open_set.filter(func(n): return n.cell == neighbor.cell)
			#new_g < neighbor.g这个条件这里可加可不加，到其他网格的间距都是一样的，没必要
			if open_node.is_empty() or new_g < neighbor.g:
				#为每个邻居的损耗赋值
				neighbor.g = new_g
				#给每个邻居计算自己到终点的曼哈顿
				neighbor.h = manhattan(neighbor.cell.get_index(), end_grid.get_index())
				neighbor.parent = current#标记父节点，以便回溯
				#如果重复的节点为空，那就没事了，该干嘛干嘛
				if open_node.is_empty():
					open_set.append(neighbor)
					open_grid_list.append(neighbor.cell)
	
	return []
#回溯路径
func retrace_path(start: GridNode, end: GridNode) -> Array[ColorRect]:
	var path: Array[ColorRect] = []
	var current = end
	
	while current != start and current != null:
		path.append(current.cell)
		current = current.parent
	
	path.reverse()
	return path
#可视化路径
func visualize(path: Array[ColorRect]):
	for grid in open_grid_list:
		grid.color = Color.AQUAMARINE
	for grid in close_grid_list:
		grid.color = Color.RED
	for grid in path:
		grid.color = Color.GREEN
	
	moving_grid.color = Color.AQUA
	end_grid.color = Color.WHITE
	
#点按钮开始
func _on_button_pressed() -> void:
	var path = find_path()
	if path.size() > 0:
		visualize(path)
	else:
		print("无路径")
