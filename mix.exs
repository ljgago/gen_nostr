defmodule GenNostr.MixProject do
  use Mix.Project

  @source_url "https://github.com/ljgago/gen_nostr"

  def project do
    [
      # Library
      app: :gen_nostr,
      version: "0.1.0",

      # Elixir
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "GenNostr",
      package: package(),
      description: description(),
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mint_web_socket, "~> 1.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      # docs
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: "gen_nostr",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp description() do
    "A low level Nostr client"
  end
end
