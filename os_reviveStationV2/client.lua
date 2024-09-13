-- May take knowledge of LUA to modify. Contact on discord for help: veryappropriatename

local circleCenter = vector3(342.5406, -1398.013, 32.55817)
local npcCenter = vector4(342.5406, -1398.013, 32.55817, 59.527554)
local circleRadius = 1.0
local spawned = false
local model = "s_m_m_doctor_01"
local npc = nil
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)



local medics = false
local blip = nil
local showing = true
local blipCreated = false

function bliping()
    if showing and not blipCreated then
        AddTextEntry('label', 'Revive Station')
        blip = AddBlipForCoord(circleCenter)
        SetBlipSprite(blip, 621)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.9)
        SetBlipColour(blip, 29)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("label")
        EndTextCommandSetBlipName(blip)
        blipCreated = true
    end
end

RegisterNetEvent('os_revivestation:client:receiveCount')
AddEventHandler('os_revivestation:client:receiveCount', function(count)
    if count > 1 then
        medics = true
        showing = false
        if blipCreated then
            RemoveBlip(blip)
            blipCreated = false
        end
    else
        medics = false
        showing = true
        bliping()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        TriggerServerEvent('os_revivestation:client:count')
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(playerCoords, circleCenter, true)

        if distance <= 25 and medics == false then

            local playerHealth = GetEntityHealth(playerPed)
            if spawned == false then
                SpawnNPC()
                spawned = true
            end
            if playerHealth <= 0 then
                DisplayHelpText("Drücke ~INPUT_CONTEXT~ um dich zu Reviven.")
                DrawMarker(27, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 255, 0, 0, 200, false, true, 2, nil, nil, false)

                if distance <= circleRadius and IsControlJustReleased(0, 38) then
                    TriggerEvent('esx_ambulancejob:revive')
                end
            elseif playerHealth <= 150 then
                DisplayHelpText("Drücke ~INPUT_CONTEXT~ um dich zu Heilen.")
                DrawMarker(27, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 255, 0, 200, false, true, 2, nil, nil, false)

                if distance <= circleRadius and IsControlJustReleased(0, 38) then
                    TriggerEvent('esx_ambulancejob:revive')
                end
            elseif playerHealth >= 150 then
                DrawMarker(27, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 0, 0, 255, 200, false, true, 2, nil, nil, false)

                if distance <= circleRadius then
                    DisplayHelpText("Du hast keine verletzungen.")
                end
                if distance <= circleRadius and IsControlJustReleased(0, 38) then
                    ESX.ShowNotification('Wein drüber.')
                end
            end
        else

            DeleteNPC()
            spawned = false
            RemoveHelpText()
        end
    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function RemoveHelpText()
    BeginTextCommandDisplayHelp("STRING")
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function SpawnNPC()
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(500)
    end

    local pos = vector4(npcCenter.x, npcCenter.y, npcCenter.z, npcCenter.w - 1.0)

    npc = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, 0.0, true, false)

    SetEntityCoordsNoOffset(npc, pos.x, pos.y, pos.z, pos.w, true, true, true)
    SetEntityInvincible(npc, true)
    SetEntityHasGravity(npc, false)
    FreezeEntityPosition(npc, true)
    SetAmbientVoiceName(npc, "ALERT_Player")
    SetModelAsNoLongerNeeded(model)
end

function DeleteNPC()
    if spawned and DoesEntityExist(npc) then
        DeleteEntity(npc)
        spawned = false
    end
end



