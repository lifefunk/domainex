# Domainex

`DomainEx` is an Elixir library which provides a set of common typespec and domain models and also provides
a set of function helpers for basic function and domain building  

## About Domainex

### Why TypeSpces

Elixir is not a static typing language, it's dynamic typing, which mean when we doesn't need to define any variable
or function type parameters. But Elixir provides their `TypeSpecs` that really useful to: 

- Documentation. I'm one of believer that good (and beautiful) code documentation is important
- Code analysis using `Dialyzer`

When I begin to learn Elixir's *typespec* , I'm starting to learn the mental model, and I really like it. The typespec
actually is *just* a *typehint* , but somehow I've felt that the type specification mechanism still able to help us to provide rich modeling domain business and in the same time can help us to building a great domain business documentation
from our codes.

The `Domainex` provides common types such as: 

```elixir
  @type error :: {:error, {error_type(), error_payload()}}
  @type success :: {:ok, any()}
  @type result :: success() | error()
```

### Domain Driven Design

Although Elixir is not a static type language, we are still possible to modeling business needs by take a leverage of *typespec*.

`Domainex` also build with purpose to provide a helpers and also *specs* to define some common DDD concepts, like aggregates: 

```elixir
  @type aggregate_name :: String.t() | atom()
  @type aggregate_payload :: Aggregate.Structure.t()
  @type aggregate :: {:aggregate, {aggregate_name(), aggregate_payload()}}
```

By providing a *shortcut* for its *spec* , it can help us when modeling our business needs. 

### The power of Tuple

When I learning Elixir, I've seen a lot of *tuple* used to grouping some context. Let just take our previous sample for return values : 

```elixir
  @type error :: {:error, {error_type(), error_payload()}}
  @type success :: {:ok, any()}
  @type result :: success() | error()
```

In the first time, it just look *weird*, but after learn more, I just think that it actually a reall simple and powerfull concept. We can use *tuple* to build a set of context from some value, not just its *type* but also the *context*, what kind of information do we get from some value. From the example above, when we got the information that the *value* is a *succes* or an *error*, we know how to handling it.

It's same with previous *aggregate*. By just defining an *aggregate* as a *tuple* , when we got a *value* which is a *tuple* and the first element is `:aggregate`, what we need to do next is extract the following elements like for `aggregate_name` and it's payload.

And thanks to Elixir's pattern matching its really simple to *match* and *extract* tuple values

```elixir
iex(1)> {typed, value} = {:ok, "hello world"}
{:ok, "hello world"}
iex(2)> typed
:ok
iex(3)> value
"hello world"
iex(4)> 
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `domainex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:domainex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/domainex>.

