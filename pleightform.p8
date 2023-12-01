pico-8 cartridge // http://www.pico-8.com
version 41
__lua__










-->8
--random functions
function explosion(x,y)
 --big center explosion
 fadeamount=0.3
 local myex={}
 myex.x=x
 myex.y=y
 myex.dur=0
 myex.speedx=0
 myex.speedy=0
 myex.maxdur=0
 myex.size=15
 add(explosions,myex)
 --smaller surrounding explosions
 for i=1,20 do
  local myex={}
  myex.x=x
  myex.y=y
  myex.dur=rnd(3)
  myex.speedx=(rnd()-0.5)*3.5
  myex.speedy=(rnd()-0.5)*3.5
  myex.maxdur=30+rnd(10)
  myex.size=1+rnd(5)
  add(explosions,myex)
 end
end

function shockwave(x,y)
 local sw={}
 sw.x=x
 sw.y=y
 sw.r=0
 sw.maxr=5
 add(swaves,sw)
end

function speedup()
 if xvel + acc < maxspeed then
  xvel+=acc
 else
  xvel=maxspeed
 end
end

function handleleft()
 player.x-=xvel
 checkleft()
 
 if movingleft==true then
  --slowly switch focuspoint to 35 pix left of player
  local focusleft=64.0+35.0
  focus=lerp(focusleft,focus,0.9)
 end
end

function handleright()
 player.x+=xvel
 checkright()

 if movingright==true then
  --slowly switch focuspoint to 35 pix right of player
  local focusright=64.0-35.0
  focus=lerp(focusright,focus,0.9)
 end
end

function col(a,b)
 if
  a.x+a.colbox_right > b.x+b.colbox_left and 
  a.y+a.colbox_bottom > b.y+b.colbox_top and
  a.x+a.colbox_left < b.x+b.colbox_right and
  a.y+a.colbox_top < b.y+b.colbox_bottom
 then
  return true
 end
end

function col2(a,b)
 if
  a.x+a.colbox_right+1 > b.x+b.colbox_left and 
  a.y+a.colbox_bottom+1 > b.y+b.colbox_top and
  a.x+a.colbox_left-1 < b.x+b.colbox_right and
  a.y+a.colbox_top-1 < b.y+b.colbox_bottom
 then
  return true
 end
end

function centercamera()
 local temp=lerp(int(player.x)+4-camerax,focus,0.9)
 local scrollx=0
 
 if temp < focus then
  scrollx = focus-temp
  camerax -= scrollx
 elseif temp > focus then
  scrollx = temp-focus
  camerax += scrollx
 end
end

function animatereactor()
 --reactor animation stuff
 if framecounter%8==0 then
 
  if animationflip==false then
   reactorframe+=1
   if reactorframe==2 then
    animationflip=true
   -- fadeamount=fade[reactorframe]
   end
  else
   reactorframe-=1
   if reactorframe==0 then
    animationflip=false
    --fadeamount=fade[reactorframe]
   end
  end
  
 end
 

 --fadeamount=fade[reactorframe+1]
end


function drawplayer()
 if player.invul<30 then
	 --draw player sprite
	 local frame=playerstate+(animationframe*2)
	 spr(frame,int(player.x),int(player.y),2,2,flipx)
 else
  if sin(framecounter/5)<0.5 then
	 local frame=playerstate+(animationframe*2)
	 spr(frame,int(player.x),int(player.y),2,2,flipx)
  end 
 end
 rememberplayerstate=playerstate
end


function drawreactor()
for reactor in all(reactors) do
 --draw reactor
 spr(206,reactor.x,   reactor.y,2,1,false,true)
 spr(206,reactor.x+16,reactor.y,2,1,true,true)

 spr(203,reactor.x,   reactor.y+8,2,1,false,true)
 spr(203,reactor.x+16,reactor.y+8,2,1,true,true)
 --animated part

 
 local frame=0
 if reactor.active then
  frame=234+reactorframe
 else
  frame=233
 end
 
 
 spr(frame,reactor.x+8, reactor.y+16,1,1,true,true)
 spr(frame,reactor.x+16,reactor.y+16,1,1,false,true)
 spr(frame,reactor.x+8, reactor.y+24,1,1,true,false)
 spr(frame,reactor.x+16,reactor.y+24,1,1,false,false)
 --animated part end
 
 spr(203,reactor.x,   reactor.y+32,2,1,false,false)
 spr(203,reactor.x+16,reactor.y+32,2,1,true,false)

 spr(205,reactor.x-8, reactor.y+40,3,4,false,false)
 spr(205,reactor.x+16,reactor.y+40,3,4,true,false)


  --if are_closer_than(127, reactor.x,reactor.y, player.x,player.y) then
  -- if fadeindone==true then
  --   fadeamount=fade[reactorframe+1]
   --end
  --end

 --rect(reactor.x+reactor.colbox_left,reactor.y+reactor.colbox_top,reactor.x+reactor.colbox_right,reactor.y+reactor.colbox_bottom,5)

end
end


function drawhealth()
 if player.health>100 then
  player.health=100
 end

 local barw=flr(36*player.health/100)
 
 --draw lifebar
 --top left corner
 local x1=1+camerax
 local y1=1+cameray
 --bottom right corner
 local x2=41+camerax
 local y2=7+cameray
 rectfill(x1,y1,x2,y2,0)
 rect(x1,y1,x2,y2,5)
 if player.health>0 then
  rectfill(x1+2,y1+2,x1+2+barw,y2-2,6)
 end
end

function drawmetroids()
 for metroid in all(metroids) do
  spr(246+metroid.frame,metroid.x,metroid.y)
 end
end

function drawrobots()
 --draw enemy 1 (robots)
 for enemy in all(enemies) do
  if enemy.flash>0 then
   enemy.flash-=1
   pal(12,8)
   pal(13,9)
  end
  spr(72+enemyframe,enemy.x,enemy.y,2,4,enemy.flipx)
  pal()
  fade_scr(fadeamount)
  --treat color 2 as transparant
  palt(2,true)
  --draw black pixels
  palt(0, false)
 end
end
 
function animatemetroids()
for metroid in all(metroids) do
 local frames=0
 if are_closer_than(45, metroid.x,metroid.y, player.x,player.y) then
	 if dst(player,metroid)<40 then
	  if player.y-12>metroid.y then
			
			 
			 metroid.angry=true
			 
	
	  end
	 end
	end
 
 if metroid.angry then
  metroid.y+=1
  frames=3
 else
  frames=5
 end
 
 if framecounter%frames==0 then
  metroid.frame+=1
  metroid.frame=metroid.frame&3
 end
end
end


function animateplayer()
	animationcounter+=1
	if playerstate ~= rememberplayerstate then
	 animationcounter=0
	 animationframe=0
	end
	 
	if animationcounter%6==0 then
	 if animationframe<4-1 then 
	  animationframe+=1
	 else 
	  animationframe=0
	 end
 end
end



function moverobots()
--handle enemy movement
--and bg collission
if framecounter%6==0 then
--(| is the bitwise or operator
--it takes all corresponding 
--pairs of bits of both sides,
-- and if either of them is a 1, 
--the corresponding bit in the result is a 1
for enemy in all(enemies) do
 if enemy.flipx == false then
  enemy.x+=1.00
  local solid=0
  local maptile1=mget(besideright(enemy),top(enemy))
  local maptile2=mget(besideright(enemy),bottom(enemy))
  local maptile5=mget(besideright(enemy),bellow(enemy))
--if bumped into solid
--or no ground bellow corner
--if fget(maptile1) + fget(maptile2)>0
  --if fget(maptile1) | fget(maptile2)!=0
  if fget(maptile1,0) 
  or fget(maptile2,0)
  or fget(maptile5)==0 then
   enemy.flipx = true
   enemy.x+=1
   enemy.colbox_right=13.0
   enemy.colbox_left=1.0
  end
 else
  enemy.x-=1.00
  local solid=0
  local maptile1=mget(besideleft(enemy),top(enemy))
  local maptile2=mget(besideleft(enemy),bottom(enemy))
  local maptile5=mget(besideleft(enemy),bellow(enemy))
--if fget(maptile1) + fget(maptile2)>0
  --if fget(maptile1) | fget(maptile2)!=0
  --or fget(maptile5)==0 then
   if fget(maptile1,0) 
   or fget(maptile2,0)
   or fget(maptile5)==0 then
   enemy.flipx = false
   enemy.x-=1
   enemy.colbox_right=14.0
   enemy.colbox_left=2.0
  end
 end
end
end
end

function lerp(a,b,t)
 return a+(b-a)*t
end







function easeinoutovershoot(t)
    if t<.5 then
        return (2.7*8*t*t*t-1.7*4*t*t)/2
    else
        t-=1
        return 1+(2.7*8*t*t*t+1.7*4*t*t)/2
    end
end



function moveup()
 if yvel>up_acc then
  yvel-=up_acc
 else
  movingup = false
  yvel=0.0
 end

 --yvel-=0.125
 player.y-=yvel
 checkup()
end

function movedown()
 yvel+=0.25
 player.y+=yvel
 checkdown()
end

--lua has no define keyword
--a function is an alternative
--solution to save tokens

--function left()
-- return ((player.x&0xffff)/8)
--end

function left(obj)
 return (int(obj.x)+obj.colbox_left)/8
end

function besideleft(obj)
 return ((int(obj.x)-1)+obj.colbox_left)/8
end

function right(obj)
 return (int(obj.x)+obj.colbox_right)/8
end

function besideright(obj)
 return ((int(obj.x)+1)+obj.colbox_right)/8
end

function top(obj)
 return (int(obj.y)+obj.colbox_top)/8
end

function above(obj)
 return ((int(obj.y)-1)+obj.colbox_top)/8
end

function bottom(obj)
 return (int(obj.y)+obj.colbox_bottom)/8
end

function bellow(obj)
 return ((int(obj.y)+1)+obj.colbox_bottom)/8
end




function overlapright()
 return 1.0+(int(player.x)+player.colbox_right)&7
end

function overlapleft()
 return 8.0-(int(player.x)+player.colbox_left)&7
end

function overlapdown()
 return 1.0+(int(player.y)+player.colbox_bottom)&7
end

function overlapup()
 return 8.0-(int(player.y)+player.colbox_top)&7
end


function int(fixedpoint)
 return fixedpoint&0xffff
end


function are_closer_than(d, x1,y1, x2,y2)
  local dx = abs(x2-x1)
  local dy = abs(y2-y1)
  return dx < d 
     and dy < d 
     and (dx^2 + dy^2) < d^2
end




function checkdown()
 --get tile
 local maptile1=mget(left(player),bellow(player))
 local maptile2=mget(right(player),bellow(player))
 
 --check if solid flag is set
 if fget(maptile1,solid) 
 or fget(maptile2,solid) then
  player.y-=overlapdown()
  yvel=0.0
  onground=true
  --player.y=int(player.y)
  return
 end
 
 
 --check if spikes
 if fget(maptile1,spikes) 
 or fget(maptile2,spikes) then
  up_acc=0.125
  if maptile1==250 then
   if (int(player.y)+16)&7 >= 4 then
    --player.y-=overlapdown()+1
    spiketile()
   end
  else
		 --player.y-=overlapdown()
		 spiketile()
		 --player.y=int(player.y)
   --return
  end
 return
 end
 
 if fallthroughtimer==0 then
  if fget(maptile1,semisolid) 
  or fget(maptile2,semisolid) then

   --convert pixel cordinate bellow
   --player to tile cordinate
   --to get tile y pos
   local topoftile=((int(player.y)+16)\8)*8
   --if feet less than 3 pixels
   --from the top of the tile..
   if (int(player.y)+16)&7 < 3
   --or you were above the tile
   --on the previous frame
   or previousfeetpos<topoftile then
    player.y-=overlapdown()
    yvel=0.0
    onground=true
    return
   end
  end
  
 else
  if fallthroughtimer==4 then
	  if fget(maptile1,semisolid) 
	  and fget(maptile2,semisolid) then
	   sfx(60)--60
	  --end
	  elseif fget(maptile1,semisolid) 
	  and fget(maptile2)==0 then
	   sfx(60)--60
	  --end
	  elseif fget(maptile1)==0
	  and fget(maptile2,semisolid) then
	   sfx(60)--60
	  end
  end
 end
 
--test
 for box in all(boxes1) do
  if col2(player,box) then
   player.y=((box.y+box.colbox_top)-player.colbox_bottom)-1
   onground=true
   yvel=0.0
   return
  end
 end
 
 --else
 onground=false
 jumprestrainer=true
end

function spiketile()
    sfx(62)
    yvel=1.0
		  movingup=true
		  onground=true
		  player.health-=1.0
		  player.invul=60
		  jumprestrainer=false
end

function checkleft()
 local maptile1=mget(besideleft(player),top(player))
 local maptile2=mget(besideleft(player),bottom(player))

 if fget(maptile1,solid)
 or fget(maptile2,solid) then
  player.x+=overlapleft()
  xvel=0.0
  movingleft=false
  playerstate=idle
 end
 
 for box in all(boxes1) do
  if col2(player,box) then
   player.x=((box.x+box.colbox_right)-player.colbox_left)+1
	  xvel=0.0
	  movingleft=false
	  playerstate=idle
  end
 end
end

function checkright()
 local maptile1=mget(besideright(player),top(player))
 local maptile2=mget(besideright(player),bottom(player))

 if fget(maptile1,solid)
 or fget(maptile2,solid) then
  player.x-=overlapright()
  xvel=0.0
  movingright=false
  playerstate=idle
 end
 
 for box in all(boxes1) do
  if col2(player,box) then
    player.x=((box.x+box.colbox_left)-player.colbox_right)-1
    xvel=0.0
    movingright=false
    playerstate=idle
  end
 end
 
 --[[
 for box in all(boxes1) do
  if col2(player,box) then
   --xvel=0.095
   --player.x=((box.x+box.colbox_left)-player.colbox_right)-1
   box.x=((player.x+player.colbox_right)-box.colbox_left)+1
   maptile2=mget(besideright(box),bottom(box))
   if fget(maptile2,solid) then
    box.x-=1
    player.x=((box.x+box.colbox_left)-player.colbox_right)-1
    xvel=0.0
    movingright=false
    playerstate=idle
   end
  end
 end
 
 
 for box in all(boxes1) do
  for otherbox in all(boxes1) do
	  if box.y != otherbox.y and box.x != otherbox.x then
		  if col2(box,otherbox) then
	    box.x=otherbox.x-16
	    player.x=((box.x+box.colbox_left)-player.colbox_right)-1
	    xvel=0.0
	    movingright=false
	    playerstate=idle
	   end
	  end
  end
 end]]--
end

function checkup()
 local maptile1=mget(left(player),above(player))
 local maptile2=mget(right(player),above(player))

 if fget(maptile1,solid)
 or fget(maptile2,solid) then
  player.y+=overlapup()
  yvel=0.0
  movingup=false
 end
 
 for box in all(boxes1) do
  if col2(player,box) then
   player.y=((box.y+box.colbox_bottom)-player.colbox_top)+1
   yvel=0.0
   movingup = false
   return
  end
 end
end


function boxboxcol()
 for box in all(boxes1) do
  for otherbox in all(boxes1) do
	  if box.y  != otherbox.y
	  and box.x != otherbox.x then
	   if col2(box,otherbox) then
     return true
	   end
	  end
  end
 end
 --return false
end

function createwatersprite(x,y)
		 local wtile={}
		 wtile.x=x*8
		 wtile.y=y*8
		 wtile.frame=mget(x,y)
		 
		 add(watertiles,wtile)
end

function createboxobject(x,y,btype)
 local box={}
 box.x=x*8
 box.y=y*8
 box.type=btype
 box.colbox_bottom=15.0
 box.colbox_top=0.0
 box.colbox_right=15.0
 box.colbox_left=0.0
 box.hits=15
 box.yvel=0
 add(boxes1,box)
 
    mset(x,y,000)
    mset(x,y+1,000)
    mset(x+1,y,000)
    mset(x+1,y+1,000)
end

function createrobotobject(x,y,o)
 local enemy={}
 enemy.x=x*8
 enemy.y=y*8-24
 --enemy.w=16-1
 --enemy.h=32-1

 enemy.colbox_bottom=31.0
 enemy.colbox_top=11.0
 enemy.colbox_right=13.0
 enemy.colbox_left=2.0
 
 enemy.carries=o
 if o=="card" then
  cardcounter+=1
  enemy.cardnr=cardcounter
 else
  enemy.cardnr=0
 end
 

 enemy.flipx=false
 enemy.life=50
 enemy.flash=0
 add(enemies,enemy)
 mset(x,y,000)
end

--https://github.com/clowerweb/lib-pico8/blob/master/distance.lua
function dst(o1,o2)
 return sqrt(sqr(o1.x-o2.x)+sqr(o1.y-o2.y))
end
function sqr(x) return x*x end

function doshake()
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)
-- then we apply the shake
-- strength
 shakex*=shake
 shakey*=shake
