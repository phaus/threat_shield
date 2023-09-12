defmodule ThreatShieldWeb.ThreatLive.ThreatComponent do
  use ThreatShieldWeb, :live_component

  import ThreatShield.Threats.Threat,
    only: [system_name: 1]

  @impl true
  def render(assigns) do
    ~H"""
    <div class="threats">
    <.table
      id="threats"
      rows={@threats}
      row_click={
        fn threat -> JS.navigate(~p"/organisations/#{@organisation.id}/threats/#{threat.id}") end
        }
    >
      <:col :let={threat} label="Description"><%= threat.description %></:col>
      <:col :if={!assigns[:hide_system]} :let={threat} label="System"><%= system_name(threat) %></:col>
    </.table>
    </div>
    """
  end
end