defmodule PrimerLive.Options.FormGroup.Classes do
  use Options

  @moduledoc false

  @doc """
  Options for `classes` in `PrimerLive.Options.FormGroup`.

  | **Classname** | **Description**     |
  | ------------- | ------------------- |
  | `form_group`  | Form group element. |
  | `header`      | Geader element.     |
  | `body`        | Body element.       |
  | `note`        | Note element.       |
  """

  typed_embedded_schema do
    field(:form_group, :string)
    field(:header, :string)
    field(:body, :string)
    field(:note, :string)
  end

  @impl Options
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:form_group, :header, :body, :note])
  end
end

defmodule PrimerLive.Options.ValidationData do
  use Options

  typed_embedded_schema do
    field(:is_error, :boolean, enforce: true)
    field(:has_message, :boolean, enforce: true)
    field(:message, :string, enforce: true)
    field(:validation_message_id, :string, enforce: true)
  end

  @impl Options
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :is_error,
      :has_message,
      :message,
      :validation_message_id
    ])
    |> validate_required([:is_error, :has_message, :message, :validation_message_id])
  end
end

defmodule PrimerLive.Options.FormGroup do
  use Options

  alias PrimerLive.Options.FormGroup.Classes
  alias PrimerLive.Options.ValidationData

  @moduledoc false

  @doc """
  Options for `form_group` in `PrimerLive.Options.TextInput`.

  | **Name**   | **Type** | **Validation** | **Default** | **Description**                                                                                                                                           |
  | ---------- | -------- | -------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `class`    | `string` | -              | -           | Additional classname.                                                                                                                                     |
  | `classes`  | `map`    | -              | -           | Map of classnames. Any provided value will be appended to the default classnames. See `PrimerLive.Options.FormGroup.Classes`.                             |
  | `header`   | `slot`   | -              | -           | Header text.                                                                                                                                              |

  ## Internal

  Internal options that are passed from input component to `form_group`.

  | **Name**            | **Type**                            | **Validation** | **Default** | **Description**                                                                                                                                                                                                                                                        |
  | ------------------- | ----------------------------------- | -------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `inner_block`       | `slot`                              | required       | -           | Form group content, usually a form input.                                                                                                                                                                                                                              |
  | `field`             | `atom` or `string`                  | required       | -           | Field name.                                                                                                                                                                                                                                                            |
  | `form`              | `Phoenix.HTML.Form` or `atom`       | required       | -           | Either a [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html) or an atom.                                                                                                                                                                       |
  | `validation_data`   | `PrimerLive.Options.ValidationData` | -              | -           | Only when a form changeset is available. The status is derived from the value of `changeset.valid?`. The message text is received from `PrimerLive.Options.TextInput` option `get_validation_message`, otherwise from the first of the form changeset errors (if any). |
  """

  typed_embedded_schema do
    # Slots
    field(:inner_block, :any, virtual: true, enforce: true, null: false)
    field(:header, :any, virtual: true, enforce: true, null: false)
    # Required options
    field(:field, :any, virtual: true, enforce: true, null: false)
    field(:form, :any, virtual: true, enforce: true, null: false)
    # Optional options
    field(:class, :string)
    # Embedded options
    embeds_one(:classes, Classes)
    embeds_one(:validation_data, ValidationData)
  end

  @impl Options
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :class,
      :field,
      :form,
      :header,
      :inner_block
    ])
    |> cast_embed_with_defaults(attrs, :classes, %{})
    |> cast_embed_with_defaults(attrs, :validation_data, %{
      is_error: false,
      has_message: false,
      message: nil,
      validation_message_id: nil
    })
    |> validate_required([:inner_block, :field, :form])
    |> validate_validation_status(attrs)
  end

  defp validate_validation_status(changeset, _) do
    changeset
  end
end

