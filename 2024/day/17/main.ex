[registers, program] = File.read!("input") |> String.trim() |> String.split("\n\n")

registers =
  registers
  |> String.split("\n")
  |> Enum.map(&String.split(&1, ": "))
  |> Enum.map(&List.last/1)
  |> Enum.map(&String.to_integer/1)

raw_program =
  program
  |> String.split(": ")
  |> List.last()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

max_ip = length(raw_program) - 1
ip_to_code = raw_program |> Enum.with_index() |> Map.new(fn {code, ip} -> {ip, code} end)

program =
  raw_program
  |> Enum.chunk_every(2)

resolve_combo = fn state, combo ->
  {[a, b, c], _, _} = state

  case combo do
    0 -> 0
    1 -> 1
    2 -> 2
    3 -> 3
    4 -> a
    5 -> b
    6 -> c
  end
end

adv = fn state, combo ->
  {[a, b, c], ip, output} = state
  exp = Integer.pow(2, resolve_combo.(state, combo))
  {[div(a, exp), b, c], ip + 2, output}
end

bxl = fn {[a, b, c], ip, output}, lit ->
  {[a, Bitwise.bxor(b, lit), c], ip + 2, output}
end

bst = fn state, combo ->
  {[a, b, c], ip, output} = state
  {[a, rem(resolve_combo.(state, combo), 8), c], ip + 2, output}
end

jnz = fn {registers, ip, output}, lit ->
  [a, _, _] = registers

  if a === 0 do
    {registers, ip + 2, output}
  else
    {registers, lit, output}
  end
end

bxc = fn {[a, b, c], ip, output}, _ ->
  {[a, Bitwise.bxor(b, c), c], ip + 2, output}
end

out = fn state, combo ->
  {registers, ip, output} = state
  value = rem(resolve_combo.(state, combo), 8)
  {registers, ip + 2, [value | output]}
end

bdv = fn state, combo ->
  {[a, b, c], ip, output} = state
  exp = Integer.pow(2, resolve_combo.(state, combo))
  {[a, div(a, exp), c], ip + 2, output}
end

cdv = fn state, combo ->
  {[a, b, c], ip, output} = state
  exp = Integer.pow(2, resolve_combo.(state, combo))
  {[a, b, div(a, exp)], ip + 2, output}
end

execute = fn state, self ->
  {_, ip, _} = state
  opcode = ip_to_code |> Map.get(ip)
  operand = ip_to_code |> Map.get(ip + 1)

  instruction =
    case opcode do
      0 -> adv
      1 -> bxl
      2 -> bst
      3 -> jnz
      4 -> bxc
      5 -> out
      6 -> bdv
      7 -> cdv
    end

  new_state = instruction.(state, operand)
  {_, new_ip, new_output} = new_state

  if new_ip <= max_ip do
    self.(new_state, self)
  else
    new_output |> Enum.reverse()
  end
end

execute.({registers, 0, []}, execute) |> Enum.join(",") |> IO.puts()

# Part 2

execute = fn state, self ->
  {_, ip, _} = state
  opcode = ip_to_code |> Map.get(ip)
  operand = ip_to_code |> Map.get(ip + 1)

  instruction =
    case opcode do
      0 -> adv
      1 -> bxl
      2 -> bst
      3 -> jnz
      4 -> bxc
      5 -> out
      6 -> bdv
      7 -> cdv
    end

  new_state = instruction.(state, operand)
  {_, new_ip, new_output} = new_state

  if new_ip <= max_ip and
       new_output |> length() <= raw_program |> length() and
       (length(new_output) === 0 or
          hd(new_output) === Map.get(ip_to_code, length(new_output) - 1)) do
    self.(new_state, self)
  else
    new_output |> Enum.reverse()
  end
end

execute.({registers, 0, []}, execute) |> Enum.join(",") |> IO.puts()

try_find = fn a_to_try, self ->
  [a, b, c] = registers
  output = execute.({[a_to_try, b, c], 0, []}, execute)

  if rem(a_to_try, 100_000) === 0 do
    IO.inspect(a_to_try)
  end

  if(output === raw_program) do
    IO.puts(a_to_try)
  else
    self.(a_to_try + 1, self)
  end
end

try_find.(6_617_148_600, try_find)
