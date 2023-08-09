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

  defmodule Structure do
    @moduledoc """
    An aggregate objects may using this structure as their
    base data structure, although the function implementation it
    will always depends to some specific requirements and logics.

    This structure provides only two possible keys, which are:
    - :contains
    - :events

    An aggregate may contains a single entity object or a group of entities.
    An aggregate also should responsible to emit an event for each domain activities
    """
    @enforce_keys [:contains, :events]
    defstruct [:contains, :events]

    @type t :: %__MODULE__{
      contains: struct() | list(struct()),
      events: list(BaseType.event())
    }
  end

  @doc """
  A `new/1` has two possibilities depends on given parameter.
  If it give a single entity which is a `struct()` it will generate a
  `Structure.t()` that contains a single entity.

  If it give a list of entities, it will generate a `Structure.t()` that
  contains a list of entities.

  All generated structure will always generated with an empty `:events`
  """
  @spec new(entity :: struct()) :: Structure.t()
  def new(entity) when is_struct(entity) do
    %Structure{
      contains: entity,
      events: []
    }
  end

  @spec new(entities :: list(struct())) :: Structure.t()
  def new(entities) when is_list(entities) do
    %Structure{
      contains: entities,
      events: []
    }
  end
end
