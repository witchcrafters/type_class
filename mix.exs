defmodule TypeClass.Mixfile do
  use Mix.Project

  def project do
    [
      app: :type_class,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [espec: :test],

      # Versions
      version: "1.2.6",
      elixir: "~> 1.9",

      # Docs
      name: "TypeClass",
      docs: docs(),

      # Hex
      description: "(Semi-)principled type classes for Elixir",
      package: package()
    ]
  end

  defp aliases do
    [
      quality: ["credo --strict", "inch"]
    ]
  end

  defp deps do
    [
      {:exceptional, "~> 2.1"},
      {:credo, "~> 1.1.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: :dev},
      {:earmark, "~> 1.4.0", only: :dev},
      {:espec, "~> 1.7.0", only: :test},
      {:ex_doc, "~> 0.21.2", only: :dev},
      {:inch_ex, "~> 2.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      logo: "./brand/logo.png",
      main: "readme",
      source_url: "https://github.com/witchcrafters/type_class"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/witchcrafters/type_class"},
      maintainers: ["Brooklyn Zelenka", "Steven Vandevelde"],
      organization: "witchcrafters"
    ]
  end
end
