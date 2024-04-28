-- test the augmented function suite
package.path = package.path .. ';../?.lua'
local afunction = require "augFunc"

local unAugmenteds = {
  -- identity function of a single variable
  id = function(x) return x end,

  -- add two to a number
  add3 = function(x) return x+3 end,

  -- double a number
  double = function(x) return x*2 end,

  -- prepend "Hey, " to a string
  greet = function(str) return "Hey, "..str end,

  -- postpend a bang!
  emphatic = function(str) return str.."!" end,

  tostring = tostring,

  print = print,
}

print "testing constructor and mapping via setup (lol)"
local augmenteds = afunction * unAugmenteds;
print(("done. functions are now in %s"):format(augmenteds))

local printAugmentedFn = afunction(function(afn,key)
  print(("%-10s: %s"):format(key,afn))
end)

local function massComposition()
  local _ENV = augmenteds
  return print..tostring..emphatic..greet..double..add3..id
end

local massComposeTests = {
  {
    arg = -1,
    expect = "\"Hey, 4!\"",
  },
  {
    arg = 4,
    expect = "\"Hey, 14!\"",
  },
}

local function massComposePrompt(idx,value)
  return ("iteration %d; testing masscompose(%d), expecting %s"):format(idx,value.arg,value.expect)
end

local function testMassComposition()
  print "creating composition:"
  print "print..tostring..emphatic..greet..double..add3..id"
  local massCompose = massComposition()
  print(("completed. Enter massCompose: %s"):format(massCompose))
  for idx,value in pairs(massComposeTests) do
    print(massComposePrompt(idx,value))
    massCompose(value.arg)
  end
end

local function main()
  print "Listing results of augmented function list generation:"
  printAugmentedFn:ontoEach(augmenteds)
  print "Executing mass composition test:"
  testMassComposition()
end

main()

return {
  augmenteds = augmenteds,
  testMassComposition = testMAssComposition,
  printAugmentedFn = printAugmentedFn,
  massComposition = massComposition,
  main = main,
}