--clamp
 if state=="game" then
 camerax=mid(map_start,camerax+shakex,map_end-screenwidth)
 cameray=mid(0,cameray+shakey,mapheight-128) 
 camera(camerax,cameray)
 end
-- finally, fade out the shake
-- reset to 0 when very low
 shake = shake*0.95
 if (shake<0.05) shake=0
end

function tb_init(voice,string) -- this function starts and defines a text box.
    reading=true -- sets reading to true when a text box has been called.
    tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
    str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
    voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
    i=1, -- index used to tell what string from tb.str to read.
    cur=0, -- buffer used to progressively show characters on the text box.
    char=0, -- current character to be drawn on the text box.
    x=0  +camerax, -- x coordinate
    y=106+cameray, -- y coordginate
    w=127, -- text box width
    h=21, -- text box height
    col1=0, -- background color
    col2=7, -- border color
    col3=7, -- text color
    --jumprestrainer=true
    }
end

function tb_update()  -- this function handles the text box on every frame update.
    if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
        tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
        if tb.cur>0.9 then -- if the buffer is larger than 0.9:
            tb.char+=1 -- set next character to be drawn.
            tb.cur=0    -- reset the buffer.
            if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
        end
        if (btnp(5)) tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
    elseif btnp(5) then -- if already on the last message character and button ❎/x is pressed:
        if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
            tb.i+=1 -- increase the index, to display the next message on tb.str
            tb.cur=0 -- reset the buffer.
            tb.char=0 -- reset the character position.
        else -- if there are no more messages to display:
            reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
            state="game"
            jumprestrainer=true
        end
    end
end

function tb_draw() -- this function draws the text box.
    if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
        rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
        rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
        print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
    end
end


--notice backslash
--for integer division
function truncate8(a)
 return a\8*8
end

--random int between 0,h
function rand(h) --exclusive
    return flr(rnd(h))
end
function randi(h) --inclusive
    return flr(rnd(h+1))
end

--random int between l,h
function randb(l,h) --exclusive
    return flr(rnd(h-l))+l
end
function randbi(l,h) --inclusive
    return flr(rnd(h+1-l))+l
end

--https://www.lexaloffle.com/bbs/?tid=29397
-- return random # from a to b
--[[
function rand(a,b)
  if (a>b) a,b=b,a
  return a+flr(rnd(b-a+1))
end--rand(..)
]]--

function fade_scr(fa)
	fa=max(min(1,fa),0)
	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1
	local fades={
		{1,1,1,1,0,0,0,0},
		{2,2,2,1,1,0,0,0},
		{3,3,4,5,2,1,1,0},
		{4,4,2,2,1,1,1,0},
		{5,5,2,2,1,1,1,0},
		{6,6,13,5,2,1,1,0},
		{7,7,6,13,5,2,1,0},
		{8,8,9,4,5,2,1,0},
		{9,9,4,5,2,1,1,0},
		{10,15,9,4,5,2,1,0},
		{11,11,3,4,5,2,1,0},
		{12,12,13,5,5,2,1,0},
		{13,13,5,5,2,1,1,0},
		{14,9,9,4,5,2,1,0},
		{15,14,9,4,5,2,1,0}
	}
	
	for n=1,pn do
		pal(n,fades[n][fi],0)
	end
end



function freshscreen()
-- copies the map from the cartridge file back into ram, effectivly resetting the whole map back to the default
reload(0x1000, 0x1000, 0x2000)
--[[
--player table/object
player={
x=127,
y=-32,
w=8,
colbox_bottom=15.0,
colbox_top=5.0, --7
colbox_right=13.0,
colbox_left=3.0,
health=100,
invul=0
}
camerax=player.x-128/2+8/2
cameray=player.y-72 --((player.y-75)-128/2)+8/2
focus=player.x+8/2-camerax
]]--
--loop through every tile
--and create objects
_brokenlights={}
enemies={}
boxes1={}
--boxes2={}
tunnels={}
doors={}
pickups={}
animations={}
metroids={}
bubbles={}
reactors={}
rcounter=0
cards={}
cardcounter=0
watertiles={}
for x=0,127 do
 for y=0,31 do
 
  if mget(x,y)==140 then
   add(_brokenlights,{x,y})
  elseif mget(x,y)==120 then
   --add enemies
   createrobotobject(x,y,"nothing")

  elseif mget(x,y)==164 then
   --add boxes type 1
  createboxobject(x,y,164)

  elseif mget(x,y)==166 then
  --add boxes type 2
  createboxobject(x,y,166)

  elseif mget(x,y)==224 then
  --add tunnels
   local tun={}
   tun.x=x*8
   tun.y=y*8
   
   
   mset(x,y,000)
   add(tunnels,tun)
   map_end=x*8+24
  --add tunnel doors
   local door_l={}
   door_l.x=tun.x-8
   door_l.y=tun.y
   door_l.frame=0
   door_l.flipx=true
   door_l.clearance=false
   add(doors,door_l)
   local door_r={}
   door_r.x=tun.x+48
   door_r.y=tun.y
   door_r.frame=0
   door_r.flix=false
   door_r.clearance=false
   add(doors,door_r)
  elseif mget(x,y)==151 then
   local pickup={}
   pickup.x=x*8
   pickup.y=y*8
   
   pickup.colbox_bottom=7.0
   pickup.colbox_top=0.0
   pickup.colbox_right=7.0
   pickup.colbox_left=0.0
   add(pickups,pickup)
   mset(x,y,000)
  elseif mget(x,y)==192
  or mget(x,y)==208 then
   local anim={}
   anim.x=x*8
   anim.y=y*8
   anim.tile=mget(x,y)
   anim.flipx=false

   add(animations,anim)
   mset(x,y,000)
  elseif mget(x,y)==246 then
   local metroid={}
   metroid.x=x*8
   metroid.y=y*8
   metroid.colbox_bottom=7.0
   metroid.colbox_top=0.0
   metroid.colbox_right=7.0
   metroid.colbox_left=0.0
   metroid.angry=false
   metroid.frame=0
   add(metroids,metroid)
   
   mset(x,y,000)
  elseif mget(x,y)==212 then
   local bubble={}
   bubble.x=x*8+1
   bubble.y=y*8+4
   
   bubble.spawnx=x*8+1
   bubble.spawny=y*8+3
   
   bubble.radius=rnd(2)-0.1--1.99
   add(bubbles,bubble)
   
   mset(x,y,211)
   createwatersprite(x,y)
  elseif mget(x,y)==206 then
   local reactor={}
   reactor.x=x*8
   reactor.y=y*8

   reactor.colbox_bottom=27.0
   reactor.colbox_top=20.0
   reactor.colbox_right=21.0
   reactor.colbox_left=10.0
   
   rcounter+=1
   reactor.number=rcounter
   reactor.active=true
   
   add(reactors,reactor)
   mset(x,y,000)
  elseif mget(x,y)==141 then

   
   
   createrobotobject(x,y,"card")
  elseif mget(x,y)==195
  or mget(x,y)==211 then
   createwatersprite(x,y)
  
  end
 end
end

end
-->8
--init

--16.16 fixed point
--https://www.lexaloffle.com/dl/docs/pico-8_manual.html#types_and_assignment
--alt+enter (windowed mode)


--toolkit of easing functions
--https://www.lexaloffle.com/bbs/?tid=40577

--you can use the entire map 
--and half the spritesheet(tab 1 and 2), 
--or the entire spritesheet 
--and half the map


music(8)
cls()
finito=false
fadeamount=1.0
--player table/object
player={
x=127,
y=-32,
w=8,
colbox_bottom=15.0,
colbox_top=5.0, --7
colbox_right=13.0,
colbox_left=3.0,
health=100,
invul=0
}
flipx=false
function _init()

reading=false
player.health=100


