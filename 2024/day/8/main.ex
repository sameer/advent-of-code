grid =
  File.read!("input")
  |> String.split("\n")
  |> Enum.filter(&(String.length(&1) > 0))
  |> Enum.map(&String.codepoints/1)

height = grid |> length()
width = grid |> hd() |> length()

empty = "."

antenna_groups =
  grid
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char !== empty end)
    |> Enum.map(fn {char, j} -> {{i, j}, char} end)
  end)
  |> Enum.group_by(fn {_, char} -> char end, fn {{i, j}, _} -> {i, j} end)

find_antinodes = fn primary, remaining_pairs, self ->
  if length(remaining_pairs) === 0 do
    []
  else
    {p_i, p_j} = primary

    antinodes =
      Enum.flat_map(remaining_pairs, fn secondary ->
        {s_i, s_j} = secondary
        delta_i = p_i - s_i
        delta_j = p_j - s_j

        above_i = p_i + delta_i
        above_j = p_j + delta_j
        below_i = s_i - delta_i
        below_j = s_j - delta_j

        [{above_i, above_j}, {below_i, below_j}]
      end)
      |> Enum.filter(fn {i, j} ->
        i in 0..(height - 1) and j in 0..(width - 1)
      end)

    antinodes ++ self.(hd(remaining_pairs), tl(remaining_pairs), self)
  end
end

antinodes =
  antenna_groups
  |> Map.to_list()
  |> Enum.flat_map(fn {_, nodes} ->
    find_antinodes.(hd(nodes), tl(nodes), find_antinodes)
  end)
  |> MapSet.new()
  |> MapSet.size()

antinodes |> IO.puts()

# Part 2

find_all_antinodes = fn primary, remaining_pairs, self ->
  if length(remaining_pairs) === 0 do
    []
  else
    {p_i, p_j} = primary

    is_pos_valid = fn {i, j} ->
      i in 0..(height - 1) and j in 0..(width - 1)
    end

    antinodes =
      Enum.flat_map(remaining_pairs, fn secondary ->
        {s_i, s_j} = secondary
        delta_i = p_i - s_i
        delta_j = p_j - s_j

        above_antinodes =
          Stream.unfold({p_i, p_j}, fn {i, j} ->
            next = {i + delta_i, j + delta_j}
            {next, next}
          end)
          |> Enum.take_while(&is_pos_valid.(&1))

        below_antinodes =
          Stream.unfold({s_i, s_j}, fn {i, j} ->
            next = {i - delta_i, j - delta_j}
            {next, next}
          end)
          |> Enum.take_while(&is_pos_valid.(&1))

        Enum.concat(above_antinodes, below_antinodes) |> Enum.to_list()
      end)

    antinodes ++ self.(hd(remaining_pairs), tl(remaining_pairs), self)
  end
end

antenna_groups
|> Map.to_list()
|> Enum.flat_map(fn {_, nodes} ->
  if length(nodes) > 1 do
    nodes
  else
    []
  end ++
    find_all_antinodes.(hd(nodes), tl(nodes), find_all_antinodes)
end)
|> MapSet.new()
|> MapSet.size()
|> IO.puts()
