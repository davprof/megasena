defmodule Megasena.Player do
  use GenServer

  def start_link({guesses, numbers}) do
    GenServer.start_link(__MODULE__, {guesses, numbers}, name: __MODULE__)
  end

  # Server (GenServer) Callbacks
  def init({guesses, numbers}) do
    # Ensure Megasena.Server is started
    server =
      case Megasena.Server.start_link(numbers) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    # Initialize state with server pid and other data
    {:ok, %{server: server, plays: 0, cost: 0, wins: 0, guesses: guesses, numbers: numbers, story: []}}
  end

  # Play a single round, calling the server with a guess and updating state
  def handle_call(
        {:play, guess},
        _from,
        state = %{server: server, plays: plays, wins: wins, guesses: _guesses, numbers: numbers, story: story}
      ) do
    correct_guesses = GenServer.call(server, {:play, guess})

    new_wins = if correct_guesses == numbers, do: wins + 1, else: wins

    response =
      "Você jogou #{inspect(guess, charlists: :as_lists)} acertou #{correct_guesses} números corretamente!"

    # IO.puts("numbers: #{numbers}")
    # IO.puts("wins: #{wins}")
    # IO.puts("new_wins: #{new_wins}")
    {:reply, response, %{state | plays: plays + 1, cost: (plays + 1) * 5, wins: new_wins, story: [response | story]}}
  end

  # Retrieve the current state
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # Public API to play a specified number of times with a generated guess
  def play(n) do
    %{guesses: guesses} = get_state()

    Enum.each(1..n, fn _ ->
      guess = 1..60 |> Enum.to_list() |> Enum.shuffle() |> Enum.take(guesses) |> Enum.sort()
      IO.inspect(GenServer.call(__MODULE__, {:play, guess}), label: "Play result")
    end)

    IO.inspect(get_state())
  end

  # Public API to get the current state
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Optional helper function to start the player and check the state
  def new(guesses, numbers) do
    {:ok, pid} = Megasena.Player.start_link({guesses, numbers})
    IO.inspect(Megasena.Player.get_state(), label: "Initial Player State")
    pid
  end
end
