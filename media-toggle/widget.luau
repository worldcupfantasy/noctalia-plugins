--!nonstrict
-- Media play/pause bar widget whose glyph follows the active MPRIS player.
--
-- State sources, in order of authority:
--   1. `playerctl --follow status` — pushed the moment the player changes, so a
--      pause from a hardware key or the player window lands immediately.
--   2. A slow `playerctl status` poll — only a fallback for "no player yet" and
--      for a dead stream. Poll results are dropped while a live event has
--      already answered, and during the short quiet window after a click.
--
-- Dropping those stale answers is what stops the icon from flipping back to the
-- previous state right after a press.

local PLAYING = "Playing"
local PAUSED = "Paused"
local STOPPED = "Stopped"

local QUIET_MS = 1200 -- ignore poll results this soon after a click
local POLL_MS = 5000
local FAIL_LIMIT = 3

local playing = false
local available = false
local fails = 0
local intentAt = 0
local eventSeq = 0
local pollBusy = false

local function apply()
  barWidget.setVisible(available)
  if not available then
    return
  end
  barWidget.setGlyph(playing and "media-pause" or "media-play")
  barWidget.setTooltip(noctalia.tr(playing and "pause" or "play"))
end

local function commit(status)
  if status == PLAYING or status == PAUSED or status == STOPPED then
    available = true
    playing = status == PLAYING
    fails = 0
  else
    available = false
  end
  apply()
end

local function poll()
  if pollBusy then
    return
  end
  pollBusy = true
  local seq = eventSeq

  noctalia.runAsync({ "playerctl", "status" }, function(result)
    pollBusy = false
    -- A live event answered after this poll started: its answer is newer.
    if eventSeq ~= seq then
      return
    end
    if noctalia.nowMs() - intentAt < QUIET_MS then
      return
    end

    local status = noctalia.string.trim(result.stdout)
    if result.exitCode == 0 and status ~= "" then
      commit(status)
      return
    end
    -- One failed call means nothing; players exit and respawn constantly.
    fails = fails + 1
    if fails >= FAIL_LIMIT then
      available = false
      apply()
    end
  end, 1000)
end

function update()
  noctalia.setUpdateInterval(POLL_MS)
  poll()
end

function onClick()
  intentAt = noctalia.nowMs()
  -- Flip before the player answers so the press feels instant. The stream is
  -- the only thing allowed to correct this; no poll fires here on purpose.
  if available then
    playing = not playing
    apply()
  end
  noctalia.runAsync({ "playerctl", "play-pause" }, nil, 1000)
end

noctalia.runStream("playerctl --follow status", function(line)
  eventSeq = eventSeq + 1
  commit(noctalia.string.trim(line))
end)

poll()
