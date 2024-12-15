gardens =
  File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)

height = gardens |> length()
width = gardens |> List.first() |> length()

directions = [[0, -1], [-1, 0], [1, 0], [0, 1]]

pos_to_type =
  gardens
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, i} ->
    row |> Enum.with_index() |> Enum.map(fn {type, j} -> {[i, j], type} end)
  end)
  |> Map.new()

pos_to_unique_component =
  pos_to_type
  |> Map.to_list()
  |> Enum.with_index()
  |> Enum.map(fn {{k, _}, idx} -> {k, idx} end)
  |> Map.new()

adjacent_positions = fn pos ->
  directions
  |> Enum.map(fn dir ->
    Enum.zip(pos, dir) |> Enum.map(&Tuple.to_list/1) |> Enum.map(&Enum.sum/1)
  end)
end

flood_fill_from = fn pos, acc, self ->
  component = acc |> Map.get(pos)
  type = pos_to_type |> Map.get(pos)

  valid_adjacent_positions =
    adjacent_positions.(pos)
    |> Enum.filter(fn [i, j] ->
      i in 0..(height - 1) and j in 0..(width - 1) and pos_to_type |> Map.get([i, j]) === type and
        acc |> Map.get([i, j]) !== component
    end)
    |> Enum.reduce(acc, fn dir_pos, acc ->
      self.(dir_pos, acc |> Map.replace(dir_pos, component), self)
    end)
end

pos_to_component =
  pos_to_unique_component
  |> Map.keys()
  |> Enum.reduce(pos_to_unique_component, fn pos, acc ->
    flood_fill_from.(pos, acc, flood_fill_from)
  end)

component_to_elements =
  pos_to_component
  |> Map.to_list()
  |> Enum.group_by(fn {_, component} -> component end, fn {pos, _} -> pos end)


area_by_component =
  component_to_elements
  |> Map.to_list()
  |> Enum.map(fn {component, elements} -> {component, length(elements)} end)
  |> Map.new()

perimeter_by_component =
  component_to_elements
  |> Map.to_list()
  |> Enum.map(fn {component, elements} ->
    component_perimeter =
      elements
      |> Enum.map(fn pos ->
        component = pos_to_component |> Map.get(pos)

        adjacent_positions.(pos)
        |> Enum.map(fn pos ->
          if pos_to_component |> Map.get(pos) === component, do: 0, else: 1
        end)
        |> Enum.sum()
      end)
      |> Enum.sum()

    {component, component_perimeter}
  end)
  |> Map.new()

total_price =
  perimeter_by_component
  |> Map.to_list()
  |> Enum.map(fn {component, perimeter} ->
    area = area_by_component |> Map.get(component)

    perimeter * area
  end)
  |> Enum.sum()

IO.puts(total_price)
