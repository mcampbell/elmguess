module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import String exposing (..)


-- Model


type alias Model =
    { currentGuess : String
    , pastGuesses : List PastGuess
    , guessResult : Maybe String
    , secretAnswer : Int
    }


type alias PastGuess =
    { numericGuess : Int
    , result : String
    }


initModel : ( Model, Cmd Msg )
initModel =
    ( Model "" [] Nothing 42, Cmd.none )



-- update


type Msg
    = Input String
    | SubmitGuess
    | StartOver


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input guess ->
            ( { model | currentGuess = guess, guessResult = Nothing }, Cmd.none )

        SubmitGuess ->
            ( validateGuess model, Cmd.none )

        _ ->
            ( model, Cmd.none )


validateGuess : Model -> Model
validateGuess model =
    let
        parsed =
            String.toInt model.currentGuess
    in
        case parsed of
            Ok value ->
                { model | guessResult = Just ("Got value " ++ model.currentGuess) }

            Err msg ->
                { model | guessResult = Just ("Error: " ++ (toString msg)) }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- view


headerHtml : Model -> Html Msg
headerHtml model =
    header [] [ text "Guess A Number!" ]


mainHtml : Model -> Html Msg
mainHtml model =
    main' []
        [ explanation model
        , takeAGuess model
        ]


explanation : Model -> Html Msg
explanation model =
    div [ id "explanation" ]
        [ p [] [ text "I'm thinking of a number between 1 and 100.  Try to guess what it is." ]
        ]


takeAGuess : Model -> Html Msg
takeAGuess model =
    div [ id "guess" ]
        [ input [ type' "text", onInput Input, value model.currentGuess ] []
        , button [ type' "button", onClick SubmitGuess ] [ text "Guess!" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "guessnumber" ]
        [ headerHtml model
        , mainHtml model
        , p [] [ toString model |> text ]
        ]


main =
    App.program
        { init = initModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
