-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Github.Enum.TeamRepositoryOrderField exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-| Properties by which team repository connections can be ordered.

  - CreatedAt - Order repositories by creation time
  - UpdatedAt - Order repositories by update time
  - PushedAt - Order repositories by push time
  - Name - Order repositories by name
  - Permission - Order repositories by permission
  - Stargazers - Order repositories by number of stargazers

-}
type TeamRepositoryOrderField
    = CreatedAt
    | UpdatedAt
    | PushedAt
    | Name
    | Permission
    | Stargazers


list : List TeamRepositoryOrderField
list =
    [ CreatedAt, UpdatedAt, PushedAt, Name, Permission, Stargazers ]


decoder : Decoder TeamRepositoryOrderField
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "CREATED_AT" ->
                        Decode.succeed CreatedAt

                    "UPDATED_AT" ->
                        Decode.succeed UpdatedAt

                    "PUSHED_AT" ->
                        Decode.succeed PushedAt

                    "NAME" ->
                        Decode.succeed Name

                    "PERMISSION" ->
                        Decode.succeed Permission

                    "STARGAZERS" ->
                        Decode.succeed Stargazers

                    _ ->
                        Decode.fail ("Invalid TeamRepositoryOrderField type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : TeamRepositoryOrderField -> String
toString enum =
    case enum of
        CreatedAt ->
            "CREATED_AT"

        UpdatedAt ->
            "UPDATED_AT"

        PushedAt ->
            "PUSHED_AT"

        Name ->
            "NAME"

        Permission ->
            "PERMISSION"

        Stargazers ->
            "STARGAZERS"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe TeamRepositoryOrderField
fromString enumString =
    case enumString of
        "CREATED_AT" ->
            Just CreatedAt

        "UPDATED_AT" ->
            Just UpdatedAt

        "PUSHED_AT" ->
            Just PushedAt

        "NAME" ->
            Just Name

        "PERMISSION" ->
            Just Permission

        "STARGAZERS" ->
            Just Stargazers

        _ ->
            Nothing
