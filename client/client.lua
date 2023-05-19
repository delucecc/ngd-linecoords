local isDrawingLine = false

function ToggleDrawLine()
    isDrawingLine = not isDrawingLine
    if isDrawingLine then
        TriggerEvent('chat:addMessage', {
            color = { 255, 255, 0 },
            multiline = true,
            args = { 'ngd-LineCoords', 'Line On' }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 255, 0 },
            multiline = true,
            args = { 'ngd-LineCoords', 'Line Off' }
        })
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isDrawingLine then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local cameraRotation = GetGameplayCamRot(2)
            local camPitch = math.rad(cameraRotation.x)
            local camYaw = math.rad(cameraRotation.y)
            local lineLength = Config.LineLength
            local forwardVector = vector3(
                math.sin(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
                math.cos(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
                math.sin(camPitch)
            )
            local lineEnd = playerCoords + forwardVector * lineLength
            local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y,
                lineEnd.z, 7, playerPed, 0)
            local _, hit, hitCoords, _, _ = GetShapeTestResult(rayHandle)
            DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y, lineEnd.z, 255, 0, 0, 255)
            if hit then
                local roundedCoords = {
                    x = string.format("%.2f", hitCoords.x),
                    y = string.format("%.2f", hitCoords.y),
                    z = string.format("%.2f", hitCoords.z)
                }
                local heading = playerHeading + 180.0
                if heading > 360.0 then
                    heading = heading - 360.0
                end
                DrawText3D(hitCoords.x, hitCoords.y, hitCoords.z + 1.0,
                    string.format('~r~Collision~n~X: %.2f Y: %.2f Z: %.2f~n~Heading: %.2f', hitCoords.x, hitCoords.y,
                        hitCoords.z, heading))
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterCommand(Config.TDrawLine, function()
    ToggleDrawLine()
end)

RegisterCommand(Config.CopyCoord, function()
    if isDrawingLine then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        local cameraRotation = GetGameplayCamRot(2)
        local camPitch = math.rad(cameraRotation.x)
        local camYaw = math.rad(cameraRotation.y)
        local lineLength = 10.0
        local forwardVector = vector3(
            math.sin(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
            math.cos(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
            math.sin(camPitch)
        )
        local lineEnd = playerCoords + forwardVector * lineLength
        local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y,
            lineEnd.z, 7, playerPed, 0)
        local _, hit, hitCoords, _, _ = GetShapeTestResult(rayHandle)
        if hit then
            local coords = {
                x = hitCoords.x,
                y = hitCoords.y,
                z = hitCoords.z
            }
            local heading = playerHeading + 180.0
            if heading > 360.0 then
                heading = heading - 360.0
            end
            local data = string.format('vec4(%.2f, %.2f, %.2f, %.2f)', coords.x, coords.y, coords.z, heading)
            TriggerEvent('chat:addMessage', {
                args = { '^3Copied to clipboard: ' .. data }
            })
            SendNUIMessage({
                type = 'clipboard',
                data = data
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            args = { '^1DrawLine is not enabled!' }
        })
    end
end)
