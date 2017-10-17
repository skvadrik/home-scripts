import Graphics.X11.ExtraTypes
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run
import XMonad.Layout.NoBorders
import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Hooks.SetWMName (setWMName)

import System.IO

import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map as M

myTerminal = "xterm"

myBorderWidth = 1

myModMask = mod1Mask

myWorkspaces = ["[1]","[2]","[3]","[4]","[5]","[6]","[7]","[8]","[9]"]

myNormalBorderColor = "#dddddd"
myFocusedBorderColor = "#ff0000"

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((controlMask , xK_grave ), spawn $ XMonad.terminal conf)

    , ((mod4Mask, xK_b ), sendMessage ToggleStruts)

    -- s2ram
    , ((mod4Mask , xK_F10 ), spawn "~/bin/s2ram.sh")

    -- my proggies
    , ((modMask .|. controlMask, xK_f ), spawn "firefox")
    , ((modMask .|. controlMask, xK_p ), spawn "pidgin")
    , ((modMask .|. controlMask, xK_l ), spawn "liferea")
    , ((modMask .|. controlMask, xK_t ), spawn "thunderbird-bin")
    , ((modMask .|. controlMask, xK_s ), spawn "~/bin/skype.sh")

    -- sound
    , ((mod4Mask , xK_grave ), spawn "xterm -e 'alsamixer -c0'" )
    , ((0, xF86XK_AudioMute       ), spawn "~/bin/volume.sh mute")
    , ((0, xF86XK_AudioLowerVolume), spawn "~/bin/volume.sh lower")
    , ((0, xF86XK_AudioRaiseVolume), spawn "~/bin/volume.sh raise")

    -- screenshot
    , ((mod4Mask, xK_Print), spawn "/usr/bin/screenshot.sh scr")

    -- close focused window
    , ((mod4Mask .|. shiftMask, xK_c ), kill)

     -- Rotate through the available layout algorithms
    , ((mod4Mask, xK_space ), sendMessage NextLayout)

    -- Move focus to the next window
    , ((mod4Mask, xK_Tab ), windows W.focusDown)

    -- Swap the focused window and the master window
    , ((mod4Mask, xK_Return), windows W.swapMaster)

    -- Shrink the master area
    , ((mod4Mask, xK_h ), sendMessage Shrink)

    -- Expand the master area
    , ((mod4Mask, xK_l ), sendMessage Expand)

    -- Push window back into tiling
    , ((mod4Mask, xK_t ), withFocused $ windows . W.sink)

    -- Quit xmonad
    , ((mod4Mask .|. shiftMask, xK_q ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((mod4Mask , xK_q ),
          broadcastMessage ReleaseResources >> restart "xmonad" True)
    ]
    ++

    -- control-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m , k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
        , (f, m) <- [(W.greedyView, controlMask), (W.shift, shiftMask .|. modMask)]]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    -- Mouse scroll wheel to raise/lower windows
    , ((modMask, button5), (\w -> windows W.swapDown))
    , ((modMask, button4), (\w -> windows W.swapUp))
    ]

myLayout = smartBorders $ avoidStruts $ (Full ||| tiled ||| Mirror tiled)
  where
     tiled = Tall nmaster delta ratio
     nmaster = 1
     ratio = 4/5
     delta = 3/100

myManageHook = composeAll []

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myStartupHook = return ()

------------------------------------------------------------------------
xmobarCmdT = " xmobar -o -B '#122c60' -F '#adbadd' -t '%StdinReader%' "
xmobarCmdB = " xmobar -b -B '#122c60' -F '#adbadd' -t '<fc=#00FF00>hello from xmobar :)</fc> }{ %battery% | %cpu% | %memory% ||| %wlan0% ||| <fc=cyan>%date%</fc>'"
main = do dinT <- spawnPipe xmobarCmdT
          dinB <- spawnPipe xmobarCmdB
          xmonad $ fullscreenFix $ ewmh $ defaultConfig {
      -- simple stuff
      terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,

      -- key bindings
      keys = myKeys,
      mouseBindings = myMouseBindings,

      -- hooks, layouts
      layoutHook = myLayout,
      manageHook = myManageHook,
      logHook = dynamicLogWithPP $ {- dzenPP -} xmobarPP { ppOutput = hPutStrLn dinT },

      startupHook = myStartupHook,

      handleEventHook = fullscreenEventHook
}

-- https://github.com/mpv-player/mpv/issues/888
-- workarounds firefox fullscreen (on F11)
fullscreenFix :: XConfig a -> XConfig a
fullscreenFix c = c {
                      startupHook = startupHook c +++ setSupportedWithFullscreen
                    }
                  where x +++ y = mappend x y

setSupportedWithFullscreen :: X ()
setSupportedWithFullscreen = withDisplay $ \dpy -> do
    r <- asks theRoot
    a <- getAtom "_NET_SUPPORTED"
    c <- getAtom "ATOM"
    supp <- mapM getAtom ["_NET_WM_STATE_HIDDEN"
                         ,"_NET_WM_STATE_FULLSCREEN"
                         ,"_NET_NUMBER_OF_DESKTOPS"
                         ,"_NET_CLIENT_LIST"
                         ,"_NET_CLIENT_LIST_STACKING"
                         ,"_NET_CURRENT_DESKTOP"
                         ,"_NET_DESKTOP_NAMES"
                         ,"_NET_ACTIVE_WINDOW"
                         ,"_NET_WM_DESKTOP"
                         ,"_NET_WM_STRUT"
                         ]
    io $ changeProperty32 dpy r a c propModeReplace (fmap fromIntegral supp)

    setWMName "xmonad"
