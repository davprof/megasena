defmodule Megasena.Supervisor do
  use Supervisor

  # Accept numbers and guesses as arguments
  def start_link({numbers, guesses}) do
    Supervisor.start_link(__MODULE__, {numbers, guesses}, name: __MODULE__)
  end

  def init({numbers, guesses}) do
    children = [
      # Pass numbers to Megasena.Server
      {Megasena.Server, numbers},
      # # Pass guesses and numbers to Megasena.Player
      {Megasena.Player, {guesses, numbers}}
    ]

    # Supervisor with :one_for_one strategy
    Supervisor.init(children, strategy: :one_for_one)
  end
end
