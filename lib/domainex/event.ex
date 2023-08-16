defmodule Domainex.Event do
  @moduledoc """
  Event described on this module is specified for domain's event.
  It provides a base event's structure and also a behaviour to handle
  all available events.
  """
  alias Domainex, as: BaseType
  alias Domainex.Common

  @error_invalid_event_type "invalid event type"

  @spec error_invalid_event_type() :: binary()
  def error_invalid_event_type, do: @error_invalid_event_type

  defmodule Structure do
    @moduledoc """
    Event.Structure used to grouping all necessary properties for the
    domain event, which including:

    - name
    - payload
    - timestamp

    By using this structure we can simplify our base type spec for event, it
    will become like this:

      ```elixir
        {:event, Event.Structure.t()}
      ```

    Compare with previous implementation

      ```elixir
        {:event, {event_name(), event_payload()}}
      ```

    It become more simpler
    """
    @enforce_keys [:name, :payload, :timestamp]
    defstruct [:name, :payload, :timestamp]

    @type t :: %__MODULE__{
      name: BaseType.event_name(),
      payload: BaseType.event_payload(),
      timestamp: DateTime.t()
    }
  end

  @doc """
  `new/2` used to generate new Event structure with given `name` and `payload`. The `payload` itself
  may be a `struct()` or `map()` depends on business logic needs.
  """
  @spec new(name :: BaseType.event_name(), payload :: BaseType.event_payload()) :: BaseType.event()
  def new(name, payload) when is_atom(name) and is_map(payload) or is_struct(payload) do
    event_payload = %Structure{
      name: name,
      payload: payload,
      timestamp: DateTime.utc_now()
    }

    {:event, event_payload}
  end

  @doc """
  `is_event?/1` used to check if given tuple is an event or not
  """
  @spec is_event?(given :: tuple()) :: boolean()
  def is_event?(given) when is_tuple(given), do: Common.is_tuple_has_context?(given, :event)
  def is_event?(_), do: false

  @doc """
  `payload/1` used to extract event's payload from given event's tuple
  """
  @spec payload(event :: BaseType.event()) :: BaseType.result()
  def payload(event) when is_tuple(event) do
    with  true <- is_event?(event),
          {:ok, structure} <- Common.extract_element_from_tuple(event, 1)
    do
      {:ok, structure.payload}
    else
      false -> {:error, {:event, @error_invalid_event_type}}
      {:error, {error_type, error_msg}} -> {:error, {error_type, error_msg}}
    end
  end
  def payload(_), do: {:error, {:event, @error_invalid_event_type}}

  @doc """
  `structure/1` used to extract base event's structure
  """
  @spec structure(event :: BaseType.event()) :: BaseType.result()
  def structure(event) when is_tuple(event) do
    with  true <- is_event?(event),
          {:ok, event} <- Common.extract_element_from_tuple(event, 1)
    do
      {:ok, event}
    else
      false -> {:error, {:event, @error_invalid_event_type}}
      {:error, {error_type, error_msg}} -> {:error, {error_type, error_msg}}
    end
  end
  def structure(_), do: {:error, {:event, @error_invalid_event_type}}
end
