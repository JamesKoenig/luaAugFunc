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

local mt = {
  --af(...) -- calls f(...)
  __call = function(aft,...)
    return aft.f(...)
  end,

  --f .. g -- composition: ((f..g)(x) is f'(g(x))), returns an augmented fn
  __concat = function(aft,fn)
    return augFunction(function(...)
      return aft.f(fn(...))
    end)
  end,


  --f * foo -- map f' over foo, returns the result as a table
  __mul = function(aft,nextable)
    res = {}
    for key,value in pairs(nextable) do
      res[key] = aft.f(value)
    end
    return res
  end,

  --f << foo -- return first element of foo for which f' does not return nil
  __shl = function(aft, nextable)
    for _,value in pairs(nextable) do
      local testVal = aft.f(value)
      if testVal then
        return testVal
      end
    end
    return nil
  end,

  --f ^ g -- return an augmented functiont hat maps f' over the results of g
  __pow = function(aft, fn)
    return augFunction(function(...)
      res = {}
      for key,value in pairs(fn(...)) do
        res[key] = aft.f(value)
      end
      return res
    end)
  end,

  -- f ~ foo -- filter elements of foo where f'(ele) ~= nil
  __bnot = function(aft, nextable)
    res = {}
    for key,value in pairs(nextable) do
      if aft.f(value) ~= nil then
        res[key] = value
      end
    end
    return res
  end,

  -- f & g -- returns an augmented fn that executes f, & if f doesn't return nil
  --       --  it returns the result of g on the same arguments
  __band = function(aft, fn)
    return augFunction(function(...)
      if(aft.f(...) ~= nil) then
        return fn(...)
      else
        return nil -- this was implied but I felt better adding it explicitly
      end
    end)
  end,

  -- f | g -- returns an augmented fn that that executes f, & if f returns nil
  --       --  it returns the result of g on the same arguments
  __bor = function(aft, fn)
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

function augFunction(fn)
  return setmetatable({f = fn}, mt)
end

return augFunction(augFunction)
