defmodule AdventOfCode.Day03 do
  import Enum

  def parse_line(line) do
    line
    |> String.split(",", trim: true)
    |> map(fn
      "R" <> n -> {:right, String.to_integer(n)}
      "L" <> n -> {:left, String.to_integer(n)}
      "U" <> n -> {:up, String.to_integer(n)}
      "D" <> n -> {:down, String.to_integer(n)}
    end)
  end

  def segment({x, y}, {:up, distance}), do: for(i <- 1..distance, do: {x, y + i})
  def segment({x, y}, {:down, distance}), do: for(i <- 1..distance, do: {x, y - i})
  def segment({x, y}, {:right, distance}), do: for(i <- 1..distance, do: {x + i, y})
  def segment({x, y}, {:left, distance}), do: for(i <- 1..distance, do: {x - i, y})

  def parse(args) do
    args
    |> String.trim()
    |> String.split("\n", trim: true)
    |> map(&parse_line/1)
  end

  def compute_path(instructions) do
    reduce(instructions, [{0, 0}], fn instruction, path ->
      path ++ segment(List.last(path), instruction)
    end)
  end

  def part1(args) do
    [c1, c2] = parse(args) |> map(&compute_path/1)
    inters = MapSet.intersection(MapSet.new(c1), MapSet.new(c2)) |> MapSet.delete({0, 0})
    for({x, y} <- inters, do: abs(x) + abs(y)) |> min()
  end

  def travel(c1, target), do: Enum.take_while(c1, fn i -> i != target end) |> count()

  def part2(args) do
    [c1, c2] = parse(args) |> map(&compute_path/1)
    inters = MapSet.intersection(MapSet.new(c1), MapSet.new(c2)) |> MapSet.delete({0, 0})
    for(i <- inters, do: travel(c1, i) + travel(c2, i)) |> min()
  end
end
