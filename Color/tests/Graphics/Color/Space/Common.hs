{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
module Graphics.Color.Space.Common
  ( module Graphics.Color.Space
  , module Graphics.Color.Model.Common
  , colorSpaceSpec
  , colorSpaceLenientSpec
  , colorSpaceCommonSpec
  , prop_toFromColorXYZ
  , prop_LuminanceColorXYZ
  , prop_toFromLenientColorXYZ
  , prop_toFromBaseSpace
  ) where

import Data.Coerce
import Graphics.Color.Space
import Graphics.Color.Model.Common

instance (Elevator e, Random e) => Arbitrary (Color X e) where
  arbitrary = coerce $ arbitraryElevator @e

instance (Elevator e, Random e) => Arbitrary (Color (Y i) e) where
  arbitrary = coerce $ arbitraryElevator @e

instance (Elevator e, Random e) => Arbitrary (Color (XYZ i) e) where
  arbitrary = ColorXYZ <$> arbitraryElevator <*> arbitraryElevator <*> arbitraryElevator


prop_toFromColorXYZ ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => Color cs e
  -> Property
prop_toFromColorXYZ c = c `epsilonEqColor` fromColorXYZ (toColorXYZ c :: Color (XYZ i) Double)


-- For RGB standards, that have matrices rounded to 4 digits after the decimal point
prop_toFromLenientColorXYZ ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => e
  -> Color cs e
  -> Property
prop_toFromLenientColorXYZ epsilon c =
  epsilonEqColorTol epsilon c (fromColorXYZ (toColorXYZ c :: Color (XYZ i) Double))

prop_LuminanceColorXYZ :: forall cs e i . ColorSpace cs i e => Color cs e -> Property
prop_LuminanceColorXYZ c =
  (luminance c :: Color (Y i) Float) `epsilonEqColor`
  luminance (toColorXYZ c :: Color (XYZ i) Float)

prop_toFromBaseSpace ::
     forall cs e i. (ColorSpace cs i e, ColorSpace (BaseSpace cs) i e, RealFloat e)
  => Color cs e
  -> Property
prop_toFromBaseSpace c = c `epsilonEqColor` fromBaseSpace (toBaseSpace c)

prop_toFromBaseSpaceLenient ::
     forall cs e i. (ColorSpace cs i e, ColorSpace (BaseSpace cs) i e, RealFloat e)
  => e
  -> Color cs e
  -> Property
prop_toFromBaseSpaceLenient epsilon c = epsilonEqColorTol epsilon c $ fromBaseSpace (toBaseSpace c)


prop_toFromBaseModel ::
     forall cs e i. ColorSpace cs i e
  => Color cs e
  -> Property
prop_toFromBaseModel c = c === fromBaseModel (toBaseModel c)

prop_toApplyGrayscale ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => e
  -> Color cs e
  -> Property
prop_toApplyGrayscale epsilon c = epsilonEqColorTol epsilon c $ applyGrayscale c id

prop_toReplaceGrayscale ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => e
  -> Color cs e
  -> Property
prop_toReplaceGrayscale epsilon c =
  epsilonEqColorTol epsilon c (replaceGrayscale c (grayscale c))

prop_toApplyGrayscaleAsReplace ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => e
  -> Color cs e
  -> Fun (Color X e) (Color X e)
  -> Property
prop_toApplyGrayscaleAsReplace epsilon c f =
  epsilonEqColorTol
    epsilon
    (applyGrayscale c (applyFun f))
    (replaceGrayscale c (applyFun f (grayscale c)))


prop_toReplaceGrayscaleAsApply ::
     forall cs e i. (ColorSpace cs i e, RealFloat e)
  => e
  -> Color cs e
  -> Color X e
  -> Property
prop_toReplaceGrayscaleAsApply epsilon c y =
  epsilonEqColorTol epsilon (replaceGrayscale c y) (applyGrayscale c (const y))


colorSpaceCommonSpec ::
     forall cs e i.
     (Arbitrary (Color cs e), ColorSpace cs i e)
  => Spec -> Spec
colorSpaceCommonSpec extra =
  describe "ColorSpace" $ do
    prop "luminance . toColorXYZ" $ prop_LuminanceColorXYZ @cs @e @i
    prop "toFromBaseModel" $ prop_toFromBaseModel @cs @e @i
    extra

colorSpaceSpec ::
     forall cs e i.
     (Arbitrary (Color cs e), ColorSpace (BaseSpace cs) i e, ColorSpace cs i e, RealFloat e)
  => Spec
colorSpaceSpec =
  colorSpaceCommonSpec @cs @e @i $ do
    prop "toFromBaseSpace" $ prop_toFromBaseSpace @cs @e @i
    prop "toFromColorXYZ" $ prop_toFromColorXYZ @cs @e @i

colorSpaceLenientSpec ::
     forall cs e i.
     ( Arbitrary (Color cs e)
     , ColorSpace (BaseSpace cs) i e
     , ColorSpace cs i e
     , RealFloat e
     , Function e
     , Random e
     , CoArbitrary e
     )
  => e
  -> Spec
colorSpaceLenientSpec tol =
  let tolStr = "(lenient=" ++ show tol ++ ")"
  in colorSpaceCommonSpec @cs @e @i $ do
       prop ("toFromBaseSpace " ++ tolStr) $ prop_toFromBaseSpaceLenient @cs @e @i tol
       prop ("toFromColorXYZ " ++ tolStr) $ prop_toFromLenientColorXYZ @cs @e @i tol
       prop ("toReplaceGrayscale " ++ tolStr) $ prop_toReplaceGrayscale @cs @e @i tol
       prop ("toReplaceGrayscaleAsApply " ++ tolStr) $ prop_toReplaceGrayscaleAsApply @cs @e @i tol
       prop ("toApplyGrayscale" ++ tolStr) $ prop_toApplyGrayscale @cs @e @i tol
       prop ("toApplyGrayscaleAsReplace" ++ tolStr) $ prop_toApplyGrayscaleAsReplace @cs @e @i tol