--puny mode before pasting
----https://www.lexaloffle.com/bbs/?tid=49901
--titlescr="⁶-b⁶x8⁶y8⁶-#ᶜ5⁶.\0\0ナナナナナナ⁸⁶-#ᶜ9⁶.\0ユ▮▮▮▮▮▮⁶-#ᶜ5⁶.\0\0?○◝ナらら⁸⁶-#ᶜ9⁶.\0?@█\0゜!!⁶-#ᶜ5⁶.\0\0、、ううツツ⁸⁶-#ᶜ9⁶.\0>\"けcc\"\"⁶-#ᶜ5⁶.\0\0|◝◝れ▒¹⁸⁶-#ᶜ9⁶.\0|⬇️\0\0<B🐱⁶-#ᶜ5⁶.\0\000899;9ま⁸⁶-#ᶜ9⁶.\0|EFFろをE⁶-#ᶜ5⁶.\0\0x<゛ᶠ⁷³⁸⁶-#ᶜ9⁶.\0ヲ░B!▮⁸⁴⁶-#ᶜ5⁶.\0\0ナナナナナナ⁸⁶-#ᶜ9⁶.\0ユ▮▮▮▮▮▮⁶-#ᶜ5⁶.\0\0ナユx<、ᵉ⁸⁶-#ᶜ9⁶.\0ニ■	✽C#■⁶-#ᶜ5⁶.\0\0。、ううチチ⁸⁶-#ᶜ9⁶.\0?\"こbb\"\"⁶-#ᶜ5⁶.\0\0|◝◝れ▒¹⁸⁶-#ᶜ9⁶.\0|⬇️\0\0<B🐱⁶-#ᶜ5⁶.\0\000899;9ま⁸⁶-#ᶜ9⁶.\0|EFFろをE⁶-#ᶜ5⁶.\0\0x<゛ᶠ⁷³⁸⁶-#ᶜ9⁶.\0ヲ░るく…☉░⁶-#ᶜ5⁶.\0\0◝◝◝⁷⁷⁷⁸⁶-#ᶜ9⁶.\0◝\0\0\0ヲ⁸ヲ⁶-#ᶜ5⁶.\0\0ワワワppp⁸⁶-#ᶜ9⁶.\0◝⁸⁸⁸◆☉⬅️⁶-#ᶜ5⁶.\0\0りりネccc⁸⁶-#ᶜ9⁶.\0ネ\"\"⁘⬆️⬆️⬆️⁶-#ᶜ5⁶.\0\0⁷⁷⁷⁷⁷⁷⁸⁶-#ᶜ9⁶.\0ᶠ⁸⁸⁸⁸⁸⁸\n⁶-#ᶜ6⁶.ナナナナナナナナ⁸⁶-#ᶜ9⁶.▮▮▮▮▮▮▮▮⁶-#ᶜ6⁶.ららららナ◝○?⁸⁶-#ᶜ9⁶.!!!!゜\0█@⁶-#ᶜ6⁶.ツツツツうう、、⁸⁶-#ᶜ9⁶.\"\"\"\"ccけ\"⁶-#ᶜ6⁶.¹¹¹▒れ◝◝|⁸⁶-#ᶜ9⁶.²²🐱B<\0\0⬇️⁶-#ᶜ6⁶.ヲヲx9;998⁸⁶-#ᶜ9⁶.⁴⁴✽FDFFE⁶-#ᶜ6⁶.⁷ᶠᵉ、、8pp⁸⁶-#ᶜ9⁶.⁸▮■\"\"D☉☉⁶-#ᶜ6⁶.ナナナナナナナナ⁸⁶-#ᶜ9⁶.▮▮▮▮▮▮▮▮⁶-#ᶜ6⁶.゜?9ppナらら⁸⁶-#ᶜ9⁶. @F웃웃■!!⁶-#ᶜ6⁶.チチチチうう。。⁸⁶-#ᶜ9⁶.\"\"\"\"bcけ\"⁶-#ᶜ6⁶.¹¹¹▒れ◝◝|⁸⁶-#ᶜ9⁶.²²🐱B<\0\0⬇️⁶-#ᶜ6⁶.ヲヲx9;998⁸⁶-#ᶜ9⁶.⁴⁴✽FDFFE⁶-#ᶜ6⁶.⁷ᶠᵉ、、8pp⁸⁶-#ᶜ9⁶.☉…➡️けけろ☉☉⁶-#ᶜ6⁶.◝◝⁷⁷⁷◝◝◝⁸⁶-#ᶜ9⁶.\0\0ヲ⁸ヲ\0\0\0⁶-#ᶜ6⁶.qqpppwww⁸⁶-#ᶜ9⁶.⌂⌂⬅️☉◆☉☉☉⁶-#ᶜ6⁶.w666>、、、⁸⁶-#ᶜ9⁶.☉ゃゃゃりけけけ⁶-#ᶜ6⁶.⁷⁷⁷⁷⁷⁷⁷⁷⁸⁶-#ᶜ9⁶.⁸⁸⁸⁸⁸⁸⁸⁸\n⁶-#ᶜ6⁶.\0\0\0\0\0ら@ら⁸⁶-#ᶜ9⁶.ユ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0GDC⁸⁶-#ᶜ9⁶.?\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$²⁸⁶-#ᶜ9⁶.>\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$²⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0Iゃゃ⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0ノ$f⁸⁶-#ᶜ9⁶.ヲ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0\0¹\0⁸⁶-#ᶜ9⁶.ユ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$ᶜ⁸⁶-#ᶜ9⁶.ニ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\00023;⁸⁶-#ᶜ9⁶.?\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0░⌂⌂⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0   ⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0ナ `⁸⁶-#ᶜ9⁶.ヲ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0p▥⁸⁸⁶-#ᶜ9⁶.◝\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0▮((⁸⁶-#ᶜ9⁶.◝\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0🐱🐱🐱⁸⁶-#ᶜ9⁶.ゆ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0⁷\0³⁸⁶-#ᶜ9⁶.ᶠ\0\0\0\0\0\0\0\n⁶-#ᶜ6⁶.  ナ\0\0\0\0\0⁶.$$#\0\0\0\0\0⁶.□□、\0\0\0\0\0⁶.★★、\0\0\0\0\0⁶.d$'\0\0\0\0\0⁶.⬇️⁙ヌ\0\0\0\0\0⁶.1¹\0\0\0\0\0\0⁶.0\"、\0\0\0\0\0⁶.•▶ˇ\0\0\0\0\0⁶.IOっ\0\0\0\0\0⁶.▮▮ワ\0\0\0\0\0⁶.█▮ニ\0\0\0\0\0⁶.	웃p\0\0\0\0\0⁶.$<\"\0\0\0\0\0⁶.AAト\0\0\0\0\0⁶.\0\0³\0\0\0\0\0"
--titlescr="⁶-b⁶x8⁶y8⁶-#ᶜ5⁶.\0\0ナナナナナナ⁸⁶-#ᶜ9⁶.\0ユ▮▮▮▮▮▮⁶-#ᶜ5⁶.\0\0?○◝ナらら⁸⁶-#ᶜ9⁶.\0?@█\0゜!!⁶-#ᶜ5⁶.\0\0、、ううツツ⁸⁶-#ᶜ9⁶.\0>\"けcc\"\"⁶-#ᶜ5⁶.\0\0|◝◝れ▒¹⁸⁶-#ᶜ9⁶.\0|⬇️\0\0<B🐱⁶-#ᶜ5⁶.\0\000899;9ま⁸⁶-#ᶜ9⁶.\0|EFFろをE⁶-#ᶜ5⁶.\0\0x<゛ᶠ⁷³⁸⁶-#ᶜ9⁶.\0ヲ░B!▮⁸⁴⁶-#ᶜ5⁶.\0\0ナナナナナナ⁸⁶-#ᶜ9⁶.\0ユ▮▮▮▮▮▮⁶-#ᶜ5⁶.\0\0ナユx<、ᵉ⁸⁶-#ᶜ9⁶.\0ニ■	✽C#■⁶-#ᶜ5⁶.\0\0。、ううチチ⁸⁶-#ᶜ9⁶.\0?\"こbb\"\"⁶-#ᶜ5⁶.\0\0|◝◝れ▒¹⁸⁶-#ᶜ9⁶.\0|⬇️\0\0<B🐱⁶-#ᶜ5⁶.\0\000899;9ま⁸⁶-#ᶜ9⁶.\0|EFFろをE⁶-#ᶜ5⁶.\0\0x<゛ᶠ⁷³⁸⁶-#ᶜ9⁶.\0ヲ░るく…☉░⁶-#ᶜ5⁶.\0\0◝◝◝⁷⁷◝⁸⁶-#ᶜ9⁶.\0◝\0\0\0ヲヲ\0⁶-#ᶜ5⁶.\0\0ワワワppq⁸⁶-#ᶜ9⁶.\0◝⁸⁸⁸◆⬅️⌂⁶-#ᶜ5⁶.\0\0りりネccc⁸⁶-#ᶜ9⁶.\0ネ\"\"⁘⬆️⬆️⬆️⁶-#ᶜ5⁶.\0\0⁷⁷⁷⁷⁷⁷⁸⁶-#ᶜ9⁶.\0ᶠ⁸⁸⁸⁸⁸⁸\n⁶-#ᶜ6⁶.ナナナナナナナナ⁸⁶-#ᶜ9⁶.▮▮▮▮▮▮▮▮⁶-#ᶜ6⁶.ららららナ◝○?⁸⁶-#ᶜ9⁶.!!!!゜\0█@⁶-#ᶜ6⁶.ツツツツうう、、⁸⁶-#ᶜ9⁶.\"\"\"\"ccけ\"⁶-#ᶜ6⁶.¹¹¹▒れ◝◝|⁸⁶-#ᶜ9⁶.²²🐱B<\0\0⬇️⁶-#ᶜ6⁶.ヲヲx9;998⁸⁶-#ᶜ9⁶.⁴⁴✽FDFFE⁶-#ᶜ6⁶.⁷ᶠᵉ、、8pp⁸⁶-#ᶜ9⁶.⁸▮■\"\"D☉☉⁶-#ᶜ6⁶.ナナナナナナナナ⁸⁶-#ᶜ9⁶.▮▮▮▮▮▮▮▮⁶-#ᶜ6⁶.゜?9ppナらら⁸⁶-#ᶜ9⁶. @F웃웃■!!⁶-#ᶜ6⁶.チチチチうう。。⁸⁶-#ᶜ9⁶.\"\"\"\"bcけ\"⁶-#ᶜ6⁶.¹¹¹▒れ◝◝|⁸⁶-#ᶜ9⁶.²²🐱B<\0\0⬇️⁶-#ᶜ6⁶.ヲヲx9;998⁸⁶-#ᶜ9⁶.⁴⁴✽FDFFE⁶-#ᶜ6⁶.⁷ᶠᵉ、、8pp⁸⁶-#ᶜ9⁶.☉…➡️けけろ☉☉⁶-#ᶜ6⁶.◝◝⁷⁷⁷◝◝◝⁸⁶-#ᶜ9⁶.\0\0ヲ⁸ヲ\0\0\0⁶-#ᶜ6⁶.qqpppwww⁸⁶-#ᶜ9⁶.⌂⌂⬅️☉◆☉☉☉⁶-#ᶜ6⁶.w666>、、、⁸⁶-#ᶜ9⁶.☉ゃゃゃりけけけ⁶-#ᶜ6⁶.⁷⁷⁷⁷⁷⁷⁷⁷⁸⁶-#ᶜ9⁶.⁸⁸⁸⁸⁸⁸⁸⁸\n⁶-#ᶜ6⁶.\0\0\0\0\0ら@ら⁸⁶-#ᶜ9⁶.ユ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0GDC⁸⁶-#ᶜ9⁶.?\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$²⁸⁶-#ᶜ9⁶.>\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$²⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0Iゃゃ⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0ノ$f⁸⁶-#ᶜ9⁶.ヲ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0\0¹0⁸⁶-#ᶜ9⁶.ユ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0、$ᶜ⁸⁶-#ᶜ9⁶.ニ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\00023;⁸⁶-#ᶜ9⁶.?\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0░⌂⌂⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0   ⁸⁶-#ᶜ9⁶.|\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0ナ `⁸⁶-#ᶜ9⁶.ヲ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0p▥⁸⁸⁶-#ᶜ9⁶.◝\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0▮((⁸⁶-#ᶜ9⁶.◝\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0🐱🐱🐱⁸⁶-#ᶜ9⁶.ゆ\0\0\0\0\0\0\0⁶-#ᶜ6⁶.\0\0\0\0\0⁷\0³⁸⁶-#ᶜ9⁶.ᶠ\0\0\0\0\0\0\0\n⁶-#ᶜ6⁶.  ナ\0\0\0\0\0⁶.$$#\0\0\0\0\0⁶.□□、\0\0\0\0\0⁶.★★、\0\0\0\0\0⁶.d$'\0\0\0\0\0⁶.⬇️⁙ヌ\0\0\0\0\0⁶.1¹\0\0\0\0\0\0⁶.0\"、\0\0\0\0\0⁶.•▶ˇ\0\0\0\0\0⁶.IOっ\0\0\0\0\0⁶.▮▮ワ\0\0\0\0\0⁶.█▮ニ\0\0\0\0\0⁶.	웃p\0\0\0\0\0⁶.$<\"\0\0\0\0\0⁶.AAト\0\0\0\0\0⁶.\0\0³\0\0\0\0\0"

