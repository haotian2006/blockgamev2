local greedy = {}
local gs = require(game.ReplicatedStorage.GameSettings)
local gridsize = gs.GridSize
local function findintable(tab,x,y,z)
   if tab[x] and tab[x][y] and tab[x][y][z]   then
       return tab[x][y][z] 
   end
end
local function addtotabl(tab,data,x,y,z)
   tab[x] = tab[x] or {}
   tab[x][y] = tab[x][y] or {}
   tab[x][y][z] = data
end
local function shallowCopy(original)
   local copy = {}
   for key, value in pairs(original) do
       copy[key] = value
   end
   return copy
end
local function decombine(str)
   return str:split(",")
end
function  greedy.meshtable(tabletodemesh)
   local startx,endx,startz,endz,starty,endy
   local D3 = {}
   local checked = {}
   local old = 0
   for i,v in pairs(tabletodemesh)do
       if not v then continue end
       old+=1
       local x,y,z = unpack(i:split(","))
       x,y,z = tonumber(x),tonumber(y),tonumber(z)
       if startx == nil then
           startx = x
           starty = y
           startz = z
           endx = x
           endy = y
           endz = z
       end
       D3[x] = D3[x] or {}
       D3[x][y] = D3[x][y] or {}
       D3[x][y][z] = v
       if x >=endx then
           endx = x
       end
       if z >=endz then
           endz = z
       end
       if y >=endy then
           endy = y
       end
       if x <=startx then
           startx = x
       end
       if z <=startz then
           startz = z
       end
       if y <=starty then
           starty = y
       end
   end
   local currentz = startz
   local currenty = starty
   local currentx = startx
   local ssx,ssz,ssy = startx,startz,starty
   local new,total = {},0
   local lastx,lastz,lasty 
   local function createblock(sx,ex,sz,ez,sy,ey)
       local l = math.sqrt((sx-ex)^2)
       local midpointx = (sx+ex )/2
       l += l ~= -1 and 1 or 0
       local w = math.sqrt((sz-ez)^2)
       local midpointz = (sz+ez )/2
       w += w ~= -1 and 1 or 0
       local h = math.sqrt((sy-ey)^2)
       local midpointy = (sy+ey )/2
       h += h ~= -1 and 1 or 0
       return {startx = sx,endx = ex,startz = sz,endz = ez,starty = sy,endy = ey,h=h,l=l,w=w,real = Vector3.new(midpointx,midpointy,midpointz)},midpointx..','..midpointy..','..midpointz
   end
   while currentz <= endz+1 do
       while currentx <= endx+1 do
           while currenty <= endy+1 do
               if findintable(D3,currentx,currenty,currentz) and not findintable(checked,currentx,currenty,currentz) then
                   if not findintable(D3,lastx,lasty,lastz) then
                       startx = currentx
                       startz = currentz
                       starty = currenty
                   end
                   addtotabl(checked,true,currentx,currenty,currentz)
               elseif not findintable(D3,currentx,currenty,currentz) and findintable(D3,startx,starty,startz) and startx and startz and starty and lastx and lastz and lasty then
                   local data,index = createblock(startx,lastx,startz,lastz,starty, lasty)
                   new[index] = data
                   startx = nil
                   startz = nil
                   starty = nil
               end
               lastx = currentx
               lastz = currentz
               lasty = currenty
               currenty +=1
           end
           currenty = ssy
           currentx+=1
       end
       currentx = ssx
       lastz = currentz
       currentz+=1
   end
   local function dosmt(key,dir)
       local ox,oy,oz = unpack(decombine(key))
       local rx,ry,rz = ox,oy,oz
       local info = new[key]
       local sx,ex,sz,ez,sy,ey = info.startx,info.endx,info.startz,info.endz,info.starty,info.endy
       local l,w,h = info.l,info.w,info.h
       local involved = {key}
       local function move(goback)
           if dir == 'x' then
               rx += goback and -l or l
           elseif  dir == 'z' then
               rz += goback and -w or w
           elseif  dir == 'y' then
               ry += goback and -h or h
           end
       end
       local currentdir = -1
       while true do
           move(currentdir ==-1 and true or nil)
           local c = new[rx..','..ry..','..rz]
           if c and c.w == w and c.l == l and c.h == h then
               if currentdir == -1 then
                   sx = c.startx
                   sz = c.startz
                   sy = c.starty
               else
                   ex = c.endx
                   ez = c.endz
                   ey = c.endy
               end
               table.insert(involved,rx..','..ry..','..rz)
           elseif currentdir == -1 then
               currentdir = 1
               rx,rz,ry = ox,oz,oy
               continue
           else
               break
           end
       end
       return involved,createblock(sx,ex,sz,ez,sy,ey)
   end
   local cc ={}
   for key,value in pairs(shallowCopy(new)) do
       if not new[key] then continue end
       local inv,data,newkey = dosmt(key,"x")
       cc[newkey] = data
       for i,v in ipairs(inv)do
           new[v] = nil
       end
   end
   new = cc
   local cc ={}
   for key,value in pairs(shallowCopy(new)) do
       if not new[key] then continue end
       local inv,data,newkey = dosmt(key,"z")
       cc[newkey] = data
       for i,v in ipairs(inv)do
           new[v] = nil
       end
   end
   return cc
end
return greedy