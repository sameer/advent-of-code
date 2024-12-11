grid =
  File.read!("input")
  |> String.split("\n")
  |> Enum.filter(&(String.length(&1) > 0))
  |> Enum.map(&String.codepoints/1)

grid_height = grid |> length()
grid_width = grid |> hd() |> length()

height_by_pos =
  grid
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row |> Enum.with_index() |> Enum.map(fn {elem, j} -> {{i, j}, String.to_integer(elem)} end)
  end)
  |> Map.new()

find_valid_adjacent_positions = fn {i, j} ->
  directions = [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]

  directions
  |> Enum.map(fn {d_i, d_j} -> {i + d_i, j + d_j} end)
  |> Enum.filter(fn {o_i, o_j} ->
    o_i in 0..(grid_height - 1) and o_j in 0..(grid_width - 1)
  end)
end

filter_to_relevant = fn height_by_pos ->
  height_by_pos
  |> Map.filter(fn {pos, height} ->
    valid_adjacent_positions = find_valid_adjacent_positions.(pos)

    (height === 0 or
       valid_adjacent_positions
       |> Enum.any?(fn pos -> height_by_pos |> Map.get(pos) == height - 1 end)) and
      (height === 9 or
         valid_adjacent_positions
         |> Enum.any?(fn pos -> height_by_pos |> Map.get(pos) == height + 1 end))
  end)
end

relevant_by_pos =
  Enum.reduce_while(0..(grid_width * grid_height), height_by_pos, fn _, height_by_pos ->
    new_height_by_pos = filter_to_relevant.(height_by_pos)

    if map_size(height_by_pos) === map_size(new_height_by_pos) do
      {:halt, new_height_by_pos}
    else
      {:cont, new_height_by_pos}
    end
  end)

summit_positions_to_reachable_summits =
  relevant_by_pos
  |> Map.filter(fn {_, height} ->
    height === 9
  end)
  |> Map.keys()
  |> Enum.map(&{&1, MapSet.new([&1])})
  |> Map.new()

positions_by_height =
  relevant_by_pos
  |> Map.to_list()
  |> Enum.group_by(fn {_, height} -> height end, fn {pos, _} -> pos end)

trailheads_to_reachable_summits =
  Enum.reduce(8..0//-1, summit_positions_to_reachable_summits, fn target_height,
                                                                  reachable_summits_by_prev_height_pos ->
    positions_at_target_height =
      positions_by_height
      |> Map.get(target_height)

    reachable_summits_by_target_height_pos =
      positions_at_target_height
      |> Enum.map(fn pos_at_target_height ->
        adjacent_at_prev_height =
          find_valid_adjacent_positions.(pos_at_target_height)
          |> Enum.filter(fn adj_pos ->
            reachable_summits_by_prev_height_pos |> Map.has_key?(adj_pos)
          end)

        {pos_at_target_height,
         adjacent_at_prev_height
         |> Enum.flat_map(&Map.get(reachable_summits_by_prev_height_pos, &1, MapSet.new()))
         |> MapSet.new()}
      end)
      |> Map.new()

    reachable_summits_by_target_height_pos
  end)

trailhead_score_sum =
  trailheads_to_reachable_summits |> Map.values() |> Enum.map(&MapSet.size/1) |> Enum.sum()

IO.puts(trailhead_score_sum)

# Part 2

summit_positions_to_reachable_summit_count =
  relevant_by_pos
  |> Map.filter(fn {_, height} ->
    height === 9
  end)
  |> Map.keys()
  |> Enum.map(&{&1, 1})
  |> Map.new()

trailheads_to_reachable_unique_paths_count =
  Enum.reduce(8..0//-1, summit_positions_to_reachable_summit_count, fn target_height,
                                                                       reachable_summit_count_by_prev_height_pos ->
    positions_at_target_height =
      positions_by_height
      |> Map.get(target_height)

    reachable_summit_count_by_target_height_pos =
      positions_at_target_height
      |> Enum.map(fn pos_at_target_height ->
        adjacent_at_prev_height =
          find_valid_adjacent_positions.(pos_at_target_height)
          |> Enum.filter(fn adj_pos ->
            reachable_summit_count_by_prev_height_pos |> Map.has_key?(adj_pos)
          end)

        {pos_at_target_height,
         adjacent_at_prev_height
         |> Enum.map(&Map.get(reachable_summit_count_by_prev_height_pos, &1, 0))
         |> Enum.sum()}
      end)
      |> Map.new()

    reachable_summit_count_by_target_height_pos
  end)

trailhead_rating_sum =
  trailheads_to_reachable_unique_paths_count
  |> Map.values()
  |> Enum.sum()

IO.puts(trailhead_rating_sum)
