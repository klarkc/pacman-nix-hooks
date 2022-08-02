module Action where

import Control.Monad

type Command = (String, [String])

type User = String

class Monad a => EffectMonad a where
  readProcess :: Command -> a String

findUsers :: EffectMonad a => a [User]
findUsers = filter byUsers <$> lines <$> readProcess ("find", args)
  where
    byUsers u = u /= "per-user"
    args =
      [ "/nix/var/nix/profiles/per-user",
        "-type",
        "d",
        "-exec",
        "basename",
        "{}",
        ";"
      ]

upgrade :: EffectMonad a => User -> a ()
upgrade u = void $ readProcess ("su", ["-", u, "-c", "\"nix-env -u\""])

upgradeNix :: EffectMonad a => a ()
upgradeNix = findUsers >>= foldM (const upgrade) ()
