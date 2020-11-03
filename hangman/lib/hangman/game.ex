defmodule Hangman.Game do

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters:    [],
    word_length: 0,
    guesses:    MapSet.new(),
  )

  def new_game() do
    new_game(Dictionary.random_word())
  end

  def new_game(word) do
    %Hangman.Game{
      letters: word |> String.codepoints,
      word_length: String.length(word),
    }
  end

  def make_move(game = %{ game_state: state }, _guess) when state in [:won, :lost] do
    {game, tally(game) }
  end

  def make_move(game, guess) do
    game = accept_move(game, guess, MapSet.member?(game.guesses, guess))
    {game, tally(game)}
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      word: game.letters |> Enum.join(" "),
      letters: game.letters |> reveal_guessed(game.guesses),
      word_length: game.word_length,
      guesses: MapSet.to_list(game.guesses),
    }
  end




  defp accept_move(game, _guess, _duplicate_guess = true) do
    Map.put(game, :game_state, :duplicated_guess)
  end

  defp accept_move(game, guess, _duplicate_guess = false) do
    Map.put(game, :guesses, MapSet.put(game.guesses, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
                |> MapSet.subset?(game.guesses)
                |> maybe_won()
    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    Map.put(game, :game_state, :lost)
  end

  defp score_guess(game = %{turns_left: turns_left}, _bad_guess) do
    %{game |
      game_state: :bad_guess,
      turns_left: turns_left - 1}
  end

  defp reveal_guessed(letters, guesses) do
    letters
    |> Enum.map(fn l -> reveal_letter(l, MapSet.member?(guesses, l)) end)
  end

  defp reveal_letter(letter, _match = true), do: letter
  defp reveal_letter(_letter, _no_match),    do: "_"

  defp maybe_won(true),  do: :won
  defp maybe_won(_),     do: :good_guess
end
