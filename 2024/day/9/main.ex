raw_disk_map = File.read!("input") |> String.trim() |> String.codepoints()
free = "."

{_, _, disk_map} =
  raw_disk_map
  |> Enum.reduce({false, 0, []}, fn elem, {is_free_count, file_idx, disk_map} ->
    if is_free_count do
      {false, file_idx, Enum.concat(disk_map, List.duplicate(free, String.to_integer(elem)))}
    else
      {true, file_idx + 1,
       Enum.concat(
         disk_map,
         List.duplicate(Integer.to_string(file_idx), String.to_integer(elem))
       )}
    end
  end)

free_indices =
  Enum.with_index(disk_map)
  |> Enum.filter(fn {elem, _} -> elem === free end)
  |> Enum.map(fn {_, idx} -> idx end)

{final_disk_map, _} =
  Enum.with_index(disk_map)
  |> Enum.reverse()
  |> Enum.filter(fn {elem, _} -> elem !== free end)
  |> Enum.reduce_while(
    {disk_map, free_indices},
    fn {element, idx}, {disk_map, free_indices} ->
      cond do
        length(free_indices) === 0 or hd(free_indices) > idx ->
          {:halt, {disk_map, free_indices}}

        element === free ->
          {:cont, {disk_map, free_indices}}

        true ->
          new_disk_map =
            disk_map |> List.replace_at(hd(free_indices), element) |> List.replace_at(idx, free)

          {:cont, {new_disk_map, tl(free_indices)}}
      end
    end
  )

calculate_checksum = fn map ->
  map
  |> Enum.with_index()
  |> Enum.map(fn {elem, idx} ->
    cond do
      elem === free ->
        0

      true ->
        String.to_integer(elem) * idx
    end
  end)
  |> Enum.sum()
end

checksum = calculate_checksum.(final_disk_map)

IO.puts(checksum)

# Part 2

{_, files_in_reverse, free_spaces_in_reverse} =
  raw_disk_map
  |> Enum.with_index()
  |> Enum.reduce({0, [], []}, fn {elem, idx},
                                 {block_pos, files_in_reverse, free_spaces_in_reverse} ->
    size = String.to_integer(elem)

    if rem(idx, 2) === 1 do
      {block_pos + size, files_in_reverse, [{size, block_pos} | free_spaces_in_reverse]}
    else
      id = div(idx, 2)
      {block_pos + size, [{id, {size, block_pos}} | files_in_reverse], free_spaces_in_reverse}
    end
  end)

free_spaces = free_spaces_in_reverse |> Enum.reverse()

{contiguous_files, _} =
  files_in_reverse
  |> Enum.reduce(
    {[], free_spaces},
    fn {id, {file_size, file_block_pos}}, {acc, free_spaces} ->
      new_location =
        free_spaces
        |> Enum.take_while(fn {_, free_space_block_pos} ->
          free_space_block_pos < file_block_pos
        end)
        |> Enum.with_index()
        |> Enum.find(fn {{free_space_size, _}, _} -> free_space_size >= file_size end)

      if new_location !== nil do
        free_space = elem(new_location, 0)
        free_space_block_pos = free_space |> elem(1)
        new_free_space = {elem(free_space, 0) - file_size, free_space_block_pos + file_size}

        {[{id, {file_size, free_space_block_pos}} | acc],
         List.replace_at(free_spaces, elem(new_location, 1), new_free_space)}
      else
        {[{id, {file_size, file_block_pos}} | acc], free_spaces}
      end
    end
  )

contiguous_checksum =
  contiguous_files
  |> Enum.flat_map(fn {id, {size, pos}} ->
    pos..(pos + size - 1)
    |> Enum.map(&(&1 * id))
  end)
  |> Enum.sum()

contiguous_checksum |> IO.puts()
