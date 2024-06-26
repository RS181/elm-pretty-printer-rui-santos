module GPretty.GRenderer exposing (pretty, Renderer)

{-| Pretty.Renderer lets you specify custom rendering functions to modify the
output of the pretty printer as it is layed out. You do not need to use this
module for the default monochrome text only rendering which can be achieved
with `Pretty.pretty`.

If you have a tagged `Doc` model, you can use the tags to do syntax highlighting
with a custom `Renderer`. You can also turn the output into other structured
forms such as HTML.

@docs pretty, Renderer

-}

import GInternals exposing (Doc(..), Normal(..))



-- Pretty printing -------------------------------------------------------------


{-| Pretty prints a document trying to fit it as best as possible to the specified
column width of the page.

A custom `Renderer` must be specified to handle the different parts of the output.

-}
pretty : Int -> Renderer t a b -> Doc t -> b
pretty w handler doc =
    layout handler (GInternals.best w 0 doc)


{-| A custom `Renderer`.

This works a bit like a `foldl` operation. Note that the text being rendered
is folded left to right, which means if you accumulate intermediate results into
`List`s, you will need to reverse them.

  - The `init` value defines the initial state of an accumulator that is passed
    over the entire rendering.

  - Tagged and untagged string from the `Doc` are passed through the `tagged`
    and `untagged` functions. (DEPRECATED)

  - When the end of a line is reached, `untagged` is invoked to update the
    accumulator. Note that you must manually add `\n` newline character here if
    you need one. You may not be using newlines for an HTML rendering.

  - The `outer` function is invoked on the complete accumulator, and provides an
    opportunity to complete the layout, for example by adding outer HTML tags
    around in, and so on.

  - The `open` and `close` functions are passed through the `tagged`, `openTag` and 
  `closeTag` functions.  

-}
type alias Renderer t a b =
    { init : a
    , open :  t -> a -> a 
    , close :  t -> a -> a 
    ,string :String -> a -> a
    , untagged : String -> a -> a -- this is not needed (REMOVE)
    , newline : a -> a
    , outer : a -> b
    }


layout : Renderer t a b -> Normal t -> b
layout handler normal =
    let
        layoutInner : Normal t -> a -> a
        layoutInner normal2 acc =
            case normal2 of
                NNil ->
                    acc
                NText text innerNormal  ->  
                    layoutInner (innerNormal()) (handler.string text acc)
                NLine i sep innerNormal ->
                    let
                        norm =
                            innerNormal ()
                    in
                    case norm of
                        NLine _ _ _ ->
                            case sep of
                                "" ->
                                    layoutInner (innerNormal ())
                                        (handler.newline acc)

                                _ ->
                                    layoutInner (innerNormal ())
                                        (handler.untagged sep (handler.newline acc))

                        _ ->
                            layoutInner (innerNormal ())
                                (handler.untagged (GInternals.copy i " " ++ sep) (handler.newline acc))

                Nopen tag innerNormal ->
                    layoutInner (innerNormal ()) 
                        (handler.open tag acc)

                Nclose tag innerNormal ->
                    layoutInner (innerNormal ())
                        (handler.close tag acc)
                   
    in
    layoutInner normal handler.init
        |> handler.outer