titlescr="⁶-b⁶x8⁶y8⁶-#ᶜ5⁶.\0\0ユユユppユ⁸⁶-#ᶜ9⁶.\0ヲ⁸⁸⁸☉☉⁸⁶-#ᶜ5⁶.\0\0◆かよままよ⁸⁶-#ᶜ9⁶.\0エP`@GG@⁶-#ᶜ5⁶.\0\0³³³³³³⁸⁶-#ᶜ9⁶.\0⁷⁴⁴⁴⁴⁴⁴⁶-#ᶜ5⁶.\0\0◜◜◜ᵉᵉ◜⁸⁶-#ᶜ9⁶.\0◝¹¹¹ヨヨ¹⁶-#ᶜ5⁶.\0\0wwwppw⁸⁶-#ᶜ9⁶.\0◝☉☉☉◆◆☉⁶-#ᶜ5⁶.\0\0ユュ◜ᵉ⁷⁷⁸⁶-#ᶜ9⁶.\0ユᶜ²¹ヨ⁸ヘ⁶-#ᶜ5⁶.\0\0ニフフヤヒナ⁸⁶-#ᶜ9⁶.\0ヨ◀「「▮」゜⁶-#ᶜ5⁶.\0\0ナナナナナ◝⁸⁶-#ᶜ9⁶.\0ヨ■■■■゜\0⁶-#ᶜ5⁶.\0\0◜◜◜ナナナ⁸⁶-#ᶜ9⁶.\0◝¹¹¹゜■■⁶-#ᶜ5⁶.\0\0ヤヤヤナナナ⁸⁶-#ᶜ9⁶.\0◝▮▮▮゜■■⁶-#ᶜ5⁶.\0\0??よ█らト⁸⁶-#ᶜ9⁶.\0○@ら@○? ⁶-#ᶜ5⁶.\0\0<◝◝れ▒▒⁸⁶-#ᶜ9⁶.\0<れ\0\0<BB⁶-#ᶜ5⁶.\0\0ヲヲン9;ャ⁸⁶-#ᶜ9⁶.\0ュ⁴⁵⁶をろ⁴⁶-#ᶜ5⁶.\0\0◆かよままよ⁸⁶-#ᶜ9⁶.\0エP`@GG@⁶-#ᶜ5⁶.\0\0⁷⁷◆◆◆タ⁸⁶-#ᶜ9⁶.\0⁷☉☉PPP$⁶-#ᶜ5⁶.\0\0ᶠᶠᶠᶠᶠᵉ⁸⁶-#ᶜ9⁶.\0゜▮▮▮▮▮■\n⁶-#ᶜ6⁶.ユユppppp\0⁸⁶-#ᶜ9⁶.⁸⁸☉☉☉☉☉ヲ⁶-#ᶜ6⁶.か◆█████\0⁸⁶-#ᶜ9⁶.`PO@@@@ら⁶-#ᶜ6⁶.³³³³◝◝◝\0⁸⁶-#ᶜ9⁶.⁴⁴⁴ュ\0\0\0◝²6⁶.¹¹ヨヨ¹¹¹◝⁶.☉☉◆◆☉☉☉◝⁶-#ᶜ6⁶.んんんᵉ◜ュユ\0⁸⁶-#ᶜ9⁶.(((ヨ¹²ᶜユ⁶-#ᶜ6⁶.ヤヤヤモヤフニ\0⁸⁶-#ᶜ9⁶.▮▮▮■▮「◀ヨ⁶-#ᶜ6⁶.◝◝ナナナナナ\0⁸⁶-#ᶜ9⁶.\0\0゜■■■■ヨ⁶-#ᶜ6⁶.ナナナナナナナ\0⁸⁶-#ᶜ9⁶.■■■■■■■ヨ⁶-#ᶜ6⁶.ナナナナナナナ\0⁸⁶-#ᶜ9⁶.■■■■■■■ヨ⁶-#ᶜ6⁶.トトら██\0\0\0⁸⁶-#ᶜ9⁶.  ?AA▒¹¹⁶-#ᶜ6⁶.▒▒▒れ◝◝<\0⁸⁶-#ᶜ9⁶.BBB<\0\0れ<⁶-#ᶜ6⁶.ャャ;9988\0⁸⁶-#ᶜ9⁶.⁴⁴ろFFED|⁶-#ᶜ6⁶.か♥◆おうもヲ\0⁸⁶-#ᶜ9⁶.`xPabB⁴ュ⁶-#ᶜ6⁶.タタタsss#\0⁸⁶-#ᶜ9⁶.$$$😐😐😐T'⁶-#ᶜ6⁶.ᵉᵉᵉᵉᵉᵉᵉ\0⁸⁶-#ᶜ9⁶.■■■■■■■゜\n⁶-#ᶜ6⁶.\0\0\0\0\0ら@ら⁶.\0\0\0\0\0GDC⁶.\0\0\0\0\0、$²⁶.\0\0\0\0\0、$²⁶.\0\0\0\0\0Iゃゃ⁶.\0\0\0\0\0ノ$f⁶.\0\0\0\0\0\0¹0⁶.\0\0\0\0\0、$ᶜ⁶.\0\0\0\0\00023;⁶.\0\0\0\0\0░⌂⌂⁶.\0\0\0\0\0   ⁶.\0\0\0\0\0ナ `⁶.\0\0\0\0\0p▥⁸⁶.\0\0\0\0\0▮((⁶.\0\0\0\0\0🐱🐱🐱⁶.\0\0\0\0\0⁷\0³\n⁶.  ナ\0\0\0\0\0⁶.$$#\0\0\0\0\0⁶.□□、\0\0\0\0\0⁶.★★、\0\0\0\0\0⁶.d$'\0\0\0\0\0⁶.⬇️⁙ヌ\0\0\0\0\0⁶.1¹\0\0\0\0\0\0⁶.0\"、\0\0\0\0\0⁶.•▶ˇ\0\0\0\0\0⁶.IOっ\0\0\0\0\0⁶.▮▮ワ\0\0\0\0\0⁶.█▮ニ\0\0\0\0\0⁶.	웃p\0\0\0\0\0⁶.$<\"\0\0\0\0\0⁶.AAト\0\0\0\0\0⁶.\0\0³\0\0\0\0\0"
gameoverscr="⁶-b⁶x8⁶y8 ⁶-#ᶜ5⁶.\0ナヲュ<゛ᵉ\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0ᵉ⁸⁶-#ᶜ9⁶.ナ「⁴²る!■➡️⁶-#ᶜ5⁶.\0⁷゜゜<「\0\0⁸⁶-#ᶜ9⁶.⁷「  C$「◝⁶-#ᶜ5⁶.\0|||モモモ\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0ん⁸⁶-#ᶜ9⁶.|🐱🐱🐱■■■(⁶-#ᶜ5⁶.\0ユユユppp\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0q⁸⁶-#ᶜ9⁶.ヲ⁸⁸⁸웃웃웃⌂⁶-#ᶜ5⁶.\0りりネccc\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0w⁸⁶-#ᶜ9⁶.り\"\"⁘⬆️⬆️⬆️☉²5ᶜ6⁶.\0\0\0\0\0\0\0ワ⁸⁶-#ᶜ9⁶.◝⁸⁸⁸☉☉⁸⁸⁶-#ᶜ5⁶.\0○○○\0\0?\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0?⁸⁶-#ᶜ9⁶.◝███◝○@@⁶-#ᶜ5⁶.\0\0らナナユp\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0p⁸⁶-#ᶜ9⁶.\0ら ▮▮⁸☉☉⁶-#ᶜ5⁶.\0゜○◝ヨナら\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0ら⁸⁶-#ᶜ9⁶.゜`█\0ᵉ■  ⁶-#ᶜ5⁶.\0ᵉ、、、99\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0009⁸⁶-#ᶜ9⁶.゜■\"##FFF⁶-#ᶜ5⁶.\0まううう🅾️🅾️\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0🅾️⁸⁶-#ᶜ9⁶.ュDbbbQQQ²5ᶜ6⁶.\0\0\0\0\0\0\0◝⁸⁶-#ᶜ9⁶.◝\0\0\0ュュ\0\0⁶-#ᶜ5⁶.\0ャャャ889\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0ン⁸⁶-#ᶜ9⁶.◝⁴⁴⁴んCる²⁶-#ᶜ5⁶.\0ᶠ゜?888\0⁸⁶-#ᶜ6⁶.\0\0\0\0\0\0\0゜⁸⁶-#ᶜ9⁶.ᶠ▮ @GDG \n⁶-# ⁶-#ᶜ6⁶.ᵉᵉ゛<ュヲナ\0⁸⁶-#ᶜ9⁶.➡️➡️くる²⁴「ナ⁶-#ᶜ6⁶.??よまよトん\0⁸⁶-#ᶜ9⁶.らら@G@ 8フ⁶-#ᶜ6⁶.ん◝◝◝⬇️¹¹\0⁸⁶-#ᶜ9⁶.8\0\0\0|🐱🐱⬇️⁶-#ᶜ6⁶.qqsssww\0⁸⁶-#ᶜ9⁶.⌂⌂😐😐😐☉☉◝⁶-#ᶜ6⁶.666>、、、\0⁸⁶-#ᶜ9⁶.ゃゃゃりけけけゆ²6⁶.⁸☉☉☉⁸⁸⁸◝⁶-#ᶜ6⁶.?\0\0\0○○○\0⁸⁶-#ᶜ9⁶.@○\0◝███◝⁶-#ᶜ6⁶.ppユナナら\0\0⁸⁶-#ᶜ9⁶.☉☉⁸▮▮ ら\0⁶-#ᶜ6⁶.ららナヨ◝○゜\0⁸⁶-#ᶜ9⁶.  ■ᵉ\0█`゜⁶-#ᶜ6⁶.qqqナナナら\0⁸⁶-#ᶜ9⁶.⌂⌂⌂■■▮ ナ⁶-#ᶜ6⁶.♥♥♥⬇️⬇️⬇️▒\0⁸⁶-#ᶜ9⁶.HHHDDDBれ⁶-#ᶜ6⁶.◝³³³◝◝◝\0⁸⁶-#ᶜ9⁶.\0ュ⁴ュ\0\0\0◝⁶-#ᶜ6⁶.ンヲ88;;;\0⁸⁶-#ᶜ9⁶.²³らGDDD○⁶-#ᶜ6⁶.゜⁷ᶠ゛、<x\0⁸⁶-#ᶜ9⁶. 「▮!\"B░ュ"
state="menu"
-- your starting seed 
my_seed=0xabcd.0123   -- or time() or whatever
-- use your most recent seed
srand(my_seed)



unlocked={
semisolid=false
}
--tileflags
solid=0
semisolid=1
water=2
spikes=3

tilewidth=8
tileheight=8

jumprestrainer=false
movingup=false
xvel=0.0
yvel=0.0
onground=false
maxspeed=1.0
acc=0.095
friction=0.25
jumpbuffer=0
rememberflipx=false



camerax=player.x-128/2+8/2
cameray=player.y-72 --((player.y-75)-128/2)+8/2
focus=player.x+8/2-camerax
shkx=0
shky=0
screenwidth=128

movingright=false
movingleft=false

test =18

idle=96
walk=64
playerstate=idle
rememberplayerstate=playerstate
animationframe=0
animationcounter=0

previousfeetpos=0
fallthroughtimer=0

bulx=0
buly=0

buls={}

gunyrun={10,9,10,11}
gunyidle={10,11,11,11}
playertoprun={6,5,5,7}
playertopidle={6,6,8,7}

framecounter=0

--reactorx=64
--reactory=168
animationflip=false
reactorframe=0

 if finito==false then
 freshscreen()
 end

 
blinktimer=25

enemyframe=0

explosions={}
swaves={}
muzzles={}
shake=0

mapwidth=1024 --128*8
mapheight=256 --32x8

map_start=0

scrollcounter=0

textcolor=1
startcountdown=0
startpressed=false
blinkfreq=0
fade={0.7,0.6,0.3,0.6,0.7,0,0}
--fadeamount=1.0
fadeindone=false
palt(2,true)
palt(0, false)
 tval=0.3
 lstart=0
 lend=0
 
 duration = 1.5 -- seconds
 start = time()
 
 up_acc=0.125
 down_acc=0.25
 finito=false
 
 
end
-->8
--update

function _update60()
 framecounter+=1
 
 if state=="menu" then
  --update_game()
  animatereactor()
  animatemetroids()
  animateplayer()
  if framecounter%6==0 then
   enemyframe+=2
   enemyframe=enemyframe&7
  end
  moverobots()
  update_menu()
 elseif state=="game" then
  update_game()
   if finito==true
   and onground==true
   and reading==false then
    _init()
    fadeamount=0.7
   end
 elseif state=="scroll_l" then
  update_scroll_l()
 elseif state=="scroll_r" then
  update_scroll_r()
 elseif state=="gameover" then
  update_gameover()
 elseif state=="reading" then
  tb_update() -- handle the text box on every frame update.

 elseif state=="returntotitle" then
  update_return()
 end
end

function update_return()
 --fadeamount=0.7
 --yvel=0.0
 --xvel=0.0
 --movingup=false

 
 if flr(camerax)<=0 and flr(cameray)>=128 then
  if reactors[2].active
  or reactors[3].active then
   tb_init(45,{"i see you found my speedrun bug"})
   state="reading"
  else
   tb_init(45,{"thanks for playing my generic\nplatformer. i was in the middle\nof a move and felt terrible so","i joined my first game jam,\ngithub gameoff,\nthe theme was scale so i choose","pico-8 since it has an\nextremely small screen\nresolution, which is probably","why it was cancelled, only a\nhandful of prototypes have been\nfound,three in a tec toy","warehouse in brazil, and one in\nsouth korea branded 'lexaloffle\nsuper aladdin boy-8'.","very little is\nknown about the console, but\none thing is for sure,","i like it!","graphics: 0x72, me\nmusic: snabisch, gruber\nsfx: me, gruber"})
   state="reading"
  --_init()
  --state="menu"
  --jumprestrainer=false
  --finito=false
 --fadeamount=0.7
  end
 end
 
 if camerax>0 then
  camerax-=1
 end
 
 if cameray<128 then
  cameray+=1
 end
end

function update_gameover()
		if btnp(❎) then
		 --jumprestrainer=true
		 startpressed=true
		 --cls()
		 --_init()
		end
		
	if startpressed==true then
		if fadeamount<1.0 then
		 fadeamount+=0.025
		else
		 _init()
		 --cls()
		end
	else
			if fadeamount<0.8 then
		 fadeamount+=0.025
		end
	end
	
	
end

function update_scroll_r()
 
 tval = (time() - start) / duration
 if mid(tval, 0, 1) == tval then
  camerax=lerp(lstart,lend,easeinoutovershoot(tval))
 end
 camera(camerax,cameray)
 
 if camerax==lend then
  state="game"
  sfx(-2)
  map_start=0
  map_end=camerax+screenwidth
 end
 

end

function update_scroll_l()
 --tval is just (time() - start) / duration 
 --where start is assigned when you trigger the animation
 tval = (time() - start) / duration

 if mid(tval, 0, 1) == tval then
  camerax=lerp(lstart,lend,easeinoutovershoot(tval))
 end
 camera(camerax,cameray)
 
 if camerax==lend then
  state="game"
  sfx(-2)
  map_start=camerax
  map_end=mapwidth
 end
 
end


