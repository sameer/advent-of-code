coordinates =
  File.read!("input")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.split(&1, ","))
  |> Enum.map(fn coords -> coords |> Enum.map(&String.to_integer/1) end)

width = 71
height = 71
limit = 1024

start = [0, 0]
finish = [width - 1, height - 1]
directions = [:left, :right, :up, :down]

dijkstra = fn walls, unvisited, distances, self ->
  candidates =
    unvisited
    |> MapSet.to_list()
    |> Enum.filter(&Map.has_key?(distances, &1))

  if candidates |> length() === 0 do
    Map.get(distances, finish)
  else
    current_pos = candidates |> Enum.min_by(&Map.get(distances, &1))
    [i, j] = current_pos
    current_cost = distances |> Map.get(current_pos)

    if current_pos === finish do
      current_cost
    else
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

      new_unvisited =
        unvisited
        |> MapSet.delete(current_pos)

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
    end
  end
end

walls = coordinates |> Enum.take(limit) |> MapSet.new()

unvisited =
  Enum.flat_map(0..(width - 1), fn w ->
    Enum.map(0..(height - 1), fn h -> [w, h] end)
  end)
  |> Enum.filter(fn pos ->
    not MapSet.member?(walls, pos)
  end)
  |> MapSet.new()

dijkstra.(walls, unvisited, Map.new([{start, 0}]), dijkstra) |> IO.puts()

# Part 2

# Brute force search in reverse
index =
  Enum.find((length(coordinates) - 1)..0, fn limit ->
    walls = coordinates |> Enum.take(limit) |> MapSet.new()
    dijkstra.(walls, unvisited, Map.new([{start, 0}]), dijkstra) !== nil
  end)

coordinates |> Enum.at(index) |> IO.inspect(charlists: :as_lists)
