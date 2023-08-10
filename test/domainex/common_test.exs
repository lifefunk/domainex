defmodule Domainex.CommonTest do
  use ExUnit.Case
  alias Domainex.Common

  describe "extract_element_from_tuple/2" do
    test "should be success" do
      {:ok, out} = Common.extract_element_from_tuple({:test, :testing}, 1)
      assert out == :testing
    end

    test "should be error out of range" do
      {:error, {error_type, error_msg}} = Common.extract_element_from_tuple({:test, :testing}, 3)
      assert error_type == :exception
      assert String.contains?(error_msg, "out of range")
    end
  end

  describe "is_tuple_length_valid?/2" do
    test "should be success" do
      assert Common.is_tuple_length_valid?({:test}, 1)
      assert Common.is_tuple_length_valid?({:test, :testing}, 2)
      assert Common.is_tuple_length_valid?({:test, :testing, :testing3}, 3)
    end

    test "should be invalid length" do
      assert !Common.is_tuple_length_valid?({:test}, 3)
    end
  end

  describe "is_tuple_has_context?/2" do
    test "should be success" do
      assert Common.is_tuple_has_context?({:test}, :test)
      assert Common.is_tuple_has_context?({:testing}, :testing)
      assert Common.is_tuple_has_context?({:testing2}, :testing2)
    end

    test "invalid result" do
      assert !Common.is_tuple_has_context?({:test}, :testing)
    end
  end
end
