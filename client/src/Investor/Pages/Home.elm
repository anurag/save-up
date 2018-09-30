module Investor.Pages.Home exposing (Model, Msg, init, subscriptions, update, view)

import Api.Object
import Api.Object.Account
import Api.Object.Investor
import Api.Object.Transaction
import Api.Query
import Graphql.Field as Field
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class, href, name, src, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import RemoteData
import Shared.Actions as Actions
import Shared.Css exposing (molecules)
import Shared.Globals exposing (..)
import Shared.GraphQl as GraphQl exposing (GraphData, GraphResponse, MutationError)
import Shared.Routes as Routes
import Time exposing (Posix)
import UI.AccountInfo as AccountInfo
import UI.Chart as Chart
import UI.Empty as Empty


type alias Model =
    { data : GraphData Data
    }


newModel =
    { data = RemoteData.NotAsked
    }


type alias Data =
    { accounts : List Account
    }


type Msg
    = NoOp
    | OnData (GraphResponse Data)


type alias Returns =
    ( Model, Cmd Msg, Actions.Actions Msg )


init : Context -> Returns
init context =
    ( newModel, getData context, Actions.none )


update : Context -> Msg -> Model -> Returns
update context msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Actions.none )

        OnData result ->
            case result of
                Err e ->
                    ( { model
                        | data = RemoteData.Failure e
                      }
                    , Cmd.none
                    , Actions.none
                    )

                Ok data ->
                    ( { model
                        | data = RemoteData.Success data
                      }
                    , Cmd.none
                    , Actions.none
                    )


subscriptions model =
    Sub.none


view : Context -> Model -> Html Msg
view context model =
    let
        inner =
            case model.data of
                RemoteData.NotAsked ->
                    Empty.loading

                RemoteData.Loading ->
                    Empty.loading

                RemoteData.Failure e ->
                    Empty.graphError e

                RemoteData.Success data ->
                    viewWithData context model data
    in
    section [ class molecules.page.container ]
        [ h1 [ class molecules.page.title ] [ text "Your account" ]
        , inner
        ]


viewWithData : Context -> Model -> Data -> Html Msg
viewWithData context model data =
    if List.isEmpty data.accounts then
        Empty.noData

    else
        div [] (List.map accountView data.accounts)


accountView : Account -> Html Msg
accountView account =
    let
        info =
            AccountInfo.view
                { canAdmin = False
                , onEdit = NoOp
                }
                account
                Nothing
    in
    div [ class "mt-4" ]
        [ info
        , actions account
        , Chart.view account.transactions
        ]


actions account =
    p [ class "my-4" ]
        [ a
            [ class molecules.button.primary
            , href (Routes.pathFor (Routes.routeForInvestorRequestWithdrawal account.id))
            ]
            [ text "Request a withdrawal" ]
        ]



-- DATA


type alias Account =
    { id : Int
    , balanceInCents : Int
    , name : String
    , yearlyInterest : Float
    , transactions : List Transaction
    }


type alias Transaction =
    { createdAt : Posix
    , balanceInCents : Int
    }


getData : Context -> Cmd Msg
getData context =
    GraphQl.sendQuery
        context
        "investor-home-data"
        dataQuery
        OnData


dataQuery : SelectionSet Data RootQuery
dataQuery =
    Api.Query.selection identity
        |> with (Api.Query.investor investorSelection)


investorSelection : SelectionSet Data Api.Object.Investor
investorSelection =
    Api.Object.Investor.selection Data
        |> with (Api.Object.Investor.accounts accountSelection)


accountSelection : SelectionSet Account Api.Object.Account
accountSelection =
    Api.Object.Account.selection Account
        |> with Api.Object.Account.id
        |> with (Api.Object.Account.balanceInCents |> Field.map round)
        |> with Api.Object.Account.name
        |> with Api.Object.Account.yearlyInterest
        |> with (Api.Object.Account.transactions { since = 0 } transactionSelection)


transactionSelection : SelectionSet Transaction Api.Object.Transaction
transactionSelection =
    Api.Object.Transaction.selection Transaction
        |> with (Api.Object.Transaction.createdAt |> Field.mapOrFail GraphQl.unwrapNaiveDateTime)
        |> with (Api.Object.Transaction.balanceInCents |> Field.map round)
