module Graphql.SelectionSet exposing
    ( map
    , map2, map3, map4, map5, map6, map7, map8
    , withDefault
    , with, hardcoded, succeed
    , empty
    , SelectionSet(..), FragmentSelectionSet(..)
    , mapOrFail, nonNullOrFail, nonNullElementsOrFail
    )

{-| The auto-generated code from the `@dillonkearns/elm-graphql` CLI provides
functions that you can use to build up `SelectionSet`s for the GraphQL Objects,
Interfaces, and Unions in your GraphQL schema.

Note that in these examples, all of the modules that start with `StarWars.` or `Github.`
are generated by running the [`@dillonkearns/elm-graphql`](https://npmjs.com/package/@dillonkearns/elm-graphql)
command line tool.

There are lots more end-to-end examples in the
[`examples` ](https://github.com/dillonkearns/elm-graphql/tree/master/examples/src)
folder.

With `dillonkearns/elm-graphql`, a `SelectionSet` describes a set of fields to
retrieve. It contains all the information needed to make the request and decode
the response (you don't hand-code the decoders yourself, they are auto-generated
for you!).


## Building `SelectionSet`s

A `SelectionSet` in `dillonkearns/elm-graphql` represents a set of
zero or more things which are either sub-`SelectionSet`s or leaf fields.

For example, `SelectionSet.empty` is the most basic `SelectionSet` you could build.

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Query as Query

    query : SelectionSet () RootQuery
    query =
        SelectionSet.empty

You can execute this query, but the result won't be very interesting!

In the StarWars API example in the [`examples`](https://github.com/dillonkearns/elm-graphql/tree/master/examples/src)
folder, there is a top-level query field called `hello`. So you could also
build a valid query to get `hello`:

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Query as Query

    query : SelectionSet Response RootQuery
    query =
        Query.hello

This is the equivalent of this raw GraphQL query:

    query {
      hello
    }

If we wanted to query for two top-level fields it's just as easy. Let's see how we would grab both the `hello` and `goodbye` fields like this:

    query {
      hello
      goodbye
    }

The only difference for combining two `SelectionSet`s is that you need to define which
function we want to use to combine the two fields together into one piece of data.
Let's just define our own function for now, called `helloAndGoodbyeToString`.

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Query

    helloAndGoodbyeToString : String -> String -> String
    helloAndGoodbyeToString helloValue goodbyeValue =
        "greeting: "
            ++ helloValue
            ++ "\ngoodbye: "
            ++ goodbyeValue

    hero : SelectionSet String RootQuery
    hero =
        SelectionSet.map2 helloAndGoodbyeToString
            Query.hello
            Query.goodbye

Great, we retrieved two fields! But often you don't want to combine the values
into a primitive, you just want to store the values in some data structure
like a record. So a very common pattern is to use record constructors as the
constructor function for `map2` (or `mapN`). Any function that takes the right number of arguments
(of the right types, order matters) will work here.

Let's define a type alias for a record called `Phrases`. When we define this
type alias, Elm creates a function called `Phrases` that will build up a record
of that type. So we can use that function with `map2`!

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Query

    type alias Phrases =
        { helloPhrase : String
        , goodbyePhrase : String
        }

    hero : SelectionSet Phrases RootQuery
    hero =
        SelectionSet.map2 Phrases
            Query.hello
            Query.goodbye

Note that if you changed the order of `Query.hello` and `Query.goodbye`,
you would end up with a record with values under the wrong name. Order matters
with record constructors!


## Modularizing `SelectionSet`s

Since both single fields and collections of fields are `SelectionSet`s in `dillonkearns/elm-graphql`,
you can easily pull in sub-`SelectionSet`s to your queries. Just treat it like you would a regular field.

This is analagous to using a [fragment in plain GraphQL](https://graphql.org/learn/queries/#fragments).
This is a handy tool for modularizing your GraphQL queries.

Let's say we want to query Github's GraphQL API like this:

    {
      repository(owner: "dillonkearns", name: "elm-graphql") {
      nameWithOwner
      ...timestamps
      stargazers(first: 0) { totalCount }
      }
    }

    fragment timestamps on Repository {
      createdAt
      updatedAt
    }

(You can try the above query for yourself by pasting the query into the [Github query explorer](https://developer.github.com/v4/explorer/)).

We could do the equivalent of the `timestamps` fragment with the `timestampsFragment`
we define below.

    import Github.Object
    import Github.Object.Repository as Repository
    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import Iso8601
    import Time exposing (Posix)

    type alias Repo =
        { nameWithOwner : String
        , timestamps : Timestamps
        }

    type alias Timestamps =
        { createdAt : Posix
        , updatedAt : Posix
        }

    repositorySelection : SelectionSet Repo Github.Object.Repository
    repositorySelection =
        SelectionSet.map2 Repo
            Repository.nameWithOwner
            timestampsFragment

    timestampsFragment : SelectionSet Timestamps Github.Object.Repository
    timestampsFragment =
        SelectionSet.map2 Timestamps
            (Repository.createdAt |> mapToDateTime)
            (Repository.updatedAt |> mapToDateTime)

    mapToDateTime : SelectionSet Github.Scalar.DateTime typeLock -> SelectionSet Posix typeLock
    mapToDateTime =
        SelectionSet.mapOrFail
            (\(Github.Scalar.DateTime value) ->
                Iso8601.toTime value
                    |> Result.mapError
                        (\_ ->
                            "Failed to parse "
                                ++ value
                                ++ " as Iso8601 DateTime."
                        )
            )

Note that both individual GraphQL fields (like `Repository.nameWithOwner`), and
collections of fields (like our `timestampsFragment`) are just `SelectionSet`s.
So whether it's a single field or a pair of fields, we can pull it into our
query using the exact same syntax!

Modularizing your queries like this is a great idea. Dealing with these
sub-`SelectionSet`s also allows the Elm compiler to give you more precise
error messages. Just be sure to add type annotations to all your `SelectionSet`s!


## Mapping & Combining

Note: If you run out of `mapN` functions for building up `SelectionSet`s,
you can use the pipeline
which makes it easier to handle large objects, but produces
lower quality type errors.

@docs map

@docs map2, map3, map4, map5, map6, map7, map8

@docs withDefault


## Pipelines

As an alternative to the `mapN` functions, you can build up
`SelectionSet`s using the pipeline syntax. If you've used
the [`elm-json-decode-pipeline`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/)
package then this style will feel very familiar. The example above in this page
would translate to this using the pipeline notation:

    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
    import StarWars.Object
    import StarWars.Object.Human as Human

    type alias Human =
        { name : String
        , id : String
        }

    hero : SelectionSet Hero StarWars.Object.Human
    hero =
        SelectionSet.succeed Human
            |> with Human.name
            |> with Human.id

You can see an end-to-end example using the pipeline syntax in the [`examples`](https://github.com/dillonkearns/elm-graphql/tree/master/examples/src)
folder.

@docs with, hardcoded, succeed

@docs empty


## Types

These types are built for you by the code generated by the `@dillonkearns/elm-graphql` command line tool.

@docs SelectionSet, FragmentSelectionSet


## Result (`...OrFail`) Transformations

**Warning** When you use these functions, you lose the guarantee that the
server response will decode successfully.

These helpers, though convenient, will cause your entire decoder to fail if
it ever maps to an `Err` instead of an `Ok` `Result`.

If you're wondering why there are so many `Maybe`s in your generated code,
take a look at the
[FAQ question "Why are there so many Maybes in my responses? How do I reduce them?"](https://github.com/dillonkearns/graphqelm/blob/master/FAQ.md#why-are-there-so-many-maybes-in-my-responses-how-do-i-reduce-them).

@docs mapOrFail, nonNullOrFail, nonNullElementsOrFail

-}

import Graphql.Document.Field
import Graphql.RawField as RawField exposing (RawField)
import Json.Decode as Decode exposing (Decoder)
import List.Extra


{-| SelectionSet type
-}
type SelectionSet decodesTo typeLock
    = SelectionSet (List RawField) (Decoder decodesTo)


{-| Maps the data coming back from the GraphQL endpoint. In this example,
`User.name` is a function that the `@dillonkearns/elm-graphql` CLI tool created which tells us
that the `name` field on a `User` object is a String according to your GraphQL
schema.

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet exposing (SelectionSet)
    import StarWars.Query as Query

    query : SelectionSet String RootQuery
    query =
        Query.hello |> SelectionSet.map String.toUpper

You can also map to values of a different type. For example, if we
use a (`String -> Int`) map function, it will change the type of our `SelectionSet`
accordingly:

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet exposing (SelectionSet)
    import StarWars.Query as Query

    query : SelectionSet Int RootQuery
    query =
        Query.hello |> SelectionSet.map String.length

`SelectionSet.map` is also helpful when using a record to wrap a type:

    import Graphql.Operation exposing (RootQuery)
    import Graphql.SelectionSet exposing (SelectionSet)
    import StarWars.Query as Query

    type alias Response =
        { hello : String }

    query : SelectionSet Response RootQuery
    query =
        SelectionSet.map Response Query.hello

Mapping is also handy when you are dealing with polymorphic GraphQL types
(Interfaces and Unions).

    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Object.Droid as Droid
    import StarWars.Object.Human as Human
    import StarWars.Union
    import StarWars.Union.CharacterUnion

    type HumanOrDroidDetails
        = HumanDetails (Maybe String)
        | DroidDetails (Maybe String)

    heroUnionSelection : SelectionSet HumanOrDroidDetails StarWars.Union.CharacterUnion
    heroUnionSelection =
        StarWars.Union.CharacterUnion.fragments
            { onHuman = SelectionSet.map HumanDetails Human.homePlanet
            , onDroid = SelectionSet.map DroidDetails Droid.primaryFunction
            }

-}
map : (a -> b) -> SelectionSet a typeLock -> SelectionSet b typeLock
map mapFunction (SelectionSet selectionFields selectionDecoder) =
    SelectionSet selectionFields (Decode.map mapFunction selectionDecoder)


{-| A helper for mapping a SelectionSet to provide a default value.
-}
withDefault : a -> SelectionSet (Maybe a) typeLock -> SelectionSet a typeLock
withDefault default =
    map (Maybe.withDefault default)


{-| Combine two `SelectionSet`s into one, using the given combine function to
merge the two data sets together.

    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Object
    import StarWars.Object.Human as Human
    import StarWars.Scalar

    type alias Human =
        { name : String
        , id : StarWars.Scalar.Id
        }

    hero : SelectionSet Hero StarWars.Object.Human
    hero =
        SelectionSet.map2 Human
            Human.name
            Human.id

Check out the [`examples`](https://github.com/dillonkearns/elm-graphql/tree/master/examples/src)
folder, there are lots of end-to-end examples there!

-}
map2 :
    (decodesTo1 -> decodesTo2 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesToCombined typeLock
map2 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) =
    SelectionSet
        (selectionFields1 ++ selectionFields2)
        (Decode.map2 combine selectionDecoder1 selectionDecoder2)


{-| Combine three `SelectionSet`s into one, using the given combine function to
merge the two data sets together. This gives more clear error messages than the
pipeline syntax (using `SelectionSet.succeed` to start the pipeline
and `SelectionSet.with` to continue it).

    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
    import StarWars.Interface
    import StarWars.Interface.Character as Character
    import StarWars.Scalar

    type alias Character =
        { name : String
        , id : StarWars.Scalar.Id
        , friends : List String
        }

    characterSelection : SelectionSet Character StarWars.Interface.Character
    characterSelection =
        SelectionSet.map3 Character
            Character.name
            Character.id
            (Character.friends Character.name)

-}
map3 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesToCombined typeLock
map3 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3 ])
        (Decode.map3 combine selectionDecoder1 selectionDecoder2 selectionDecoder3)


{-| -}
map4 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesTo4 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesTo4 typeLock
    -> SelectionSet decodesToCombined typeLock
map4 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) (SelectionSet selectionFields4 selectionDecoder4) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3, selectionFields4 ])
        (Decode.map4 combine selectionDecoder1 selectionDecoder2 selectionDecoder3 selectionDecoder4)


{-| -}
map5 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesTo4 -> decodesTo5 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesTo4 typeLock
    -> SelectionSet decodesTo5 typeLock
    -> SelectionSet decodesToCombined typeLock
map5 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) (SelectionSet selectionFields4 selectionDecoder4) (SelectionSet selectionFields5 selectionDecoder5) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3, selectionFields4, selectionFields5 ])
        (Decode.map5 combine selectionDecoder1 selectionDecoder2 selectionDecoder3 selectionDecoder4 selectionDecoder5)


{-| -}
map6 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesTo4 -> decodesTo5 -> decodesTo6 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesTo4 typeLock
    -> SelectionSet decodesTo5 typeLock
    -> SelectionSet decodesTo6 typeLock
    -> SelectionSet decodesToCombined typeLock
map6 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) (SelectionSet selectionFields4 selectionDecoder4) (SelectionSet selectionFields5 selectionDecoder5) (SelectionSet selectionFields6 selectionDecoder6) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3, selectionFields4, selectionFields5, selectionFields6 ])
        (Decode.map6 combine selectionDecoder1 selectionDecoder2 selectionDecoder3 selectionDecoder4 selectionDecoder5 selectionDecoder6)


