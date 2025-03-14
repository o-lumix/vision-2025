RegisterNUICallback("init", function(data, cb)
    SendNUIMessage({
        status = "init",
        time = config.RefreshTime,
    })

    if cb then cb('ok') end
end)

RegisterNUICallback("data_status", function(data, cb)
    if soundInfo[data.id] ~= nil then
        if data.type == "finished" then
            if not soundInfo[data.id].loop then
                soundInfo[data.id].playing = false
            end
            TriggerEvent("xSound:songStopPlaying", data.id)
        end
        if data.type == "maxDuration" then
            if not soundInfo[data.id].SkipTimeStamp then
                soundInfo[data.id].timeStamp = 0
            end
            soundInfo[data.id].maxDuration = data.time

            soundInfo[data.id].SkipTimeStamp = nil
        end
    end

    if cb then cb('ok') end
end)

RegisterNUICallback("events", function(data, cb)
    local id = data.id
    local type = data.type
    if type == "resetTimeStamp" then
        if soundInfo[id] then
            soundInfo[id].timeStamp = 0
            soundInfo[id].maxDuration = data.time
            soundInfo[id].playing = true
        end
    end
    if type == "onPlay" then
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onPlayStartSilent then
                globalOptionsCache[id].onPlayStartSilent(getInfo(id))
            end

            if globalOptionsCache[id].onPlayStart and not soundInfo[id].SkipEvents then
                globalOptionsCache[id].onPlayStart(getInfo(id))
            end

            soundInfo[id].SkipEvents = nil
        end
    end
    if type == "onEnd" then
        TriggerServerEvent("core:dj:ended", id)
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onPlayEnd then
                globalOptionsCache[id].onPlayEnd(getInfo(id))
            end
        end
        if soundInfo[id] then
            if soundInfo[id].loop then
                soundInfo[id].timeStamp = 0
            end
            if soundInfo[id].destroyOnFinish and not soundInfo[id].loop then
                Destroy(id)
            end
        end
    end
    if type == "onLoading" then
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onLoading then
                globalOptionsCache[id].onLoading(getInfo(id))
            end
        end
    end

    if cb then cb('ok') end
end)

RegisterNetEvent("xsound:stateSound", function(state, data)
    local soundId = data.soundId

    if state == "destroyOnFinish" then
        if soundExists(soundId) then
            destroyOnFinish(soundId, data.value)
        end
    end

    if state == "timestamp" then
        if soundExists(soundId) then
            setTimeStamp(soundId, data.time)
        end
    end

    if state == "texttospeech" then
        TextToSpeech(soundId, data.lang, data.url, data.volume, data.loop or false)
    end

    if state == "texttospeechpos" then
        TextToSpeechPos(soundId, data.lang, data.url, data.volume, data.position, data.loop or false)
    end

    if state == "play" then
        PlayUrl(soundId, data.url, data.volume, data.loop or false)
    end

    if state == "playpos" then
        PlayUrlPos(soundId, data.url, data.volume, data.position, data.loop or false)
    end

    if state == "position" then
        if soundExists(soundId) then
            Position(soundId, data.position)
        end
    end

    if state == "distance" then
        if soundExists(soundId) then
            Distance(soundId, data.distance)
        end
    end

    if state == "destroy" then
        if soundExists(soundId) then
            Destroy(soundId)
        end
    end

    if state == "pause" then
        if soundExists(soundId) then
            Pause(soundId)
        end
    end

    if state == "resume" then
        if soundExists(soundId) then
            Resume(soundId)
        end
    end

    if state == "volume" then
        if soundExists(soundId) then
            if isDynamic(soundId) then
                setVolumeMax(soundId, data.volume)
            else
                setVolume(soundId, data.volume)
            end
        end
    end
end)
