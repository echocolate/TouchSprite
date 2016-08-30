require "TSLib"
require("sz")

function recognizeMin()
	local min = ocrText(30,160, 68,200, 0)  --当前页的第一行执行顺序 

	startString = string.sub(min,1, 1)
	if  startString == "O" then
		min = string.sub(min,2)
		toast("当前页：" .. min)
	end
	return min
end

function changeNZT(environmentParam)
	isRunning = runApp("NZT")

	mSleep(500)

	bid = frontAppBid();

	if bid ~= "NZT" then
		toast("open NZT")
		pressHomeKey(0)
		pressHomeKey(1)

		mSleep(30)

		init(bid,0)
		mSleep(100)

		tap(93, 1025)
		--touchUp(93, 1025)
		mSleep(200)
	end

	init(bid,0)
	mSleep(500)

	environmentArray = string.split(environmentParam, "_")

	curSeq = tonumber(environmentArray[1])      --服务端指令中要找的执行顺序
	endAccount = environmentArray[2]
	--toast("server seq:" .. curSeq .. ", endAccount:" .. endAccount)

	mSleep(1000)
	
	first_line_text = recognizeMin()
	
	if first_line_text == nil or first_line_text == "" then
		toast("要下拉")
		
		tap(39, 82)     --点击返回，返回到znt首页
		mSleep(50)

		bid = frontAppBid();
		init(bid,0)
		mSleep(500)

		tap(120, 960)    --点击 参数记录，回到环境列表页

		mSleep(1000)
		
		touchDown(00,421, 181)   --要往下拉直到能识别
		mSleep(200)
		touchMove(00,421, 243)
		mSleep(200)
		touchUp(00,421, 243)
		mSleep(1000)
	end
	
	min = tonumber(recognizeMin())
	toast("当前页第一行：" .. min)

	if curSeq < min then   --当前页的第一行比要查找的seq小，则从最上面往下翻

		downPages = math.modf((min - curSeq)/ 9)  --往下翻整页的次数

		downLine = 1
		--toast("往下翻页:" .. downPages )

		circleTimes = downPages + 1   --不往下翻整页，代表着下翻几行
		firstX, firstY = 160, 160
		lastX = 160

		for j=1, circleTimes, 1 do
			if j == circleTimes then
				downLine = min - 9*downPages - curSeq
				lastY = downLine * 100 + firstY + 20
			else
				lastY =  1060 + 20   --向上滑动一屏
			end

			moveTo(firstX, firstY,lastX,lastY,5)
			mSleep(2000)
		end	

	else 

		upPages = math.modf( (curSeq - min) / 9)  --需要翻页的次数
		upLine =1         --要找的执行顺序，离第一行的间距行数
		--toast("翻页：" .. upPages)

		if upPages > 0 then            --upPages==0说明在当前页
			startX = 160
			endX, endY= 160,160
			for i=1, upPages, 1 do      --第一个参数代表从1开始，第二个参数要循环的次数，第三个参数是步长
				if i == upPages then
					upLine = (curSeq - upPages*9)-min 
					startY =  upLine * 100 + endY +20
				else
					startY = 1060 + 20   --滑动一屏

				end

				moveTo(startX,startY,endX,endY,5)
				mSleep(1000)
			end

		end

	end


	min = recognizeMin()  --整屏滑动，最后一屏可能不足10个，这是第二屏其实只移动几个
	moveLine = curSeq - min

	--toast("行数:" .. moveLine)

	regStartX=32
	regStartY=moveLine * 100 + 160 
	regEndX=120
	regEndY=regStartY + 40

	recognize = ocrText(regStartX, regStartY,regEndX, regEndY,0);  

	toast("识别到的行数：" .. recognize)
	mSleep(1000); 

	array = strSplit(recognize, "-")
	seq = array[1]
	endNum = array[2]

	if endAccount == endNum then
		tap(regEndX, regEndY)
	else
		dialog("hi")
	end

end

changeNZT("23_80")
