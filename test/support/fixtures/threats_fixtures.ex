defmodule ThreatShield.ThreatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ThreatShield.Threats` context.
  """

  @doc """
  Generate a threat.
  """

  def threat_fixture(user, organisation, attrs \\ %{}) do
    default_attrs = %{
      description: "some description",
      organisation: "some organisation",
      is_candidate: false
    }

    all_attrs = Map.merge(default_attrs, attrs)

    {:ok, threat} = ThreatShield.Threats.create_threat(user, organisation, all_attrs)
    threat
  end
end
