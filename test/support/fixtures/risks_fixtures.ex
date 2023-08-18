defmodule ThreatShield.RisksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ThreatShield.Risks` context.
  """

  @doc """
  Generate a risk.
  """
  def risk_fixture(attrs \\ %{}) do
    {:ok, risk} =
      attrs
      |> Enum.into(%{
        name: "some name",
        description: "some description",
        estimated_cost: 42,
        probability: 120.5
      })
      |> ThreatShield.Risks.create_risk()

    risk
  end
end
