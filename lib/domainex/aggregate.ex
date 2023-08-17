defmodule Domainex.Aggregate do
  @moduledoc """
  Aggregate is a module provide base Aggregate module functions.
  It provide base structure for the aggregate. An aggregate itself
  means, a cluster of objects that treat as a single unit of domain business
  logic, although it's possible too to contain only a single object.

  This module should not provide any functions that possible to limiting
  scope of some domain business, or it should be designed to be generic,
  and only provide some helpers
  """
  alias Domainex, as: BaseType
  alias Domainex.Common, as: Common

  @error_invalid_aggregate_type "given data is not aggregate type"
  @error_invalid_data_type "unknown given data type"

  @spec error_invalid_aggregate_type() :: binary()
  def error_invalid_aggregate_type, do: @error_invalid_aggregate_type

  @spec error_invalid_data_type() :: binary()
  def error_invalid_data_type, do: @error_invalid_data_type

  defmodule Structure do
    @moduledoc """
    An aggregate objects may using this structure as their
    base data structure, although the function implementation it
    will always depends to some specific requirements and logics.

    This structure provides only four possible keys, which are:
    - :name
    - :contains
    - :events
    - :processors

    An aggregate may contains a single entity object or a group of entities.
    An aggregate also should responsible to emit an event for each domain activities

    Specific for `:processor`, it must be a module which implement behaviour `Event.Processor`
    """
    @enforce_keys [:name, :contains, :events, :processors]
    defstruct [:name, :contains, :events, :processors]

    @type t :: %__MODULE__{
      name: BaseType.aggregate_name(),
      contains: BaseType.aggregate_payload() | %{atom() => BaseType.aggregate_payload()},
      events: list(BaseType.event()),
      processors: list(module())
    }
  end

  @doc """
  A `new/2` has two possibilities depends on given parameter.
  If it give a single entity which is a `struct()` it will generate a
  `BaseType.aggregate()` that contains a main aggregate object with single entity,
  or people common said as aggregate root.

  If it give a list of entities, it will generate a `BaseType.aggregate()` that
  contains a list of entities.

  All generated structure will always generated with an empty `:events`
  """
  @spec new(name :: BaseType.aggregate_name(), entity :: BaseType.aggregate_payload(), processors :: list(module())) :: BaseType.aggregate()
  def new(name, entity, processors) when is_struct(entity) and is_atom(name) or is_binary(name) and is_list(processors) do
    aggregate = %Structure{
      name: name,
      contains: entity,
      events: [],
      processors: processors
    }

    {:aggregate, aggregate}
  end

  @spec new(name :: BaseType.aggregate_name(), entities :: %{atom() => BaseType.aggregate_payload()}, processors :: list(module())) :: BaseType.aggregate()
  def new(name, entities, processors) when is_map(entities) and is_atom(name) or is_binary(name) and is_list(processors) do
    aggregate = %Structure{
      name: name,
      contains: entities,
      events: [],
      processors: processors
    }

    {:aggregate, aggregate}
  end

  @doc """
  `is_aggregate?/1` used to check if given tuple is an `:aggregate` or not. For any types
  which not a tuple, it will return false
  """
  @spec is_aggregate?(given :: BaseType.aggregate()) :: boolean()
  def is_aggregate?(given) when is_tuple(given), do: Common.is_tuple_has_context?(given, :aggregate)
  def is_aggregate?(_), do: false

  @doc """
  `aggregate/1` used to extract a main aggregate data structure from the tuple of:

  ```elixir
    # used to extract structure
    {:aggregate, {name, structure}}
  ```

  It will return an error of `:aggregate` if given parameter is not tuple
  """
  @spec aggregate(data :: BaseType.aggregate()) :: BaseType.result()
  def aggregate(data) when is_tuple(data) do
    with true <- is_aggregate?(data),
         {:ok, aggregate} <- Common.extract_element_from_tuple(data, 1)
    do
      {:ok, aggregate}
    else
      false -> {:error, {:aggregate, @error_invalid_aggregate_type}}
      {:error, {error_type, error_message}} -> {:error, {error_type, error_message}}
    end
  end
  def aggregate(_), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `entity/1` used to load current aggregate's `:contains` property, which expected result
  is a single entity.
  """
  @spec entity(data :: BaseType.aggregate()) :: BaseType.result()
  def entity(data) when is_tuple(data) do
    case data |> aggregate do
      {:ok, aggregate} ->
        {:ok, aggregate.contains}
      error ->
        error
    end
  end
  def entity(_), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `entities/1` used to load multiple entities. It just using `entity/1` under the hood.
  If your current aggregate contains multiple entities, then it will all of that entities
  in `map()` format.
  """
  @spec entities(data :: BaseType.aggregate()) :: BaseType.result()
  def entities(data) when is_tuple(data) do
    data |> entity
  end
  def entities(_), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `update_entity/2` used to update internal aggregate's entity. This function used
  only for an aggregate with a single entity.

  Usage:

    ```elixir
      aggregate2 = aggregate |> Aggregate.update_entity(fake_entity_updated)
    ```
  """
  @spec update_entity(data :: BaseType.aggregate(), entity :: struct()) :: BaseType.result()
  def update_entity(data, entity) when is_tuple(data) and is_struct(entity) do
    with true <- is_aggregate?(data),
         {:ok, aggregate} <- Common.extract_element_from_tuple(data, 1)
    do
      {:ok, {:aggregate, %{aggregate | contains: entity}}}
    else
      false -> {:error, {:aggregate, "given data is not aggregate type"}}
      {:error, {error_type, error_msg}} -> {:error, {error_type, error_msg}}
    end
  end
  def update_entity(_, _), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `update_entity/3` used to update one of available entities. This function used for an aggregate
  with multiple entities.

  Usage:

    ```elixir
      {:ok, aggregate2} = aggregate |> Aggregate.update_entity(:fake1, fake_entity_1_updated)
    ```

  The `update_entity/3` need a `key` to update some entity, since an aggregate that contains multiple
  entities will be mapped based on some unique key
  """
  @spec update_entity(data :: BaseType.aggregate(), key :: atom() , entity :: struct()) :: BaseType.result()
  def update_entity(data, key, entity) when is_tuple(data) and is_atom(key) and is_struct(entity) do
    with true <- is_aggregate?(data),
         {:ok, aggregate} <- Common.extract_element_from_tuple(data, 1)
    do
      {:ok, {:aggregate, %{aggregate | contains: Map.put(aggregate.contains, key, entity)}}}
    else
      false -> {:error, {:aggregate, "given data is not aggregate type"}}
      {:error, {error_type, error_msg}} -> {:error, {error_type, error_msg}}
    end
  end
  def update_entity(_, _, _), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `add_event/2` used to adding an event to current available events in some aggregate
  """
  @spec add_event(data :: BaseType.aggregate(), event :: BaseType.event()) :: BaseType.result()
  def add_event(data, event) when is_tuple(data) and is_tuple(event) do
    case data |> aggregate do
      {:ok, agg} ->
        {:ok, {:aggregate, %{agg | events: agg.events ++ [event]}}}
      {:error, {error_type, error_msg}} ->
        {:error, {error_type, error_msg}}
    end
  end
  def add_event(_, _), do: {:error, {:aggregate, @error_invalid_data_type}}

  @doc """
  `emit_events/1` used to emit all current available events from an aggregate. All of available
  event will send to all registered processors, and after emitting events, we need to reset current
  events to empty list.
  """
  @spec emit_events(data :: BaseType.aggregate()) :: BaseType.result()
  def emit_events(data) when is_tuple(data) do
    case data |> aggregate() do
      {:ok, agg} ->
        Enum.map(agg.processors, fn processor -> agg.events |> processor.process end)
        data |> reset_events
      {:error, {error_type, error_msg}} ->
        {:error, {error_type, error_msg}}
    end
  end
  def emit_events(_), do: {:error, {:aggregate, @error_invalid_data_type}}

  defp reset_events(data) when is_tuple(data) do
    case data |> aggregate do
      {:ok, agg} ->
        {:ok, {:aggregate, %{agg | events: []}}}
      {:error, {error_type, error_msg}} ->
        {:error, {error_type, error_msg}}
    end
  end
end
