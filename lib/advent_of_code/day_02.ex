defmodule AdventOfCode.Day02 do
  import Enum

  def execute(pc, program) do
    case program[pc] do
      99 ->
        program

      1 ->
        a = Map.get(program, pc + 1, 0)
        b = Map.get(program, pc + 2, 0)
        c = Map.get(program, pc + 3, 0)
        execute(pc + 4, Map.put(program, c, Map.get(program, a, 0) + Map.get(program, b, 0)))

      2 ->
        a = Map.get(program, pc + 1, 0)
        b = Map.get(program, pc + 2, 0)
        c = Map.get(program, pc + 3, 0)
        execute(pc + 4, Map.put(program, c, Map.get(program, a, 0) * Map.get(program, b, 0)))
    end
  end

  def part1(args) do
    program =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      |> with_index(fn a, b -> {b, a} end)
      |> Map.new()
      |> Map.put(1, 12)
      |> Map.put(2, 2)

    execute(0, program) |> Map.get(0)
  end

  def part2(args) do
    program =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      |> with_index(fn a, b -> {b, a} end)
      |> Map.new()

    for noun <- 0..99, verb <- 0..99 do
      {noun, verb, execute(0, program |> Map.put(1, noun) |> Map.put(2, verb)) |> Map.get(0)}
    end
    |> filter(fn {_, _, e} -> e == 19_690_720 end)
    |> map(fn {n, v, _} -> n * 100 + v end)
    |> List.first()
  end
end
