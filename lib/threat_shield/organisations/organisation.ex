defmodule ThreatShield.Organisations.Organisation do
  use Ecto.Schema
  import Ecto.Changeset

  alias ThreatShield.Systems.System

  schema "organisations" do
    field :name, :string
    field :location, :string
    field :attributes, :map

    many_to_many :users, ThreatShield.Accounts.User, join_through: "memberships"
    has_many :systems, ThreatShield.Systems.System
    has_many :threats, ThreatShield.Threats.Threat
    has_many :assets, ThreatShield.Assets.Asset

    timestamps()
  end

  @doc false
  def changeset(organisation, attrs) do
    organisation
    |> cast(attrs, [
      :name,
      :location,
      :attributes
    ])
    |> validate_required([:name])
  end

  def attribute_keys() do
    [
      "Industry",
      "Legal Form",
      "Type of Business",
      "Size",
      "Financial Information"
    ]
  end

  def list_system_options(%__MODULE__{systems: systems}) do
    [{"None", nil} | Enum.map(systems, fn s -> {s.name, s.id} end)]
  end

  def describe(%__MODULE__{name: name, attributes: attributes, systems: systems}) do
    attribute_description =
      "It has the following attributes:\n" <>
        (attributes
         |> Enum.filter(fn {_, val} -> val != "" end)
         |> Enum.map_join("\n", fn {key, val} -> ~s{"#{key}: ", "#{val}"} end))

    system_description =
      "It has the following systems:\n" <>
        (systems
         |> Enum.map(fn sys -> System.describe(sys) end)
         |> Enum.join("\n"))

    "The name of my organisation is #{name}." <> attribute_description <> system_description
  end

  import Ecto.Query

  def get(id) do
    from(e in __MODULE__, as: :organisation, where: e.id == ^id)
  end

  def for_user(query, user_id) do
    query
    |> join(:inner, [organisation: o], assoc(o, :users), as: :user)
    |> where([user: u], u.id == ^user_id)
  end

  def with_threats(query) do
    query
    |> join(:left, [organisation: o], assoc(o, :threats), as: :threats)
    |> preload([threats: t], threats: t)
  end
end
