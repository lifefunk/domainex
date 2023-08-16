defmodule Domainex.EventTest do
  use ExUnit.Case

  alias Domainex.Event

  defmodule FakeEntityStruct do
    defstruct [:name]
  end

  describe "new/2" do
    test "initiate new event" do
      fake_entity = %FakeEntityStruct{name: "testing"}
      event = Event.new(:fake, fake_entity)
      assert Event.is_event?(event)
    end
  end

  describe "is_event?/1" do
    test "using invalid event spec" do
      assert !Event.is_event?({:ok, "hello world"})
    end

    test "using invalid types" do
      assert !Event.is_event?(1)
    end
  end

  describe "payload/1" do
    test "extract payload should be success" do
      fake_entity = %FakeEntityStruct{name: "testing"}
      event = Event.new(:fake, fake_entity)
      {type, data} = event |> Event.payload

      assert type == :ok
      assert data == fake_entity
      assert data.name == "testing"
    end

    test "extract payload using invalid tuple length" do
      {type, {error_type, _error_msg}} = {:event} |> Event.payload
      assert type == :error
      assert error_type == :exception
    end

    test "extract payload using invalid tuple spec" do
      {type, {error_type, error_msg}} = {:ok} |> Event.payload
      assert type == :error
      assert error_type == :event
      assert error_msg == Event.error_invalid_event_type
    end

    test "extract payload using invalid type spec" do
      {type, {error_type, error_msg}} = 1 |> Event.payload
      assert type == :error
      assert error_type == :event
      assert error_msg == Event.error_invalid_event_type
    end
  end

  describe "structure/1" do
    test "extract structure should be success" do
      fake_entity = %FakeEntityStruct{name: "testing"}
      event = Event.new(:fake, fake_entity)
      {type, data} = event |> Event.structure

      assert type == :ok
      assert data.name == :fake
      assert data.payload == fake_entity
    end

    test "extract structure using invalid tuple length" do
      {type, {error_type, _error_msg}} = {:event} |> Event.structure
      assert type == :error
      assert error_type == :exception
    end

    test "extract structure using invalid tuple spec" do
      {type, {error_type, error_msg}} = {:ok} |> Event.structure
      assert type == :error
      assert error_type == :event
      assert error_msg == Event.error_invalid_event_type
    end

    test "extract structure using invalid type spec" do
      {type, {error_type, error_msg}} = 1 |> Event.structure
      assert type == :error
      assert error_type == :event
      assert error_msg == Event.error_invalid_event_type
    end
  end
end
