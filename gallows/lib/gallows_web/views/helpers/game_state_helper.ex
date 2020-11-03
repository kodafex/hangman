defmodule Gallows.Views.Helpers.GameStateHelper do
  import Phoenix.HTML, only: [raw: 1]

  @responses %{
    :won              => {:success, "You Won!"},
    :lost             => {:danger, "You Lost!"},
    :good_guess       => {:success, "Good Guess!"},
    :bad_guess        => {:warning, "Bad Guess!"},
    :duplicated_guess => {:info, "You already guessed that"},
  }

  def game_state(state) do
    @responses[state]
    |> alert()
  end

  defp alert(nil) do
    ""
  end

  defp alert({class, message}) do
    """
    <div class="alert alert-#{class}">
      #{message}
    </div>
    """
    |> raw()
  end
end
