defmodule Domainex.AggregateTest do
  use ExUnit.Case

  alias Domainex.Aggregate
  alias Domainex.Event
  alias Domainex.Common

  require Logger


  defmodule FakeEntityStruct do
    defstruct [:name]
  end

  defmodule FakeEventProcessor do
    @behaviour Event.Processor

    def process(events) when is_list(events) do
      Logger.info([events: events])
    end
  end

  describe "new/1" do
    test "with single entity" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])

      assert is_tuple(aggregate)
      assert elem(aggregate, 0) == :aggregate
      assert elem(aggregate, 1).name == :fake_entity
      assert is_struct(elem(aggregate, 1))

      agg_object = elem(aggregate, 1)
      assert agg_object.contains == fake_entity
    end

    test "with map of entities" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity_1"}
      fake_entity_2 = %FakeEntityStruct{name: "fake_entity_2"}
      aggregate = Aggregate.new(:fake_agg, %{:fake1 => fake_entity_1, :fake2 => fake_entity_2}, [FakeEventProcessor])

      assert is_tuple(aggregate)
      assert elem(aggregate, 0) == :aggregate
      assert elem(aggregate, 1).name == :fake_agg
      assert is_struct(elem(aggregate, 1))

      agg_object = elem(aggregate, 1)
      agg_fake_1 = agg_object.contains.fake1
      agg_fake_2 = agg_object.contains.fake2

      assert agg_fake_1 == fake_entity_1
      assert agg_fake_2 == fake_entity_2
    end
  end

  describe "is_aggregate?/1" do
    test "with correct tuple type" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])
      assert Aggregate.is_aggregate?(aggregate)
    end

    test "with invalid tuple type" do
      assert !Aggregate.is_aggregate?({:test, :test})
    end

    test "with invalid type" do
      assert !Aggregate.is_aggregate?(1)
    end
  end

  describe "aggregate/1" do
    test "using valid type" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])
      {:ok, structure} = aggregate |> Aggregate.aggregate

      assert structure.contains == fake_entity
    end

    test "with different tuple format" do
      {:error, {error_type, error_message}} = Aggregate.aggregate({:test, :test})
      assert error_type == :aggregate
      assert error_message == Aggregate.error_invalid_aggregate_type()
    end

    test "with invalid aggregate tuple format" do
      {:error, {error_type, error_message}} = Aggregate.aggregate({:aggregate})
      assert error_type == :exception
      assert String.contains?(error_message, "out of range")
    end

    test "with non-tuple type" do
      {:error, {error_type, error_message}} = Aggregate.aggregate(1)
      assert error_type == :aggregate
      assert error_message == Aggregate.error_invalid_data_type()
    end
  end

  describe "entity/1" do
    test "should be able to load a single entity" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])
      {:ok, entity} = aggregate |> Aggregate.entity

      assert entity == fake_entity
    end

    test "should be error with invalid aggregate type" do
      {:error, {error_type, error_msg}} = {:invalid} |> Aggregate.entity

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "should be error with given data type" do
      {:error, {error_type, error_msg}} = 1 |> Aggregate.entity

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_data_type
    end
  end

  describe "entities/1" do
    test "should be able to load multiple entities" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      fake_entity_2 = %FakeEntityStruct{name: "fake_entity_updated"}
      aggregate = Aggregate.new(:entities, %{:fake1 => fake_entity_1, :fake2 => fake_entity_2}, [FakeEventProcessor])

      {:ok, entities} = aggregate |> Aggregate.entities
      assert entities |> Map.has_key?(:fake1)
      assert entities |> Map.has_key?(:fake2)
    end

    test "should be error with invalid aggregate type" do
      {:error, {error_type, error_msg}} = {:invalid} |> Aggregate.entities

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "should be error with given data type" do
      {:error, {error_type, error_msg}} = 1 |> Aggregate.entities

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_data_type
    end
  end

  describe "update_entity/2" do
    test "should be success" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      fake_entity_updated = %FakeEntityStruct{name: "fake_entity_updated"}
      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])

      {:ok, structure} = aggregate |> Aggregate.aggregate
      assert structure.contains == fake_entity
      assert structure.contains.name == fake_entity.name

      aggregate2 = aggregate |> Aggregate.update_entity(fake_entity_updated)
      {:ok, agg_object_2} = Common.extract_element_from_tuple(aggregate2, 1)

      {:ok, structure} = agg_object_2 |> Aggregate.aggregate
      assert structure.contains == fake_entity_updated
      assert structure.contains.name == fake_entity_updated.name
    end

    test "with invalid aggregate type" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      {:error, {error_type, error_msg}} = Aggregate.update_entity({:test, :test}, fake_entity)

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "with invalid aggregate format" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}

      {:error, {error_type, error_message}} = Aggregate.update_entity({:aggregate}, fake_entity)
      assert error_type == :exception
      assert String.contains?(error_message, "out of range")
    end

    test "with invalid data type" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}

      {:error, {error_type, error_message}} = 1 |> Aggregate.update_entity(fake_entity)
      assert error_type == :aggregate
      assert error_message == Aggregate.error_invalid_data_type()
    end
  end

  describe "update_entity/3" do
    test "should be success" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      fake_entity_2 = %FakeEntityStruct{name: "fake_entity_updated"}
      aggregate = Aggregate.new(:entities, %{:fake1 => fake_entity_1, :fake2 => fake_entity_2}, [FakeEventProcessor])

      {:ok, structure} = aggregate |> Aggregate.aggregate
      assert structure.contains.fake1 == fake_entity_1
      assert structure.contains.fake1.name == fake_entity_1.name
      assert structure.contains.fake2 == fake_entity_2
      assert structure.contains.fake2.name == fake_entity_2.name

      fake_entity_1_updated = %FakeEntityStruct{name: "fake_entity_updated"}
      {:ok, aggregate2} = aggregate |> Aggregate.update_entity(:fake1, fake_entity_1_updated)
      {:ok, structure} = aggregate2 |> Aggregate.aggregate

      assert structure.contains.fake1 == fake_entity_1_updated
      assert structure.contains.fake1.name == fake_entity_1_updated.name
    end

    test "with invalid aggregate type" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      {:error, {error_type, error_msg}} = Aggregate.update_entity({:test, :test}, fake_entity_1)

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "with invalid aggregate format" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      {:error, {error_type, error_msg}} = Aggregate.update_entity({:aggregate}, fake_entity_1)

      assert error_type == :exception
      assert String.contains?(error_msg, "out of range")
    end

    test "with invalid data type" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      {:error, {error_type, error_msg}} = Aggregate.update_entity(1, :fake, fake_entity_1)

      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_data_type()
    end
  end

  describe "add_event/2" do
    test "should be success to adding event" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      fake_event = %Event.Structure{
        name: :fake_event,
        payload: %{},
        timestamp: DateTime.utc_now()
      }

      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])
      {result, aggregate} = aggregate |> Aggregate.add_event({:event, fake_event})

      assert result == :ok
      {:ok, updated} = aggregate |> Aggregate.aggregate
      assert length(updated.events) == 1
    end

    test "should be error when using invalid aggregate spec" do
      {result, {error_type, error_msg}} = {:invalid} |> Aggregate.add_event({:event})
      assert result == :error
      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "should be error when using invalid data type spec" do
      {result, {error_type, error_msg}} = 1 |> Aggregate.add_event({:event})
      assert result == :error
      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_data_type()
    end
  end

  describe "emit_events/1" do
    test "should be success to emit all events" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      fake_event = %Event.Structure{
        name: :fake_event,
        payload: %{},
        timestamp: DateTime.utc_now()
      }

      aggregate = Aggregate.new(:fake_entity, fake_entity, [FakeEventProcessor])
      {result, aggregate} = aggregate |> Aggregate.add_event({:event, fake_event})
      assert result == :ok

      {result, aggregate} = aggregate |> Aggregate.emit_events
      assert result == :ok

      {:ok, updated} = aggregate |> Aggregate.aggregate
      assert length(updated.events) == 0
    end

    test "should be error using invalid aggregate type" do
      {result, {error_type, error_msg}} = {:invalid} |> Aggregate.emit_events
      assert result == :error
      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_aggregate_type()
    end

    test "should be error invalid data type" do
      {result, {error_type, error_msg}} = 1 |> Aggregate.emit_events
      assert result == :error
      assert error_type == :aggregate
      assert error_msg == Aggregate.error_invalid_data_type()
    end
  end
end
