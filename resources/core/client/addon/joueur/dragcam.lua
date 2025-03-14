local angleY = 0.0
local angleZ = 0.0
camDragCam = nil
local running = false
local gEntity = nil
local gOffset = vector3(0.0, 0.0, 0.0)
local gRadius = nil
local gRadiusMax = nil
local gRadiusMin = nil
local scaleform = nil
local scrollIncrements = nil

local function cos(degrees)
    return math.cos(math.rad(degrees))
end

local function sin(degrees)
    return math.sin(math.rad(degrees))
end

local radius = 1.5
local function setCamPosition()
    local entityCoords = GetEntityCoords(gEntity) + gOffset + vector3(0.0, 0.0, 0.1)
    --local mouseX = GetDisabledControlNormal(0, 1) * 7.0 -- 8x multiplier to make it more sensitive
    --local mouseY = GetDisabledControlNormal(0, 2) * 7.0

    if IsControlPressed(0, 174) or IsDisabledControlPressed(0, 174) then 
        mouseX = mouseX + 0.01
    elseif IsControlPressed(0, 175) or IsDisabledControlPressed(0, 175) then 
        mouseX = mouseX - 0.01
    else
        mouseX = 0.0
        mouseY = 0.0
    end
    -- Ajoutez cette ligne pour définir l'angle Z par défaut (ajustez la valeur selon vos besoins)
    --angleZ = 180.0

    angleZ = angleZ - mouseX -- left / right
    angleY = angleY + mouseY -- up / down
    --angleY = math.clamp(angleY, 0.0, 89.0) -- >=90 degrees will flip the camera, < 0 is underground
    
    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end

    --local cosAngleZ = cos(angleZ)
    --local cosAngleY = cos(angleY)
    --local sinAngleZ = sin(angleZ)
    --local sinAngleY = sin(angleY)
    
    --local offset = vec3(
    --    ((cosAngleZ * cosAngleY) + (cosAngleY * cosAngleZ)) / 2 * gRadius,
    --    ((sinAngleZ * cosAngleY) + (cosAngleY * sinAngleZ)) / 2 * gRadius,
    --    ((sinAngleY)) * gRadius
    --)

    local pCoords = entityCoords
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (radius + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (radius + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (radius + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    local maxRadius = radius
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < radius + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end
    
    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }

    local camPos = vec3(entityCoords.x + offset.x, entityCoords.y + offset.y, entityCoords.z + offset.z)
    SetCamCoord(camDragCam, camPos.x, camPos.y, camPos.z + 1.0)
    PointCamAtCoord(camDragCam, entityCoords.x, entityCoords.y, entityCoords.z)
end

local function disablePlayerMovement()
    DisableControlAction(0, 21, true) -- INPUT_SPRINT | LEFT SHIFT
    DisableControlAction(0, 24, true) -- INPUT_ATTACK | LEFT MOUSE BUTTON
    DisableControlAction(0, 25, true) -- INPUT_AIM | RIGHT MOUSE BUTTON
    DisableControlAction(0, 30, true) -- INPUT_MOVE_LR | D
    DisableControlAction(0, 31, true) -- INPUT_MOVE_UD | S
    DisableControlAction(0, 36, true) -- INPUT_DUCK | LEFT CTRL
    DisableControlAction(0, 47, true) -- INPUT_DETONATE | G
    DisableControlAction(0, 58, true) -- INPUT_THROW_GRENADE | G
    DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK | LEFT MOUSE BUTTON
    DisableControlAction(0, 75, true) -- INPUT_VEH_EXIT | F
    DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT | R
    DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY | Q
    DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE | LEFT MOUSE BUTTON
    DisableControlAction(0, 143, true) -- INPUT_MELEE_BLOCK | SPACEBAR
    DisableControlAction(0, 257, true) -- INPUT_ATTACK2 | LEFT MOUSE BUTTON
    DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1 | R
    DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2 | Q
end

local function disableCamMovement()
    DisableControlAction(0, 1, true) -- INPUT_LOOK_LR | MOUSE RIGHT
    DisableControlAction(0, 2, true) -- INPUT_LOOK_UD | MOUSE DOWN
    DisableControlAction(0, 3, true) -- INPUT_LOOK_UP_ONLY | (NONE)
    DisableControlAction(0, 4, true) -- INPUT_LOOK_DOWN_ONLY | MOUSE DOWN
    DisableControlAction(0, 5, true) -- INPUT_LOOK_LEFT_ONLY | (NONE)
    DisableControlAction(0, 6, true) -- INPUT_LOOK_RIGHT_ONLY | MOUSE RIGHT
    DisableControlAction(0, 12, true) -- INPUT_WEAPON_WHEEL_UD | MOUSE DOWN
    DisableControlAction(0, 13, true) -- INPUT_WEAPON_WHEEL_LR | MOUSE RIGHT
    DisableControlAction(0, 200, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE | ESC
end

local function mouseDownListener()
    CreateThread(function()
        while running do
            setCamPosition()

            if IsDisabledControlJustReleased(0, 24) or IsControlJustReleased(0, 24) then
                --SetMouseCursorSprite(3)
                return
            end

            Wait(0)
        end
    end)
end

local function inputListener()
    --setCamPosition() -- Set initial camDragCam position, otherwise camDragCam will remain at player until first left click
    --mouseDownListener()
    CreateThread(function()
        while running do
            --SetMouseCursorActiveThisFrame()
            disableCamMovement()
            disablePlayerMovement()
            setCamPosition()

            --if IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 24) then
                --SetMouseCursorSprite(4)
                --mouseDownListener()
            --end

            --if IsDisabledControlJustReleased(0, 14) or IsControlJustReleased(0, 14) then
            --    if gRadius + scrollIncrements <= gRadiusMax then
            --        gRadius += scrollIncrements
            --        setCamPosition()
            --    end
            --elseif IsDisabledControlJustReleased(0, 15) or IsControlJustReleased(0, 15) then
            --    if gRadius - scrollIncrements >= gRadiusMin then
            --        gRadius -= scrollIncrements
            --        setCamPosition()
            --    end
            --end

            Wait(0)
        end
    end)
end

local function instructionalButton(controlId, text)
    ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, controlId, true))
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    EndTextCommandScaleformString()
end

