[rules, updates] = String.split(File.read!("input"), "\n\n")

parsed_rules =
  String.split(rules, "\n")
  |> Enum.map(fn r ->
    String.split(r, "|") |> Enum.map(&String.to_integer/1)
  end)

parsed_updates =
  String.split(updates, "\n")
  |> Enum.filter(fn u -> String.length(u) > 0 end)
  |> Enum.map(fn u -> String.split(u, ",") |> Enum.map(&String.to_integer/1) end)

after_to_befores =
  Enum.group_by(parsed_rules, fn [_, aft] -> aft end, fn [bef, _] -> bef end)
  |> Enum.into(%{}, fn {k, vals} -> {k, vals |> MapSet.new()} end)

befores_to_after =
  Enum.group_by(parsed_rules, fn [bef, _] -> bef end, fn [_, aft] -> aft end)
  |> Enum.into(%{}, fn {k, vals} -> {k, vals |> MapSet.new()} end)

{right_order_updates, wrong_order_updates} =
  Enum.split_with(
    parsed_updates,
    fn update ->
      {_, _, is_right_order} =
        Enum.reduce(update, {MapSet.new(), MapSet.new(update), true}, fn page,
                                                                         {pages_before,
                                                                          pages_after,
                                                                          right_order_so_far} ->
          must_be_before = after_to_befores |> Map.get(page, MapSet.new())
          must_be_after = befores_to_after |> Map.get(page, MapSet.new())

          {pages_before |> MapSet.put(page), pages_after |> MapSet.delete(page),
           right_order_so_far and
             MapSet.intersection(pages_after, must_be_before) |> MapSet.size() === 0 and
             MapSet.intersection(pages_before, must_be_after) |> MapSet.size() === 0}
        end)

      is_right_order
    end
  )

middle_page_numbers = right_order_updates |> Enum.map(fn u -> Enum.at(u, length(u) |> div(2)) end)
sum = middle_page_numbers |> Enum.sum()
IO.puts(sum)

# Part 2
fixed_order_updates =
  wrong_order_updates
  |> Enum.map(fn update ->
    update
    |> Enum.sort(fn l, r ->
      must_be_before_l = after_to_befores |> Map.get(l, MapSet.new())
      must_be_after_r = befores_to_after |> Map.get(r, MapSet.new())

      not MapSet.member?(must_be_before_l, r) and not MapSet.member?(must_be_after_r, l)
    end)
  end)

fixed_middle_page_numbers =
  fixed_order_updates |> Enum.map(fn u -> Enum.at(u, length(u) |> div(2)) end)

fixed_sum = fixed_middle_page_numbers |> Enum.sum()
IO.puts(fixed_sum)
