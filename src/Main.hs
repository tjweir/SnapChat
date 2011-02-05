{-|
 Main module for this application. Defines the Snap application, handlers for the 
 application, and the main loop.
 
 The application itself forks off a 'tick' thread. This thread monitors all users and 
 autokicks inactive users. This combined with browser-side javascript lets us remove
 users who navigate away from the page.
-}
module Main where

import System
import Data.Text
import qualified Data.Map as Map
import Control.Applicative
import Control.Monad.Trans
import Snap.Http.Server
import Snap.Types
import Snap.Util.FileServe
import Text.Templating.Heist
import Data.CIByteString (CIByteString(..))
import Data.ByteString (ByteString)
import Data.Maybe (fromMaybe)
import Control.Concurrent (threadDelay)

import Chat
import Control.Concurrent (forkIO)
import Control.Monad (forever)

-- |Adds a field to the current header.
addHeaderField :: CIByteString -> [ByteString] -> Snap ()
addHeaderField key values = do
    modifyResponse $ (updateHeaders $ Map.insert key values)

-- |Indicates that the response generated by the snap context this is executed in 
--  should not be cached.
dontCache :: Snap () -> Snap ()
dontCache action = do
    action
    addHeaderField "Cache-Control" ["no-store"]

-- |Top level configuration for the Snap application.
chatter :: ChatRoom -> Snap ()
chatter room = dontCache $ route [("say",     sayHandler room),
                                  ("room",    fileServeSingle "static/room.html"),
                                  ("static",  fileServe "static/"),
                                  ("entries", (roomHandler room))]

-- |Handles the /say URL. Posts a message to the room.
sayHandler :: ChatRoom -> Snap ()
sayHandler state = do
    userParam <- getParam "user"
    let user = fromMaybe "system" userParam
    newEntry <- getParam "text"
    case newEntry of
        Just msg -> liftIO $ addEntry state (Message user msg)
        Nothing -> writeBS "say something!"

    roomHandler state

-- |Handles the /entries URL. Returns a list of all messages in the room.
roomHandler :: ChatRoom -> Snap ()
roomHandler room = do
    userParam <- getParam "user"
    case userParam of
        Nothing -> return ()
        Just "unknown" -> return ()
        Just userName -> liftIO $ addUser room userName

    currentEntries <- liftIO (getEntries room)
    writeText $ pack $ show currentEntries

-- |Program entry point.
main :: IO ()
main = do
    args <- getArgs
    let port = case args of
                   []  -> 8000
                   p:_ -> read p
    room <- startingState

    _ <- forkIO (forever $ do tick room; threadDelay 500000)
    let site = chatter room
    quickHttpServe site
