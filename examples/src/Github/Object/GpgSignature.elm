-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Github.Object.GpgSignature exposing (..)

import Github.Enum.GitSignatureState
import Github.InputObject
import Github.Interface
import Github.Object
import Github.Scalar
import Github.ScalarCodecs
import Github.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Email used to sign this object.
-}
email : SelectionSet String Github.Object.GpgSignature
email =
    Object.selectionForField "String" "email" [] Decode.string


{-| True if the signature is valid and verified by GitHub.
-}
isValid : SelectionSet Bool Github.Object.GpgSignature
isValid =
    Object.selectionForField "Bool" "isValid" [] Decode.bool


{-| Hex-encoded ID of the key that signed this object.
-}
keyId : SelectionSet (Maybe String) Github.Object.GpgSignature
keyId =
    Object.selectionForField "(Maybe String)" "keyId" [] (Decode.string |> Decode.nullable)


{-| Payload for GPG signing object. Raw ODB object without the signature header.
-}
payload : SelectionSet String Github.Object.GpgSignature
payload =
    Object.selectionForField "String" "payload" [] Decode.string


{-| ASCII-armored signature header from object.
-}
signature : SelectionSet String Github.Object.GpgSignature
signature =
    Object.selectionForField "String" "signature" [] Decode.string


{-| GitHub user corresponding to the email signing this commit.
-}
signer : SelectionSet decodesTo Github.Object.User -> SelectionSet (Maybe decodesTo) Github.Object.GpgSignature
signer object_ =
    Object.selectionForCompositeField "signer" [] object_ (identity >> Decode.nullable)


{-| The state of this signature. `VALID` if signature is valid and verified by GitHub, otherwise represents reason why signature is considered invalid.
-}
state : SelectionSet Github.Enum.GitSignatureState.GitSignatureState Github.Object.GpgSignature
state =
    Object.selectionForField "Enum.GitSignatureState.GitSignatureState" "state" [] Github.Enum.GitSignatureState.decoder