function update_menu()
	if jumprestrainer==false then
		if btnp(❎) then
		 startpressed=true
		 startcountdown=80--80
		 sfx(61)--61
		 
		 jumprestrainer=true
		end
 end
  
  if startpressed then
   startcountdown-=1
   blinkfreq=3
   if startcountdown==50 then
    music(-1,700)
   end
   
	  if startcountdown<9 then
    if fadeamount<1.0 then
     fadeamount+=0.025
    end
	  end
	  --fade_scr(fadeamount)
	  
	  if startcountdown==0 then
	   state="game"
	   jumprestrainer=true
	   --cls()
	   music(0)
	   player.x=179
				player.y=16*6
				camerax=player.x+4-128/2 +33
				cameray=player.y-72 --((player.y-75)-128/2)+8/2
				focus=player.x+4-camerax
				flipx=false
	   
	   --reset
	   startpressed=false
	   freshscreen()
	  end

	 
	 else
	  blinkfreq=10
	  if fadeamount>0.7 then
    fadeamount-=0.025
   end
   --fade_scr(fadeamount)
   --fade_scr(0.7)
  end
  

  --fadeamount=0.7
  --fade_scr(fadeamount)
  fade_scr(fadeamount)
end

function update_game()
if fadeindone==false then
	if fadeamount>0.6 then
	 fadeamount-=0.025
	else
	 fadeindone=true
	end
	
else
 fadeamount=0.6
end

 --fadeamount=0.7


--if state=="game" then

--framecounter+=1
rememberflipx=flipx

if movingright==false then
 if btn(⬅️) then
  if rememberflipx==false then
   player.x-=1
  end
  flipx=true
  player.colbox_right=12.0
  player.colbox_left=5.0
  playerstate=walk
  
  speedup()
  movingleft=true
  handleleft()
 
 --if still sliding left
 elseif movingleft==true then
  if xvel > 0.0 then
   xvel-=0.25
  else
   movingleft=false
   playerstate=idle
  end
  handleleft()
 end
end
 

if movingleft==false then
 if btn(➡️) then
  if rememberflipx==true then
   player.x+=1
  end
  flipx=false
  player.colbox_right=11.0
  player.colbox_left=4.0
  playerstate=walk
  
  speedup()
  movingright=true
  handleright()

 --if still sliding right
 elseif movingright==true then
  if xvel > 0.0 then
   xvel-=0.25
  else
   movingright=false
   playerstate=idle
  end
  handleright() 
 end
end
 
 --move bullets
for i=#buls,1,-1 do
 local mybul=buls[i]
 if mybul.dir==false then
  mybul.x+=7
 else
  mybul.x-=7
 end
 
 if mybul.x-camerax<-4
 or mybul.x-camerax>132 then
  del(buls,mybul)
 end
end

--if unlocked.semisolid then
if btn(❎) then
 up_acc=0.125
 if btn(⬇️) then
  if unlocked.semisolid then
   if jumprestrainer == false then
    fallthroughtimer=5
    jumprestrainer = true
    onground = false
   end
  end
 else
  if jumprestrainer == false then
   sfx(48)--59
   jumprestrainer = true
   movingup = true
   yvel=2.75 --3.25
   onground = false
  end
 end
else
 if jumprestrainer == true
 and movingup == true then
  up_acc=0.5
 else
  up_acc=0.125
 end
 --you can jump again
 --after releasing jump button
 --and touching ground
 if onground == true then
  jumprestrainer = false
 end
end
--end
 
if fallthroughtimer>0 then
 fallthroughtimer-=1
end

 
 --[[
 if onground == false then
  --count down jump buffer
  if jumpbuffer > 0 then 
   jumpbuffer-=1
  end
  --if pressing jump before
  --touching ground, set
  --jumbuffer timer
  if btn(❎) then
   if jumprestrainer == false then
    jumpbuffer=4
   end 
  end
 end
 ]]--
 
--end--if state=="game"
 animateplayer()

 
  --update animationframe before this
  --and check collision after this
if playerstate==idle then
 player.colbox_top=playertopidle[animationframe+1]
else
 player.colbox_top=playertoprun[animationframe+1]
end
 

if movingup == true then
 moveup()
else 
 movedown()
end

previousfeetpos=int(player.y)+16
 
if btn(🅾️) then

--javascript version
--if framecounter%1==0 then
 --new bullet object
 sfx(0)
 local newbul={}
 local muzzle={}
 local xdistance=0
 local xdistance2=0
 --if framecounter%2==0 then
 --fadeamount=0.3
 --end
 
 if flipx==false then
  xdistance=15
  xdistance2=-1
  player.x-=0.1
 else
  xdistance=-7
  xdistance2=1
  player.x+=0.1
 end
 
 if playerstate==idle then
  newbul.y=player.y+gunyidle[animationframe+1]
  muzzle.y=player.y+gunyidle[animationframe+1]
 else
  xdistance+=xdistance2
  newbul.y=player.y+gunyrun[animationframe+1]
  muzzle.y=player.y+gunyrun[animationframe+1]
 end
 
 newbul.x=player.x+xdistance
 muzzle.x=player.x+xdistance
 
 if rand(2)==1 then
  newbul.y+=1
  muzzle.y-=1
 end
 
 muzzle.dir=flipx
 newbul.dir=flipx

 newbul.colbox_bottom=0.0
 newbul.colbox_top=0.0
 newbul.colbox_right=0.0
 newbul.colbox_left=0.0
 --add new bullet to bullet array
 add(buls,newbul)
 add(muzzles,muzzle)
-- end
end
--end
 
if finito==false then
	centercamera()
	
	
	 --camera y catches up quickly
	 --when touching ground
	if onground==true then
	 cameray=lerp((player.y-72),cameray,0.9)
	else
	 --camera still catches up slowly
	 --when not on ground
	 if cameray < player.y-72 then
	  cameray+=1
	 elseif cameray > player.y-54 then
	  cameray-=1
	 end
 end
 
 doshake()
end

 --handle bubbles
if framecounter%4==0 then
 for bubble in all(bubbles) do
	 if bubble.radius > 0 then
	  bubble.y-=1
	  bubble.radius-=0.2
	  bubble.x+=(rnd()-0.4)*1
	 else
	  bubble.y=bubble.spawny
	  bubble.x=bubble.spawnx
	  bubble.radius=1.99
	 end
 end
end

if framecounter%6==0 then
 enemyframe+=2
 enemyframe=enemyframe&7
end

 --check player collision
 --with pickups
for pickup in all(pickups) do
 if col(player,pickup) then
  del(pickups,pickup)
  sfx(4)
  if player.health<100 then
   player.health+=4.0
  end
 end
end

 --check player collision
 --with cards
for card in all(cards) do
 if col(player,card) then
  del(cards,card)
  sfx(4)
  state="reading"

  if card.number==1 then
   doors[1].clearance=true
   doors[2].clearance=true
   --tb_init(63,{"you unlocked the ability to\nfall through semi-solid\nplatforms by pressing ❎⬇️ "})
   tb_init(49,{"airlock 54 access card"})
   local x=doors[1].x/8+1
   local y=doors[1].y/8
   mset(x,y+1,000)
   mset(x,y+2,000)
  elseif card.number==2 then
   doors[3].clearance=true
   doors[4].clearance=true
   --tb_init(63,{"you unlocked the ability to\nfall through semi-solid\nplatforms by pressing ❎⬇️ "})
   tb_init(49,{"airlock 53 access card"})
   local x=doors[3].x/8+1
   local y=doors[3].y/8
   mset(x,y+1,000)
   mset(x,y+2,000)  
  end
 end
end

--ckeck collision with reactors
for reactor in all(reactors) do
 if col(player,reactor) then
 
  if reactor.active then
   reactor.active=false
   state="reading"
   --sfx(61)
   if reactor.number==1 then
    music(14)
    finito=true
    state="returntotitle"
   elseif reactor.number==2 then
    tb_init(49,{"you unlocked the ability\nto fall through semi-solid\nplatforms by pressing ❎⬇️ "})
    unlocked.semisolid=true  --reading=true
   elseif reactor.number==3 then
    tb_init(49,{"opened safety gate"})
    mset(58,21,215)
    mset(58,22,000)
    mset(58,23,231)
   end
  end
 end
end

 animatereactor()
 

 
 
 --check col between player
 --and enemies
if player.invul==0 then
 for enemy in all(enemies) do
  if col(player,enemy) then
  
    sfx(59)--62
	   player.health-=4.0
	   player.invul=60
	   xvel=3
	   if flipx==false then
	    movingright=false
     movingleft=true
	   else
	    movingright=true
     movingleft=false	   
	   end

  end
 end
else
 player.invul-=1
end

 if player.health<=0 then
  state="gameover"
  music(8)
 end
 
 
 for box in all(boxes1) do
  local maptile1=mget(right(box),bellow(box))
  local maptile2=mget(left(box),bellow(box))
 
    if fget(maptile1) | fget(maptile2)!=0 then
    
    else
     box.yvel+=0.050
     box.y+=box.yvel
    end
    
  for otherbox in all(boxes1) do
	  if box.y != otherbox.y
	  and box.x != otherbox.x then
	   if col2(box,otherbox) then
	    box.y=otherbox.y-16
	    box.yvel=0.0
	   end
	  end
  end
 
 end
 
 
function boxboxcol()
 for box in all(boxes1) do
  for otherbox in all(boxes1) do
	  if box.y  != otherbox.y
	  and box.x != otherbox.x then
	   if col2(box,otherbox) then
     return true
	   end
	  end
  end
 end
end


--check col with metroids
if player.invul==0 then
 for metroid in all(metroids) do
  if col(player,metroid) then
	   --fadeamount=0.3
	   sfx(62)
	   player.health-=4.0
	   player.invul=60
	   xvel=3
	   if flipx==false then
	    movingright=false
     movingleft=true
	   else
	    movingright=true
     movingleft=false	   
	   end
	  
  end
 end
else
 player.invul-=1
end

if player.invul==0 then
 local maptile1=mget(left(player),bottom(player))
 local maptile2=mget(right(player),bottom(player))

 --check if water
 if fget(maptile1,water) 
 or fget(maptile2,water) then
  --player.y-=overlapdown()
		  player.health-=4.0
		  player.invul=60
		  sfx(62)
  --player.y=int(player.y)
 end
end

 animatemetroids()
 


 --check col between bullets
 --and enemies
for bullet in all(buls) do
 for enemy in all(enemies) do
  if col(bullet,enemy) then
   --fadeamount=0.3
   shake=0.1
   shockwave(bullet.x,bullet.y)
   del(buls,bullet)
   sfx(2)
   enemy.flash=20
   enemy.life-=1
   if enemy.life==0 then
    shake=0.2
    del(enemies,enemy)
    explosion(enemy.x+8,enemy.y+16+5)
    sfx(1)
    if enemy.carries=="card" then
     local card={}
     card.x=enemy.x+4
     card.y=enemy.y+24
     card.colbox_bottom=6.0
     card.colbox_top=2.0
     card.colbox_right=7.0
     card.colbox_left=0.0
     card.number=enemy.cardnr
     add(cards,card)
    end
   end
  end
 end
end

 for bullet in all(buls) do
  for metroid in all(metroids) do
   if col(bullet,metroid) then
    shake=0.2
    explosion(metroid.x+4,metroid.y+4)
    sfx(1)
	   shockwave(bullet.x,bullet.y)
	   del(buls,bullet)
	   sfx(2)
    del(metroids,metroid)
    
   end
  end
 end
 
  --remove metroid from array
  for metroid in all(metroids) do
		 --local maptile1=mget(left(metroid),bottom(metroid))
		 --if fget(maptile1,0) then
		 -- del(metroids,metroid)
		 --end
		 if metroid.y > 256 then
		  del(metroids,metroid)
		 end
  end

 --check col between bullets
 --and boxes
for bullet in all(buls) do
 for box in all(boxes1) do
  if col(bullet,box) then
   shake=0.1
   shockwave(bullet.x,bullet.y)
   del(buls,bullet)
   sfx(2)
   box.hits-=1
   if box.hits==0 then
    shake=0.2
    mset(box.x\8,box.y\8,000)
    mset(box.x\8,box.y\8+1,000)
    mset(box.x\8+1,box.y\8,000)
    mset(box.x\8+1,box.y\8+1,000)
    del(buls,bullet)
    del(boxes1,box)
    explosion(box.x+8,box.y+8)
    sfx(1)
   end
  end
 end
end

 --check collision between bullets
 --and solid walls
for bullet in all(buls) do
 local maptile1=mget(left(bullet),top(bullet))
 --local maptile2=mget(right),bottom(enemy))
 if fget(maptile1,0) then
  shake=0.1
  shockwave(bullet.x,bullet.y)
  del(buls,bullet)
  sfx(2)
 end
end

moverobots()


 
 
if blinktimer==0 then
 blinktimer=25
else
 blinktimer-=1
end
 
--animate broken lights
if blinktimer<5 then
 for tile in all(_brokenlights) do
  local x,y=unpack(tile)
  if mget(x,y)==156 then
   mset(x,y,140)
  end
 end
else
 for tile in all(_brokenlights) do
  local x,y=unpack(tile)
  if mget(x,y)==140 then
   mset(x,y,156)
  end
 end
end
 
if player.x+7>map_end then
 state="scroll_l"
 lstart=camerax
 lend=camerax+127
 start = time()
 sfx(47)
elseif player.x+7<map_start then
 state="scroll_r"
 lstart=camerax
 lend=camerax-127
 start = time()
 sfx(47)
end



end
-->8
function _draw()

 if state=="menu" then
  draw_menu()
 elseif state=="game" then
  draw_game()
 elseif state=="scroll_l" then
  --draw_scroll()
  draw_game()
 elseif state=="scroll_r" then
  --draw_scroll()
  --works fine
  draw_game()
 elseif state=="gameover" then
  draw_game()
  draw_gameover()
 elseif state=="reading" then
  draw_game()
 elseif state=="returntotitle" then
  draw_return()
  drawhealth()
 end
