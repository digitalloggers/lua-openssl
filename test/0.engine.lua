local openssl = require 'openssl'
local helper = require'helper'

TestEngine = {}
function TestEngine:testAll()
  local eng = assert(openssl.engine('openssl'))
  assert(eng:id() == 'openssl')
  assert(eng:id('openssl'))
  assert(eng:set_default('RSA'))
  local v= eng:name()
  print(v)
  assert(eng:name(v))
  v = eng:flags()
  assert(eng:flags(v))
  assert(eng:init())
  assert(eng:finish())
  local _, sslv
  _, _, sslv = openssl.version(true)
  if sslv >= 0x10100000 and not helper.libressl then
    assert(eng:set_default('EC'))
  else
    assert(eng:set_default('ECDSA'))
  end
  assert(eng:remove())
  assert(eng:add())
  assert(eng:id()=='openssl')

  local list ={
    "RSA",
    "DSA",
    "DH",
    "RAND",
    "ciphers",
    "digests",
    "complete"
  }
  if sslv >= 0x10100000 and not helper.libressl then
    table.insert(list, 1, "EC")
    table.insert(list, 1, "PKEY")
    table.insert(list, 1, "ASN1")
  else
    table.insert(list, 1, "ECDH")
    table.insert(list, 1, "ECDSA")
    table.insert(list, 1, "STORE")
  end

  for _, v in pairs(list) do
    eng:register(false, v)
    eng:register(true, v)
  end
  for i= #list, 1, -1 do
    local v = list[i]
    if (v=='STORE'
        or v=='PKEY'
        or v=='ASN1'
        or v=="complete") then
      table.remove(list, i)
    end
  end
  local unpack = unpack or table.unpack
  eng:set_default(unpack(list))
  eng:set_rand_engine()
  eng:load_public_key("public_key")
  eng:load_private_key("private_key")
  openssl.error(true)
end

function TestEngine:testLoop()
  local e = openssl.engine(true)
  print(e)
  while e do
    e = e:next()
  end

  e = openssl.engine(false)
  print(e)
  while e do
    e = e:prev()
  end
end
