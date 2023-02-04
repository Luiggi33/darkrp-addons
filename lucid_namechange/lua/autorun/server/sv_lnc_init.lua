--Lucid Name Change
--Made by OverlordAkise
util.AddNetworkString("luctus_namechange")
util.AddNetworkString("luctus_namecheck")

local haveAlreadyJoined = {}
local shouldChangeName = {}

hook.Add("Initialize", "luctus_loadjoinedplayers", function()
  if file.Exists("luctus_joinedplayers.json", "DATA") then
    local joinedPlayers = file.Read("luctus_joinedplayers.json", "DATA")
    haveAlreadyJoined = table.Copy(util.JSONToTable(joinedPlayers))
  end
end)

hook.Add("ShutDown", "luctus_savejoinedplayers", function()
  haveAlreadyJoined = util.TableToJSON(haveAlreadyJoined)
  file.Write("luctus_joinedplayers.json", haveAlreadyJoined)
end)

hook.Add("PlayerInitialSpawn", "luctus_namechange", function(ply)
  if (not haveAlreadyJoined[ply]) then
    shouldChangeName[ply] = true
  end
end)

hook.Add("SetupMove", "luctus_namechange", function(ply, _, cmd)
  if shouldChangeName[ply] and not cmd:IsForced() then
    shouldChangeName[ply] = nil
  end
end)

net.Receive("luctus_namecheck", function(len, ply)
  local fname = net.ReadString()
  local lname = net.ReadString()
  local b, m = hook.Run("CanChangeRPName", ply, fname .. " " .. lname)

  DarkRP.retrieveRPNames(fname .. " " .. lname, function(ans)
    if b == false then
      DarkRP.notify(ply, 1, 5, "Error: Name '" .. m .. "'")
    elseif ans == true then
      DarkRP.notify(ply, 1, 5, "Error: Name 'already taken'")
    elseif fname:match("%W") or lname:match("%W") then
      DarkRP.notify(ply, 1, 5, "Error: Name 'has illegal characters'")
    else
      net.Start("luctus_namecheck")
      net.WriteString(fname .. " " .. lname)
      net.Send(ply)
    end
  end)
end)