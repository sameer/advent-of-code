empty = "."
wall = "#"
start = "S"
finish = "E"

map =
  File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)

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
end

start_pos = find_in_map.(start) |> hd()
finish_pos = find_in_map.(finish) |> hd()
walls = find_in_map.(wall) |> MapSet.new()
directions = [:left, :right, :up, :down]

dijkstra = fn unvisited, distances, self ->
  candidates =
    unvisited
    |> MapSet.to_list()
    |> Enum.filter(&Map.has_key?(distances, &1))

  if candidates |> length() === 0 do
    directions
    |> Enum.map(&{finish_pos, &1})
    |> Enum.map(&Map.get(distances, &1))
    |> Enum.filter(&(&1 !== nil))
    |> Enum.min()
  else
    {current_pos, current_dir} = candidates |> Enum.min_by(&Map.get(distances, &1))
    [i, j] = current_pos
    current_cost = distances |> Map.get({current_pos, current_dir})

    if current_pos === finish do
      current_cost
    else
      reachable =
        directions
        |> Enum.map(fn new_dir ->
          same_dir = new_dir === current_dir

          opposite_dir =
            case current_dir do
              :left -> new_dir === :right
              :right -> new_dir === :left
              :up -> new_dir === :down
              :down -> new_dir === :up
            end

          new_pos =
            cond do
              same_dir ->
                case current_dir do
                  :left -> [i, j - 1]
                  :right -> [i, j + 1]
                  :up -> [i - 1, j]
                  :down -> [i + 1, j]
                end

              true ->
                current_pos
            end

          added_cost =
            cond do
              same_dir -> 1
              opposite_dir -> 2000
              true -> 1000
            end

          new_cost = current_cost + added_cost

          {new_pos, new_dir, new_cost}
        end)
        |> Enum.filter(fn {new_pos, new_dir, _} ->
          [n_i, n_j] = new_pos

          n_i in 0..(height - 1) and n_j in 0..(width - 1) and
            not MapSet.member?(walls, new_pos)
        end)

      new_unvisited =
        unvisited
        |> MapSet.delete({current_pos, current_dir})

      unvisited |> MapSet.size() |> IO.inspect()

      new_distances =
        reachable
        |> Enum.reduce(distances, fn {new_pos, new_dir, new_cost}, acc ->
          acc
          |> Map.get_and_update({new_pos, new_dir}, fn existing_cost ->
            updated_cost =
              if existing_cost === nil, do: new_cost, else: min(existing_cost, new_cost)

            {existing_cost, updated_cost}
          end)
          |> elem(1)
        end)

      self.(new_unvisited, new_distances, self)
    end
  end
end

unvisited =
  find_in_map.(empty)
  |> Enum.concat([start_pos, finish_pos])
  |> Enum.flat_map(fn pos -> directions |> Enum.map(fn dir -> {pos, dir} end) end)
  |> MapSet.new()

dijkstra.(unvisited, Map.new([{{start_pos, :right}, 0}]), dijkstra) |> IO.inspect()
