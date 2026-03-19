--[[
    HardcorePlus — Mail Tracker
    Monitors sent and received mail.
    Tracks mail recipients, timestamps, and mail counts.
]]

local ADDON_NAME, HCP = ...
local HardcorePlus = HCP.Addon

local MailTracker = {}
HCP.MailTracker = MailTracker

-- ═══════════════════════════════════════════
--  Mail Events
-- ═══════════════════════════════════════════

local function OnMailSendSuccess()
    if not HCP.Utils.IsSystemEnabled("mailTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.mailTracker = HCP.db.char.trackerData.mailTracker or {
        sent = {},
        received = 0,
    }

    -- Get the last sent mail recipient
    -- Note: MAIL_SEND_SUCCESS fires after the mail is sent
    -- We can infer recipient from the last interaction, but WoW doesn't provide this directly
    -- Store a generic "mail sent" entry
    local data = HCP.db.char.trackerData.mailTracker
    table.insert(data.sent, {
        timestamp = HCP.Utils.GetTimestamp(),
        recipient = "Unknown",  -- TBC API limitation: can't get recipient post-send
    })
    -- Cap at 200 entries
    while #data.sent > 200 do
        table.remove(data.sent, 1)
    end
end

local function OnMailInboxUpdate()
    if not HCP.Utils.IsSystemEnabled("mailTracking") then
        return
    end

    -- Initialize data store if needed
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.mailTracker = HCP.db.char.trackerData.mailTracker or {
        sent = {},
        received = 0,
    }

    -- Count new mail
    local numItems, totalItems = GetInboxNumItems()
    local data = HCP.db.char.trackerData.mailTracker

    -- Store current inbox size as "received" count
    data.received = numItems
end

-- ═══════════════════════════════════════════
--  API
-- ═══════════════════════════════════════════

function MailTracker:GetSentMailHistory(limit)
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.mailTracker then
        return {}
    end

    limit = limit or 50
    local sent = HCP.db.char.trackerData.mailTracker.sent
    local result = {}

    local startIdx = math.max(1, #sent - limit + 1)
    for i = startIdx, #sent do
        table.insert(result, sent[i])
    end

    return result
end

function MailTracker:GetMailStats()
    if not HCP.db.char.trackerData or not HCP.db.char.trackerData.mailTracker then
        return { sent = 0, received = 0 }
    end

    local data = HCP.db.char.trackerData.mailTracker
    return {
        sent = #data.sent,
        received = data.received,
    }
end

-- ═══════════════════════════════════════════
--  Initialize
-- ═══════════════════════════════════════════

HardcorePlus:RegisterMessage("HCP_ADDON_READY", function()
    -- Initialize tracker data
    HCP.db.char.trackerData = HCP.db.char.trackerData or {}
    HCP.db.char.trackerData.mailTracker = HCP.db.char.trackerData.mailTracker or {
        sent = {},
        received = 0,
    }

    HardcorePlus:RegisterEvent("MAIL_SEND_SUCCESS", function()
        OnMailSendSuccess()
    end)

    HardcorePlus:RegisterEvent("MAIL_INBOX_UPDATE", function()
        OnMailInboxUpdate()
    end)
end)
