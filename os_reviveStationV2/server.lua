ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) -- If an error is being spammed, use "ESX = exports['es_extended']:getSharedObject()" instead.

function CountAmbulanceJob()
  local count = 0
  for _, playerId in ipairs(GetPlayers()) do
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer ~= nil then
      if xPlayer.job.name == 'ambulance' then
        count = count + 1
      end
    end
  end
  return count
end
RegisterServerEvent('os_revivestation:client:count')
AddEventHandler('os_revivestation:client:count', function()
  local count = CountAmbulanceJob()
  TriggerClientEvent('os_revivestation:client:receiveCount', source, count)
end)
