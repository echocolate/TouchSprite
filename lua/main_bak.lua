require "TSLib"
local sz = require("sz")
local http = require("szocket.http")

WX_APP = "com.tencent.xin"       --微信目前是用 英文
QQ_APP = "com.tencent.mQQi"      --QQ目前是用中文
NZT_APP = "NZT"

local function httpPost(url, kv)
    local response_body = {}
    local post_data = kv;  
    return http.request{  
        url = url,  
        method = "POST",  
        headers =   
        {  
            ["Content-Type"] = "application/x-www-form-urlencoded",  
            ["Content-Length"] = #post_data,  
        },  
        source = ltn12.source.string('data=' .. post_data),  
        sink = ltn12.sink.table(response_body)  
    }  
end

function findWXFail()   --是否查找失败，判断标准是 有蒙层和弹出框
	if isColor(512,352,0x999999,98) and isColor(550,505,0xe6e6e6,98) then
		return true
	else
		return false
	end
end

function existWX()     --是否搜不到，判断标准是 中间有无结果，背景都是白色
	if isColor(494,1060,0x007aff,98) and isColor(618,1061,0x007aff,98) and isColor(496,1119,0x007aff,98) and isColor(619,1116,0x007aff,98) then
		return false
	else
		return true
	end
end

function isSuccessTapWXAdd()
	local x, y = findColorInRegionFuzzy(0x1aad19, 100, 24,690, 600,1003)  --找到绿色背景的按钮
	--toast(x .. ",".. y)    

	local content = ocrText(x, y, x+480, y+70, 0) 
	--toast(x .."," .. y .. "," .. content)
	if content == "Add" then     --找到“Add”字样的，标识可以加WX好友
		tap(x,y)
		mSleep(30*1000)
		return true
	else
		mSleep(10*1000)
		return false
	end
	
end

function add_wx(friendAccount, authContent)
	local r = runApp(WX_APP);    --启动应用 
	local bid = frontAppBid();
	if bid ~= WX_APP then 
		dialog("请打开 微信 再运行该脚本！", 5);
		mSleep(3000); 
		lua_exit();
	end

	init(bid,0)
	mSleep(5000)

	toast("已打开微信")

	tap(241,1090)   --点击通讯录
	toast("已点击通讯录")
	mSleep(500)

	tap(587,88)     --点击 添加
	toast("已点击添加")
	mSleep(5000)

	touchDown(428,205)    --点击中间的账号填写框
	mSleep(500)
	touchUp(428,205)
	mSleep(200)
	inputText(friendAccount)    --输入要查找的账号
	mSleep(3*1000)

	tap(606,1092)    --点击 搜索
	toast("已点击搜索")
	mSleep(45*1000)

	if findWXFail() then
		toast("查找失败")
		mSleep(500)
		
		local confirm_content = ocrText(282,633, 384, 681, 0)  --关闭查找失败的对话框
		if confirm_content == "OK" then
			tap(328,660)
			mSleep(20)
		end	
	
	else
	   haveWXAccount = existWX()
		if haveWXAccount then
			if isSuccessTapWXAdd() then
				tap(584, 253)   --点击身份验证输入框，输入验证信息
				inputText(authContent)
				mSleep(5*1000)

				tap(567,84)  --点击“发送”
				toast("添加成功")
                mSleep(5*1000)
			else
				toast("已是好友或暂无法添加")
			end
		else
			toast("未找到该账号")	
		end
	end
	
	mSleep(3000); 
	closeApp(WX_APP)
end

function existQQAccount()   --是否找到该qq账号，判断的标志是 右上角有个白色的入口
	return isColor(577,70,0xffffff,98) and isColor(600,70,0xffffff,98) 
end

function isQQFriend()         --判断该账号是否已经是好友，标志是中间线的颜色
	return isColor(319,1091,0xc6c6c6,95) and 
		   isColor(319,1044,0xc6c6c6,95) and 
		   isColor(319,1129,0xc6c6c6,95) 
