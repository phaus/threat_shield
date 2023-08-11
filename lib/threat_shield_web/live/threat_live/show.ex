defmodule ThreatShieldWeb.ThreatLive.Show do
  use ThreatShieldWeb, :live_view

  alias ThreatShield.Threats

  @impl true
  def mount(%{"org_id" => org_id, "sys_id" => sys_id}, _session, socket) do
    current_user = socket.assigns.current_user
    system = Threats.get_system_with_threats(current_user, org_id, sys_id)
    threats = system.threats

    socket =
      socket
      |> assign(:organisation, system.organisation)
      |> assign(:system, system)

    {:ok, stream(socket, :threats, threats)}
  end

  @impl true
  def handle_params(%{"threat_id" => id}, _, socket) do
    user = socket.assigns.current_user

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:threat, Threats.get_threat!(user, id))}
  end

  defp page_title(:show), do: "Show Threat"
  defp page_title(:edit), do: "Edit Threat"
end