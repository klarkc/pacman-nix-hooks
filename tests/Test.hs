module Test where

import Action
import Control.Monad (void)
import Control.Monad.Trans.Class
import Control.Monad.Trans.State.Strict
import Test.Tasty
import Test.Tasty.HUnit

mkReadProcess :: Command -> String -> State [Command] String
mkReadProcess c r = do
  hs <- get
  void $ put $ c : hs
  return r

instance EffectMonad (State [Command]) where
  readProcess ("find", a) = mkReadProcess ("find", a) "per-user\nroot\nbar\nfoo"
  readProcess c = mkReadProcess c mempty

main = defaultMain $
  testCase "should run `nix-env -u` for each nix user" $ do
    execState upgradeNix mempty
      @?= [ ("su", ["foo", "-s", "/usr/bin/nix-env", "--", "-u"]),
            ("su", ["bar", "-s", "/usr/bin/nix-env", "--", "-u"]),
            ("su", ["root", "-s", "/usr/bin/nix-env", "--", "-u"]),
            ("find", ["/nix/var/nix/profiles/per-user", "-type", "d", "-exec", "basename", "{}", ";"])
          ]
