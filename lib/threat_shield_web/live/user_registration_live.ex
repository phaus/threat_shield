defmodule ThreatShieldWeb.UserRegistrationLive do
  use ThreatShieldWeb, :live_view

  alias ThreatShield.Accounts
  alias ThreatShield.Accounts.User

  @steps [
    :email,
    :password,
    :organisation
  ]

  defp is_hidden?(field, progress) do
    visible_steps =
      @steps
      |> Enum.reverse()
      |> Enum.drop_while(fn step -> step != progress end)

    field not in visible_steps
  end

  defp is_in_last_step?(progress) do
    progress == List.last(@steps)
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link
            navigate={~p"/users/log_in"}
            class="font-semibold text-primary_col-500 hover:underline"
          >
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <section class="chat-input">
          <.input
            field={@form[:email]}
            type="email"
            label="Please provide your mail address"
            required
          />
        </section>

        <section :if={not is_hidden?(:password, @progress)} class="chat-input">
          <.input field={@form[:password]} type="password" label="Please choose a password" required />
        </section>

        <section :if={not is_hidden?(:organisation, @progress)} class="chat-input">
          <.input field={@form[:organisation]} type="text" label="Please name your organisation" />
        </section>

        <:actions>
          <%= if is_in_last_step?(@progress) do %>
            <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    first_step = List.first(@steps)

    socket =
      socket
      |> assign(
        trigger_submit: false,
        check_errors: false,
        progress: first_step
      )
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    advance_progress(socket, changeset)

    if changeset.valid? do
      socket
      |> advance_progress(changeset)
      |> assign(form: form, check_errors: false)
    else
      socket
      |> advance_progress(changeset)
      |> assign(form: form)
    end
  end

  defp advance_progress(socket, changeset) do
    progress = socket.assigns.progress

    if !Keyword.has_key?(changeset.errors, progress) do
      advance_progress(socket)
    else
      socket
    end
  end

  defp advance_progress(socket) do
    current = socket.assigns.progress

    new =
      @steps
      |> Enum.reverse()
      |> Enum.take_while(fn s -> s != current end)
      |> List.last(List.last(@steps))

    assign(socket, progress: new)
  end
end