defmodule PrimerLive.Options.Form do
  import Ecto.Changeset

  @moduledoc false

  alias PrimerLive.Helpers
  alias PrimerLive.Options.FormGroup

  @doc """
  Conditionally embeds a value for form_group.
  - If form_group is a boolean: embed a default map with `form` and `field`
  - if form_group is a map: merge it with the default values containing `form` and `field`
  - Otherwise return the changeset unchanged
  """
  def cast_form_group(changeset, attrs) do
    value = attrs[:form_group]

    defaults = %FormGroup{
      form: attrs[:form],
      field: attrs[:field],
      header: nil,
      inner_block: nil
    }

    cond do
      value == true ->
        changeset
        |> put_embed(:form_group, defaults)

      is_map(value) ->
        changeset
        |> put_embed(:form_group, Map.merge(defaults, value))

      true ->
        changeset
    end
  end

  @doc """
  Validates attribute `form`.
  Allowed values:
  - nil
  - atom
  - Phoenix.HTML.Form
  """
  def validate_is_form(changeset, attrs) do
    changeset
    |> Helpers.SchemaHelpers.validate_cond(
      attrs,
      :form,
      fn value ->
        cond do
          is_nil(value) -> true
          is_atom(value) -> true
          Helpers.SchemaHelpers.is_phoenix_form(value) -> true
          true -> false
        end
      end,
      "invalid type"
    )
  end

  @doc """
  Option is_short may only be used with form_group.
  Allowed values:
  - nil
  - boolean: only when form_group exists in attrs
  """
  def validate_is_short(changeset, attrs) do
    changeset
    |> Helpers.SchemaHelpers.validate_cond(
      attrs,
      :is_short,
      fn value ->
        cond do
          is_nil(value) -> true
          is_boolean(value) -> !!attrs[:form_group]
          true -> false
        end
      end,
      "must be used with form_group"
    )
  end
end

defmodule PrimerLive.Options.TextInput do
  use Options

  alias PrimerLive.Options.FormGroup

  @moduledoc false

  # Map of input name to atom value that can be used by Phoenix.HTML.Form to render the appropriate input element.
  @input_types %{
    "color" => :color_input,
    "date" => :date_input,
    "datetime-local" => :datetime_local_input,
    "email" => :email_input,
    "file" => :file_input,
    "hidden" => :hidden_input,
    "number" => :number_input,
    "password" => :password_input,
    "range" => :range_input,
    "search" => :search_input,
    "telephone" => :telephone_input,
    "text" => :text_input,
    "textarea" => :textarea,
    "time" => :time_input,
    "url" => :url_input
  }

  typed_embedded_schema do
    field(:class, :string)
    field(:field, :any, virtual: true)
    field(:form, :any, virtual: true)
    field(:get_validation_message, :any, virtual: true)
    field(:is_contrast, :boolean, default: false)
    field(:is_full_width, :boolean, default: false)
    field(:is_hide_webkit_autofill, :boolean, default: false)
    field(:is_large, :boolean, default: false)
    field(:is_small, :boolean, default: false)
    field(:is_short, :boolean, default: false)
    field(:type, :string, default: "text")
    # Embedded options
    embeds_one(:form_group, FormGroup)
  end

  @impl Options
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :class,
      :field,
      :form,
      :get_validation_message,
      :is_contrast,
      :is_full_width,
      :is_hide_webkit_autofill,
      :is_large,
      :is_small,
      :is_short,
      :type
    ])
    |> PrimerLive.Options.Form.cast_form_group(attrs)
    |> validate_inclusion(:type, Map.keys(@input_types))
    |> PrimerLive.Options.Form.validate_is_form(attrs)
    |> PrimerLive.Options.Form.validate_is_short(attrs)
  end

  @doc false
  # Get the input type atom from a name, e.g. "search" returns :search_input
  def input_type(type_name) do
    input_type = Map.get(@input_types, type_name)

    if is_nil(input_type), do: :text_input, else: input_type
  end
end