end


function draw_gameover()
 --cls()
 pal()

 pal(9, 1)
 pal(5, 14)
 --fade_scr(fadeamount)
	if startpressed==false then
	 ?gameoverscr,camerax,cameray+64-16
	 --print("game over",30+camerax,63+cameray,7)
	end
end

function draw_return()
 cls()
 --treat color 2 as transparant
 palt(2,true)
 --draw black pixels
 palt(0, false)
 camera(camerax,cameray)
 drawmetroids()
 map(0,0)
 

 drawreactor()
 drawrobots()
 drawplayer()
end


function draw_scroll()

end


function draw_menu()
 --framecounter+=1
 local colors={0,1,14,6}
 cls()
 fade_scr(fadeamount)
 --treat color 2 as transparant
 palt(2,true)
 --draw black pixels
 palt(0, false)
 camera(0,128)
 drawmetroids()
 map(0,0)
 

 drawreactor()
 drawrobots()
 drawplayer()
 
 pal()
 --pal(6, 14)
 --pal(9, 5)
 --pal(5, 1)
 
 --pal(6, 5)
 pal(9, 1)
 pal(5, 14)

 --draw_game()
 ?titlescr,0,127+12
 --print("press ❎ to start",30,71,textcolor)
 if framecounter%blinkfreq==0 then
  textcolor+=1
 end
 pal()
 if textcolor>1 then
  print("press ❎ to start",30+2,128+82,colors[textcolor])
 end
 if textcolor==4 then
  textcolor=1
 end
end

function draw_game()
 --camera(shkx,shky)
 --clear screen
 
 cls()
 fade_scr(fadeamount)
 --treat color 2 as transparant
 palt(2,true)
 --draw black pixels
 palt(0, false)
 
 --draw enemy 2
 drawmetroids()

 --draw playfield
 map(0,0)
 

 drawreactor()


 

 
 --sspr(64,0,16.16,player.x,player.y)
 local text = camerax
 --print(text,player.x,player.y-10,9)


  --draw pickups
	for pickup in all(pickups) do
	 spr(151,pickup.x,pickup.y,1,1)
	end
	
	--draw passcards
	for card in all(cards) do
	 spr(141,card.x,card.y,1,1)
	end


 --draw boxes1
 for box in all(boxes1) do
  spr(box.type,box.x,box.y,2,2)
 end


 drawrobots()

 
 
 

 

 
 
 --draw bullets
 --for bullet in all(buls) do
  --spr(152,bullet.x,bullet.y)
 --end
 
 for muzzle in all(muzzles) do
  if framecounter%rand(4)==0 then
   spr(200,muzzle.x,muzzle.y,1,1,muzzle.dir)
  end
  del(muzzles,muzzle)
 end
 
 drawplayer()

 --draw bubbles
	for bubble in all(bubbles) do
	 if bubble.radius > 0 then
	  rectfill(bubble.x,bubble.y,bubble.x+flr(bubble.radius),bubble.y+flr(bubble.radius),6)
	 end
 end
 
 --draw flip animations
	for anim in all(animations) do
	 spr(anim.tile,anim.x,anim.y,1,1,anim.flipx)
	 
	 if framecounter%5==0 then
	  anim.flipx=not anim.flipx
	 end
 end
 
 --draw tunnels
	for tun in all(tunnels) do

	 spr(224,tun.x,   tun.y,   3,2,true,false)
	 spr(224,tun.x,   tun.y+16,3,1,true,true)
	 spr(224,tun.x+24,tun.y,   3,2,false,false)
	 spr(224,tun.x+24,tun.y+16,3,1,false,true)
 end
 

 
 --draw tunnel doors
 for door in all(doors) do
  if framecounter%6==0 then
  if door.clearance==true then
   if are_closer_than(25, door.x+4,door.y, player.x+8,player.y) then
		 --if dst(player,door)<30 then
		  if door.frame<3 then
		     if door.frame==0 then
		      sfx(54)
		     end
		   door.frame+=1
		  end
		 else
		  if door.frame>0 then
		     if door.frame==3 then
		      sfx(54)
		     end
		   door.frame-=1  
		  end
		 end
	 end
	 end
	 
	 if door.frame<3 then
   spr(227+door.frame,door.x,door.y,   1,2,door.flipx,false)
   spr(227+door.frame,door.x,door.y+16,1,1,door.flipx,true)
  end 
 end
 
 --draw explosions
 for explosion in all(explosions) do
  explosion.dur+=1
  local xcolor=0
  if explosion.dur/explosion.maxdur<0.3 then
   xcolor=7
  elseif explosion.dur/explosion.maxdur<0.7 then
   xcolor=6
  else
   xcolor=5
  end
  circfill(explosion.x,explosion.y,explosion.size,xcolor)
  
  explosion.speedx=explosion.speedx*0.9
  explosion.speedy=explosion.speedy*0.9
  explosion.x+=explosion.speedx
  explosion.y+=explosion.speedy
  
  if explosion.dur>explosion.maxdur then
   explosion.size-=0.125 --125
   if explosion.size<0 then
    del(explosions,explosion)
   end
  end
 end
 
 
  --draw shockwaves
 for sw in all(swaves) do
  circ(sw.x,sw.y,sw.r,7)
  sw.r+=0.5
  if sw.r>sw.maxr then
   del(swaves,sw)
  end
 end
 
 drawhealth()

 --water overlay
 if framecounter%2==0 then
	for wat in all(watertiles) do

	 spr(wat.frame,wat.x,wat.y)
 end
 end

