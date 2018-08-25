-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.InputObject exposing (InvitationInput, InvitationInputRequiredFields, buildInvitationInput, encodeInvitationInput)

import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


buildInvitationInput : InvitationInputRequiredFields -> InvitationInput
buildInvitationInput required =
    { email = required.email }


type alias InvitationInputRequiredFields =
    { email : String }


{-| Type for the InvitationInput input object.
-}
type alias InvitationInput =
    { email : String }


{-| Encode a InvitationInput into a value that can be used as an argument.
-}
encodeInvitationInput : InvitationInput -> Value
encodeInvitationInput input =
    Encode.maybeObject
        [ ( "email", Encode.string input.email |> Just ) ]
