defmodule AdventOfCode.Day05 do
  import Enum

  def parse(args) do
    args
    |> String.trim()
    |> String.split(",", trim: true)
    |> map(&String.to_integer/1)
    |> with_index(fn a, b -> {b, a} end)
    |> Map.new()
  end

  def execute_instruction(99, _modes, pc, program, input, output),
    do: {:stop, {pc, program, input, output}}

  def execute_instruction(1, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, va + vb), input, output}}
  end

  def execute_instruction(2, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, va * vb), input, output}}
  end

  def execute_instruction(3, _modes, pc, program, [i | r_input], output) do
    {:run, {pc + 2, Map.put(program, Map.get(program, pc + 1), i), r_input, output}}
  end

  def execute_instruction(4, _modes, pc, program, input, output) do
    {:run, {pc + 2, program, input, output ++ [Map.get(program, Map.get(program, pc + 1), nil)]}}
  end

  def execute_instruction(5, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b

    if va != 0,
      do: {:run, {vb, program, input, output}},
      else: {:run, {pc + 3, program, input, output}}
  end

  def execute_instruction(6, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b

    if va == 0,
      do: {:run, {vb, program, input, output}},
      else: {:run, {pc + 3, program, input, output}}
  end

  def execute_instruction(7, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, if(va < vb, do: 1, else: 0)), input, output}}
  end

  def execute_instruction(8, [ma, mb, _mc], pc, program, input, output) do
    a = Map.get(program, pc + 1, 0)
    b = Map.get(program, pc + 2, 0)
    c = Map.get(program, pc + 3, 0)
    va = if ma == 0, do: Map.get(program, a, 0), else: a
    vb = if mb == 0, do: Map.get(program, b, 0), else: b
    {:run, {pc + 4, Map.put(program, c, if(va == vb, do: 1, else: 0)), input, output}}
  end

  def decode_instruction(ins) do
    ins = to_charlist(Integer.to_string(ins))
    [a, b, c, d, e] = List.duplicate(?0, 5 - length(ins)) ++ ins
    {(d - ?0) * 10 + (e - ?0), [c - ?0, b - ?0, a - ?0]}
  end

  def execute_step(pc, program, input, output) do
    {opcode, modes} = decode_instruction(program[pc])
    execute_instruction(opcode, modes, pc, program, input, output)
  end

  def execute(pc, program, input, output) do
    #    IO.inspect(binding())
    {stop, {pc, program, input, output}} = execute_step(pc, program, input, output)

    if stop == :stop do
      {pc, program, input, output}
    else
      execute(pc, program, input, output)
    end
  end

  def part1(args) do
    execute(0, parse(args), [1], []) |> elem(3) |> List.last()
  end

  def part2(args) do
    execute(0, parse(args), [5], []) |> elem(3) |> List.last()
  end
end
