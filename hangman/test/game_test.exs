defmodule GameTest do
  use ExUnit.Case
  doctest Hangman.Game

  alias Hangman.Game

  test "new_game" do
    game = Game.new_game()
    assert game.game_state == :initializing
    assert game.turns_left == 10
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won or :lost" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert {^game, _} = game |> Game.make_move("a")
    end
  end

  test "state isn't changed for duplicate guess" do
    game = Game.new_game() |> Map.put(:guesses, MapSet.new(["x", "y", "z"]))
    {new_game, _} = game |> Game.make_move("x")
    assert new_game.game_state == :duplicated_guess
  end

  test "first occurence of letter not used" do
    game = Game.new_game()
    {new_game, _} = game |> Game.make_move("x")
    assert new_game.guesses |> MapSet.member?("x")
    assert new_game.game_state != :duplicated_guess
  end

  test "second occurence of letter used" do
    game = Game.new_game()
    {new_game, _} = game |> Game.make_move("x")
    assert new_game.guesses |> MapSet.member?("x")
    assert new_game.game_state != :duplicated_guess
    {new_game, _} = new_game |> Game.make_move("x")
    assert new_game.game_state == :duplicated_guess
  end

  test "good guess recognized" do
    {game, _} =   Game.new_game("wibble")
                  |> Game.make_move("w")
    assert game.game_state == :good_guess
    assert Enum.member?(game.guesses, "w")
  end

  test "guess word is :won" do
    game =   Game.new_game("win")
    {game, _} = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    {game, _} = Game.make_move(game, "i")
    assert game.game_state == :good_guess
    {game, _} = Game.make_move(game, "n")
    assert game.game_state == :won
  end

  test "bad guess" do
    game =  Game.new_game("win")
            |> Map.put(:turns_left, 2)
    {game, _} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 1
    {game, _} = Game.make_move(game, "y")
    assert game.game_state == :lost
  end
end
