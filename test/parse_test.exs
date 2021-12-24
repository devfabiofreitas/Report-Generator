defmodule ReportsGenerator.ParseTest do
  use ExUnit.Case
  alias ReportsGenerator.Parser

  describe "parse_file/1" do
    test "parses the file" do
      file_name = "report_test.csv"

      response =
        file_name
        |> Parser.parse_file()
        |> Enum.map(& &1)

      expected_response = response

      assert response == expected_response
    end
  end
end
