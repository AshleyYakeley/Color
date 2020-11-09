{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ViewPatterns #-}
-- |
-- Module      : Graphics.Color.Space.RGB.Alternative.YCbCr
-- Copyright   : (c) Alexey Kuleshevich 2019-2020
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.Color.Space.RGB.Alternative.YCbCr
  ( pattern ColorY'CbCr
  , pattern ColorY'CbCrA
  , Y'CbCr
  , Color(Y'CbCr)
  , ycbcr2srgb
  , srgb2ycbcr
  , toColorY'CbCr
  , fromColorY'CbCr
  , module Graphics.Color.Space.RGB.Luma
  ) where

import Data.Coerce
import Data.Kind
import Data.Proxy
import Data.Typeable
import Foreign.Storable
import Graphics.Color.Model.Internal
import qualified Graphics.Color.Model.YCbCr as CM
import Graphics.Color.Space.Internal
import Graphics.Color.Space.RGB.Internal
import Graphics.Color.Space.RGB.ITU.Rec601
import Graphics.Color.Space.RGB.ITU.Rec709
import Graphics.Color.Space.RGB.Luma
import Graphics.Color.Space.RGB.SRGB

-- | `Y'CbCr` representation for some non-linear (@`RedGreenBlue` cs i@) color space
data Y'CbCr (cs :: Linearity -> Type)

-- | Constructor  for `Y'CbCr` color space
newtype instance Color (Y'CbCr cs) e = Y'CbCr (Color CM.YCbCr e)

deriving instance Eq e => Eq (Color (Y'CbCr cs) e)
deriving instance Ord e => Ord (Color (Y'CbCr cs) e)
deriving instance Functor (Color (Y'CbCr cs))
deriving instance Applicative (Color (Y'CbCr cs))
deriving instance Foldable (Color (Y'CbCr cs))
deriving instance Traversable (Color (Y'CbCr cs))
deriving instance Storable e => Storable (Color (Y'CbCr cs) e)

instance (Typeable cs, ColorModel (cs 'NonLinear) e, Elevator e) => Show (Color (Y'CbCr cs) e) where
  showsPrec _ = showsColorModel

-- | Constructor for an RGB color space in an alternative Y'CbCr color model
pattern ColorY'CbCr :: e -> e -> e -> Color (Y'CbCr cs) e
pattern ColorY'CbCr y cb cr = Y'CbCr (CM.ColorYCbCr y cb cr)
{-# COMPLETE ColorY'CbCr #-}

-- | Constructor for @Y'CbCr@ with alpha channel.
pattern ColorY'CbCrA :: e -> e -> e -> e -> Color (Alpha (Y'CbCr cs)) e
pattern ColorY'CbCrA y cb cr a = Alpha (Y'CbCr (CM.ColorYCbCr y cb cr)) a
{-# COMPLETE ColorY'CbCrA #-}


instance (Typeable cs, ColorModel (cs 'NonLinear) e, Elevator e) => ColorModel (Y'CbCr cs) e where
  type Components (Y'CbCr cs) e = (e, e, e)
  type ChannelCount (Y'CbCr cs) = 3
  channelCount _ = 3
  {-# INLINE channelCount #-}
  channelNames _ = channelNames (Proxy :: Proxy (Color CM.YCbCr e))
  channelColors _ = channelColors (Proxy :: Proxy (Color CM.YCbCr e))
  toComponents (ColorY'CbCr y cb cr) = (y, cb, cr)
  {-# INLINE toComponents #-}
  fromComponents (y, cb, cr) = ColorY'CbCr y cb cr
  {-# INLINE fromComponents #-}
  showsColorModelName _ =
    ("Y'CbCr-" ++) . showsColorModelName (Proxy :: Proxy (Color (cs 'NonLinear) e))

instance Elevator e => ColorSpace (Y'CbCr SRGB) D65 e where
  type BaseModel (Y'CbCr SRGB) = CM.YCbCr
  type BaseSpace (Y'CbCr SRGB) = SRGB 'NonLinear
  toBaseSpace = fmap fromRealFloat . ycbcr2srgb . fmap toFloat
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = fmap fromRealFloat . srgb2ycbcr . fmap toFloat
  {-# INLINE fromBaseSpace #-}
  luminance = luminance . toBaseSpace
  {-# INLINE luminance #-}
  grayscale (coerce -> V3 y' _ _) = X y'
  {-# INLINE grayscale #-}
  replaceGrayscale (coerce -> V3 _ cb cr) (X y') = coerce (V3 y' cb cr)
  {-# INLINE replaceGrayscale #-}

instance Elevator e => ColorSpace (Y'CbCr BT601_525) D65 e where
  type BaseModel (Y'CbCr BT601_525) = CM.YCbCr
  type BaseSpace (Y'CbCr BT601_525) = BT601_525 'NonLinear
  toBaseSpace = fmap fromDouble . fromColorY'CbCr
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = fmap fromDouble . toColorY'CbCr
  {-# INLINE fromBaseSpace #-}
  luminance = luminance . toBaseSpace
  {-# INLINE luminance #-}
  grayscale (coerce -> V3 y' _ _) = X y'
  {-# INLINE grayscale #-}
  replaceGrayscale (coerce -> V3 _ cb cr) (X y') = coerce (V3 y' cb cr)
  {-# INLINE replaceGrayscale #-}

instance Elevator e => ColorSpace (Y'CbCr BT601_625) D65 e where
  type BaseModel (Y'CbCr BT601_625) = CM.YCbCr
  type BaseSpace (Y'CbCr BT601_625) = BT601_625 'NonLinear
  toBaseSpace = fmap fromDouble . fromColorY'CbCr
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = fmap fromDouble . toColorY'CbCr
  {-# INLINE fromBaseSpace #-}
  luminance = luminance . toBaseSpace
  {-# INLINE luminance #-}
  grayscale (coerce -> V3 y' _ _) = X y'
  {-# INLINE grayscale #-}
  replaceGrayscale (coerce -> V3 _ cb cr) (X y') = coerce (V3 y' cb cr)
  {-# INLINE replaceGrayscale #-}

instance Elevator e => ColorSpace (Y'CbCr BT709) D65 e where
  type BaseModel (Y'CbCr BT709) = CM.YCbCr
  type BaseSpace (Y'CbCr BT709) = BT709 'NonLinear
  toBaseSpace = fmap fromDouble . fromColorY'CbCr
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = fmap fromDouble . toColorY'CbCr
  {-# INLINE fromBaseSpace #-}
  luminance = luminance . toBaseSpace
  {-# INLINE luminance #-}
  grayscale (coerce -> V3 y' _ _) = X y'
  {-# INLINE grayscale #-}
  replaceGrayscale (coerce -> V3 _ cb cr) (X y') = coerce (V3 y' cb cr)
  {-# INLINE replaceGrayscale #-}

instance (Typeable cs, Luma (cs i), ColorSpace (cs i 'NonLinear) i e, RedGreenBlue (cs i) i) =>
         ColorSpace (Y'CbCr (cs i)) i e where
  type BaseModel (Y'CbCr (cs i)) = CM.YCbCr
  type BaseSpace (Y'CbCr (cs i)) = cs i 'NonLinear
  toBaseSpace = fmap fromDouble . fromColorY'CbCr
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = fmap fromDouble . toColorY'CbCr
  {-# INLINE fromBaseSpace #-}
  luminance = luminance . toBaseSpace
  {-# INLINE luminance #-}
  grayscale (coerce -> V3 y' _ _) = X y'
  {-# INLINE grayscale #-}
  replaceGrayscale (coerce -> V3 _ cb cr) (X y') = coerce (V3 y' cb cr)
  {-# INLINE replaceGrayscale #-}


-- | This conversion is only correct for sRGB and Rec601. Source: ITU-T Rec. T.871
--
-- @since 0.1.3
ycbcr2srgb ::
     (RedGreenBlue cs i, RealFloat e) => Color (Y'CbCr cs) e -> Color (cs 'NonLinear) e
ycbcr2srgb = ycbcrToRec601 . coerce
{-# INLINE ycbcr2srgb #-}

-- | This conversion is only correct for sRGB and Rec601. Source: ITU-T Rec. T.871
--
-- @since 0.1.3
srgb2ycbcr ::
     (RedGreenBlue cs i, RealFloat e) => Color (cs 'NonLinear) e -> Color (Y'CbCr cs) e
srgb2ycbcr = coerce . rec601ToYcbcr
{-# INLINE srgb2ycbcr #-}

-- | Convert any RGB color space that has `Luma` specified to `Y'CbCr`
--
-- @since 0.1.3
toColorY'CbCr ::
     forall cs i e' e. (Luma cs, RedGreenBlue cs i, Elevator e', Elevator e, RealFloat e)
  => Color (cs 'NonLinear) e'
  -> Color (Y'CbCr cs) e
toColorY'CbCr rgb = Y'CbCr (CM.rgb2ycbcr (unColorRGB rgb) weights)
  where
    !weights = rgbLumaWeights rgb
{-# INLINE toColorY'CbCr #-}

-- | Convert `Y'CbCr` to the base RGB color space, which must have `Luma` implemented.
--
-- @since 0.1.3
fromColorY'CbCr ::
     forall cs i e' e. (Luma cs, RedGreenBlue cs i, Elevator e', Elevator e, RealFloat e)
  => Color (Y'CbCr cs) e'
  -> Color (cs 'NonLinear) e
fromColorY'CbCr ycbcr = rgb
  where
    !rgb = mkColorRGB (CM.ycbcr2rgb (coerce ycbcr :: Color CM.YCbCr e') weights)
    !weights = rgbLumaWeights rgb
{-# INLINE fromColorY'CbCr #-}
