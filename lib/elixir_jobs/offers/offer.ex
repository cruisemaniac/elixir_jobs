defmodule ElixirJobs.Offers.Offer do
  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirJobs.{
    Offers.Offer,
    EctoEnums.JobPlace,
    EctoEnums.JobType
  }


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "offers" do
    field :title, :string
    field :company, :string
    field :description, :string
    field :location, :string
    field :url, :string
    field :slug, :string

    field :job_place, JobPlace
    field :job_type, JobType

    field :published_at, :naive_datetime

    timestamps()
  end

  @required_attrs [:title, :company, :description, :location, :url, :job_place, :job_type]
  @optional_attrs [:published_at, :slug]
  @attributes @required_attrs ++ @optional_attrs

  @doc false
  def changeset(%Offer{} = offer, attrs) do
    offer
    |> cast(attrs, @attributes)
    |> validate_required(@required_attrs)
    |> validate_length(:title, min: 5, max: 50)
    |> validate_length(:company, min: 2, max: 30)
    |> validate_length(:description, min: 10, max: 500)
    |> validate_length(:location, min: 3, max: 50)
    |> validate_length(:url, min: 1, max: 255)
    |> validate_format(:url, ~r/^\b((https?:\/\/?)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))$/)
    |> validate_inclusion(:job_place, JobPlace.__valid_values__())
    |> validate_inclusion(:job_type, JobType.__valid_values__())
    |> unique_constraint(:slug)
    |> generate_slug()
  end

  defp generate_slug(changeset) do
    case get_field(changeset, :slug) do
      nil -> put_change(changeset, :slug, do_generate_slug(changeset))
      _ -> changeset
    end
  end

  defp do_generate_slug(changeset) do
    uid =
      Ecto.UUID.generate()
      |> to_string()
      |> String.split("-")
      |> List.first

    title =
      changeset
      |> get_field(:title)
      |> Slugger.slugify_downcase()
    company =
      changeset
      |> get_field(:company)
      |> Slugger.slugify_downcase()

    "#{company}-#{title}-#{uid}"
  end
end
