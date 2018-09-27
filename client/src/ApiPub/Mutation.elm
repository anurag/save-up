-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module ApiPub.Mutation exposing (ConfirmEmailRequiredArguments, RedeemInvitationRequiredArguments, RequestPasswordResetRequiredArguments, ResetPasswordRequiredArguments, SignInRequiredArguments, SignUpRequiredArguments, confirmEmail, redeemInvitation, requestPasswordReset, resetPassword, selection, signIn, signUp)

import ApiPub.InputObject
import ApiPub.Interface
import ApiPub.Object
import ApiPub.Scalar
import ApiPub.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)


{-| Select fields to build up a top-level mutation. The request can be sent with
functions from `Graphql.Http`.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) RootMutation
selection constructor =
    Object.selection constructor


type alias SignUpRequiredArguments =
    { signUp : ApiPub.InputObject.SignUp }


signUp : SignUpRequiredArguments -> SelectionSet decodesTo ApiPub.Object.SignUpResponse -> Field decodesTo RootMutation
signUp requiredArgs object_ =
    Object.selectionField "signUp" [ Argument.required "signUp" requiredArgs.signUp ApiPub.InputObject.encodeSignUp ] object_ identity


type alias SignInRequiredArguments =
    { signIn : ApiPub.InputObject.SignIn }


signIn : SignInRequiredArguments -> SelectionSet decodesTo ApiPub.Object.SignInResponse -> Field decodesTo RootMutation
signIn requiredArgs object_ =
    Object.selectionField "signIn" [ Argument.required "signIn" requiredArgs.signIn ApiPub.InputObject.encodeSignIn ] object_ identity


type alias ConfirmEmailRequiredArguments =
    { input : ApiPub.InputObject.ConfirmEmailInput }


confirmEmail : ConfirmEmailRequiredArguments -> SelectionSet decodesTo ApiPub.Object.ConfirmEmailResponse -> Field decodesTo RootMutation
confirmEmail requiredArgs object_ =
    Object.selectionField "confirmEmail" [ Argument.required "input" requiredArgs.input ApiPub.InputObject.encodeConfirmEmailInput ] object_ identity


type alias RedeemInvitationRequiredArguments =
    { input : ApiPub.InputObject.RedeemInvitationInput }


redeemInvitation : RedeemInvitationRequiredArguments -> SelectionSet decodesTo ApiPub.Object.RedeemInvitationResponse -> Field decodesTo RootMutation
redeemInvitation requiredArgs object_ =
    Object.selectionField "redeemInvitation" [ Argument.required "input" requiredArgs.input ApiPub.InputObject.encodeRedeemInvitationInput ] object_ identity


type alias RequestPasswordResetRequiredArguments =
    { input : ApiPub.InputObject.RequestPasswordResetInput }


requestPasswordReset : RequestPasswordResetRequiredArguments -> SelectionSet decodesTo ApiPub.Object.RequestPasswordResetResponse -> Field decodesTo RootMutation
requestPasswordReset requiredArgs object_ =
    Object.selectionField "requestPasswordReset" [ Argument.required "input" requiredArgs.input ApiPub.InputObject.encodeRequestPasswordResetInput ] object_ identity


type alias ResetPasswordRequiredArguments =
    { input : ApiPub.InputObject.ResetPasswordInput }


resetPassword : ResetPasswordRequiredArguments -> SelectionSet decodesTo ApiPub.Object.ResetPasswordResponse -> Field decodesTo RootMutation
resetPassword requiredArgs object_ =
    Object.selectionField "resetPassword" [ Argument.required "input" requiredArgs.input ApiPub.InputObject.encodeResetPasswordInput ] object_ identity
