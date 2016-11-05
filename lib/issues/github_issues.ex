# iex -S mix
# Issues.GithubIssues.fetch("elixir-lang", "elixir")
defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    # { :ok, body }
    { :ok, Poison.Parser.parse!(body) }
  end
  def handle_response({_, %{body: body, status_code: ___}}) do
    # { :error, body }
    { :error, Poison.Parser.parse!(body) }
  end
  # def handle_response(%{status_code: 200, body: body}), do: { :ok, body }
  # def handle_response(%{status_code: ___, body: body}), do: { :error, body }
end
