init(0);
touchDown(1, 320, 1130);
mSleep(30);
step=10
y=1130
while true do
    y=y-step
    if y<=530 then 
        touchMove(1, 320, y);
        break 
    end
    touchMove(1, 320, y);
    mSleep(30);
end
touchUp(1, 320, y);
mSleep(1000);
