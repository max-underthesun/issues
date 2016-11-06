# mix run -e 'Issues.CLI.run(["-h"])'
# mix run -e 'Issues.CLI.run(["elixir-lang", "elixir"])'

# iex -S mix
# Issues.CLI.run(["elixir-lang", "elixir"])
defmodule Issues.CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a 
  table of the last _n_ issues in a github project
  """

  import Issues.TableFormatter, only: [ print_table_for_columns: 2 ]

  @default_count 4

  def run(argv) do
    argv 
      |> parse_args 
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do
      { [ help: true ], _, _ } -> :help
      { _, [ user, project, count ], _ } -> { user, project, String.to_integer(count) }
      { _, [ user, project ], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage:  issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    # { :ok, body } = Issues.GithubIssues.fetch(user, project)
    # Enum.each(body, &(IO.inspect(&1)))
    # IO.puts body
    Issues.GithubIssues.fetch(user, project)
      |> decode_response
      |> sort_into_ascending_order
      |> Enum.take(count)
      |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    IO.puts "Error fetching from Github: #{error["message"]}"
    System.halt(2)
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues, &(&1["created_at"] <= &2["created_at"])
              # fn i1, i2 -> Map.get(i1, "created_at") <= Map.get(i2, "created_at") end
              # fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
  end
end
