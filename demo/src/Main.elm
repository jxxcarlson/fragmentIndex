module Main exposing (main)

{- This is a starter app which presents a text label, text field, and a button.
   What you enter in the text field is echoed in the label.  When you press the
   button, the text in the label is reverse.
   This version uses `mdgriffith/elm-ui` for the view functions.
-}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import File.Select as Select
import FragmentIndex exposing (FragmentIndex)
import Html exposing (Html)
import Set exposing (Set)
import Task


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { input : String
    , output : String
    , fileContents : String
    , fileName : String
    , lines : List ( String, Int )
    , index : FragmentIndex Int
    , searchString : String
    , searchHit : ( String, Int )
    , linesFound : Set Int
    }


type Msg
    = NoOp
    | FileRequested
    | FileLoaded File
    | ContentLoaded String
    | MakeIndex
    | InputText String
    | Search


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { input = "App started"
      , output = "App started"
      , fileContents = ""
      , fileName = "No file yet"
      , lines = []
      , index = FragmentIndex.empty
      , searchString = ""
      , searchHit = ( "", 0 )
      , linesFound = Set.empty
      }
    , Cmd.none
    )


subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FileRequested ->
            ( model, requestFile )

        FileLoaded file ->
            ( { model | fileName = File.name file }, read file )

        ContentLoaded content ->
            ( { model | fileContents = content, lines = processLines content }, Cmd.none )

        MakeIndex ->
            ( { model | index = makeIndex model.lines }, Cmd.none )

        InputText str ->
            ( { model | searchString = str }, Cmd.none )

        Search ->
            ( { model | linesFound = FragmentIndex.search model.searchString model.index }, Cmd.none )



-- FILE


requestFile : Cmd Msg
requestFile =
    Select.file [ "application/text" ] FileLoaded


read : File -> Cmd Msg
read file =
    Task.perform ContentLoaded (File.toString file)


processLines : String -> List ( String, Int )
processLines str =
    str
        |> String.lines
        |> List.indexedMap (\k line -> ( line, k ))


makeIndex : List ( String, Int ) -> FragmentIndex Int
makeIndex stringList =
    List.foldl (\( line, lineNumber ) dict -> FragmentIndex.insert line lineNumber dict)
        FragmentIndex.empty
        stringList



--
-- VIEW
--


view : Model -> Html Msg
view model =
    Element.layout [] (mainColumn model)


mainColumn : Model -> Element Msg
mainColumn model =
    column mainColumnStyle
        [ column [ centerX, spacing 24, Font.size 16 ]
            [ title "FragmentIndex Demo"
            , viewFileData model
            , column
                [ spacing 8 ]
                [ loadFileButton
                , makeIndexButton
                ]
            , column [ spacing 8 ]
                [ el [ moveLeft 4 ] (inputText model)
                , searchButton
                ]
            , column [ spacing 8 ]
                [ el [ Font.size 14 ] (text <| "Lines found: " ++ String.fromInt (Set.size model.linesFound))
                , el [ Font.size 14, width (px 450), scrollbarX ] (text <| displayLinesFound model)
                , viewLinesFound model
                ]
            ]
        ]


displayLinesFound : Model -> String
displayLinesFound model =
    model.linesFound
        |> Set.toList
        |> List.map String.fromInt
        |> String.join ", "


title : String -> Element msg
title str =
    row [ centerX, Font.bold, Font.size 24 ] [ text str ]


viewFileData : Model -> Element msg
viewFileData model =
    column [ spacing 8, Font.size 16 ]
        [ text model.fileName
        , text <| "Lines: " ++ String.fromInt (List.length model.lines)
        , text <| "Words: " ++ String.fromInt (List.length (String.words model.fileContents))
        , text <| "Index size: " ++ String.fromInt (FragmentIndex.size model.index)
        ]


viewLinesFound : Model -> Element msg
viewLinesFound model =
    let
        lineNumbers =
            model.linesFound
                |> Set.toList

        lines_ =
            List.filter (\( _, lineNumber ) -> List.member lineNumber lineNumbers) model.lines
    in
    column [ spacing 8, height (px 200), scrollbarY ]
        (List.map viewLine lines_)


viewLine : ( String, Int ) -> Element msg
viewLine ( line, lineNumber ) =
    row [ width (px 450), Font.size 14, spacing 8 ]
        [ el [ width (px 50) ] (text <| String.fromInt lineNumber)
        , el [ width (px 50) ] (text line)
        ]


loadFileButton : Element Msg
loadFileButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just FileRequested
            , label = el [ centerY ] (text "Load file")
            }
        ]


searchButton : Element Msg
searchButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just Search
            , label = el [ centerY ] (text "Search")
            }
        ]


makeIndexButton : Element Msg
makeIndexButton =
    row []
        [ Input.button buttonStyle
            { onPress = Just MakeIndex
            , label = el [ centerY ] (text "Make index")
            }
        ]


inputText : Model -> Element Msg
inputText model =
    Input.text [ height (px 40), width (px 400), Font.size 16 ]
        { onChange = InputText
        , text = model.searchString
        , placeholder = Just (Input.placeholder [] (text "search terms"))
        , label = Input.labelLeft [] <| el [] (text "")
        }



--
-- STYLE
--


mainColumnStyle =
    [ centerX
    , centerY
    , width (px 500)
    , height (px 600)
    , Background.color (rgb255 240 240 240)
    , paddingXY 20 20
    ]


buttonStyle =
    [ Background.color (rgb255 40 40 40)
    , Font.color (rgb255 200 200 200)
    , Font.size 16
    , width (px 100)
    , paddingXY 8 6
    ]
