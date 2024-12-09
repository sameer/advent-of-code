map =
  File.read!("input")
  |> String.split("\n")
  |> Enum.filter(&(String.length(&1) > 0))
  |> Enum.map(&String.codepoints(&1))

guard = "^"
visited = "X"
obstacle = "#"
empty = "."

height = length(map)
width = List.first(map) |> length()
guard_row = map |> Enum.find_index(fn row -> row |> Enum.any?(&(&1 === guard)) end)
guard_col = Enum.at(map, guard_row) |> Enum.find_index(&(&1 === guard))
guard_dir = :up

{{_, _, _}, visited_map} =
  Enum.reduce_while(0..(width * height), {{guard_row, guard_col, guard_dir}, map}, fn _,
                                                                                      {{guard_row,
                                                                                        guard_col,
                                                                                        guard_dir},
                                                                                       map} ->
    new_row = map |> Enum.at(guard_row) |> List.replace_at(guard_col, visited)
    new_map = map |> List.replace_at(guard_row, new_row)

    {planned_new_guard_row, planned_new_guard_col} =
      case guard_dir do
        :up -> {guard_row - 1, guard_col}
        :down -> {guard_row + 1, guard_col}
        :left -> {guard_row, guard_col - 1}
        :right -> {guard_row, guard_col + 1}
      end

    if planned_new_guard_row not in 0..(height - 1) or planned_new_guard_col not in 0..(width - 1) do
      {:halt, {{guard_row, guard_col, guard_dir}, new_map}}
    else
      next =
        if(
          map |> Enum.at(planned_new_guard_row) |> Enum.at(planned_new_guard_col) === obstacle
        ) do
          new_guard_dir =
            case guard_dir do
              :up -> :right
              :down -> :left
              :left -> :up
              :right -> :down
            end

          {guard_row, guard_col, new_guard_dir}
        else
          {planned_new_guard_row, planned_new_guard_col, guard_dir}
        end

      {:cont, {next, new_map}}
    end
  end)

num_positions =
  visited_map |> Enum.flat_map(& &1) |> Enum.count(&(&1 === visited))

IO.puts(num_positions)

# Part 2

possible_obstacle_positions =
  visited_map
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, row_idx} ->
    row
    |> Enum.with_index()
    |> Enum.filter(fn {elem, _} -> elem === visited end)
    |> Enum.map(fn {_, col_idx} -> {row_idx, col_idx} end)
  end)

looping_positions =
  possible_obstacle_positions
  |> Enum.filter(fn {row_idx, col_idx} ->
    modified_map =
      map
      |> List.replace_at(row_idx, map |> Enum.at(row_idx) |> List.replace_at(col_idx, obstacle))

    {{_, _, _}, _, has_loop} =
      Enum.reduce_while(
        0..(width * height + 1),
        {{guard_row, guard_col, guard_dir}, modified_map, false},
        fn it, {{guard_row, guard_col, guard_dir}, map, _} ->
          new_row = map |> Enum.at(guard_row) |> List.replace_at(guard_col, visited)
          new_map = map |> List.replace_at(guard_row, new_row)

          {planned_new_guard_row, planned_new_guard_col} =
            case guard_dir do
              :up -> {guard_row - 1, guard_col}
              :down -> {guard_row + 1, guard_col}
              :left -> {guard_row, guard_col - 1}
              :right -> {guard_row, guard_col + 1}
            end

          if planned_new_guard_row not in 0..(height - 1) or
               planned_new_guard_col not in 0..(width - 1) do
            {:halt, {{guard_row, guard_col, guard_dir}, new_map, false}}
          else
            next =
              if(
                map |> Enum.at(planned_new_guard_row) |> Enum.at(planned_new_guard_col) ===
                  obstacle
              ) do
                new_guard_dir =
                  case guard_dir do
                    :up -> :right
                    :down -> :left
                    :left -> :up
                    :right -> :down
                  end

                {guard_row, guard_col, new_guard_dir}
              else
                {planned_new_guard_row, planned_new_guard_col, guard_dir}
              end

            # if the reduce_while gets completely exhausted without going out of bounds, there is definitely a loop somewhere
            {:cont, {next, new_map, true}}
          end
        end
      )

    has_loop
  end)

num_looping_positions = looping_positions |> length()
IO.puts(num_looping_positions)
