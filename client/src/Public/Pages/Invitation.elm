module Public.Pages.Invitation exposing (Model, Msg, init, subscriptions, update, view)

import ApiPub.InputObject exposing (SignUp)
import ApiPub.Mutation
import ApiPub.Object
import ApiPub.Object.RedeemInvitationResponse
import Browser
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl exposing (GraphData, GraphResponse, MutationError, mutationErrorPublicSelection, sendPublicMutation)
import Shared.Routes as Routes
import Shared.Sessions as Sessions
import UI.Flash as Flash
import UI.Forms as Forms
import UI.Icons as Icons


type alias Model =
    { signUp : SignUp
    , invitationToken : String
    , response : GraphData RedeemInvitationResponse
    }


initialModel : Flags -> String -> Model
initialModel flags invitationToken =
    { signUp = Sessions.newSignUp
    , invitationToken = invitationToken
    , response = RemoteData.NotAsked
    }


type alias RedeemInvitationResponse =
    { success : Bool
    , errors : List MutationError
    , token : Maybe String
    }


asSignUpInModel : Model -> SignUp -> Model
asSignUpInModel model signUp =
    { model | signUp = signUp }


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Flags -> String -> Returns
init flags invitationToken =
    ( initialModel flags invitationToken
    , Cmd.none
    , Actions.none
    )


type Msg
    = ChangeName String
    | ChangePassword String
    | Submit
    | OnSubmitResponse (GraphResponse RedeemInvitationResponse)


update : PublicContext -> Msg -> Model -> Returns
update context msg model =
    case msg of
        ChangeName name ->
            ( name
                |> Sessions.asNameInSignUp model.signUp
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        ChangePassword password ->
            ( password
                |> Sessions.asPasswordInSignUp model.signUp
                |> asSignUpInModel model
            , Cmd.none
            , Actions.none
            )

        Submit ->
            ( { model | response = RemoteData.Loading }
            , sendRedeemMutation context model.signUp model.invitationToken
            , Actions.none
            )

        OnSubmitResponse result ->
            case result of
                Err e ->
                    ( { model | response = RemoteData.Failure e }
                    , Cmd.none
                    , Actions.none
                    )

                Ok response ->
                    case response.token of
                        Just token ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.startSession token
                            )

                        Nothing ->
                            ( { model | response = RemoteData.Success response }
                            , Cmd.none
                            , Actions.none
                            )


subscriptions model =
    Sub.none



-- VIEW
-- TODO add html validation


view : PublicContext -> Model -> Html Msg
view context model =
    div [ class "flex items-center justify-center pt-16" ]
        [ div []
            [ h1 []
                [ text "Sign up" ]
            , form
                [ class "bg-white shadow-md rounded p-8 mt-3", onSubmit Submit ]
                [ maybeErrors model
                , p []
                    [ label
                        [ class molecules.form.label ]
                        [ text "Name"
                        ]
                    , input
                        [ class molecules.form.input
                        , onInput ChangeName
                        , name "name"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ label
                        [ class molecules.form.label ]
                        [ text "Password"
                        ]
                    , input
                        [ class molecules.form.input
                        , type_ "password"
                        , onInput ChangePassword
                        , name "password"
                        ]
                        []
                    ]
                , p [ class "mt-6" ]
                    [ submit model
                    ]
                ]
            , links
            ]
        ]


submit : Model -> Html Msg
submit model =
    case model.response of
        RemoteData.Loading ->
            Icons.spinner

        _ ->
            button [ class molecules.form.submit ] [ text "Sign up" ]


maybeErrors : Model -> Html msg
maybeErrors model =
    case model.response of
        RemoteData.Success response ->
            if List.isEmpty response.errors then
                text ""

            else
                Forms.mutationError
                    "other"
                    response.errors

        RemoteData.Failure err ->
            Flash.error "Error"

        _ ->
            text ""


links =
    p [ class "mt-6" ]
        [ text "Already signed up? "
        , a [ href (Routes.pathFor Routes.routeForSignUp) ] [ text "Sign in" ]
        ]



-- GraphQL data


sendRedeemMutation : PublicContext -> SignUp -> String -> Cmd Msg
sendRedeemMutation context signUp invitationToken =
    sendPublicMutation
        context
        "reedeem-invitation"
        (createRedeemMutation signUp invitationToken)
        OnSubmitResponse


createRedeemMutation : SignUp -> String -> SelectionSet RedeemInvitationResponse RootMutation
createRedeemMutation signUp invitationToken =
    let
        input : ApiPub.InputObject.RedeemInvitationInput
        input =
            { name = signUp.name
            , username = signUp.username
            , password = signUp.password
            , token = invitationToken
            }
    in
    ApiPub.Mutation.selection identity
        |> with
            (ApiPub.Mutation.redeemInvitation
                { input = input }
                redeemResponseSelection
            )


redeemResponseSelection : SelectionSet RedeemInvitationResponse ApiPub.Object.RedeemInvitationResponse
redeemResponseSelection =
    ApiPub.Object.RedeemInvitationResponse.selection RedeemInvitationResponse
        |> with ApiPub.Object.RedeemInvitationResponse.success
        |> with (ApiPub.Object.RedeemInvitationResponse.errors mutationErrorPublicSelection)
        |> with ApiPub.Object.RedeemInvitationResponse.token
