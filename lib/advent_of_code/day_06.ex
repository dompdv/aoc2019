defmodule AdventOfCode.Day06 do
  import Enum

  def parse(args) do
    args
    |> String.trim()
    |> String.split("\n", trim: true)
    |> map(&String.trim/1)
    |> map(&String.split(&1, ")"))
  end

  def build_network(entry) do
    initial_graph = for node <- entry |> List.flatten() |> uniq(), into: %{}, do: {node, []}

    reduce(entry, initial_graph, fn [from, to], acc ->
      Map.put(acc, from, [to | acc[from]])
    end)
  end

  def fill(network), do: fill(network, %{"COM" => 0}, ["COM"])
  def fill(_, distances, []), do: distances

  def fill(network, distances, [node | rest]) do
    dist_current_node = distances[node]

    surrounding_nodes = for n <- network[node], not Map.has_key?(distances, n), do: n

    new_distances =
      reduce(surrounding_nodes, distances, fn n, dist ->
        Map.put(dist, n, dist_current_node + 1)
      end)

    new_to_consider = rest ++ surrounding_nodes
    fill(network, new_distances, new_to_consider)
  end

  def part1(args) do
    args |> parse() |> build_network() |> fill() |> Map.values() |> sum()
  end

  def bidirect(entry), do: entry ++ for([from, to] <- entry, do: [to, from])

  def part2(args) do
    (args
     |> parse()
     |> bidirect()
     |> build_network()
     |> fill(%{"YOU" => 0}, ["YOU"])
     |> Map.get("SAN")) - 2
  end
end
