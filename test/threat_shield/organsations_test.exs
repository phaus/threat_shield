defmodule ThreatShield.OrgansationsTest do
  use ThreatShield.DataCase

  alias ThreatShield.Organsations

  describe "organisations" do
    alias ThreatShield.Organsations.Organisation

    import ThreatShield.OrgansationsFixtures

    @invalid_attrs %{name: nil}

    test "list_organisations/0 returns all organisations" do
      organisation = organisation_fixture()
      assert Organsations.list_organisations() == [organisation]
    end

    test "get_organisation!/1 returns the organisation with given id" do
      organisation = organisation_fixture()
      assert Organsations.get_organisation!(organisation.id) == organisation
    end

    test "create_organisation/1 with valid data creates a organisation" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Organisation{} = organisation} = Organsations.create_organisation(valid_attrs)
      assert organisation.name == "some name"
    end

    test "create_organisation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organsations.create_organisation(@invalid_attrs)
    end

    test "update_organisation/2 with valid data updates the organisation" do
      organisation = organisation_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organisation{} = organisation} = Organsations.update_organisation(organisation, update_attrs)
      assert organisation.name == "some updated name"
    end

    test "update_organisation/2 with invalid data returns error changeset" do
      organisation = organisation_fixture()
      assert {:error, %Ecto.Changeset{}} = Organsations.update_organisation(organisation, @invalid_attrs)
      assert organisation == Organsations.get_organisation!(organisation.id)
    end

    test "delete_organisation/1 deletes the organisation" do
      organisation = organisation_fixture()
      assert {:ok, %Organisation{}} = Organsations.delete_organisation(organisation)
      assert_raise Ecto.NoResultsError, fn -> Organsations.get_organisation!(organisation.id) end
    end

    test "change_organisation/1 returns a organisation changeset" do
      organisation = organisation_fixture()
      assert %Ecto.Changeset{} = Organsations.change_organisation(organisation)
    end
  end
end