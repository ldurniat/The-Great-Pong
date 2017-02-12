--[[
Lua Class System for Corona

Written by Silvia Domenech
Buy the book: http://pragprog.com/book/sdcorona/mobile-game-development-with-corona
Bugs/Suggestions: silvia.writes@newsprite.com

Feel free to use this class system in your Corona games. Just keep this notice intact. 
--]]

local M = {}

findSuperFunction = nil
callSuperFunction = nil
seekVariable = nil
indexmetamethod = nil


-- START:classes
-- Saves you from typing super() in each child class constructor
--   Set to false to call them manually
local waterfallConstructors = true

function M.new( base )
    -- Initialize a new class instance
    local instanceFunctions = { }
    
    -- Save a reference to the base class (for inheritance purposes)
    if base then
        instanceFunctions.base = base
    end
    
    -- Super function (finds a parent function)
    findSuperFunction = function( self, value, ... )
        -- Loop until we find the closest "super" function
        --  or we run out of parent classes
        local base = self.instanceFunctions.base
        local tempBase = base
        while tempBase ~= nil do
            functionName = tempBase[value]
            if ( functionName ~= nil ) then
                return functionName
            end
            tempBase = tempBase.base
        end
        
        -- Return nil if there isn't a parent function
        return nil
    end
    
    -- Call super (finds the super function and calls it)
    callSuperFunction = function( self, ... )
        local value = debug.getinfo(2, "n").name
        local superFunctionName = findSuperFunction( self, value )
        if ( superFunctionName ~= nil ) then
            return superFunctionName( self, ... )
        end
        
        -- Return nil if there is no parent function
        return nil
    end
    
    -- Index function. Seek function names, properties, 
    --   and parent class functions
    seekVariable = function( self, value, ... )
        -- Check if we're looking for an existing function
        local functionName = self.instanceFunctions[value]
        local superFunctionName = findSuperFunction( self, value )
        
        -- Check if it's a function, a parent function, or a property
        if value == 'instanceFunctions' or value == 'base' 
          or not functionName then
            -- Value is not a function for this class. 
            --   Check if it's a function in the parent class
            if value == 'base' then
                -- Return the base
                return self.instanceFunctions.base
            elseif superFunctionName ~= nil then
                -- Return the parent class function
                return superFunctionName
            else 
                -- Return the variable
                return rawget( self, value )
            end
        else
            -- It's a function. Return it
            return functionName
        end
    end
    
    -- Define a constructor to build an instance using ClassName( params )
    local callMetamethod = { }
    
    -- Constructor function. Calls constructor and parent constructors
    callMetamethod.__call = function( self, ... )
        -- Make an instance and add the __index 
        --  metamethod to call its functions
        local instance = { }
        instance.instanceFunctions = instanceFunctions
        indexmetamethod = { }
        indexmetamethod.__index = seekVariable
        setmetatable( instance, indexmetamethod )
        
        -- Super function
        instance.super = callSuperFunction
        
        -- Constructor queue (oldest first)
        local constructors = {}
        
        -- Add this constructor to the queue
        if instanceFunctions.new then
            constructors[ #constructors + 1 ] = instanceFunctions.new
        end
        
        if waterfallConstructors == true then
            --Add base/super constructors to the queue
            local tempBase = base
            local tempCurrent = instance
            while tempBase ~= nil do
                if tempBase.new and tempBase.new 
                  ~= tempCurrent.new then
                    -- Call the base constructor if it exists
                    constructors[ #constructors + 1 ] = 
                      tempBase.new
                    tempCurrent = tempBase
                end
                tempBase = tempBase.base
            end
        end
        
        -- Call the constructors. Oldest first.
        for i = #constructors, 1, -1 do
            constructors[i]( instance, ... )
        end
        -- Return the instance
        return instance
    end
    
    -- Set the meta table for the instance function
    --   so that a new class can be made using ClassName( )
    setmetatable( instanceFunctions, callMetamethod )
    return instanceFunctions
end
-- END:classes

return M
