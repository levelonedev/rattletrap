module Rattletrap.Decode.RemoteId
  ( decodeRemoteIdBits
  )
where

import Data.Semigroup ((<>))
import Rattletrap.Decode.Bitstream
import Rattletrap.Decode.Common
import Rattletrap.Decode.Word64le
import Rattletrap.Type.RemoteId
import Rattletrap.Type.Word8le
import Rattletrap.Utility.Bytes

import qualified Data.ByteString as Bytes
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Data.Word as Word

decodeRemoteIdBits :: (Int, Int, Int) -> Word8le -> DecodeBits RemoteId
decodeRemoteIdBits version systemId = case word8leValue systemId of
  0 -> RemoteIdSplitscreen <$> getWord32be 24
  1 -> RemoteIdSteam <$> decodeWord64leBits
  2 -> RemoteIdPlayStation <$> decodePsName <*> decodePsBytes version
  4 -> RemoteIdXbox <$> decodeWord64leBits
  6 -> RemoteIdSwitch <$> decodeBitstreamBits 256
  7 -> RemoteIdPsyNet
    <$> decodeBitstreamBits (if version >= (868, 24, 10) then 64 else 256)
  _ -> fail ("unknown system id " <> show systemId)

decodePsName :: DecodeBits Text.Text
decodePsName = fmap
  (Text.dropWhileEnd (== '\x00') . Text.decodeLatin1 . reverseBytes)
  (getByteStringBits 16)

decodePsBytes :: (Int, Int, Int) -> DecodeBits [Word.Word8]
decodePsBytes version = Bytes.unpack
  <$> getByteStringBits (if version >= (868, 20, 1) then 24 else 16)
