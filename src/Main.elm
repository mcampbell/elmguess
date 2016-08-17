port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import String exposing (..)
import Random exposing (..)
import Time exposing (..)
import Task exposing (..)
import Basics.Extra exposing (never)


-- Model


prng : Random.Generator Int
prng =
    Random.int 1 100



-- port gibberish : Int


type alias Model =
    { currentGuess : String
    , pastGuesses : List PastGuess
    , guessResult : Maybe GuessResult
    , currentTime : Float
    , seed : Maybe Seed
    , secretAnswer : Int
    }


type alias PastGuess =
    { numericGuess : Int
    , result : GuessResult
    }


initModel : Model
initModel =
    { currentGuess = ""
    , pastGuesses = []
    , guessResult = Nothing
    , currentTime = 0.0
    , seed = Nothing
    , secretAnswer = 0
    }



-- update


type GuessResult
    = High
    | Low
    | Correct
    | Error String


type Msg
    = Input String
    | SubmitGuess
    | StartOver
    | TimeSuccess Float


toGrString : GuessResult -> String
toGrString gr =
    case gr of
        High ->
            "Too High"

        Low ->
            "Too Low"

        Correct ->
            "Right"

        Error str ->
            "Error: " ++ str


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input guess ->
            ( { model | currentGuess = guess, guessResult = Nothing }, Cmd.none )

        SubmitGuess ->
            ( parseGuess model, Cmd.none )

        StartOver ->
            ( generateNewAnswer model, Cmd.none )

        TimeSuccess t ->
            let
                initSeed =
                    initialSeed (round t)

                ( newAnswer, newSeed ) =
                    Random.step prng initSeed
            in
                ( { model | secretAnswer = newAnswer, seed = Just newSeed, currentTime = t }, Cmd.none )


divineCurrentTime : Cmd Msg
divineCurrentTime =
    Task.perform never TimeSuccess Time.now


generateNewAnswer : Model -> Model
generateNewAnswer model =
    let
        oldSeed =
            case model.seed of
                Just s ->
                    s

                _ ->
                    initialSeed 0

        ( newAnswer, newSeed ) =
            Random.step prng oldSeed
    in
        { model | seed = Just newSeed, secretAnswer = newAnswer, pastGuesses = [], guessResult = Nothing, currentGuess = "" }


parseGuess : Model -> Model
parseGuess model =
    let
        parsed =
            String.toInt model.currentGuess
    in
        case parsed of
            Ok value ->
                validateNumberGuess model value

            Err msg ->
                { model | currentGuess = "", guessResult = Just (Error msg) }


validateNumberGuess : Model -> Int -> Model
validateNumberGuess model guess =
    if guess == model.secretAnswer then
        let
            r =
                Correct

            pastGuess =
                PastGuess guess r
        in
            { model | guessResult = Just r, currentGuess = "", pastGuesses = pastGuess :: model.pastGuesses }
    else if guess < model.secretAnswer then
        let
            r =
                Low

            pastGuess =
                PastGuess guess r
        in
            { model | guessResult = Just r, currentGuess = "", pastGuesses = pastGuess :: model.pastGuesses }
    else
        let
            r =
                High

            pastGuess =
                PastGuess guess r
        in
            { model | guessResult = Just r, currentGuess = "", pastGuesses = pastGuess :: model.pastGuesses }



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
        , guessResult model
        , pastGuesses model
        , startOver model
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


guessResult : Model -> Html Msg
guessResult model =
    let
        gr =
            model.guessResult

        ( cls, txt ) =
            case gr of
                Nothing ->
                    ( "", "" )

                Just val ->
                    ( resultClass val, toGrString val )
    in
        div [ id "result" ]
            [ p [ class cls ]
                [ text txt ]
            ]


pastGuesses : Model -> Html Msg
pastGuesses model =
    div [ id "guesslist" ]
        [ pastGuessesCount model
        , pastGuessesList model
        ]


pastGuessesCount : Model -> Html Msg
pastGuessesCount model =
    let
        guessCount =
            toString (List.length model.pastGuesses)
    in
        div [ id "guesscount" ]
            [ div [] [ text "Guesses:" ]
            , div [] [ text guessCount ]
            ]


pastGuessesList : Model -> Html Msg
pastGuessesList model =
    let
        guesses =
            model.pastGuesses
    in
        div [ id "guesses" ]
            [ ul [] (List.map pastGuessItem guesses) ]


pastGuessItem : PastGuess -> Html Msg
pastGuessItem pastGuess =
    let
        ( cls, txt ) =
            listItemClassText pastGuess
    in
        li []
            [ div [] [ text (toString pastGuess.numericGuess) ]
            , div [ class cls ] [ text txt ]
            ]


listItemClassText : PastGuess -> ( String, String )
listItemClassText pg =
    ( resultClass pg.result, toGrString pg.result )


resultClass : GuessResult -> String
resultClass gr =
    case gr of
        High ->
            "toohigh"

        Low ->
            "toolow"

        Correct ->
            "justright"

        Error msg ->
            "error"


startOver : Model -> Html Msg
startOver model =
    div [ id "startover" ]
        [ button [ type' "button", onClick StartOver ] [ text "Start Over" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "guessnumber" ]
        [ headerHtml model
        , mainHtml model
        , p [] [ text (toString model) ]
        ]


main =
    App.program
        { init = ( initModel, divineCurrentTime )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
