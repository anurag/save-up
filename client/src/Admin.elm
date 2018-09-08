module Admin exposing (main)

import Admin.AppLocation as AppLocation exposing (AppLocation)
import Admin.Pages.Home as Home
import Admin.Pages.Invite as Invite
import Admin.Routes as Routes exposing (Route)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Shared.Context exposing (Context)
import Shared.Flags as Flags exposing (Flags)
import Shared.Pages.NotFound as NotFound
import Shared.Sessions as Sessions
import UI.Navigation as Navigation
import Url exposing (Url)


type alias Model =
    { flags : Flags
    , currentLocation : AppLocation
    , key : Nav.Key
    , page : Page
    }


initialModel : Flags -> Url -> Nav.Key -> Model
initialModel flags url key =
    { flags = flags
    , currentLocation = AppLocation.fromUrl url
    , key = key
    , page = Page_Home
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initialModel flags url key
    , Cmd.none
    )
        |> initCurrentPage


type Msg
    = SignOut
    | OnUrlChange Url
    | OnUrlRequest UrlRequest
    | PageInviteMsg Invite.Msg


type Page
    = Page_Home
    | Page_Invite Invite.Model
    | Page_NotFound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        context =
            newContext model
    in
    case msg of
        SignOut ->
            ( model, Sessions.toJsSignOut () )

        OnUrlChange url ->
            let
                newLocation =
                    AppLocation.fromUrl url
            in
            ( { model | currentLocation = newLocation }
            , Cmd.none
            )
                |> initCurrentPage

        OnUrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        PageInviteMsg sub ->
            case model.page of
                Page_Invite pageModel ->
                    let
                        ( newPageModel, pageCmd ) =
                            Invite.update
                                context
                                sub
                                pageModel
                    in
                    ( { model | page = Page_Invite newPageModel }
                    , Cmd.map PageInviteMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )


newContext : Model -> Context
newContext model =
    { flags = model.flags
    }


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, cmds ) =
    let
        ( newPage, newCmd ) =
            case model.currentLocation.route of
                Routes.Route_Home ->
                    ( Page_Home, Cmd.none )

                Routes.Route_Invite ->
                    let
                        ( pageModel, pageCmd ) =
                            Invite.init
                    in
                    ( Page_Invite pageModel, Cmd.map PageInviteMsg pageCmd )

                Routes.Route_NotFound ->
                    ( Page_Home, Cmd.none )
    in
    ( { model | page = newPage }, Cmd.batch [ cmds, newCmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model.page of
                Page_NotFound ->
                    Sub.none

                Page_Home ->
                    Sub.none

                Page_Invite pageModel ->
                    Sub.map PageInviteMsg (Invite.subscriptions pageModel)
    in
    Sub.batch
        [ pageSub
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "SaveUp"
    , body =
        [ navigation model
        , currentPage model
        ]
    }


navigation : Model -> Html Msg
navigation model =
    nav [ class "flex p-4 bg-black text-white" ]
        [ Navigation.logo
        , div
            [ class "ml-8 flex-grow" ]
            [ navigationLink Routes.Route_Home "Home"
            , navigationLink Routes.Route_Invite "Invite"
            ]
        , div []
            [ text model.flags.tokenData.name
            , Navigation.signOut SignOut
            ]
        ]


navigationLink : Route -> String -> Html Msg
navigationLink route label =
    a
        [ href (Routes.pathFor route)
        , class "text-white mr-4 no-underline"
        ]
        [ text label ]


currentPage : Model -> Html Msg
currentPage model =
    let
        context =
            newContext model

        page =
            case model.page of
                Page_NotFound ->
                    NotFound.view

                Page_Home ->
                    Home.view context

                Page_Invite pageModel ->
                    Invite.view context pageModel
                        |> map PageInviteMsg
    in
    section [ class "p-4" ]
        [ page
        ]


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }
