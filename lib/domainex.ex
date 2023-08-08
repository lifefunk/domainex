defmodule Domainex do
  @moduledoc """
  A `domainex` is an Elixir library which provides:

  - common elixir typespec models
  - common domain typespec models
  - a helper for functional dependencies
  - a helper for common domain value objects
  - a helper for common domain needs
  """
  @typep error_type :: String.t() | atom()

  @typep error_payload ::
    String.t()
    | struct()
    | map()

  @typedoc """
  Common elixir error type spec actually looks like:

  ```elixir
    {:error, "error message"}
  ```

  I'm agree with the structure, but I think we need more detail and explicit
  for the error type. What kind of errors? Is it internal? Is it from core domain?
  Is it from application's level? Or is it an exception?

  The `error_type()` has two possible types:
  - String.t()
  - atom()

  By providing the `error_type()` we can provides more explicit information about
  an error, and help us to provide better error handling based on the error's types

  For the `error_payload()` , it has three possible types
  - String.t()
  - struct()
  - map()

  It is possible to just using a simple string for our error message, but I think sometimes
  we also need to provide rich error informations, maybe by providing some structs or a map,
  which contains specific application or business error handling, such as for application status
  codes with their definition/message.
  """
  @type error :: {:error, {error_type(), error_payload()}}

  @typedoc """
  `success()` actually is a common Elixir's convention result for the success return values. It just
  follow common convention

  ```elixir
    {:ok, any()}
  ```
  """
  @type success :: {:ok, any()}

  @typedoc """
  A `result()` actually follow Rust's convention from their `Result<T, E>`. A `result()`
  is a return value which only has two possibilities a `success()` or `error()` values.

  It's common in Elixir's function which provides two possible return values and looks like this

  ```elixir
  @spec do_something(a :: atom()) :: {:ok, any()} | {:error, any()}
  def do_something(a) do
  end
  ```

  To simplify the function's signature, I make it to:

  ```elixir
  @spec do_something(a :: atom()) :: Domainex.result()
  def do_something(a) do
  end
  ```
  """
  @type result :: success() | error()

  @typedoc """
  An `aggregate_name` used to define the business needs behind an `aggregate`.
  """
  @type aggregate_name :: String.t() | atom()

  @typedoc """
  An `aggregate_payload()` used to store a single `struct()` or a list of `struct()`. A `struct()` used as a
  representation of some entities.
  """
  @type aggregate_payload ::
    struct()
    | list(struct())

  @typedoc """
  An `aggregate` in DDD actually is a cluster of *objects*, it possible to be a single entity, or a group
  of entities. The definition of *object* here is just a simple `struct()`
  """
  @type aggregate :: {:aggregate, {aggregate_name(), aggregate_payload()}}
end
