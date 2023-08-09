defmodule Domainex.AggregateTest do
  use ExUnit.Case
  alias Domainex.Aggregate

  defmodule FakeEntityStruct do
    defstruct [:name]
  end

  test "new/1 with single entity" do
    fake_entity = %FakeEntityStruct{name: "fake_entity"}
    aggregate = Aggregate.new(fake_entity)
    assert aggregate.contains == fake_entity
    assert length(aggregate.events) == 0
  end

  test "new/1 with list of entities" do
    fake_entity_1 = %FakeEntityStruct{name: "fake_entity_1"}
    fake_entity_2 = %FakeEntityStruct{name: "fake_entity_2"}
    aggregate = Aggregate.new([fake_entity_1, fake_entity_2])
    assert length(aggregate.contains) == 2
    assert length(aggregate.events) == 0
  end

end
