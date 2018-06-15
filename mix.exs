defmodule TypeClass.Mixfile do
  use Mix.Project

  def project do
    [
      app: :type_class,
      name: "TypeClass",
      description: "(Semi-)principled type classes for Elixir",
      version: "1.2.4",
      elixir: "~> 1.4",
      package: [
        maintainers: ["Brooklyn Zelenka"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/expede/type_class"}
      ],
      source_url: "https://github.com/expede/type_class",
      homepage_url: "https://github.com/expede/type_class",
      aliases: [quality: ["credo --strict", "inch"]],
      preferred_cli_env: [espec: :test],
      deps: [
        {:exceptional, "~> 2.1"},
        {:credo, "~> 0.9", only: [:dev, :test]},
        {:dialyxir, "~> 0.5", only: :dev},
        {:earmark, "~> 1.2", only: :dev},
        {:ex_doc, "~> 0.18", only: :dev},
        {:inch_ex, "~> 0.5", only: [:dev, :test]}
      ],
      docs: [
        extras: ["README.md"],
        logo: "./brand/logo.png",
        main: "readme"
      ]
    ]
  end
end
