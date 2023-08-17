# SPDX-License-Identifier: MIT
defmodule Domainex.Common do

  alias Domainex, as: BaseType

  @doc """
  `extract_element_from_tuple/2` used for extract some element from a tuple. This function already
  cover some exceptions using `try/rescue` mechanism. If some exceptions was raised it will be catched
  and return an error. It use `elem/2` under the hood.
  """
  @spec extract_element_from_tuple(given :: tuple(), index :: integer()) :: BaseType.result()
  def extract_element_from_tuple(given, index) when is_tuple(given) and is_integer(index) do
    try do
      element = elem(given, index)
      {:ok, element}
    rescue
      e in ArgumentError -> {:error, {:exception, e.message}}
      _ -> {:error, {:internal, "got internal error on accessing tuple"}}
    end
  end

  @doc """
  `is_tuple_length_valid?/2` is a function to check tuple's length
  """
  @spec is_tuple_length_valid?(given :: tuple(), expected_length :: integer()) :: boolean()
  def is_tuple_length_valid?(given, expected_length)
      when is_tuple(given)
      and is_integer(expected_length), do: tuple_size(given) == expected_length

  @doc """
  `is_tuple_has_context?/2` is a function to check the first element of some tuple. The *context*
  definition here is like an `:ok` or an `:error` or anything that define the tuple's value itself,
  such for a success return value, the first element should be an `:ok`.
  """
  @spec is_tuple_has_context?(given :: tuple(), key :: atom()) :: boolean()
  def is_tuple_has_context?(given, key) when is_tuple(given) and is_atom(key) do
    case extract_element_from_tuple(given, 0) do
      {:ok, element} ->
        element == key
      {:error, {_error_type, _error_message}} ->
        false
    end
  end
end
