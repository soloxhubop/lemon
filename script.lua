local FunctionEnvironment = getfenv()

FunctionEnvironment._bsdata0 = {
    [1] = 2816934,
    [2] = 1771078761,
    [3] = 25305774,
    [4] = 47838000,
    [5] = "L\133b\244\191'f1\235L\243\249Gt\187\237Nh\177\163\127\138\223\163",
    [6] = '3.L10..L-C455.-23.23L52.52R.34_BB4BL-BE3B_R1R12.40-0_RB2200L-..C3.2R42EL1-030EB3DA.BDB311R5-20.A.5LDRBEE2-D12ALC235.0350A54_5_E3B4B51D3L',
    [7] = 4099435,
    [8] = 'ca9355a01cbde122eccc517d11ab8656628c385a0e5dee64674d2ce31ee46f49d1116c54fbc8cd3eab22d386405d51e57c81275b075c011b6618b9e55cb65d1536fd6d054cffa54a3498b7e1b6723d514bd231daf71b39bed210cdb4baaac422c666ae76fb2dae62bf99642c1e9dcafd0d1e4c802d82f1927081dbe8dfb1b836abdf9820a46926a44f4def814d57babd3f48df10941247a55fd9d5e2f7f5af7f39c6e2cfa63d432fc834ff117ad77ed6233573a4af9829e5f186caa71b7977319f51f09cfdad171c',
    [9] = ')\161\169\6\17\144\250-\199P\228\209M\142\130\193M\18.L`\223\6\204\2\236}vP',
    [10] = 25898246,
    [11] = 1427222317,
    [12] = 524721847,
}

makefolder('static_content_130525')

local CustomAttribute = FunctionEnvironment._ca920af6193
local HttpGetResponse = game:HttpGet('https://cdn.luarmor.net/v4_init_carrot.lua' .. (CustomAttribute or ''))

writefile('static_content_130525/init-f51a77ab612-carrot.lua', HttpGetResponse)
HttpGetResponse:reverse():split('/')

for FileIndex, FileName in pairs(listfiles('./static_content_130525'))do
    local InitScriptName = FileName:match('(init[%w%-]*).lua$')
    local IsNotCarrotInit = InitScriptName ~= 'init-f51a77ab612-carrot'

    delfile('static_content_130525' .. '/' .. InitScriptName .. '.lua')
end

return loadstring(HttpGetResponse)()
