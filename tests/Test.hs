module Test where

import Test.Tasty
import Test.Tasty.HUnit
import Control.Monad (void)
import Control.Monad.Trans.State.Strict
import Control.Monad.Trans.Class
import Action

mkReadProcess :: Command -> String -> State [Command] String
mkReadProcess c r = do
		hs <- get
		void $ put $ c:hs
		return r

instance EffectMonad (State [Command]) where
	readProcess ("find", a) = mkReadProcess ("find", a) "bar\nfoo"
	readProcess c = mkReadProcess c mempty

main = defaultMain $
	testCase "should run `nix-env -u` for each nix user" $ do
		execState upgradeNix mempty @?=
			[ ("su", ["-", "foo", "-c", "\"nix-env -u\""])
		 	, ("su", ["-", "bar", "-c", "\"nix-env -u\""]) ]
