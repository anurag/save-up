-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Client exposing (createdAt, id, name, selection)

import Api.InputObject
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


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Api.Object.Client
selection constructor =
    Object.selection constructor


id : Field Int Api.Object.Client
id =
    Object.fieldDecoder "id" [] Decode.int


createdAt : Field Api.Scalar.NaiveDateTime Api.Object.Client
createdAt =
    Object.fieldDecoder "createdAt" [] (Object.scalarDecoder |> Decode.map Api.Scalar.NaiveDateTime)


name : Field String Api.Object.Client
name =
    Object.fieldDecoder "name" [] Decode.string
