defmodule Domainex.AggregateTest do
  use ExUnit.Case

  alias Domainex.Aggregate
  alias Domainex.Common


  defmodule FakeEntityStruct do
    defstruct [:name]
  end

  describe "new/1" do
    test "with single entity" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      aggregate = Aggregate.new(:fake_entity, fake_entity)

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
      aggregate = Aggregate.new(:fake_agg, %{:fake1 => fake_entity_1, :fake2 => fake_entity_2})

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
      aggregate = Aggregate.new(:fake_entity, fake_entity)
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
      aggregate = Aggregate.new(:fake_entity, fake_entity)
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

  describe "update_entity/2" do
    test "should be success" do
      fake_entity = %FakeEntityStruct{name: "fake_entity"}
      fake_entity_updated = %FakeEntityStruct{name: "fake_entity_updated"}
      aggregate = Aggregate.new(:fake_entity, fake_entity)

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
  end

  describe "update_entity/3" do
    test "should be success" do
      fake_entity_1 = %FakeEntityStruct{name: "fake_entity"}
      fake_entity_2 = %FakeEntityStruct{name: "fake_entity_updated"}
      aggregate = Aggregate.new(:entities, %{:fake1 => fake_entity_1, :fake2 => fake_entity_2})

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
  end
end