tb_draw() 
end
__gfx__
00000000000000000000000000000000577777700666660005555500577777777777777006666666666666000555555555555500000550000055500000005500
00000000055055000000000000000000777766706666556055550050777777777677766066666666656665505555555550555050000500000005000000550000
00700700000000000000000000000000777777706666666055555550777777777766676066666666665556505555555555000550000550000055500000005500
00077000005500000000000000000000766766606556555050050050777776676677566066666556556655505555500500550050000500000050500000550000
00077000000000000000000000000000777675706665606055505050777777766666666066666665555555505555555000000000000550000055500000005500
00700700000000000000000000000000777666606665555055500000776676677666666066556556655555505500500550000050000500000005000000550000
00000000000000000000000000000000675776605606655005055050777767666766655066665655565555505555050005000050000550000055500000005500
00000000000000000055500005550000776665606655505055000000777766666666666066665555555555505555000000000050000500000050500000550000
00056000000000000000000000000000767556606560055050500050767677556665566065656655555555505050550000000000000000000055500000005500
00560000000000005550555055500000666066605550555000000050777666666600606066655555550050505550000000000050005555000005000000550000
00056000000000000000000000000000776666006655550055000000776665566665560066555555555555005500000000000000000550000055500000005500
00560000000005550555055505550000666500605550005050000000776776660606006066566555050500005505500000000000000500000050500000050000
00056000000000000000000000000000660056005500050050000000766666655660660065555555555055005000000000000000000500000055500000050000
00560000000000555055505550000000666660005555500000000000767666000605500065655500050550005050000000000000005000000000000000000000
00056000000000000000000000000000065055000500000000500000066666666060000005555555505000000555055055000000005005000000000000050000
00560000000000055505550555000000000000000000000000000000000000000000000000000000000000000000000000000000000550000000000000000000
00056000000000000000000000000000577777777777777057777770677777705777777067777770005056000606066600060000600660000006060500060000
00560000000000000555055500555000777777776777666077767660776766607776766077676660006060000056506000060000060006600006560500060000
00056000000000000000000000000000777777777666776076676660767776607776556067766600006000000006056000060000006600066556065000060000
00560000000000000000000000055500777777667766556077765560676666007767766076776550006000000006056000060000000066000006560000060000
00060000005500000000000000000000766766776556600077677660767755607666660076655600000000000006006000060000000000665556060000000000
00000000000000000000000055500000777675566660055076666600766666006600505066560050000000000006006000060000000000000006000000000000
00060000055055000000000000000000076666660055550066005050666600500666050006605500000000000006000000060000000000000006000000000000
00000000000000000000000000000000000000000000000006660500066055000000000000000000000000000006000000060000000000000006000000000000
00000000555555555555555500550055066666666666660006666600065666000666660006566600055555555555550005555500055555000555550005555500
05000500505000000000050500555500666666665666555066665550656655506666555065665550555555550555005050055550550050505005555055005050
00000500555550000005555500555555666666666555665066565550665555506656555066555550555555555000555055550550505500505555050050550050
05000500505005500550050500005555666666556655555065655500650505006565550065050500555555005500005050500500550555005050000055055000
00000000555000055000055500550055655655665555500066555000565550006555050065500550500500550000005055000000505500005550000050000050
05000500505005500550050500555500666565555550055065550500655005505505500055055000555050000000000055500000500000005000000055000000
00000500555550000005555500555555065555550055550055055000550550000555050005500500050555505000050050000000550000000505500005500000
05000500505000000000050500005555000000000000000005550500055005000000000000000000000000000000000005055000055050000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222220000002222222222222200022222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222200000022222222220777700222222222000007022222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222207777002222222220755070222222222077770022222222200000002222222222222222222222222222222222222222222222222222222222222222222
2222220755070222222200007500022222222207550022222222220777770222222222222c22222222222222222222222222222222222222222222222d222222
22220000750002222220077000000022222200007502222222222207550002222222222226222222222222222d222222222222222d2222222222222226222222
22200770000000222220777650707022222007700000002222220000750222222222222226222222222222222622222222222222262222222222222226222222
22207776507070222220776650707022222077765070702222200770000000222226677777777722222222222622222222222222262222222226677777777722
22207766507070222220000000000022222077665070702222207776507070222266677777777772222667777777772222266777777777222266677777777772
22200000000000222200005550000222222000000000002222207766507070222266677777777772226667777777777222666777777777722266677777777772
22200055500022222205550005550222220000555000222222200000000000222266677777777772226667777777777222666777777777722266677777777772
22005500055022222200000200000222220555000550222222220555550222222266667777777772226667777777777222666777777777722266667777777772
22055002000022222222222222222222220000020550222222220055500222222266667777777772226666777777777222666677777777722266667777777772
22222222222222222222222222222222222222222222222222222222222222222266667cd000057222666677777777722266667777777772226666700cd00572
22222222222222222222222222222222222222222222222222222222222222222266667555555572226666700dc0057222666670000dc5722266667555555572
22222222222222222222222222222222222222222222222222222222222222222266667777777772226666755555557222666675555555722266667777777772
22222222222222222222222222222222222222222222222222222222222222222266667777777772226666777777777222666677777777722266667777777772
22222222222222222222222222222222222222222222222222222222222222222225555555555522226666777777777222666677777777722225555555555522
22222200000022222222222222000222222222222222222222222222222222222222050005000522222555555555552222255555555555222222005000500222
22222207777002222222220000070222222222222222222222222200000002222222000000000222222250005000522255250005000502222222000000000222
22200007550702222222220777700222222222000000022222222207777702222225000500050222222200500050022256770500050005222222500050005772
22007700550002222220000755002222222222077777022222200007550002222225555555555522266555555555552256755555555555222225555555555565
22077760000000022200770055022222222000075500022222007700550222222277267726772672277267726772672222267726772672222267726772672265
22077666650707022207776000000002220077000000000222077760000000022677267726772677277267726772677222267726772677222267726772677255
22000066650707022207766665070702220777666507070222077666650707022677267726772677566267726772677222267726772677222267726772677222
22220000000000022200006665070702220776666507070222000066650707022277227722772277555227722772277222227722772277222227722772277222
22200655550022222220000000000002220000000000000222200000000000022277227722772277222227722772277222227722772277222227722772277222
22005500055002222200565555500222220056555550022222005655555002222566256625662566222256625662566222256625662566222256625662566222
22055002005502222205500000550222220550000055022222055000005502222555255525552555222255525552555222255525552555222255525552555222
27777777777777777777777227777772666566666662666266626662777777772227222522272225222722222227222222222222222222222222222222222222
75055005500550555005505770005507666266662555255555525552666666662227222522272225222722222227222222222222222222222222222222222222
70056665577750505666500775777507222222222222222227222722622662262277725552777255527772222277722222222222767666662222222222222222
75506065570766555606055775707667222222222222222252525252522552252277725552777255527772222277722222222222776766662222222222222222
70776660077767700666770770777677222222222222222222222222555555552776775057767750577677222776772222222222777777772222222222222222
75770006600007766000775776600077222222222222222222222222222222222776775057767750577677222776772200000000555555552222222222222222
75506606606655066066055776605507222222222222222222222222626262627766677077666770776667727766677205555550777777772222222222222222
70006650056600000566000770550007222222222222222222222222222222227766677077666770776667727766677255000055222222222222222222222222
76600550055000000550066770550007777077707770777077707770000000000000000022222222222222222222222222222222222222222222222222222222
76600066000055000000066770000557555555555555555555555555076677700766777022222222222222222222222222222222222222222222222222222222
70550066000055005500550770066607000000000000000000000000070000700760067022222222222222222222222222222222222222222222222222222222
75666770005500005776660770060607000555050000000050555000070650600707006022222222222222222222222222222222222222222222222222222222
75606775500005050776060775566607005050000000000000050500070550700700707022222222222222222222222222222222222222222222222222222222
70666005500000055506665770000007050500000000000000005050070000700760067022222222222222222222222200000000222222222222222222222222
75500000000550000000055770005507505000000000000000000505077766700777667022222222222222222000000005555550000000022222222222222222
75506605000000005066000770550007550000000000000000000055000000000000000022222222222222222050555056777765055505022222222222222222
70006600000550000066000770550007000000000000000000000000000000002222222222222222222222220000000000000000000000000000000000000000
75500055050550505500055770005507077777777777777007777777777777702222222222222222222222220000050066666666006000006666666666666666
75666775770000665776665770000077077776777766776007777677776677602222222222222222222222220000650655555555506600000000000055555555
70606770770666660776060770666577077000000000066007700000000006602222222222222222222222220006600655666655500650000000000055666650
75666055000606005506665775606557077055050077066007707705007706602222222222222222222222220006050655000055506050000000000005060055
75505500005666000055055775666007077055000777076007707770077707602222222222222222222222220006650655000055506650000000000055006055
70005505005500005055000770005507077055007770066007705700007006602222222222222222222222220006600655555555500650000000000055555555
27777777777777777777777227777772077050077700066007705007700006602222222222222222222222220006050655555576506050000000000055555576
27777777777777777777777227777772077000777005066007700007700506602222222222222222222222220006650655555560506650000000000005555560
70550000005500000055055770550007077007770055076007700700007507602222222222222222222222220006600655555576500650000000000000555576
70666005505500055056660770550007076077700055066007607770077706602222222222222222222222220006050655555555506050000000000055555000
70606005500777055006060770077707077077005055066007707700507706602222222222222222222222220006650655666655506650000000000055666655
75666550055707000006665775570707077000000000066007700000000006602222222222222222222222220006600655000055500650000000000055005055
75055000000777505500055770077757077666666776666007766666677666602222222222222222222222220006050655555555506050000000000055555500
70056600550005500066000775000557076666666666666007666666666666602222222222222222222222220000000000000000000000000000000000000000
27777777777777777777777227777772000000000000000000000000000000002222222222222222222222220505555555555555555550505555555555555555
00000000000000006666666666666666666666667777777706665550222222222777722222222222222222222222222207000777222222222222000000000000
06666660055555505555555555555555555555555555555520665502222222227666677722222222222222222222222207006666222222222222055566667777
06000060050000505555555555555555555555555555555520000002222222222777722222222222222222222222220000055555222222222222000000000000
06000060050000505555565555555555555566555555555520776602222222222222222222222222222222222222205555500000222222222220705070705070
06777760050000505555555555555555555566555555555520000002222222222222222222222222222222222222050005056567222222222206005060705070
06777760050000505556555555555555555555555555555520776602222222222222222222222222222222222222050050555667222222222050000050600070
66757766500550055555555555555555555555555555555520000002222222222222222222222222222222222222050005056567222222220555005050505067
00557500000000005555555555555555555555555555555520776602222222222222222222222222222222222222055555555667222222220000000000000000
00555500005555005555555555555555555555550055550020000002066655502222222222222222222222222222222222222222222222205555055555500555
00555500005555005565555555555555555555550055550020776602206655022222222222222222222222222222222222222222222222207700500770055007
00555500005555005555555555555555555555550055550020000002220000222222222222222222222222222222222222222222222222077770007777000077
00555500005555005555555555555555555555550055550020776602222222222222222222222222222222222222222222222222222222066670506777055077
70555500005555005556555555555555566555550055550020000002222222222222222222222222222222222222222222222222222222066660006677000077
00557500005755075555555555555555566555550055550020776602222222222222222222222222222222222222222222222222222222066660506666055067
00757500005757005555555555555555555555550055550020000002222222222222222222222222222222222222222222222222222222200000000000000000
00777700007777005555555555555555555555550055550020776602222222222222222222222222222222222222222222222222222222205555555555555555
00000000000000000066670000022222000222226022222220000002222222222222222200000070776500707776007077776070222222000000000000000000
55555555555555555566777055022222560222226602222220776602222222222222222200000070766500707776007077776070222222056600006677000077
00000050000000000000000055602222566022220602222220000002222222222222222200000070665000707760007077760070222222000005500000055000
60676050605060605066770505660222056022220602222220776602222222222222222200000070550000706600007077600070222222056600006677000077
00000050605060605066777505560222056022220022222220000002222222222222222200000070000000700000007066000070222222000005500000055000
60676050005070705067777500560222000222220022222220776602222222222222222200000070000000700000007000000070222222056600006677000077
00000050555070705067770500002222000222220022222220000002200000022222222200000070000000700000007000000070222222000005500000055000
60676050000000000000000505560222056022220602222206665550066655502222222200000070000000700000007000000070222222056600006677000077
00000555050505005050505000060222006022220602222205666650000000000566665005566550222222222222222222222222222222000000000000000000
60676050000000005066770505602222060222220022222206000060566666655600006505000050222222222222222222222222222222005555666666677777
00000000707707705067777505602222060222220022222206055060600000066005500606055060222222222227222222222222222220050005555656666767
66677660707000705067777505602222060222220022222206005060600660066000500606005060222222227257527222272222222220500500556566667677
66677660707000705067777505602222060222220022222277750777077507700775077007750770227222722757572272575272222220500055555555666676
00000000707707705067777505602222060222220022222270705707777557770770577077705777226222622665662227575722222220005005055666666767
60676050000000005066770505602222060222220022222200577500705775070757757070577507226222622655562265555562222220500000005556556667
00000555050505000050505000060222006022220602222200000000070000700070070007000070255525555566655256666652222220555000555565666676
__label__
00222220015555550022222222222220025555550525255112221122015555550155555501555555555555550255555501555555000011000525255112221122
01111111111111111111111111111111111111111155222222200202055525220555252205555555552555220552522205552522000010000555222222200202
01000000000000000000000000000000000000000152221122221120055521120522522205555555555222520525552205225222000011000552221122221120
01022222222222222222222222220000000000000152552220202002055255220555211205555522522551220252222005552112000010000552552220202002
01022222222222222222222222220000000000000122222211220220052222200552552205555555222222220525511205525522000011000522222211220220
01022222222222222222222222220000000000000125222000201100022001010522222005522522552222220522222005222220000010000525222000201100
01000000000000000000000000000000000000000122222222020000002220100220010105555252225222110222200102200101000011000022222222020000
01111111111111111111111111111111111111111100000000000000000000000022201005555222222222220022011000222010000010000000000000000000
01555555555555550000000000000000000101200000000000000000002020222000000005252551122211220000000000000000000011000000000001555555
05555555552555220000000000000000000202000000000000000000000121020000000005552222222002020000000000000000000010000000000005552522
05555555555222520000000000000000000200000000000000000000000020120000000005522211222211200000000000000000000011000000000005225222
05555522522551220000000000000000000200000000000000000000000020120000000005525522202020020000000000000000000010000000000005552112
05555555222222220000000000000000000000000000000000000000000020020000000005222222112202200000000000000000000011000000000005525522
05522522552222220000000000000000000000000000000000000000000020020000000005252220002011000000000000000000000010000000000005222220
05555252225222110000000000000000000000000000000000000000000020000000000000222222220200000000000000000000000011000000000002200101
05555222222222220000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000010000000000000222010
05252551122211220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000002000
05552222222002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000002000
05522211222211200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000002000
05525522202020020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000002000
05222222112202200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
05252220002011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00222222220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
22222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
21222111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
22111221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
12211111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
21111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
11110011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
10011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00010120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001110000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001110111000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000111000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000
00000000000000000000000000000000000000000011101110011100000000000000000000000000000000000000000000000000000000000002000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000
00000000000000000000000000000000000000000000000000001110000000000000000000000000000000000000000000000000000002255555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022255555555550000000
00000000000000000000000000000000000000000000000001110000000000000000000000000000000000000000000000000000000022255555555550000000
00000000000000000000000000111111000000000000000000000000000000000000000000000000000000000011111100000000000022255555555550000000
00000000000000000001011101255552101110100000000000000000000000000000000000000000000101110125555210111010000022225555555550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022225555555550000000
00000000000000000000001002222222200200000000000000000000000000000000000000000000000000000000000000000000000022225000025150000000
00000000000000000000021021111111110220000000000000000000000000000000000000000000000000000000000000000000000022225111111150000000
00000000000000000000220021122221110021000000000000000000000000000000000000000000000000000000000000000000000022225555555550000000
00000000000000000000201021100001110201000000000000000000000000000000000000000000000000000000000000000000000022225555555550000000
00000000000000000000221021100001000000000000000000000000000000000000000000000000000000000000000000000000000001111111111100000000
00000000000000000000220021111111055550000000000000000000000000000000000000000000000000000000000000000000001101000100010000000000
00000000000000000000201021111000051105000000000000000000000000000000000000000000000000000000000000000000001255010001000100000000
00000000000000000000221021110055001100000000000000000000000000000000000000000000000000000000000000000000001251111111111100000000
00000000000111000000220021110555200000000000000000000000000000000000000000000000000000000000000000000000000002550255025000000000
00000000000000000000201021110552222105050000000000000000000000000000000000000000000000000000000000000000000002550255025500000000
00000000000011100000221021120000222105050000000000000000000000000000000000000000000000000000000000000000000002550255025500000000
00000000000000000000220021100000000000000000000000000000000000000000000000000000000000000000000000000000000000550055005500000000
00000000011100000000201021111002111100000000000000000000000000000000000000000000000000000000000000000000000000550055005500000000
00000000000000000000000000000011000110000000000000000000000000000000000000000000000000000000000000000000000001220122012200000000
00000000000000000010111111110110010011010000000000000000000000000000000000000000000000000000000000000000000001110111011100000000
01555555555555550155555555555555015555555555555505550555055505550555055505550555015555550155555555555555025555550155555501555555
05555555552555220555555552555222055555555525552201111111111111111111111111111111155525220555555552555222055252220555252205555555
05555555555222520555555555222552055555555552225200000000000000000000000000000000052252220555555555222552052555220555211205555555
05555522522551220555555225522112055555225225512200000000000000000000000000000000055521120555555225522112025222200552552205555522
05555555222222220522522552112200055555552222222200000000000000000000000000000000055255220522522552112200052551120522222005555555
05522522552222220555251122220011055225225522222200000000000000000000000000000000052222200555251122220011052222200220010105522522
05555252225222110052222220011110055552522252221100000000000000000000000000000000022001010052222220011110022220010022201005555252
05555222222222220000000000000000055552222222222200000000000000000000000000000000002220100000000000000000002201100000000005555222
05252551122211220022222222222220052525511222112200000000000000000000000000000000002122200011111000000000001111100000000005252551
05552222222002020222222221222111055522222220020200000000000000000000000000522555021221110111100100000000011110010000000005552222
05522211222211200222222222111221055222112222112000000000000000000000000000500005022111110111111100000000011111110000000005522211
05525522202020020222222112211111055255222020200200000000000000000000000000502102021010100100100100000000010010010000000005525522
05222222112202200211211221111100052222221122022000000000000000000000000000501105012111000111010100000000011101010000000005222222
05252220002011000222121111110011052522200020110000000000000000000000000000500005021100110111000000000000011100000000000005252220
00222222220200000021111110011110002222222202000000000000000000000000000000555225011011000010110100000000001011010000000000222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000001100100110000000000000011000000000000000000000
00222222222222200011111111111110002222222222222000000000000000000000000000111111111111100101000100000000010100010000000000111111
02222222221222110111111110111001022222222212221100000000000000000000000001111111110111010000000100000000000000010000000001111111
02222222222111210111111111000111022222222221112100000000000000000000000001111111111000110110000000000000011000000000000001111111
02222211211221110111111001100001022222112112211100000000000000000000000001111100100110010100000000000000010000000000000001111100
02222222111111110100100110000001022222221111111100050005000500050005000501111111000000000100000000000000010000000000000001111111
02211211221111110111010000000000022112112211111100020002000200020002000201100100110000010000000000000000000000000000000001100100
02222121112111110010111101000010022221211121111100020002000200020002000201111010001000010001000000000000000100000000000001111010
02222111111111110000000000000000022221111111111100111011101110111011101111111000000000010000000000000000000000000000000001111000
02121221111111110000000000111110021212211111111100111110001111100011111001010110000000000000000000000000000000000000000001010110
02221111111001010000000001111001022211111110010101100101010011110110010101110000000000010000000000000000000000000000000001110000
02211111111111100000000001111111022111111111111001011001011110100101100101100000000000000000000000000000000000000000000001100000
02212211101010000000000001001001022122111010100001101110010100000110110001101100000000000000000000000000000000000000000001101100
02111111111101100000000001110101021111111111011001011000011100000100000101000000000000000000000000000000000000000000000001000000
02121110001011000000000001110000021211100010110001000000010000000110000001010000000000000000000000000000000000000000000001010000
00111111110100000000000000101101001111111101000001100000001011000011000000111011011000000000000000000000000000000000000000111011
00000000000000000000000001100000000000000000000000110100000000000000000000000000000000000000000000000000000000000000000000000000
00111110000000000000000001010001000000000000000000000000000000000000000000122221000000000000000000000000000000000000000000000000
01001111000000000000000000000001000000000000000000000000000000000000000000200002000000000000000000000000000000000000000000000000
01111011000000000000000001100000000000000000000000000000000000000000000000201102000000000000000000000000000000000000000000000000
01010010000000000000000001000000000000000000000000000000000000000000000000200102000000000000000000000000000000000000000000000000
01100000000000000000000001000000000000000000000000000000000000000000000005551055500000000000000000000000000000000000000000000000
01110000000000000000000000000000000000000000000000000000000000000000000005050150500000000000000000000000000000000000000000000000
01000000000000000000000000010000000000000000000000000000000000000000000000015510000000000000000000000000000000000000000000000000
00101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000001010101010101010100000000000000010101010101010101000000000000000303010101010000000000000000000001010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102020202080808080000000001010101020202000000000000000000010101010101010100000000000000000101010101010101000000000000000000000004000001000000000000000000000000040000010000000000000000000000000000000100000000000000000000000000000000000000080000000000
__map__
0000000000000000000000000000000000000000000000000b0c3a3b00000000050000003a3b3e0708000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003435260000000026090a0000000000000000060507083435090a
0000000000000000000000000000000000000000003a3b001b1c090a0000090a153e053d0526281718090a3a3b0000000000000b0c0036000000000000000000000b0c0000000000000b0c00000000000000000000000000000000000000000000000000000b0c002626090a0708191a052626000000090a161517183636191a
000000000000000000000000000000000000003435003d07083d191a003d191a070815261500002626191a3c393a3b343500001b1c090a3a3b00000000000000361b1c0000050034351b1c000000000000363a3b00000000000000000000000000000000051b1c282425191a17183d3e1536090a0708191ace000000053c090a
00000000000000000000000000000000090a382834352917182826070827260d17182425000000002626070824252605003d000708191a05003c00000000090a3d2626070815090a003705090a3c00053c090a003a3b000000000000000000000000003d15002425009c008c009cf69cf63c191a17183d00000000001505191a
0000000000000000000000000000003f191a070800002a00002b00171800000d0026280000000000000017180000001526262617182626152605003c0500191a260500171826191a070815191a34351526191a0708293e000000000000000000390000090a36280000000000000000000000003d00f60000000000000015090a
000000000000000000000000000007083435171800000000000000000000000d002f000000000000000000000000000010000000000000100015242515070826f6150000000000001718f600000000000000001718360000003900003900000034353d191a28000000000000000000000000000000000000000000000000191a
0000000000000000000000000b0c17180034350000000000000000000000000d00000000000000000000000000000000100000970000001000000026001718000000000000000000000000000000000000000000260500390b0c363c003600393c00373d362800000000000000000000009b9c9d00000000000000000000090a
0000000000000000000000001b1c273435002a0000000000000000000000000d0000000000000000000000000000000010009797970000100000000000000000000000000000000000000000000000000000000026153c3e1b1c00090a3c26270037090a28f60000000000000000000000abacad00000000000000000000191a
00000000000000000000003f090a28f60000000000000000000000000000001d000000000000000000000000000000878787878787878787870000000000000000000000000000000000000000000000000000090a26003a3b2425191a3934350708191a05000000000000070829000000bbbcbd000000003a3b3a3b0000090a
000000000000000000000000191a0000000000000000000000000000000000000000f60000000000000000f6000000000000000000000000000000000000000000000000000000000000000000000000000000191a2425363435262600002a00171800001500000000000017180708fafa070829000000000b0c0b0c0000191a
00000000000000000000003435070800000000000000001113000000000000000000000000000000000000000000000000000000000000000000000000000000000000009b9c9d0000000000009b8c9d000000e000000000000000009b9c9d000000000000009b8c9d00090a3e1718090a171824250708001b1c1b1c0000090a
0000000000000000000000090a171800000000009b9c9d22230000009b8c9d0000000000009b9c9d00000000000000000000000000a4a500000000000000000000000000000000000000a4a50000000000000006000000000000000000000000000000000000abaead00191a05373c191a24250538171887878787878787191a
0000000000000000000000191a3a3b2700000000abacad000000000000000000000000000000000000000000000000000000000000b4b5000000000000000000000000008d0000000000b4b500000000000000160000000000000000000000000037053c0708bbbebd970b0c153a3b3d263d3d153c263a3b3c38063a3b3f090a
0000000000000000000000000b0c343500000023bbbcbd00000000000000000078000000000000000000000000000000a6a70000a4a5a4a500000000000000009596808181818181818182868686868686868624252425272425868686868686090a1536171826090a261b1c3a3b06370b0c263d3c3c3e05383816070838191a
0000000000000000000000001b1c3d263435070824250708959595952624252728070839059495950000000000000000b6b70000b4b5b4b500000000000000000000909191919191919192000000000000000000363834353435009c009c0000191af63a3b3805191a3c3a3b0005163d1b1c808182373d150b38001718388082
0000000000000000000000000000343528281718343517180000009737060006001718391500000000000000fafafa0437242528293435050708370000780000000090910091a1a1910092970000000000000000003c833a3bf6000000000034350000003e00153c3c00260b0c1526808181919191823a3b1b1c3d0638809192
00000000000000000000000034353c242528090a3a3b090afafafa0b0c160016000b0c39009727283724253737373714002b0b0c3a3b0015171837059595959595809100919200f6909191818182c3c3c3c3c380822e908182000000000000833a3b0000003a3bf60f3c3d1b1c3a3b9091910000009182373c38381638909192
0000000000003c0000000000003435383435191a0006191a3d3e3f1b1c000000001b1c090a3737373c3d2b2d2e00000000001b1c0e00003a3b3a3b15f6f6000000a0910000918200909100919192d3d4d3d3d490922c9091920000000000009081820000003d00000ff6003e000000a0a1910000009192f63a3b3c3d3fa09192
0000003a3b07080b0c00283d090a382800003c0000160000000000f600000000000000191a0000000000000000000000000000001e9c0000003f3728000000000000909100009181910000000091818181818191922c9091920000808181819191920000000000000f0000000002032d2ea091919191a200ce0000000e2f9092
00003a3b0517181b1c090a37191a343500000f0000003e0000000000000000000000002a00009b8c9d0000000000000000000000000000f60000090a000000000097909191919191919191919100919191919191922fa0a1a28787a0a1a1a1a1a1920000000000001f000000111213f60000a0a1a1a20000000000000e00a0a2
000034351537242528191a273435270000000f00000000000000000000000000000000000000abafad0203000000000000000000000000000000191a000087878787a0a1a1a1a1a1a1a1a1a191a1a1a1a1910091923d9b9c9d00000000009b8c9d9300000000000000000000212223000000000000000000000000000e00090a
3435003727370000ce0000000000300000001f00000000000000000000000000000000007811bbbfbd1213000000000000000000000000000000c60000003031320000002a002b00002d2e00a3002a00009000009206002a000000000000abafad9300000000000000000000000000000000000000000000000000001e00193f
003435003a3b00000000000000f63000000000000000000000000000000000000000000538393734353435390000c00000373800000000000000d600000030313200000000002c0000000000000000a6a790910092161112239596808182bbbfbd9300009b9c9d0000009b9c9d0000009b9c9d00000000000000000000002425
0b0c38370034350000000000000030000000000000000000b0b200000000000000003f152b002f000000c13a3b00d500002a0000000000000000e60000783031320000000000000000000000000000b6b7909100923d00002300009091a1b1b1b1a2000000000000000000000000000000000000000000000000000000003705
1b1c00090a000d00000000000000300000000000000000000000000000b0b2000000343500000000000000000000d00000000000003435000037378686868686868682000000b082f6b0b1818181818181919191a23d97009700219092f62d2e2f2b000000000000000000000000000000000000000000003435343500000415
003435191a000d00000000000000300000000000090a00000000000000000000000028c3c3c3c3c3c3c3c3c3c3c3c5c3c3c3c3c30708090a37373ff600000000000092000000f6930000009091910000919191a228063f97973e3ca0a200002c002c00000000000000000000008081818200000000000000090a090a00001438
0000242500001d00000000000000300000000000191a0000000000000000000000003d090ad3d3d3d3d3d3d3d3d4d3d4d3d3d3d31718191af63f3000000000000000920000000093000097909100009100919226051634353f0524253435002f000000008300000000008300009091919200000000000000191a191a00002737
3c34353804000000242524250000300000000028242588898889888988898889888905191ad3d3d3d3d3d3d3d3d3d3d3d3d3d3090a00003f000030003737000000009294950000a300b0b1a1a1a1a1a1a1a1a2361528373839159b9c9d00000000b30000a30000b30000a30000a0a1a1a2000000959680818181818181823435
00003a3b14000000070807080000300000000000343539373435363c3f3c36383435153937d3d3d3d3d3d3d3d3d3d3d3d3d4d3191a06000000003000000037380000920000000000009c00008c00009c000000e0000000000023000203000000000000000000000000000000000000000000000000009000000000000092053e
000b0c3435040000171817180000307800000000000000000000000000a4a5a6a700372838d3d3d4d3d3d3d3d3d3d3d3d3d4d3d30516970000003000000000000000a2000000000000000000000000000000000600000000000011121300b0b200000000000000000000000000000000000000000000a0a1a1a1a1a1a1a2153e
001b1c0038148787878787878787242527343500000000000000000000b4b5b6b700060504050b0c3706383c3d06383c0b0c05051537283435090a370b0c3a3b0b0c06050708000000008d00000000000000001600000000000021220139090a0000000000000000000000000000000000000000000000000000000000000605
0000003a3b38383435282834353827343538282834353839393a3b3934353d3a3b37161514151b1c3c16393a3b163c381b1c15153737393a3b191a3c1b1c37381b1c1615171827383834352425262738393a3bb0b1b1b1b1b1b1b1b1b1b2191a8889888988898889888988888988898889888988898889888988898889881615
__sfx__
000100002e050250501f05019050110500c0500705003050010500105001050000500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003b6503365025650186500b650046500065000650006500060001600016000160000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000116502e650006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000091500a1500a1500a1500a150091500715005150011500015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900001705027050330500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
000d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
012000000de650de550de450de351075510745107351072500d5517e5517e4517e3517e2517e2510755107450de650de550de450de351075510745107351072500d5417e5517e4517e3517e2517e250de250de35
011d0c201072519e5519e4519e3519e251005510045100351002517e550f7350f7350f7250f72510725107251072519e3519e3519e2519e250b0250b0350b7350b0250b7250b72517e3517e350f7350f7350f725
0120000012e6512e5512e4512e351575515745157351572500d5510e5510e4510e3510e2510e25157551574512e6512e5512e4512e35157551574500d54157351572519e5519e4519e3519e2519e250de250de35
011d0c20107251ee351ee351ee351ee251503515035150251502517e35147351472514725147251572515725157251ee351ee351ee251ee2515025150351573515025157251572519e3519e350f7350f7350f725
0120000019e5519e450de3501e551405014040147321472223e3523e450be350be551505015040157321572219e5519e450de3501e551705019040197321972223e3523e450be350be551c0501e0401e7321e722
012000001ee551ee4512e3506e552105021040217322172228e4528e3528e2520050200521e0401e7321e7221ee551ee4512e3506e552105021040257322572228e5528e4528e3528e251c0401e0301e7221e722
000f00001f1601f1602b1602b1601f1601f1602b1602b1601f1601f1602b1602b1601f1601f1602b1602b16026160261603216032160261602616032160321602616026160321603216026160261603216032160
180f0000173621736023362233601736217360233622336017362173602336223360173621736023362233601f3621f3602b3622b3601f3621f3602b3622b3601f3621f3602b3622b3601f3621f3602b3622b360
180f00003875438750040640406038754387500406404060387543875004064040603875438750040640406034754347500006400060347543475000064000603475434750000640006034754347500006400060
000f000023160231602f1602f16023160231602f1602f16023160231602f1602f16023160231602f1602f16026160261603216032160261602616032160321602416024160301603016026160261603216032160
180f000021362213602d3622d36021362213602d3622d36021362213602d3622d36021362213602d3622d3601e3621e3602a3622a3601e3621e3602a3622a3601c3621c36028362283601e3621e3602a3622a360
180f00003b7543b75007064070603b7543b75007064070603b7543b75007064070603b7543b750070640706036754367500206402060367543675002064020603675436750020640206036754367500206402060
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000d0200f13010040111501105011150110501115011050111501105011150110500e1400c0200a11006000060000600006000060000600006000060000600006000060000600006000060000600007000
000300000c7700f071130611316500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002156526575005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00030000180751f575260752a57512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
0002000019045000001e0450000023045000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000260752b065300553000500703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000400002477526775297752e7753077532775357753a7752400526005290052e0053000532005350053a00500000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000197770c700197770c7001c7670c7001c7570c7001e7570c700217470c700217370c700237370c700237270c700257170c700287170c7000c7000c700135000c600135000c600135050c605135050c605
000200003f643232333a64121231346411e2312f641172312a63112221246310d2211e63109221186310522111621032110c62101211086250121504625002150261500615006000060500600006000060000600
000300000c363236650935520641063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
000100000c1700e0711107114071170711707014071120710f0710c17100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100200a4033b2110a1133b4210b033302310b343302510a1433b2410a4433b2410a0433b2510a1433b241091433a241091433a6410a4433b2510a1433b2410a7433b2510a3433b2410a1433b2410a6433b441
000100001b0601a0601b0601b0601b0601b0601b06019060180601700015000110000e00009000060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c0700e0700f070110701107011070100700c070080700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000180701d07021070240702707013000190001f000240002700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f050130501405014050140501305013050120500d0500805002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002365021050010500105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08424344
00 0b424344
00 0c424344
00 08424344
00 080a4344
00 0b0a4344
00 0c094344
02 080d4344
01 0e0f4344
00 0e0f4344
00 10114344
00 0e124344
00 0e124344
02 10134344
01 14151640
02 17181940

