# iex -S mix
# Issues.GithubIssues.fetch("elixir-lang", "elixir")
defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def handle_response({:ok, %{body: body, status_code: 200}}) do
    # { :ok, body }
    { :ok, Poison.Parser.parse!(body) }
  end
  def handle_response({_, %{body: body, status_code: ___}}) do
    # { :error, body }
    { :error, Poison.Parser.parse!(body) }
  end

  # use a module attribute to fetch the value at compile time
  @github_url Application.get_env(:issues, :github_url)

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  # def issues_url(user, project) do
  #   "https://api.github.com/repos/#{user}/#{project}/issues"
  # end
end
