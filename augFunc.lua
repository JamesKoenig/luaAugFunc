-- TODO the following:
--f | g    -- returns a metafunction which runs f'(...), returns its result on success, but returns the result of g(x) on failure
--f & g    -- returns a metafunction which returns nil if either f(...) or g(...) return nil, running f first



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

  --f >> g -- f'(...) then g(...) on the same args if f is not nil, 
  --returning the results of g's evaluation
  __shr = function(aft, fn)
    return augFunction(function(...)
      if(aft.f(...) ~= nil) then
        return fn(...)
      end
    end)
  end,
}

function augFunction(fn)
  return setmetatable({f = fn}, mt)
end

return augFunction(augFunction)
