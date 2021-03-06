defmodule BloggerdayWeb.UserRegistrationController do
  use BloggerdayWeb, :controller

  alias Bloggerday.Accounts
  alias Bloggerday.Accounts.User
  alias BloggerdayWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> put_flash(:info, "Ein Verifizierungslink wurde per E-Mail an #{user.email} geschickt.")
        # |> UserAuth.log_in_user(user)
        |> UserAuth.log_out_user()

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
