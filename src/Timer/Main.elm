port module Timer.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src, style, class)
import Time exposing (..)
import Timer.Timer exposing (..)


type alias Model =
    { driver : String, navigator : String, secondsLeft : Int, originalDurationSeconds : Int }


type Msg
    = Tick Time.Time


type alias Flags =
    { minutes : Int, driver : String, navigator : String, isDev : Bool }


port timerDone : Int -> Cmd msg


driverView : String -> Html msg
driverView name =
    p []
        [ iconView "./assets/driver-icon.png"
        , text name
        ]


navigatorView : String -> Html msg
navigatorView name =
    p []
        [ iconView "./assets/navigator-icon.png"
        , text name
        ]


iconView : String -> Html msg
iconView iconUrl =
    img [ style [ ( "max-width", "20px" ) ], src iconUrl ] []


view : Model -> Html msg
view model =
    div [ class "text-center" ]
        [ h1 [] [ text (timerToString (secondsToTimer model.secondsLeft)) ]
        , driverView model.driver
        , navigatorView model.navigator
        ]


updateTimer : Int -> Int
updateTimer seconds =
    seconds - 1


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            let
                updatedSecondsLeft =
                    updateTimer model.secondsLeft
            in
                if updatedSecondsLeft <= 0 then
                    model ! [ timerDone model.originalDurationSeconds ]
                else
                    { model | secondsLeft = updatedSecondsLeft } ! []


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        secondsLeft =
            if flags.isDev then
                -- just show timer for one second no matter what it's set to
                1
            else
                flags.minutes * 60
    in
        ( { secondsLeft = secondsLeft, driver = flags.driver, navigator = flags.navigator, originalDurationSeconds = secondsLeft }, Cmd.none )


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = \_ -> every second Tick
        , update = update
        , view = view
        }
