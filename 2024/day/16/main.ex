wall = "#"
start = "S"
finish = "E"

map = File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)
height = map |> length()
width = map |> hd() |> length()

find_in_map = fn to_find ->
  map
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row
    |> Enum.with_index()
    |> Enum.filter(fn {c, j} -> c === to_find end)
    |> Enum.map(fn {c, j} -> [i, j] end)
  end)
  |> hd()
end

start_pos = find_in_map.(start)
finish_pos = find_in_map.(finish)
directions = [:left, :right, :up, :down]

dfs_to_end = fn pos, dir, cost_so_far, visited, self ->
  [i, j] = pos

  if pos === finish_pos do
    cost_so_far
  else
    valid_directions =
      directions
      |> Enum.map(fn new_dir ->
        {new_dir,
         case dir do
           :left -> [i, j - 1]
           :right -> [i, j + 1]
           :up -> [i - 1, j]
           :down -> [i + 1, j]
         end}
      end)
      |> Enum.filter(fn {new_dir, new_pos} ->
        [n_i, n_j] = new_pos
        n_i in 0..(height - 1) and n_j in 0..(width - 1) and not MapSet.member?(visited, new_pos)
      end)

    valid_explorations =
      valid_directions
      |> Enum.map(fn {new_dir, new_pos} ->
        same_dir = new_dir === dir

        adjacent_dir =
          cond do
            dir === :left or dir === :right -> new_dir === :up or new_dir === :down
            dir === :up or dir === :down -> new_dir === :left or new_dir === :right
          end

        added_cost =
          cond do
            same_dir -> 1
            adjacent_dir -> 1000 + 1
            true -> 2000 + 1
          end

        self.(new_pos, new_dir, cost_so_far + added_cost, MapSet.put(visited, new_pos), self)
      end)
      |> Enum.filter(&(&1 !== nil))

    if valid_explorations |> length() === 0 do
      nil
    else
      valid_explorations |> Enum.min()
    end
  end
end

dfs_to_end.(start_pos, :right, 0, MapSet.new(), dfs_to_end) |> IO.inspect()
