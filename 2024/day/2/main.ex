input = File.read!("input")

reports =
  Enum.map(
    Enum.filter(String.split(input, "\n"), fn r -> String.length(r) > 0 end),
    fn report ->
      levels = String.split(report, " ")
      Enum.map(levels, &String.to_integer/1)
    end
  )

is_report_safe = fn r ->
  level_pairs = Enum.zip([r, tl(r)])

  all_increasing = Enum.all?(level_pairs, fn {first, second} -> first < second end)
  all_decreasing = Enum.all?(level_pairs, fn {first, second} -> first > second end)
  within_diff = Enum.all?(level_pairs, fn {first, second} -> abs(first - second) in 1..3 end)

  within_diff and (all_increasing or all_decreasing)
end

find_safe_reports = fn reports ->
  Enum.filter(reports, &is_report_safe.(&1))
end

safe_reports = find_safe_reports.(reports)

IO.puts(length(safe_reports))

# Part 2

actually_safe_reports =
  Enum.filter(reports, fn report ->
    level_pairs = Enum.zip([report, tl(report)])

    not_increasing = Enum.find_index(level_pairs, fn {first, second} -> not (first < second) end)
    not_decreasing = Enum.find_index(level_pairs, fn {first, second} -> not (first > second) end)

    not_within_diff =
      Enum.find_index(level_pairs, fn {first, second} -> abs(first - second) not in 1..3 end)

    is_report_safe.(report) or
      (not_increasing !== nil and
         (is_report_safe.(List.delete_at(report, not_increasing)) or
            is_report_safe.(List.delete_at(report, not_increasing + 1)))) or
      (not_decreasing !== nil and
         (is_report_safe.(List.delete_at(report, not_decreasing)) or
            is_report_safe.(List.delete_at(report, not_decreasing + 1)))) or
      (not_within_diff !== nil and
         (is_report_safe.(List.delete_at(report, not_within_diff)) or
            is_report_safe.(List.delete_at(report, not_within_diff + 1))))
  end)

IO.puts(length(actually_safe_reports))
