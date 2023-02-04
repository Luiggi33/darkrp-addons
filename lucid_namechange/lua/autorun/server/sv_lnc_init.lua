--Lucid Name Change
--Made by OverlordAkise
util.AddNetworkString("luctus_namechange")
util.AddNetworkString("luctus_namecheck")

local shouldChangeName = {}

hook.Add("onPlayerFirstJoined", "luctus_newplayerjoin", function(ply)
  shouldChangeName[ply] = true
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