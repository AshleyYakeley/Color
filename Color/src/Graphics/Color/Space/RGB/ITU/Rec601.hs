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
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
-- |
-- Module      : Graphics.Color.Space.RGB.ITU.Rec601
-- Copyright   : (c) Alexey Kuleshevich 2019-2020
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.Color.Space.RGB.ITU.Rec601
  ( pattern BT601_525
  , BT601_525
  , pattern BT601_625
  , BT601_625
  , D65
  , ycbcrToRec601
  , rec601ToYcbcr
  , applyGrayscaleRec601
  ) where

import Data.Coerce
import Data.Typeable
import Foreign.Storable
import Graphics.Color.Illuminant.ITU.Rec601
import Graphics.Color.Model.Internal
import qualified Graphics.Color.Model.RGB as CM
import qualified Graphics.Color.Model.YCbCr as CM
import Graphics.Color.Space.Internal
import Graphics.Color.Space.RGB.Internal
import Graphics.Color.Space.RGB.ITU.Rec470 (BT470_625)
import Graphics.Color.Space.RGB.Luma



------------------------------------
-- ITU-R BT.601 (525) --------------
------------------------------------

-- | [ITU-R BT.601](https://en.wikipedia.org/wiki/Rec._601) (525) color space
data BT601_525 (l :: Linearity)

newtype instance Color (BT601_525 l) e = BT601_525 (Color CM.RGB e)

-- | ITU-R BT.601 (525) color space
deriving instance Eq e => Eq (Color (BT601_525 l) e)
-- | ITU-R BT.601 (525) color space
deriving instance Ord e => Ord (Color (BT601_525 l) e)
-- | ITU-R BT.601 (525) color space
deriving instance Functor (Color (BT601_525 l))
-- | ITU-R BT.601 (525) color space
deriving instance Applicative (Color (BT601_525 l))
-- | ITU-R BT.601 (525) color space
deriving instance Foldable (Color (BT601_525 l))
-- | ITU-R BT.601 (525) color space
deriving instance Traversable (Color (BT601_525 l))
-- | ITU-R BT.601 (525) color space
deriving instance Storable e => Storable (Color (BT601_525 l) e)

-- | ITU-R BT.601 (525) color space
instance  (Typeable l, Elevator e) => Show (Color (BT601_525 l) e) where
  showsPrec _ = showsColorModel

-- | ITU-R BT.601 (525) color space
instance  (Typeable l, Elevator e) => ColorModel (BT601_525 l) e where
  type Components (BT601_525 l) e = (e, e, e)
  toComponents = toComponents . unColorRGB
  {-# INLINE toComponents #-}
  fromComponents = mkColorRGB . fromComponents
  {-# INLINE fromComponents #-}

-- | ITU-R BT.601 (525) linear color space
instance Elevator e => ColorSpace (BT601_525 'Linear) D65 e where
  type BaseModel (BT601_525 'Linear) = CM.RGB
  toBaseSpace = id
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = id
  {-# INLINE fromBaseSpace #-}
  luminance = rgbLinearLuminance . fmap toRealFloat
  {-# INLINE luminance #-}
  grayscale = rgbLinearGrayscale
  {-# INLINE grayscale #-}
  applyGrayscale = rgbLinearApplyGrayscale
  {-# INLINE applyGrayscale #-}
  toColorXYZ = rgbLinear2xyz . fmap toRealFloat
  {-# INLINE toColorXYZ #-}
  fromColorXYZ = fmap fromRealFloat . xyz2rgbLinear
  {-# INLINE fromColorXYZ #-}


-- | ITU-R BT.601 (525) linear color space
instance Elevator e => ColorSpace (BT601_525 'NonLinear) D65 e where
  type BaseModel (BT601_525 'NonLinear) = CM.RGB
  toBaseSpace = id
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = id
  {-# INLINE fromBaseSpace #-}
  luminance = rgbLuminance . fmap toRealFloat
  {-# INLINE luminance #-}
  grayscale = fmap fromDouble . coerce . rgbLuma @_ @_ @_ @Double
  {-# INLINE grayscale #-}
  applyGrayscale = applyGrayscaleRec601
  {-# INLINE applyGrayscale #-}
  toColorXYZ = rgb2xyz . fmap toRealFloat
  {-# INLINE toColorXYZ #-}
  fromColorXYZ = fmap fromRealFloat . xyz2rgb
  {-# INLINE fromColorXYZ #-}

-- | ITU-R BT.601 (525) color space
instance RedGreenBlue BT601_525 D65 where
  gamut = Gamut (Primary 0.630 0.340)
                (Primary 0.310 0.595)
                (Primary 0.155 0.070)
  transfer = transferRec601
  {-# INLINE transfer #-}
  itransfer = itransferRec601
  {-# INLINE itransfer #-}

------------------------------------
-- ITU-R BT.601 (625) --------------
------------------------------------

-- | [ITU-R BT.601](https://en.wikipedia.org/wiki/Rec._601) (625) color space
data BT601_625 (l :: Linearity)

newtype instance Color (BT601_625 l) e = BT601_625 (Color CM.RGB e)

-- | ITU-R BT.601 (625) color space
deriving instance Eq e => Eq (Color (BT601_625 l) e)
-- | ITU-R BT.601 (625) color space
deriving instance Ord e => Ord (Color (BT601_625 l) e)
-- | ITU-R BT.601 (625) color space
deriving instance Functor (Color (BT601_625 l))
-- | ITU-R BT.601 (625) color space
deriving instance Applicative (Color (BT601_625 l))
-- | ITU-R BT.601 (625) color space
deriving instance Foldable (Color (BT601_625 l))
-- | ITU-R BT.601 (625) color space
deriving instance Traversable (Color (BT601_625 l))
-- | ITU-R BT.601 (625) color space
deriving instance Storable e => Storable (Color (BT601_625 l) e)

-- | ITU-R BT.601 (625) color space
instance (Typeable l, Elevator e) => Show (Color (BT601_625 l) e) where
  showsPrec _ = showsColorModel

-- | ITU-R BT.601 (625) color space
instance (Typeable l, Elevator e) => ColorModel (BT601_625 l) e where
  type Components (BT601_625 l) e = (e, e, e)
  toComponents = toComponents . unColorRGB
  {-# INLINE toComponents #-}
  fromComponents = mkColorRGB . fromComponents
  {-# INLINE fromComponents #-}

-- | ITU-R BT.601 (625) linear color space
instance Elevator e => ColorSpace (BT601_625 'Linear) D65 e where
  type BaseModel (BT601_625 'Linear) = CM.RGB
  toBaseSpace = id
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = id
  {-# INLINE fromBaseSpace #-}
  luminance = rgbLinearLuminance . fmap toRealFloat
  {-# INLINE luminance #-}
  grayscale = rgbLinearGrayscale
  {-# INLINE grayscale #-}
  applyGrayscale = rgbLinearApplyGrayscale
  {-# INLINE applyGrayscale #-}
  toColorXYZ = rgbLinear2xyz . fmap toRealFloat
  {-# INLINE toColorXYZ #-}
  fromColorXYZ = fmap fromRealFloat . xyz2rgbLinear
  {-# INLINE fromColorXYZ #-}

-- | ITU-R BT.601 (625) color space
instance Elevator e => ColorSpace (BT601_625 'NonLinear) D65 e where
  type BaseModel (BT601_625 'NonLinear) = CM.RGB
  toBaseSpace = id
  {-# INLINE toBaseSpace #-}
  fromBaseSpace = id
  {-# INLINE fromBaseSpace #-}
  luminance = rgbLuminance . fmap toRealFloat
  {-# INLINE luminance #-}
  grayscale = fmap fromDouble . coerce . rgbLuma @_ @_ @_ @Double
  {-# INLINE grayscale #-}
  applyGrayscale = applyGrayscaleRec601
  {-# INLINE applyGrayscale #-}
  toColorXYZ = rgb2xyz . fmap toRealFloat
  {-# INLINE toColorXYZ #-}
  fromColorXYZ = fmap fromRealFloat . xyz2rgb
  {-# INLINE fromColorXYZ #-}

-- | ITU-R BT.601 (625) color space
instance RedGreenBlue BT601_625 D65 where
  gamut = coerceGamut (gamut @_ @BT470_625)
  transfer = transferRec601
  {-# INLINE transfer #-}
  itransfer = itransferRec601
  {-# INLINE itransfer #-}

instance Luma BT601_525 where
  rWeight = 0.299
  gWeight = 0.587
  bWeight = 0.114

instance Luma BT601_625 where
  rWeight = 0.299
  gWeight = 0.587
  bWeight = 0.114


-- | Rec.601 transfer function "gamma". This is a helper function, therefore `ecctf` should be used
-- instead.
--
-- \[
-- \gamma(L) = \begin{cases}
--     4.500 L & L \le 0.018 \\
--     1.099 L^{0.45} - 0.099 & \text{otherwise}
--   \end{cases}
-- \]
--
-- @since 0.1.0
transferRec601 :: (Ord a, Floating a) => a -> a
transferRec601 l
  | l < 0.018 = 4.5 * l
  | otherwise = 1.099 * (l ** 0.45 {- ~ 1 / 2.2 -}) - 0.099
{-# INLINE transferRec601 #-}

-- | Rec.601 inverse transfer function "gamma". This is a helper function, therefore `dcctf` should
-- be used instead.
--
-- \[
-- \gamma^{-1}(E) = \begin{cases}
--     E / 4.5 & E \leq gamma(0.018) \\
--     \left(\tfrac{E + 0.099}{1.099}\right)^{\frac{1}{0.45}} & \text{otherwise}
--   \end{cases}
-- \]
--
itransferRec601 :: (Ord a, Floating a) => a -> a
itransferRec601 e
  | e < inv0018 = e / 4.5
  | otherwise = ((e + 0.099) / 1.099) ** (1 / 0.45)
{-# INLINE itransferRec601 #-}

inv0018 :: (Ord a, Floating a) => a
inv0018 = transferRec601 0.018 -- ~ 0.081



-- | This conversion is correct only for sRGB and Rec601. Source: ITU-T Rec. T.871
--
-- @since 0.1.3
ycbcrToRec601 ::
     (RedGreenBlue cs i, RealFloat e)
  => Color CM.YCbCr e
  -> Color (cs 'NonLinear) e
ycbcrToRec601 (CM.ColorYCbCr y' cb cr) = mkColorRGB (CM.ColorRGB r' g' b')
  where
    !cb05 = cb - 0.5
    !cr05 = cr - 0.5
    !r' = clamp01 (y'                   + 1.402    * cr05)
    !g' = clamp01 (y' - 0.344136 * cb05 - 0.714136 * cr05)
    !b' = clamp01 (y' + 1.772    * cb05)
{-# INLINE ycbcrToRec601 #-}

-- | This conversion is correct only for sRGB and Rec601. Source: ITU-T Rec. T.871
--
-- @since 0.1.3
rec601ToYcbcr :: (RedGreenBlue cs i, RealFloat e) => Color (cs 'NonLinear) e -> Color CM.YCbCr e
rec601ToYcbcr rgb = CM.ColorYCbCr y' cb cr
  where
    CM.ColorRGB r' g' b' = unColorRGB rgb
    !y' =          0.299 * r' +    0.587 * g' +    0.114 * b'
    !cb = 0.5 - 0.168736 * r' - 0.331264 * g' +      0.5 * b'
    !cr = 0.5 +      0.5 * r' - 0.418688 * g' - 0.081312 * b'
{-# INLINE rec601ToYcbcr #-}


applyGrayscaleRec601 ::
     forall cs i e. (RedGreenBlue cs i, ColorSpace (cs 'NonLinear) i e)
  => Color (cs 'NonLinear) e
  -> (Color X e -> Color X e)
  -> Color (cs 'NonLinear) e
applyGrayscaleRec601 rgb f =
  case rec601ToYcbcr (toDouble <$> rgb) of
    (CM.ColorYCbCr y' cb cr :: Color CM.YCbCr Double) ->
      fromDouble <$>
      ycbcrToRec601 (CM.ColorYCbCr (toDouble (coerce (f (X (fromDouble y'))) :: e)) cb cr)
{-# INLINE applyGrayscaleRec601 #-}
