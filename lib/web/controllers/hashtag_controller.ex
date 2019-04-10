defmodule Web.HashtagController do
  use Web, :controller

  alias Parteibot.Hashtag

  def index(conn, _params) do
    hashtags = Repo.all(Hashtag)
    render(conn, "index.html", hashtags: hashtags)
  end

  def create(conn, %{"hashtag" => hashtag_params}) do
    changeset = Hashtag.changeset(%Hashtag{}, hashtag_params)

    case Repo.insert(changeset) do
      {:ok, hashtag} ->
        conn
        |> put_flash(:info, "Hashtag created successfully.")
        |> redirect(to: twitter_account_path(conn, :show, hashtag.twitter_account_id))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hashtag =
      Repo.get!(Hashtag, id)
      |> Repo.preload([:twitter_account])
      |> Repo.preload([:reply_messages])

    reply_message_changeset = Parteibot.ReplyMessage.changeset(%Parteibot.ReplyMessage{})
    render(conn, "show.html", hashtag: hashtag, reply_message_changeset: reply_message_changeset)
  end

  def edit(conn, %{"id" => id}) do
    hashtag = Repo.get!(Hashtag, id)
    changeset = Hashtag.changeset(hashtag)
    render(conn, "edit.html", hashtag: hashtag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "hashtag" => hashtag_params}) do
    hashtag = Repo.get!(Hashtag, id)
    changeset = Hashtag.changeset(hashtag, hashtag_params)

    case Repo.update(changeset) do
      {:ok, hashtag} ->
        conn
        |> put_flash(:info, "Hashtag updated successfully.")
        |> redirect(to: hashtag_path(conn, :show, hashtag))

      {:error, changeset} ->
        render(conn, "edit.html", hashtag: hashtag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hashtag = Repo.get!(Hashtag, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(hashtag)

    conn
    |> put_flash(:info, "Hashtag deleted successfully.")
    |> redirect(to: hashtag_path(conn, :index))
  end
end