{-| -}
map7 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesTo4 -> decodesTo5 -> decodesTo6 -> decodesTo7 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesTo4 typeLock
    -> SelectionSet decodesTo5 typeLock
    -> SelectionSet decodesTo6 typeLock
    -> SelectionSet decodesTo7 typeLock
    -> SelectionSet decodesToCombined typeLock
map7 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) (SelectionSet selectionFields4 selectionDecoder4) (SelectionSet selectionFields5 selectionDecoder5) (SelectionSet selectionFields6 selectionDecoder6) (SelectionSet selectionFields7 selectionDecoder7) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3, selectionFields4, selectionFields5, selectionFields6, selectionFields7 ])
        (Decode.map7 combine selectionDecoder1 selectionDecoder2 selectionDecoder3 selectionDecoder4 selectionDecoder5 selectionDecoder6 selectionDecoder7)


{-| -}
map8 :
    (decodesTo1 -> decodesTo2 -> decodesTo3 -> decodesTo4 -> decodesTo5 -> decodesTo6 -> decodesTo7 -> decodesTo8 -> decodesToCombined)
    -> SelectionSet decodesTo1 typeLock
    -> SelectionSet decodesTo2 typeLock
    -> SelectionSet decodesTo3 typeLock
    -> SelectionSet decodesTo4 typeLock
    -> SelectionSet decodesTo5 typeLock
    -> SelectionSet decodesTo6 typeLock
    -> SelectionSet decodesTo7 typeLock
    -> SelectionSet decodesTo8 typeLock
    -> SelectionSet decodesToCombined typeLock
