codes =
  File.read!("input") |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)

numpad_vertices = 0..9 |> Enum.map(&Integer.to_string/1) |> Enum.concat(["A"])

numpad_edges = %{
  "0" => MapSet.new([{"2", :up}, {"A", :right}]),
  "A" => MapSet.new([{"0", :left}, {"3", :up}]),
  "1" => MapSet.new([{"2", :right}, {"4", :up}]),
  "2" => MapSet.new([{"1", :left}, {"5", :up}, {"3", :right}, {"0", :down}]),
  "3" => MapSet.new([{"2", :left}, {"6", :up}, {"A", :down}]),
  "4" => MapSet.new([{"7", :up}, {"5", :right}, {"1", :down}]),
  "5" => MapSet.new([{"2", :down}, {"4", :left}, {"6", :right}, {"8", :up}]),
  "6" => MapSet.new([{"3", :down}, {"5", :left}, {"9", :up}]),
  "7" => MapSet.new([{"4", :down}, {"8", :right}]),
  "8" => MapSet.new([{"7", :left}, {"5", :down}, {"9", :right}]),
  "9" => MapSet.new([{"8", :left}, {"6", :down}])
}

dir_to_dirpad = %{
  :up => "^",
  :left => "<",
  :right => ">",
  :down => "v"
}

dirpad_vertices = ["^", "<", "v", ">", "A"]

dirpad_edges = %{
  "^" => MapSet.new([{"v", :down}, {"A", :right}]),
  "v" => MapSet.new([{"<", :left}, {">", :right}, {"^", :up}]),
  "<" => MapSet.new([{"v", :right}]),
  ">" => MapSet.new([{"v", :left}, {"A", :up}]),
  "A" => MapSet.new([{"^", :left}, {">", :down}])
}

get_all_paths = fn pos, finish, edges, sequence, visited, self ->
  if pos === finish do
    [["A" | sequence] |> Enum.reverse() |> Enum.join()]
  else
    to_visit =
      Map.get(edges, pos) |> MapSet.filter(&(not MapSet.member?(visited, elem(&1, 0))))

    to_visit
    |> Enum.flat_map(fn {new_pos, direction} ->
      self.(
        new_pos,
        finish,
        edges,
        [Map.get(dir_to_dirpad, direction) | sequence],
        MapSet.put(visited, new_pos),
        self
      )
    end)
  end
end

shortest_start_to_finish_numpad =
  numpad_vertices
  |> Enum.flat_map(fn start ->
    numpad_vertices
    |> Enum.map(fn finish ->
      paths = get_all_paths.(start, finish, numpad_edges, [], MapSet.new([start]), get_all_paths)
      shortest = paths |> Enum.min_by(&String.length/1) |> String.length()

      {{start, finish},
       paths
       |> Enum.filter(&(String.length(&1) === shortest))}
    end)
  end)
  |> Map.new()

shortest_start_to_finish_dirpad =
  dirpad_vertices
  |> Enum.flat_map(fn start ->
    dirpad_vertices
    |> Enum.map(fn finish ->
      paths = get_all_paths.(start, finish, dirpad_edges, [], MapSet.new([start]), get_all_paths)
      shortest = paths |> Enum.min_by(&String.length/1) |> String.length()

      {{start, finish},
       paths
       |> Enum.filter(&(String.length(&1) === shortest))}
    end)
  end)
  |> Map.new()

defmodule Expander do
  use Agent
  use Bitwise

  def start do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def expand_path({parent_pos, path}, shortest_start_to_finish_dirpad, 1) do
    cached_list = Agent.get(__MODULE__, &Map.get(&1, {path, 1}))

    if cached_list do
      {parent_pos, cached_list}
    else
      list =
        path
        |> String.codepoints()
        |> Enum.reduce({"A", []}, fn next_pos, {current_pos, shortest_shallow_paths_list} ->
          shallow_paths = shortest_start_to_finish_dirpad |> Map.get({current_pos, next_pos})
          shortest = shallow_paths |> hd() |> String.length()
          {next_pos, [shortest | shortest_shallow_paths_list]}
        end)
        |> elem(1)
        |> Enum.reverse()

      Agent.update(__MODULE__, &Map.put(&1, {path, 1}, list))

      {parent_pos, list}
    end
  end

  def expand_path({parent_pos, path}, shortest_start_to_finish_dirpad, levels) do
    cached_expansion = Agent.get(__MODULE__, &Map.get(&1, {path, levels}))

    if cached_expansion do
      {parent_pos, cached_expansion}
    else
      expansion =
        path
        |> String.codepoints()
        |> Enum.reduce({"A", []}, fn next_pos, {current_pos, shortest_expanded_paths_list} ->
          shallow_paths = shortest_start_to_finish_dirpad |> Map.get({current_pos, next_pos})

          expanded_paths =
            shallow_paths
            |> Enum.map(fn shallow_path ->
              expand_path({next_pos, shallow_path}, shortest_start_to_finish_dirpad, levels - 1)
            end)

          shortest_expanded_path =
            expanded_paths
            |> Enum.min_by(fn {pos_used_by_expanded, expanded_list} ->
              expanded_list |> Enum.sum()
            end)
            |> elem(1)
            |> Enum.sum()

          {next_pos, [shortest_expanded_path | shortest_expanded_paths_list]}
        end)
        |> elem(1)
        |> Enum.reverse()

      Agent.update(__MODULE__, &Map.put(&1, {path, levels}, expansion))

      {parent_pos, expansion}
    end
  end
end

Expander.start()

find_shortest_sequence_length = fn code, expansions ->
  path_options_by_pos =
    code
    |> Enum.reduce({"A", []}, fn next_pos, {current_pos, paths_list} ->
      paths = shortest_start_to_finish_numpad |> Map.get({current_pos, next_pos})
      {next_pos, [{next_pos, paths} | paths_list]}
    end)
    |> elem(1)
    |> Enum.reverse()

  expanded =
    path_options_by_pos
    |> Enum.map(fn {pos, path_options} ->
      {
        pos,
        path_options
        |> Enum.map(fn path_option ->
          Expander.expand_path({pos, path_option}, shortest_start_to_finish_dirpad, expansions)
        end)
        |> Enum.map(fn {pos, expanded_path} ->
          expanded_path |> Enum.sum()
        end)
        |> Enum.min()
      }
    end)

  expanded |> Enum.map(&elem(&1, 1)) |> Enum.sum()
end

codes
|> Enum.map(fn code ->
  shortest_sequence_length = find_shortest_sequence_length.(code, 2)

  numeric_part =
    code
    |> Enum.filter(fn c -> String.match?(c, ~r"[0-9]") end)
    |> Enum.join()
    |> String.to_integer()

  shortest_sequence_length * numeric_part
end)
|> Enum.sum()
|> IO.inspect()

# Part 2

codes
|> Enum.map(fn code ->
  shortest_sequence_length = find_shortest_sequence_length.(code, 25)

  numeric_part =
    code
    |> Enum.filter(fn c -> String.match?(c, ~r"[0-9]") end)
    |> Enum.join("")
    |> String.to_integer()

  shortest_sequence_length * numeric_part
end)
|> Enum.sum()
|> IO.inspect()
