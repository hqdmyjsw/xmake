--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2018, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        find_tool.lua
--

-- imports
import("lib.detect.find_program")
import("lib.detect.find_programver")
import("lib.detect.find_toolname")

-- find tool from modules
function _find_from_modules(name, opt)

    -- attempt to import "detect.tools.find_xxx" 
    local find_tool = import("detect.tools.find_" .. name, {try = true})
    if find_tool then
        local program, version, toolname = find_tool(opt)
        if program then
            return {name = toolname or name, program = program, version = version}
        end
    end
end

-- find tool
--
-- @param name      the tool name
-- @param opt       the options, .e.g {program = "xcrun -sdk macosx clang", pathes = {"/usr/bin"}, 
--                                     check = function (tool) os.run("%s -h", tool) end, version = true
--                                     force = true, cachekey = "xxx"}
--
-- @return          {name = "", program = "", version = ""} or nil
--
-- @code
--
-- local tool = find_tool("clang")
-- local tool = find_tool("clang", {program = "xcrun -sdk macosx clang"})
-- local tool = find_tool("clang", {pathes = {"/usr/bin", "/usr/local/bin"}})
-- local tool = find_tool("clang", {check = "--help"}) -- simple check command: ccache --help
-- local tool = find_tool("clang", {check = function (tool) os.run("%s -h", tool) end})
-- local tool = find_tool("clang", {pathes = {"$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug;Debugger)"}})
-- local tool = find_tool("clang", {pathes = {"$(env PATH)", function () return "/usr/bin"end}})
-- local tool = find_tool("ccache", {version = true})
--
-- @endcode
--
function main(name, opt)

    -- init options
    opt = opt or {}

    -- find tool name
    local toolname = find_toolname(name or opt.program)
    if not toolname then
        return 
    end

    -- init program
    opt.program = opt.program or name

    -- attempt to find tool from modules first
    local tool = _find_from_modules(toolname, opt)
    if tool then
        return tool
    end
 
    -- find tool
    local program = find_program(opt.program, opt.pathes, opt.check, opt)
    if not program then
        return 
    end

    -- find tool version
    local version = nil
    if program and opt.version then
        version = find_programver(program, opt)
    end

    -- ok?
    return {name = toolname, program = program, version = version}
end