map8 combine (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) (SelectionSet selectionFields3 selectionDecoder3) (SelectionSet selectionFields4 selectionDecoder4) (SelectionSet selectionFields5 selectionDecoder5) (SelectionSet selectionFields6 selectionDecoder6) (SelectionSet selectionFields7 selectionDecoder7) (SelectionSet selectionFields8 selectionDecoder8) =
    SelectionSet
        (List.concat [ selectionFields1, selectionFields2, selectionFields3, selectionFields4, selectionFields5, selectionFields6, selectionFields7, selectionFields8 ])
        (Decode.map8 combine selectionDecoder1 selectionDecoder2 selectionDecoder3 selectionDecoder4 selectionDecoder5 selectionDecoder6 selectionDecoder7 selectionDecoder8)


{-| Useful for Mutations when you don't want any data back.

    import Graphql.Operation exposing (RootMutation)
    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
    import StarWars.Mutation as Mutation

    sendChatMessage : String -> SelectionSet () RootMutation
    sendChatMessage message =
        Mutation.sendMessage { message = message } SelectionSet.empty

-}
empty : SelectionSet () typeLock
empty =
    SelectionSet [] (Decode.succeed ())


{-| FragmentSelectionSet type
-}
type FragmentSelectionSet decodesTo typeLock
    = FragmentSelectionSet String (List RawField) (Decoder decodesTo)



