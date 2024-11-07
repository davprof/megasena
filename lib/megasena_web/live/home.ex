defmodule MegasenaWeb.HomeLive do
  use MegasenaWeb, :live_view

  def mount(_params, _session, socket) do
    server_numbers = Megasena.Server.get_numbers()

    dbg(server_numbers)

    {:ok,
      socket
      |> assign(:server_numbers, server_numbers)
      |> assign(:state, nil)
      |> assign(:tries, 10)
    }
  end

  def render(assigns) do
    formatted_numbers = Enum.join(assigns.server_numbers, ", ")

    ~H"""
    <div>
      <h1>Megasena!</h1>
      <h2>Faça sua aposta</h2>
      <.form phx-change="update_tries">
        <label for="tries">Quantos tickets de 10 números você vai tentar apostar? (5 R$)</label>
        <input
          type="number"
          name="tries"
          id="tries"
          min="1"
          value={@tries}
        />
      </.form>
      <p>Números prêmiados: <%= formatted_numbers %></p>
      <.button phx-click="bet">Apostar!</.button>
      <%= if @state do %>
        <p>Vitórias: <%= @state.wins %></p>
        <p>Jogos: <%= @state.plays %></p>
        <p>Custo (R$): <%= @state.cost %></p>
        <div style="max-height: 300px; overflow-y: auto;">
          <%= for entry <- @state.story do %>
            <p><%= entry %></p>
          <% end %>
        </div>
      <% end %>

    </div>
    """
  end

  def handle_event("update_tries", %{"tries" => tries}, socket) do
    {:noreply, assign(socket, :tries, String.to_integer(tries))}
  end

  def handle_event("bet", _value, socket) do
    state = Megasena.Player.play(socket.assigns.tries)

    {:noreply, assign(socket, :state, state)}
  end
end
