module Main
  ( main
  ) where

import qualified Data.Binary.Get as Binary
import qualified Data.Binary.Put as Binary
import qualified Data.ByteString.Lazy as ByteString
import qualified Rattletrap
import qualified System.FilePath as FilePath
import qualified Test.Tasty as Tasty
import qualified Test.Tasty.Hspec as Hspec

main :: IO ()
main = do
  tests <- Hspec.testSpec "rattletrap" (Hspec.parallel spec)
  Tasty.defaultMain tests

spec :: Hspec.Spec
spec =
  Hspec.describe
    "Rattletrap"
    (Hspec.context
       "can get and put a replay with"
       (mapM_ (uncurry itCanGetAndPut) replays))

itCanGetAndPut :: String -> String -> Hspec.Spec
itCanGetAndPut uuid description =
  Hspec.it
    description
    (do let file = pathToReplay uuid
        (input, _, output) <- getAndPut file
        Hspec.shouldBe output input)

pathToReplay :: String -> FilePath
pathToReplay uuid =
  FilePath.joinPath ["test", "replays", FilePath.addExtension uuid ".replay"]

getAndPut :: FilePath
          -> IO (ByteString.ByteString, Rattletrap.Replay, ByteString.ByteString)
getAndPut file = do
  input <- ByteString.readFile file
  let replay = Binary.runGet Rattletrap.getReplay input
  let output = Binary.runPut (Rattletrap.putReplay replay)
  pure (input, replay, output)

replays :: [(String, String)]
replays =
  [ ("F811C1D24888015E23B598AD8628C742", "no frames")
  , ("29F582C34A65EB34D358A784CBE3C189", "frames")
  , ("6688EEE34BFEB3EC3A9E3283098CC712", "a malformed byte property")
  , ("18D6738D415B70B5BE4C299588D3C141", "an online loadout attribute")
  , ("F299F176491554B11E34AB91CA76B2CE", "a location attribute")
  , ("1BC2D01444ACE577D01E988EADD4DFD0", "no padding after the frames")
  , ("7BF6073F4614CE0A438994B9A260DA6A", "an online loadouts attribute")
  , ("C8372B1345B1803DEF039F815DBD802D", "a spectator")
  , ("B9F9B87D4A9D0A3D25D4EC91C0401DE2", "a party leader")
  , ("C14F7E0E4D9B5E6BE9AD5D8ED56B174C", "some mutators")
  , ("4126861E477F4A03DE2A4080374D7908", "a game mode after Neo Tokyo")
  , ("372DBFCA4BDB340E4357B6BD43032802", "a camera yaw attribute")
  , ("D7FB197A451D69075A0C99A2F49A4053", "an explosion attribute")
  , ("07E925B1423653D44CB8B4B2524792C1", "a game mode before Neo Tokyo")
  , ("EAE311E84BA35B590A6FDBA6DD4F2FEB", "an actor/object ID collision")
  , ("540DA764423C8FB24EB9D486D982F16F", "a demolish attribute")
  , ("211466D04B983F5A33CC2FA1D5928672", "a match save")
  , ("1D1DE97D4941C86E43FE0093563DB621", "a camera pitch")
  , ("7109EB9846D303E54B7ACBA792036213", "a boost modifier")
  , ("A52F804845573D8DA65E97BF59026A43", "some more mutators")
  , ("6D1B06D844A5BB91B81FD4B5B28F08BA", "a flip right")
  , ("00080014003600090000036E0F65CCEB", "a flip time")
  , ("1A126AC24CAA0DB0E98835BD960B8AF8", "overtime")
  ]
