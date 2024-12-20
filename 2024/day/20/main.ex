empty = "."
wall = "#"
start = "S"
finish = "E"
minimum_savings = 100

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
directions = [:left, :right, :up, :down]

# Modified Dijkstra that doesn't have an early stopping condition and flood fills "unexpected" improvements
dijkstra = fn walls, unvisited, distances, self ->
  candidates =
    unvisited
    |> MapSet.to_list()
    |> Enum.filter(&Map.has_key?(distances, &1))

  if candidates |> length() === 0 do
    {unvisited, distances, Map.get(distances, finish_pos)}
  else
    current_pos = candidates |> Enum.min_by(&Map.get(distances, &1))
    [i, j] = current_pos
    current_cost = distances |> Map.get(current_pos)

    reachable =
      directions
      |> Enum.map(fn dir ->
        new_pos =
          case dir do
            :left -> [i, j - 1]
            :right -> [i, j + 1]
            :up -> [i - 1, j]
            :down -> [i + 1, j]
          end

        new_cost = current_cost + 1

        {new_pos, new_cost}
      end)
      |> Enum.filter(fn {new_pos, _} ->
        [n_i, n_j] = new_pos

        n_i in 0..(height - 1) and n_j in 0..(width - 1) and
          not MapSet.member?(walls, new_pos)
      end)

    reachable_improved =
      reachable
      |> Enum.filter(fn {new_pos, new_cost} ->
        existing_cost = distances |> Map.get(new_pos)
        existing_cost === nil or new_cost < existing_cost
      end)
      |> Enum.map(fn {new_pos, _} -> new_pos end)
      |> MapSet.new()

    new_unvisited =
      unvisited
      |> MapSet.delete(current_pos)
      |> MapSet.union(reachable_improved)

    new_distances =
      reachable
      |> Enum.reduce(distances, fn {new_pos, new_cost}, acc ->
        acc
        |> Map.get_and_update(new_pos, fn existing_cost ->
          updated_cost =
            if existing_cost === nil, do: new_cost, else: min(existing_cost, new_cost)

          {existing_cost, updated_cost}
        end)
        |> elem(1)
      end)

    self.(walls, new_unvisited, new_distances, self)
    # end
  end
end

walls = find_in_map.(wall) |> MapSet.new()

unvisited =
  Enum.flat_map(0..(width - 1), fn w ->
    Enum.map(0..(height - 1), fn h -> [w, h] end)
  end)
  |> Enum.filter(fn pos ->
    not MapSet.member?(walls, pos)
  end)
  |> MapSet.new()

{original_unvisited, original_distances, original_cost} =
  dijkstra.(walls, unvisited, Map.new([{start_pos, 0}]), dijkstra)

cheating_candidates =
  walls
  |> MapSet.to_list()
  |> Enum.map(fn wall ->
    [i, j] = wall

    adjacent =
      directions
      |> Enum.map(fn dir ->
        case dir do
          :left -> [i, j - 1]
          :right -> [i, j + 1]
          :up -> [i - 1, j]
          :down -> [i + 1, j]
        end
      end)

    adjacent_costs =
      adjacent
      |> Enum.map(&Map.get(original_distances, &1))
      |> Enum.filter(&(&1 !== nil))

    {wall, adjacent_costs}
  end)
  |> Enum.filter(fn {_, adjacent_costs} ->
    adjacent_costs
    |> Enum.with_index()
    |> Enum.flat_map(fn {cost, i} ->
      adjacent_costs
      |> Enum.split(i + 1)
      |> elem(1)
      |> Enum.map(fn other_cost -> abs(cost - other_cost) end)
    end)
    |> Enum.any?(fn diff -> diff >= minimum_savings end)
  end)
  |> Enum.map(fn {wall, adjacent_costs} ->
    {wall,
     adjacent_costs
     |> Enum.map(&(&1 + 1))
     |> Enum.min()}
  end)

cheating_candidates
|> Task.async_stream(
  fn {wall, wall_cost} ->
    {_, _, cost} =
      dijkstra.(
        walls |> MapSet.delete(wall),
        MapSet.new([wall]),
        original_distances |> Map.put(wall, wall_cost),
        dijkstra
      )

    cost
  end,
  timeout: :infinity
)
|> Enum.map(fn {:ok, cost} -> cost end)
|> Enum.filter(&(&1 <= original_cost - minimum_savings))
|> Enum.count()
|> IO.inspect()


# Part 2 (not dijkstra I guess)