{- TODO add this documentation to `with`
   Used to pick out fields on an object.

      import StarWars.Enum.Episode as Episode exposing (Episode)
      import StarWars.Object
      import StarWars.Scalar
      import Graphql.SelectionSet exposing (SelectionSet, with)

      type alias Hero =
          { name : String
          , id : StarWars.Scalar.Id
          , appearsIn : List Episode
          }

      hero : SelectionSet Hero StarWars.Interface.Character
      hero =
          Character.commonSelection Hero
              |> with Character.name
              |> with Character.id
              |> with Character.appearsIn

-}


{-| TODO
-}
with : SelectionSet a typeLock -> SelectionSet (a -> b) typeLock -> SelectionSet b typeLock
with (SelectionSet selectionFields1 selectionDecoder1) (SelectionSet selectionFields2 selectionDecoder2) =
    SelectionSet (selectionFields1 ++ selectionFields2)
        (Decode.map2 (|>)
            selectionDecoder1
            selectionDecoder2
        )


{-| Include a hardcoded value.

        import StarWars.Enum.Episode as Episode exposing (Episode)
        import StarWars.Object
        import Graphql.SelectionSet exposing (SelectionSet, with, hardcoded)

        type alias Hero =
            { name : String
            , movie : String
            }

        hero : SelectionSet Hero StarWars.Interface.Character
        hero =
            Character.commonSelection Hero
                |> with Character.name
                |> hardcoded "Star Wars"

-}
hardcoded : a -> SelectionSet (a -> b) typeLock -> SelectionSet b typeLock
hardcoded constant (SelectionSet objectFields objectDecoder) =
    SelectionSet objectFields
        (Decode.map2 (|>)
            (Decode.succeed constant)
            objectDecoder
        )


