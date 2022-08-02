module Main where

import Action
import System.Process as S

instance EffectMonad IO where
  readProcess (c, a) = S.readProcess c a mempty

main :: IO ()
main = upgradeNix
