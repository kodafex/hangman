defmodule GallowsWeb.HangmanController do
  use GallowsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create_game(conn, _params) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    conn
    |> put_session("game", game)
    |> render("game_field.html", tally: tally)
  end
end
