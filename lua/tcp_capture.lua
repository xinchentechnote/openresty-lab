local socket = ngx.socket.tcp
local spawn = ngx.thread.spawn
local wait = ngx.thread.wait
local log = ngx.log
local ERR = ngx.ERR
local INFO = ngx.INFO
local encode_base64 = ngx.encode_base64

-- 获取毫秒时间戳
local function timestamp_ms()
    return string.format("%.3f", ngx.now() * 1000)
end

-- 日志队列
local log_queue = {}

-- 启动日志写协程
local function start_logger(fd)
    return spawn(function()
        while true do
            if #log_queue > 0 then
                local line = table.remove(log_queue, 1)
                local ok, err = fd:write(line)
                if not ok then
                    log(ERR, "write log error: ", err)
                end
                fd:flush()
            else
                if ngx.ctx.stop_logger then
                    break
                end
                ngx.sleep(0.001)
            end
        end
    end)
end

-- 写入队列
local function record(direction, src_ip, src_port, dst_ip, dst_port, data)
    local line = string.format(
        "%s %s %s:%d -> %s:%d len=%d data=%s\n",
        timestamp_ms(),
        direction,
        src_ip, src_port,
        dst_ip, dst_port,
        #data,
        encode_base64(data)
    )
    table.insert(log_queue, line)
end

-- TCP 双向转发
local function pipe_forward(reader, writer, direction,
                            src_ip, src_port, dst_ip, dst_port)
    while true do
        local data, err, partial = reader:receiveany(8192)
        if not data then
            if partial and #partial > 0 then
                data = partial
            else
                if err ~= "closed" and err ~= "timeout" then
                    log(ERR, "receive error: ", err)
                end
                if writer then writer:close() end
                return
            end
        end

        -- 写队列
        record(direction, src_ip, src_port, dst_ip, dst_port, data)

        -- 转发
        if writer then
            local ok, werr = writer:send(data)
            if not ok then
                log(ERR, "send error: ", werr)
                if reader then reader:close() end
                return
            end
        end
    end
end

-- 处理 TCP session
local function handle_session(up_host, up_port)
    local client = ngx.req.socket(true)
    if not client then
        return ngx.exit(500)
    end
    client:settimeout(60000)  -- 60s

    local upstream = socket()
    upstream:settimeouts(60000, 60000, 60000)
    local ok, err = upstream:connect(up_host, up_port)
    if not ok then
        log(ERR, "connect upstream error: ", err)
        return ngx.exit(502)
    end

    local session_id = string.format("%d_%d", ngx.worker.pid(), ngx.now()*1000)
    local filename = "/tmp/tcp_session_" .. session_id .. ".log"
    local fd = assert(io.open(filename, "a+"))
    log(INFO, "session log file: ", filename)

    -- 启动日志协程
    ngx.ctx.stop_logger = false
    local log_thread = start_logger(fd)

    local client_ip = ngx.var.remote_addr or "0.0.0.0"
    local client_port = tonumber(ngx.var.remote_port or 0)
    local upstream_ip = up_host
    local upstream_port = up_port

    -- 双向转发
    local t1 = spawn(pipe_forward, client, upstream, "C2S",
                     client_ip, client_port, upstream_ip, upstream_port)

    local t2 = spawn(pipe_forward, upstream, client, "S2C",
                     upstream_ip, upstream_port, client_ip, client_port)

    wait(t1, t2)

    -- 等待队列清空
    while #log_queue > 0 do
        ngx.sleep(0.001)
    end

    -- 停止日志协程并关闭文件
    ngx.ctx.stop_logger = true
    wait(log_thread)

    if upstream then upstream:close() end
    if client then client:close() end
    fd:close()
end

return {
    handle_session = handle_session
}