end

function isIdentity()       --判断加好友的验证方式。1：允许任何人添加；2：需要身份验证；3：需要回答问题
	mSleep(2*1000)
	
	local addType = 3
	local verify_text = ocrText(25, 149, 376, 188, 0)
	if  verify_text == "Enter your friend request" then   --身份验证
		addType = 2
	else  
		send_text = ocrText(530, 66, 611, 99, 0)   --直接点击Send，允许任何人添加
		if send_text == "Send" then
			addType =1
		end	
	end
	return addType
end

function add_QQ(account, authContent, softAccount)
	r = runApp(QQ_APP);    --启动应用 
	
	mSleep(1000)

	bid = frontAppBid();
	if bid ~= QQ_APP then 
		dialog("请打开 QQ 再运行该脚本！", 5);
		mSleep(3000); 
		lua_exit();
	end

	init(bid,0)
	mSleep(5000)

	toast("已打开QQ")
	mSleep(5*1000)

--默认打开的是qq首页--
	tap(240,1070)  --点击“联系人”
	toast("已点击联系人")
	mSleep(400)

	tap(595,80)   --点击“添加”
	toast("已点击添加")
	mSleep(1100)

	local current = getNetTime();                         --获取网络时间 
	local current_text = os.date("%Y%m%d", current); --格式化时间 

	initLog(current_text, 0);   --打开每天的log日志

	add_text = ocrText(110, 375, 186, 420, 0)
	if add_text == "Add" then
		tap(140, 400)  --点击“添加好友”
		toast("已点击添加好友")
		mSleep(100)

		tap(50, 250)  --点击“qq账号或邮箱地址的输入框”
		mSleep(500)

		inputText(account)   --输入要加好友的账号
		mSleep(1200)

		accountEndChar = string.sub(account,-1)  --一次输入账号，不能点击search；采取的方式是删掉最后一个，再加上
		keyDown("DeleteOrBackspace")
		keyUp("DeleteOrBackspace")   
		mSleep(400)
		keyDown(accountEndChar)
		keyUp(accountEndChar)

		mSleep(50)

		tap(555,1091)  --点击 “Search”
		mSleep(12*1000)

		if existQQAccount() then 
			if isQQFriend() then
				wLog(current_text,"[DATE] " .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：对方已经是QQ好友" );
				toast("已经是QQ好友")
			else
				tap(298,1092)  --点击“加好友”
				mSleep(12*1000)

				local addType = isIdentity()
				if  addType== 1 then    --允许任何人添加
					tap(572,81)    --点击“发送”
					mSleep(300)
					wLog(current_text,"[DATE] " .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：对方允许任何人添加，已成功发送" );
					toast("已完成发送")

				elseif addType == 2 then    --身份验证
					touchDown(30,250) --按下文本框的起始位置
					mSleep(600)
					touchMove(51,240)  --移动到文本框的第一个字符后面
					mSleep(600)
					touchUp(51,240)   

					mSleep(800)

					tap(51+120, 240-80)   --点击“全选”
					mSleep(1000)

					keyDown("DeleteOrBackspace")  --把文本框现有的内容全部删掉
					mSleep(10)
					keyUp("DeleteOrBackspace")
					mSleep(100)

					inputText(authContent)  --输入验证信息
					mSleep(3*1000)

					tap(572,81)    --点击“下一步”
					mSleep(1200)
					
					tap(572,81)    --点击“发送”
					mSleep(3200)
					
					send_text = ocrText(530, 66, 611, 99, 0)
					
					if send_text == "Send" then
						toast("发送失败，频繁操作")
						wLog(current_text,"[DATE] "  .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：发送失败，频繁操作" );
						
					else
						toast("成功发送")
						wLog(current_text,"[DATE] "  .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：身份验证已成功发送" );
						
					end


				elseif addType == 3 then 
					wLog(current_text,"[DATE] " .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：对方需要回答问题，未发送请求" );
					toast("对方需要回答问题")
				end

			end
		else
			wLog(current_text,"[DATE] " .. " " .. softAccount .. " 加 " .. account .. " " .. authContent .. "----结果是：未搜到该账号" );
			toast("未搜到该账号")
		end
	else
		wLog(current_text, "[DATE] " .. " " .. softAccount .. " 加 " .. account .. "----结果是：未点击到添加好友")
	end

	mSleep(500);    
	closeLog(current_text);      --关闭日志

	mSleep(5*1000); 
	closeApp(QQ_APP)
end

function recognizeMax()
	local max = ocrText(32,160, 65,200, 0)  --当前页的第一行执行顺序 
	toast(max)

	startString = string.sub(max,1, 1)
	if  startString == "O" then
		max = string.sub(max,2)
		toast("当前页：" .. max)
	end
	return max
end

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
	
	if first_line_text == nil or tonumber(first_line_text) == nil then
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

function getInstruction()
	execArray = {}

	id = readFileString("/var/mobile/Media/TouchSprite/res/id.txt")
	toast(id)

	local url = "http://www.minihub.com.cn:9999/instruction/exec" 

	respContent=httpPost(url,"id=" .. id)  

	if respContent ~= nil and type(respContent) == "string" then  --使用find函数要求内容必须是string类型

		splitFlag = string.find(respContent, "|")

		if splitFlag ~= nil then
			execArray = string.split(respContent, "|")	
			return execArray
		end
		execArray[1] = respContent
	end
	return execArray

end

function isSuccessSign(instructionArray)   --对指令进行解密
	for i=1,#instructionArray do
		local array = string.split(instructionArray[i], ",,")
		local id = array[1]
		local softType = array[2]
		local model = array[3]
		local account = array[4]
		local content = array[5]
		local remark = array[6]
		local condition = array[7]
		local time = array[8]
		local respSign = array[9]
		local softAccount = array[10]
		local hardFlag = array[11]

		local signContent = softType .. id .. model .. account .. remark .. content .. condition .. time .. softAccount .. hardFlag

		local sign = signContent:md5()

		if(respSign~=sign) then
			return false
		end	

	end
	return true
end

function execInstruction(instructions)
	local firstInstruction = string.split(instructions[1], ",,")
	local nztFlag = firstInstruction[11]
	
	toast("硬件标识：" .. nztFlag)
		
	changeNZT(nztFlag)
	mSleep(3*1000)
	
	for i=1,#instructions do
		local array = string.split(instructions[i], ",,")

		local softType = array[2]
		local model = array[3]
		local account = array[4]
		local content = array[5]
		local softAccount = array[10]
		local hardFlag = array[11]

		if nztFlag == hardFlag then
			if softType == "1" then
				add_QQ(account, content, softAccount)
			elseif softType == "2" then
				add_wx(account, content)
			end
		end

		mSleep(3*1000)
	end
end

function parseInstruction()
	local instructions = getInstruction()

	local instructionNum = #instructions

	toast(instructionNum .. "条指令需要执行")
	mSleep(1000)
	if instructionNum > 0 then
		if isSuccessSign(instructions) == true then
			execInstruction(instructions)
		end
	else 
		toast("对不起，未返回指令")
	end

end

function  changeIP()   --连续打开、关闭飞行模式两次
	toast("开始变换IP...")
	for i=1, 2 do
		setAirplaneMode(true)   --打开飞行模式
		mSleep(6*1000)

		setAirplaneMode(false)  --关闭飞行模式
		mSleep(8*1000)
		
	end
	toast("成功变换IP...")
end

--mSleep(5*60*1000)  --每隔5分钟执行一次指令
width,height = getScreenSize(); 

if width == 640 and height==1136 then
	changeIP()
	mSleep(2*1000)
	parseInstruction(respContent)
else
	toast("屏幕尺寸不是640*1136，无法使用！")
	lua_exit()
end

