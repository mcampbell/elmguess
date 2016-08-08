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
    , guessResult : Maybe GuessResult
    , secretAnswer : Int
    }


type alias PastGuess =
    { numericGuess : Int
    , result : GuessResult
    }


initModel : Model
initModel =
    Model "" [] Nothing 42



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
            ( initModel, Cmd.none )


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
    p []
        [ text
            (case model.guessResult of
                Nothing ->
                    ""

                Just val ->
                    toString val
            )
        ]


pastGuesses : Model -> Html Msg
pastGuesses model =
    div []
        [ pastGuessesCount model
        , pastGuessesList model
        ]


pastGuessesCount : Model -> Html Msg
pastGuessesCount model =
    let
        guessCount =
            toString (List.length model.pastGuesses)
    in
        div []
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
    case pg.result of
        High ->
            ( "toohigh", (toGrString pg.result) )

        Low ->
            ( "toolow", (toGrString pg.result) )

        Correct ->
            ( "right", (toGrString pg.result) )

        Error msg ->
            ( "error", (toGrString pg.result) )


startOver : Model -> Html Msg
startOver model =
    button [ type' "button", onClick StartOver ] [ text "Start Over" ]


view : Model -> Html Msg
view model =
    div [ class "guessnumber" ]
        [ headerHtml model
        , mainHtml model
        , p [] [ toString model |> text ]
        ]


main =
    App.program
        { init = ( initModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
