{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
module Graphics.Color.Illuminant.CIE1931Spec (spec) where

import Graphics.Color.Space.Common
import Graphics.Color.Illuminant.Common
import Graphics.Color.Illuminant.CIE1931

spec :: Spec
spec =
  describe "Wikipedia" $ do
    describe "IlluminantSpec" $ do
      illuminantSpec @'A
      illuminantSpec @'B
      illuminantSpec @'C
      illuminantSpec @'D50
      illuminantSpec @'D55
      illuminantSpec @'D60
      illuminantSpec @'D65
      illuminantSpec @'D75
      illuminantSpec @'E
      illuminantSpec @'FL1
      illuminantSpec @'FL2
      illuminantSpec @'FL3
      illuminantSpec @'FL4
      illuminantSpec @'FL5
      illuminantSpec @'FL6
      illuminantSpec @'FL7
      illuminantSpec @'FL8
      illuminantSpec @'FL9
      illuminantSpec @'FL10
      illuminantSpec @'FL11
      illuminantSpec @'FL12
      illuminantSpec @'FL3_1
      illuminantSpec @'FL3_2
      illuminantSpec @'FL3_3
      illuminantSpec @'FL3_4
      illuminantSpec @'FL3_5
      illuminantSpec @'FL3_6
      illuminantSpec @'FL3_7
      illuminantSpec @'FL3_8
      illuminantSpec @'FL3_9
      illuminantSpec @'FL3_10
      illuminantSpec @'FL3_11
      illuminantSpec @'FL3_12
      illuminantSpec @'FL3_13
      illuminantSpec @'FL3_14
      illuminantSpec @'FL3_15
      illuminantSpec @'HP1
      illuminantSpec @'HP2
      illuminantSpec @'HP3
      illuminantSpec @'HP4
      illuminantSpec @'HP5
    describe "Derived Classes" $ do
      let is = [A .. HP5]
      it "Bounded" $ [minBound .. maxBound] `shouldBe` is
      it "Enum" $ forM_ is $ \ i -> toEnum (fromEnum i) `shouldBe` i
      it "Read . Show" $ forM_ is $ \ i -> read (show i) `shouldBe` i
      it "Read . Show" $  read (show is) `shouldBe` (is :: [CIE1931])


daylightChromaticityY :: RealFloat a => a -> a
daylightChromaticityY x = 2.87 * x - 3 * x ^ (2 :: Int) - 0.275


daylightChromaticityX_4000to7000K :: Fractional a => a -> a
daylightChromaticityX_4000to7000K t =
    0.244063
  + 0.09911 * 10 ^ (3 :: Int) / t
  + 2.96780 * 10 ^ (6 :: Int) / (t ^ (2 :: Int))
  - 4.60700 * 10 ^ (9 :: Int) / (t ^ (3 :: Int))

daylightChromaticityX_7000to25000K :: Fractional a => a -> a
daylightChromaticityX_7000to25000K t =
    0.237040
  + 0.24748 * 10 ^ (3 :: Int) / t
  + 1.90180 * 10 ^ (6 :: Int) / (t ^ (2 :: Int))
  - 2.00640 * 10 ^ (9 :: Int) / (t ^ (3 :: Int))

chromaticity :: (Show e, RealFloat e) => e -> V2 e
chromaticity t = V2 x y
  where
    x
      | 4000 <= t && t < 7000 = daylightChromaticityX_4000to7000K t
      | 7000 <= t && t <= 25000 = daylightChromaticityX_7000to25000K t
      | otherwise = error $ "Invalid temperature: " ++ show t
    y = daylightChromaticityY x



ts =
  [ unCCT (colorTemperature :: CCT 'D50)
  , unCCT (colorTemperature :: CCT 'D55)
  , unCCT (colorTemperature :: CCT 'D60)
  , unCCT (colorTemperature :: CCT 'D65)
  , unCCT (colorTemperature :: CCT 'D75)
  ]


--data D (t :: Nat)

--instance
