module Rattletrap.Decode.Replication
  ( getReplications
  , getReplication
  ) where

import Rattletrap.Type.Replication
import Rattletrap.Type.ClassAttributeMap
import Rattletrap.Type.Word32
import Rattletrap.Type.CompressedWord
import Rattletrap.Decode.CompressedWord
import Rattletrap.Decode.ReplicationValue

import qualified Data.Binary.Bits.Get as BinaryBit
import qualified Data.Map as Map

getReplications
  :: (Int, Int, Int)
  -> Word
  -> ClassAttributeMap
  -> Map.Map CompressedWord Word32
  -> BinaryBit.BitGet ([Replication], Map.Map CompressedWord Word32)
getReplications version maxChannels classAttributeMap actorMap = do
  maybeReplication <- getReplication
    version
    maxChannels
    classAttributeMap
    actorMap
  case maybeReplication of
    Nothing -> pure ([], actorMap)
    Just (replication, newActorMap) -> do
      (replications, newerActorMap) <- getReplications
        version
        maxChannels
        classAttributeMap
        newActorMap
      pure (replication : replications, newerActorMap)

getReplication
  :: (Int, Int, Int)
  -> Word
  -> ClassAttributeMap
  -> Map.Map CompressedWord Word32
  -> BinaryBit.BitGet (Maybe (Replication, Map.Map CompressedWord Word32))
getReplication version maxChannels classAttributeMap actorMap = do
  hasReplication <- BinaryBit.getBool
  if not hasReplication
    then pure Nothing
    else do
      actorId <- getCompressedWord maxChannels
      (value, newActorMap) <- getReplicationValue
        version
        classAttributeMap
        actorMap
        actorId
      pure (Just (Replication actorId value, newActorMap))
