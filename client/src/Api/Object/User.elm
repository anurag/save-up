-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.User exposing (clientId, createdAt, email, emailConfirmationToken, emailConfirmedAt, id, name, passwordHash, role, selection)

import Api.Enum.Role
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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Api.Object.User
selection constructor =
    Object.selection constructor


id : Field Int Api.Object.User
id =
    Object.fieldDecoder "id" [] Decode.int


createdAt : Field Api.Scalar.NaiveDateTime Api.Object.User
createdAt =
    Object.fieldDecoder "createdAt" [] (Object.scalarDecoder |> Decode.map Api.Scalar.NaiveDateTime)


clientId : Field Int Api.Object.User
clientId =
    Object.fieldDecoder "clientId" [] Decode.int


email : Field String Api.Object.User
email =
    Object.fieldDecoder "email" [] Decode.string


passwordHash : Field String Api.Object.User
passwordHash =
    Object.fieldDecoder "passwordHash" [] Decode.string


name : Field String Api.Object.User
name =
    Object.fieldDecoder "name" [] Decode.string


role : Field Api.Enum.Role.Role Api.Object.User
role =
    Object.fieldDecoder "role" [] Api.Enum.Role.decoder


emailConfirmationToken : Field (Maybe String) Api.Object.User
emailConfirmationToken =
    Object.fieldDecoder "emailConfirmationToken" [] (Decode.string |> Decode.nullable)


emailConfirmedAt : Field (Maybe Api.Scalar.NaiveDateTime) Api.Object.User
emailConfirmedAt =
    Object.fieldDecoder "emailConfirmedAt" [] (Object.scalarDecoder |> Decode.map Api.Scalar.NaiveDateTime |> Decode.nullable)
