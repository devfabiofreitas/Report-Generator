defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @available_foods [
    "açaí",
    "pizza",
    "pastel",
    "esfirra",
    "hambúrguer",
    "prato_feito",
    "sushi",
    "churrasco"
  ]

  @options ["users", "foods"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build_from_many() do
    {
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
    }

    def fetch_hiper_cost(report, option) when option in @options do
      {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}
    end

    def fetch_hiper_cost(report, option), do: {:error, "invalid option"}

    defp sum_values([id, food_name, price], %{"users" => users, "foods" => foods} = report) do
      users = Map.put(users, id, users[id] + price)
      foods = Map.put(foods, food_name, foods[food_name] + 1)

      %{report | "users" => users, "foods" => foods}
    end

    defp report_acc do
      foods = Enum.into(@available_foods, %{}, &{&1, 0})
      users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})

      %{"users" => users, "foods" => foods}
    end

    defp sum_reports(%{"foods" => foods1, "users" => users2}, %{
           "foods" => foods2,
           "users" => users2
         }) do
      foods = merge_maps(foods1, foods2)
      users = merge_maps(users1, users2)
      %{"users" => users, "foods" => foods}
    end

    defp merge_maps(map1, map2) do
      Map.merge(map1, map2, fn key, value1, value2 -> value1(+value2) end)
    end
  end
end
