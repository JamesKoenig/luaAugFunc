--[[
-- defines a metatable that grants some shorthand rules of composition and
--   utility for a given function.
--
-- the wrapped function **must** return nil on failure, and any value on success
--
-- the result function-wrapping metatable is called an augmented function 
--   or augFn in this documentation
--
-- further documentation is available in the readme and at the end of the file.
--
-- the augmented function metatable defines the operations:
--  calling:
--    f()
--  composition:
--    f .. g
--  mapping:
--    f * tableLike
--  selection:
--    f << tableLike
--  binding of a an augmented function to a mappable result of another:
--    f ^ g
--  filtering:
--    f ~ tableLike
--  and-conditional-sequencing (f then g on success of f):
--    f & g
--  or-conditional-sequencing (f then g on failure of f):
--    f | g
--
-- the result of `require`-ing this file is itself an augmented function which
--  wraps its own constructor
--]]

-- generate a table of util methods for the augmented function
--  note that `aft` is used here to refer to the table itself
--   itself standing for 'augmented function table'
local function genUtilsTable(func)
  return {
    f = func,

    -- aft:call(...)
    call = function(aft,...)
      return aft.f(...)
    end,

    -- aft:compose(fn)
    compose = function(aft,fn)
      return augFunction(function(...)
        return aft.f(fn(...))
      end)
    end,

    -- aft:map(nextable)
    map = function(aft,tableLike)
      res = {}
      for key, value in pairs(tableLike) do
        res[key] = aft.f(value)
      end
      return res
    end,

    -- aft:first(nextable)
    first = function(aft, tableLike)
      for _,value in pairs(tableLike) do
        local testVal = aft.f(value)
        if testVal then
          return testVal
        end
      end
      return nil
    end,

    -- aft:bindRes(fn)
    bindRes = function(aft,fn)
      return augFunction(function(...)
        local res = {}
        for key,value in pairs(fn(...)) do
          res[key] = aft.f(value)
        end
        return res
      end)
    end,

    -- aft:filter(tableLike)
    filter = function(aft, tableLike)
      res = {}
      for key,value in pairs(tableLike) do
        if aft.f(value) ~= nil then
          res[key] = value
        end
      end
      return res
    end,

    -- aft:sequenceAnd(fn)
    sequenceAnd = function(aft,fn)
      return augFunction(function(...)
        if(aft.f(...) ~= nil) then
          return fn(...)
        else
          return nil
        end
      end)
    end,

    -- aft:sequenceOr(fn)
    sequenceOr = function(aft, fn)
      return augFunction(function(...)
        local maybe = aft.f(...)
        if maybe == nil then
          return fn(...)
        else
          return maybe
        end
      end)
    end,
  }
end

local function genMetaTable(aft)
  return {
    --af(...) -- calls f(...)
    __call = aft.call,

    --f .. g -- composition: ((f..g)(x) is f'(g(x))), returns an augmented fn
    __concat = aft.compose,

    --f * foo -- map f' over foo, returns the result as a table
    __mul = aft.map,

    --f << foo -- return first element of foo for which f' does not return nil
    __shl = aft.first,

    --f ^ g -- return an augmented function that maps f' over the results of g
    __pow = aft.bindRes,

    -- f ~ foo -- filter elements of foo where f'(ele) ~= nil
    __bnot = aft.filter,

    -- f & g -- returns an augmented fn that calls f, & if f doesn't return nil
    --       --  it returns the result of g on the same arguments
    __band = aft.sequenceAnd,

    -- f | g -- returns an augmented fn that that executes f, & if f returns nil
    --       --  it returns the result of g on the same arguments
    __bor = aft.sequenceOr,

    __tostring = function()
      return ("Augmented (%s)"):format(tostring(aft.f))
    end
  }
end

function augFunction(fn)
  local utilTable = genUtilsTable(fn)
  local metaTable = genMetaTable(utilTable)
  return setmetatable(utilTable, metaTable)
end

return augFunction(augFunction)