{-| Instead of hardcoding a field like `hardcoded`, `SelectionSet.succeed` hardcodes
an entire `SelectionSet`. This can be useful if you want hardcoded data based on
only the type when using a polymorphic type (Interface or Union).

    import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
    import StarWars.Interface
    import StarWars.Interface.Character as Character

    type alias Character =
        { typename : HumanOrDroid
        , name : String
        }

    type HumanOrDroid
        = Human
        | Droid

    hero : SelectionSet Character StarWars.Interface.Character
    hero =
        SelectionSet.succeed Character
            |> with heroType
            |> with Character.name

    heroType : SelectionSet HumanOrDroid StarWars.Interface.Character
    heroType =
        Character.fragments
            { onHuman = SelectionSet.succeed Human
            , onDroid = SelectionSet.succeed Droid
            }

-}
succeed : a -> SelectionSet a typeLock
succeed constructor =
    SelectionSet [] (Decode.succeed constructor)


{-| If the map function provided returns an `Ok` `Result`, it will map to that value.
If it returns an `Err`, the _entire_ response will fail to decode.

    import Time exposing (Posix)
    import Github.Object
    import Github.Object.Repository
    import Github.Scalar
    -- NOTE: Iso8601 comes from an external dependency in Elm >= 0.19:
    -- https://package.elm-lang.org/packages/rtfeldman/elm-iso8601-date-strings/latest/
    import Iso8601
    import Graphql.SelectionSet as SelectionSet exposing (with)

    type alias Timestamps =
    { created : Posix
    , updated : Posix
    }


    timestampsSelection : SelectionSet Timestamps Github.Object.Repository
    timestampsSelection =
        SelectionSet.succeed Timestamps
            |> with (Repository.createdAt |> mapToDateTime)
            |> with (Repository.updatedAt |> mapToDateTime)


    mapToDateTime : Field Github.Scalar.DateTime typeLock -> Field Posix typeLock
    mapToDateTime =
        Field.mapOrFail
            (\(Github.Scalar.DateTime value) ->
                Iso8601.toTime value
                    |> Result.mapError (\_ -> "Failed to parse "
                     ++ value ++ " as Iso8601 DateTime.")

-}
mapOrFail : (decodesTo -> Result String mapsTo) -> SelectionSet decodesTo typeLock -> SelectionSet mapsTo typeLock
mapOrFail mapFunction (SelectionSet field decoder) =
    decoder
        |> Decode.map mapFunction
        |> Decode.andThen
            (\result ->
                case result of
                    Ok value ->
                        Decode.succeed value

                    Err errorMessage ->
                        Decode.fail ("Check your code for calls to mapOrFail, your map function returned an `Err` with the message: " ++ errorMessage)
            )
        |> SelectionSet field


{-| Effectively turns an attribute that is `String` => `String!`, or `User` =>
`User!` (if you're not familiar with the GraphQL type language notation, learn more
[here](http://graphql.org/learn/schema/#type-language)).

This will cause your _entire_ decoder to fail if the field comes back as null.
It's far better to fix your schema then to use this escape hatch!

-}
nonNullOrFail : SelectionSet (Maybe decodesTo) typeLock -> SelectionSet decodesTo typeLock
nonNullOrFail (SelectionSet fields decoder) =
    decoder
        |> Decode.andThen
            (\result ->
                case result of
                    Just value ->
                        Decode.succeed value

                    Nothing ->
                        Decode.fail "Expected non-null but got null, check for calls to nonNullOrFail in your code. Ideally your schema should indicate that this is non-nullable so you don't need to use nonNullOrFail at all."
            )
        |> SelectionSet fields


{-| Effectively turns a field that is `[String]` => `[String!]`, or `[User]` =>
`[User!]` (if you're not familiar with the GraphQL type language notation, learn more
[here](http://graphql.org/learn/schema/#type-language)).

This will cause your _entire_ decoder to fail if any elements in the list for this
field comes back as null.
It's far better to fix your schema then to use this escape hatch!

Often GraphQL schemas will contain things like `[String]` (i.e. a nullable list
of nullable strings) when they really mean `[String!]!` (a non-nullable list of
non-nullable strings). You can chain together these nullable helpers if for some
reason you can't go in and fix this in the schema, for example:

    releases : SelectionSet (List Release) Github.Object.ReleaseConnection
    releases =
        Github.Object.ReleaseConnection.nodes release
            |> Field.nonNullOrFail
            |> Field.nonNullElementsOrFail

Without the `Field.nonNull...` transformations here, the type would be
`SelectionSet (Maybe (List (Maybe Release))) Github.Object.ReleaseConnection`.

-}
nonNullElementsOrFail : SelectionSet (List (Maybe decodesTo)) typeLock -> SelectionSet (List decodesTo) typeLock
nonNullElementsOrFail (SelectionSet fields decoder) =
    decoder
        |> Decode.andThen
            (\result ->
                case combineMaybeList result of
                    Nothing ->
                        Decode.fail "Expected only non-null list elements but found a null. Check for calls to nonNullElementsOrFail in your code. Ideally your schema should indicate that this is non-nullable so you don't need to use nonNullElementsOrFail at all."

                    Just listWithoutNulls ->
                        Decode.succeed listWithoutNulls
            )
        |> SelectionSet fields


combineMaybeList : List (Maybe a) -> Maybe (List a)
combineMaybeList listOfMaybes =
    let
        step maybeElement accumulator =
            case maybeElement of
                Nothing ->
                    Nothing

                Just element ->
                    Maybe.map ((::) element) accumulator
    in
    List.foldr step (Just []) listOfMaybes