local function showInstructionalButtons()
    CreateThread(function()
        scaleform = RequestScaleformMovie("instructional_buttons")
        while not HasScaleformMovieLoaded(scaleform) do
            Wait(0)
        end
        BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(1)
        instructionalButton(14, "Dézoomer")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(2)
        instructionalButton(15, "Zoomer")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamInt(80)
        EndScaleformMovieMethod()

        while running do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            Wait(0)
        end
    end)
end

---@param entity integer
---@param radiusOptions? {initial?: number, min?: number, max?: number, scrollIncrements?: number}
function startDragCam(entity, radiusOptions, offset)
    running = true
    gEntity = entity
    if offset then gOffset = offset end
    gRadius = radiusOptions?.initial or 5.0
    gRadiusMin = radiusOptions?.min or 2.5
    gRadiusMax = radiusOptions?.max or 10.0
    scrollIncrements = radiusOptions?.scrollIncrements or 0.5
    camDragCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local coords, forward = GetEntityCoords(entity), GetEntityForwardVector(entity)
    local camCoords = (coords + forward * 0.5)
    gDefaultCamPos = camCoords
    SetCamCoord(camDragCam, camCoords.x, camCoords.y, camCoords.z + 1.0)
    RenderScriptCams(true, true, 0, true, false)
    --showInstructionalButtons()
    inputListener()
end

function stopDragCam()
    running = false
    RenderScriptCams(false, true, 0, true, false)
    DestroyCam(camDragCam, true)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    camDragCam = nil
end

exports('startDragCam', startDragCam)
exports('stopDragCam', stopDragCam)